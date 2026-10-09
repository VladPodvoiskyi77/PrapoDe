const fs = require("fs");
const path = require("path");
const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const { BetaAnalyticsDataClient } = require("@google-analytics/data");
const admin = require("firebase-admin");

admin.initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 2 });

const ACCESS_FILE = path.join(__dirname, "admin-access.json");
const ACCESS_DOC = "admin/access";
const CONFIG_DOC = "admin/config";
const functionOptions = {
  invoker: "public",
  serviceAccount: "prapode-analytics-setup@prapode-bf274.iam.gserviceaccount.com",
};

function fileAccess() {
  return JSON.parse(fs.readFileSync(ACCESS_FILE, "utf8"));
}

async function loadRemoteAccess() {
  const snap = await admin.firestore().doc(ACCESS_DOC).get();
  return snap.exists ? snap.data() || {} : {};
}

async function loadTrustedDevices() {
  const snap = await admin.firestore().doc(CONFIG_DOC).get();
  const devices = snap.data()?.trustedDevices;
  return Array.isArray(devices) ? devices.map(String) : [];
}

async function loadAccess() {
  const file = fileAccess();
  let remote = {};
  let trustedDevices = [];
  try {
    remote = await loadRemoteAccess();
  } catch (error) {
    console.error("load_access_remote", error);
  }
  try {
    trustedDevices = await loadTrustedDevices();
  } catch (error) {
    console.error("load_trusted_devices", error);
  }
  const src = Object.keys(remote).length ? remote : file;
  return {
    enabled: src.enabled !== false,
    passcode: String(src.passcode ?? ""),
    alertEmail: String(src.alertEmail || ""),
    telegramBotToken: String(src.telegramBotToken || ""),
    telegramChatId: String(src.telegramChatId || ""),
    resendApiKey: String(src.resendApiKey || ""),
    alertWebhook: String(src.alertWebhook || ""),
    trustedDevices,
  };
}

function clientIp(req) {
  const forwarded = req.get("x-forwarded-for") || "";
  return forwarded.split(",")[0].trim() || req.ip || "";
}

async function notifyFailedUnlock({ ip, deviceId, trusted, passcode }) {
  const access = await loadAccess();
  try {
    await admin.firestore().collection("admin_alerts").add({
      type: "wrong_passcode",
      ip,
      deviceId,
      trusted,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error("alert_log", error);
  }

  let allowAlert = true;
  try {
    allowAlert = await canAlert();
  } catch (error) {
    console.error("alert_rate", error);
  }
  if (!allowAlert) return;

  const tried = String(passcode || "").replace(/\D/g, "").slice(0, 8) || "—";
  const text = [
    "PrapoDe: неверный код админки",
    `Код: ${tried}`,
    trusted ? "Устройство: твоё (уже входило с верным кодом)" : "Устройство: неизвестное",
    `Время: ${new Date().toISOString()}`,
    `IP: ${ip || "—"}`,
  ].join("\n");

  const jobs = [];
  if (access.telegramBotToken && access.telegramChatId) {
    console.log("telegram_alert_send", { trusted, hasToken: true });
    jobs.push(
      fetch(`https://api.telegram.org/bot${access.telegramBotToken}/sendMessage`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ chat_id: access.telegramChatId, text }),
      }).catch((error) => console.error("telegram_alert", error)),
    );
  }
  if (access.resendApiKey && access.alertEmail) {
    jobs.push(
      fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${access.resendApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: "PrapoDe <alerts@resend.dev>",
          to: [access.alertEmail],
          subject: "PrapoDe: неверный код админки",
          text,
        }),
      }).catch((error) => console.error("email_alert", error)),
    );
  }
  if (access.alertWebhook) {
    jobs.push(
      fetch(access.alertWebhook, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text, ip, deviceId }),
      }).catch((error) => console.error("webhook_alert", error)),
    );
  }
  await Promise.all(jobs);
}

async function canAlert() {
  const ref = admin.firestore().doc("admin/rate");
  const now = Date.now();
  const snap = await ref.get();
  const windowStart = Number(snap.data()?.windowStart || 0);
  const count = Number(snap.data()?.count || 0);
  if (now - windowStart > 10 * 60 * 1000) {
    await ref.set({ windowStart: now, count: 1 });
    return true;
  }
  if (count >= 5) return false;
  await ref.set({ windowStart, count: count + 1 });
  return true;
}

async function rememberDevice(deviceId) {
  if (!deviceId) return;
  const ref = admin.firestore().doc(CONFIG_DOC);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const current = Array.isArray(snap.data()?.trustedDevices) ? snap.data().trustedDevices.map(String) : [];
    if (current.includes(deviceId)) return;
    const trustedDevices = [...current, deviceId].slice(-8);
    tx.set(ref, { trustedDevices }, { merge: true });
  });
}

async function authorizeAdmin(req) {
  const header = req.get("Authorization") || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : "";
  if (!token) {
    return { error: "auth", status: 401 };
  }
  await admin.auth().verifyIdToken(token);

  const access = await loadAccess();
  if (!access.enabled || !access.passcode) {
    return { error: "disabled", status: 403 };
  }

  const passcode = String(req.body?.passcode || "");
  const deviceId = String(req.body?.deviceId || "").slice(0, 80);
  if (passcode !== access.passcode) {
    const trusted = Boolean(deviceId && access.trustedDevices.includes(deviceId));
    try {
      await notifyFailedUnlock({ ip: clientIp(req), deviceId, trusted, passcode });
    } catch (error) {
      console.error("notify_failed", error);
    }
    return { error: "passcode", status: 403 };
  }

  try {
    await rememberDevice(deviceId);
  } catch (error) {
    console.error("remember_device", error);
  }
  return { ok: true };
}

function adminHttp(handler) {
  return onRequest(functionOptions, async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "method" });
      return;
    }
    try {
      const auth = await authorizeAdmin(req);
      if (!auth.ok) {
        res.status(auth.status).json({ error: auth.error });
        return;
      }
      await handler(req, res);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "failed" });
    }
  });
}

const PROPERTY = "properties/525311318";
const DAYS = 13;
const MODES = ["quiz", "sprint", "training", "writing"];

function metricInt(row, index) {
  return Number(row.metricValues[index]?.value || 0);
}

function formatDate(yyyymmdd) {
  if (!yyyymmdd || yyyymmdd.length !== 8) return yyyymmdd;
  return `${yyyymmdd.slice(6, 8)}.${yyyymmdd.slice(4, 6)}`;
}

function minutesFromSeconds(seconds) {
  return Math.round((Number(seconds) / 60) * 10) / 10;
}

async function runReport(client, { dimensions = [], metrics, eventName, limit = 50 }) {
  const request = {
    property: PROPERTY,
    dateRanges: [{ startDate: `${DAYS}daysAgo`, endDate: "today" }],
    dimensions: dimensions.map((name) => ({ name })),
    metrics: metrics.map((name) => ({ name })),
    limit,
  };
  if (eventName) {
    request.dimensionFilter = {
      filter: {
        fieldName: "eventName",
        stringFilter: { value: eventName },
      },
    };
  }
  const [response] = await client.runReport(request);
  return response.rows || [];
}

async function buildUsage() {
  const client = new BetaAnalyticsDataClient();

  const [totalsRows, dailyRows, platformRows, datePlatformRows] = await Promise.all([
    runReport(client, {
      metrics: ["activeUsers", "newUsers", "sessions", "eventCount", "averageSessionDuration"],
    }),
    runReport(client, {
      dimensions: ["date"],
      metrics: ["activeUsers", "newUsers", "sessions", "eventCount", "averageSessionDuration"],
    }),
    runReport(client, {
      dimensions: ["platform"],
      metrics: ["activeUsers", "newUsers", "sessions"],
    }),
    runReport(client, {
      dimensions: ["date", "platform"],
      metrics: ["activeUsers", "sessions"],
    }),
  ]);

  const modesByDate = {};
  const windowModes = [];
  for (const mode of MODES) {
    const [startedRows, finishedRows] = await Promise.all([
      runReport(client, { dimensions: ["date"], metrics: ["eventCount"], eventName: `${mode}_started` }),
      runReport(client, { dimensions: ["date"], metrics: ["eventCount"], eventName: `${mode}_finished` }),
    ]);

    let startedTotal = 0;
    let finishedTotal = 0;
    for (const row of startedRows) {
      const date = row.dimensionValues[0].value;
      const value = metricInt(row, 0);
      startedTotal += value;
      if (!modesByDate[date]) modesByDate[date] = {};
      if (!modesByDate[date][mode]) modesByDate[date][mode] = { started: 0, finished: 0 };
      modesByDate[date][mode].started = value;
    }
    for (const row of finishedRows) {
      const date = row.dimensionValues[0].value;
      const value = metricInt(row, 0);
      finishedTotal += value;
      if (!modesByDate[date]) modesByDate[date] = {};
      if (!modesByDate[date][mode]) modesByDate[date][mode] = { started: 0, finished: 0 };
      modesByDate[date][mode].finished = value;
    }
    windowModes.push({ name: mode, started: startedTotal, finished: finishedTotal });
  }

  const iosAndroidByDate = {};
  for (const row of datePlatformRows) {
    const date = row.dimensionValues[0].value;
    const platform = (row.dimensionValues[1].value || "").toLowerCase();
    if (!iosAndroidByDate[date]) iosAndroidByDate[date] = { ios: 0, android: 0 };
    if (platform === "ios") iosAndroidByDate[date].ios = metricInt(row, 0);
    if (platform === "android") iosAndroidByDate[date].android = metricInt(row, 0);
  }

  const total = totalsRows[0];
  const daily = dailyRows
    .slice()
    .sort((a, b) => a.dimensionValues[0].value.localeCompare(b.dimensionValues[0].value))
    .map((row) => {
      const rawDate = row.dimensionValues[0].value;
      const split = iosAndroidByDate[rawDate] || { ios: 0, android: 0 };
      const dayModes = MODES.map((name) => ({
        name,
        started: modesByDate[rawDate]?.[name]?.started || 0,
        finished: modesByDate[rawDate]?.[name]?.finished || 0,
      }));
      return {
        dateKey: rawDate,
        date: formatDate(rawDate),
        activeUsers: metricInt(row, 0),
        newUsers: metricInt(row, 1),
        sessions: metricInt(row, 2),
        eventCount: metricInt(row, 3),
        avgSessionMinutes: minutesFromSeconds(row.metricValues[4]?.value || 0),
        iosUsers: split.ios,
        androidUsers: split.android,
        modes: dayModes,
      };
    });

  return {
    days: DAYS,
    totals: {
      activeUsers: total ? metricInt(total, 0) : 0,
      newUsers: total ? metricInt(total, 1) : 0,
      sessions: total ? metricInt(total, 2) : 0,
      eventCount: total ? metricInt(total, 3) : 0,
      avgSessionMinutes: total ? minutesFromSeconds(total.metricValues[4]?.value || 0) : 0,
    },
    platforms: platformRows.map((row) => ({
      name: row.dimensionValues[0].value,
      users: metricInt(row, 0),
      newUsers: metricInt(row, 1),
      sessions: metricInt(row, 2),
    })),
    daily,
    modes: windowModes,
  };
}

function parseCreatedAt(raw) {
  if (raw && typeof raw.toMillis === "function") return raw.toMillis();
  if (raw && typeof raw._seconds === "number") return raw._seconds * 1000;
  if (typeof raw === "number") return raw > 10_000_000_000 ? raw : raw * 1000;
  return 0;
}

async function buildDirectory() {
  const db = admin.firestore();
  const [usersSnap, resultsSnap] = await Promise.all([
    db.collection("users").get(),
    db.collection("global_leaderboard").orderBy("timestamp", "desc").limit(25).get(),
  ]);

  const users = usersSnap.docs
    .map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        name: String(data.name || "—"),
        country: String(data.country || "—"),
        createdAt: parseCreatedAt(data.createdAt),
      };
    })
    .sort((a, b) => b.createdAt - a.createdAt);

  const results = resultsSnap.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      userName: String(data.userName || "—"),
      countryCode: String(data.countryCode || "—"),
      gameType: String(data.gameType || ""),
      level: String(data.level || "—"),
      category: String(data.category || "—"),
      score: Number(data.score || 0),
      total: Number(data.total || 0),
      timeElapsed: Number(data.timeElapsed || 0),
      timestamp: parseCreatedAt(data.timestamp),
    };
  });

  return { users, results };
}

exports.adminUnlock = adminHttp(async (_req, res) => {
  res.json({ ok: true });
});

exports.adminDirectory = adminHttp(async (_req, res) => {
  res.json(await buildDirectory());
});

exports.adminUsage = adminHttp(async (_req, res) => {
  res.json(await buildUsage());
});
