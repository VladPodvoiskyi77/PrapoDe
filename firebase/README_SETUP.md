# Автоматическая настройка GA4 Custom Dimensions (без пароля)

Скрипт `setup_custom_dimensions.py` регистрирует все параметры из `GA4_CUSTOM_DIMENSIONS.md` через **Google Analytics Admin API**.

Firebase project: **`prapode-bf274`**

---

## Шаг 1. Service Account (один раз)

1. Открой [Google Cloud Console → IAM → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts?project=prapode-bf274)
2. **Create service account**
   - Name: `prapode-analytics-setup`
   - Role на уровне проекта: **Viewer** (достаточно для API; GA4-права ниже)
3. **Keys → Add key → Create new key → JSON**
4. Сохрани файл локально:

```bash
mkdir -p firebase/keys
mv ~/Downloads/prapode-bf274-*.json firebase/keys/prapode-sa.json
chmod 600 firebase/keys/prapode-sa.json
```

Файл `firebase/keys/` уже в `.gitignore` — **не коммить ключ**.

---

## Шаг 2. Включить Analytics Admin API

[Enable Analytics Admin API](https://console.cloud.google.com/apis/library/analyticsadmin.googleapis.com?project=prapode-bf274) → **Enable**

---

## Шаг 3. Доступ service account к GA4

Service account **не видит** GA4 только через GCP IAM. Нужно добавить его в Analytics.

### Вариант A — через терминал (рекомендуется, если UI ругается)

GA4 UI часто пишет «email не соответствует аккаунту Google» для service account — это нормально.

1. Установи [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (если ещё нет)
2. Один раз войди **своим** Google-аккаунтом (администратор GA4):

```bash
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/analytics.manage.users,https://www.googleapis.com/auth/cloud-platform
```

В браузере выбери **тот аккаунт, где ты админ GA4 для PrapoDe** (не service account).

3. Выдай доступ service account:

```bash
cd Learning_Prepositions_is_easy
source firebase/.venv/bin/activate
python3 firebase/grant_sa_access.py --property-id 525311318
```

### Вариант B — через GA4 UI

1. [Google Analytics](https://analytics.google.com/) → **Администрирование**
2. Колонка **Ресурс** → **Управление доступом к ресурсу**
3. Email: `prapode-analytics-setup@prapode-bf274.iam.gserviceaccount.com`
4. Роль: **Редактор**
5. **Сними** галочку «Уведомить новых пользователей по электронной почте»

Если UI всё равно отклоняет email — используй вариант A.

### Вариант C — API Explorer (если не хочешь gcloud)

Открой в **режиме инкognito** только с нужным Google-аккаунтом:

[properties.accessBindings.create](https://developers.google.com/analytics/devguides/config/admin/v1/rest/v1alpha/properties.accessBindings/create?apix=true)

- **parent:** `properties/525311318`
- **body:** `{"user":"prapode-analytics-setup@prapode-bf274.iam.gserviceaccount.com","roles":["predefinedRoles/editor"]}`

Не переключай аккаунт на странице — иначе редирект на главную developers.google.com.

---

## Шаг 4. Установить зависимости

```bash
cd Learning_Prepositions_is_easy
python3 -m venv firebase/.venv
source firebase/.venv/bin/activate
pip install -r firebase/requirements.txt
```

---

## Шаг 5. Узнать GA4 Property ID

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/firebase/keys/prapode-sa.json"
python3 firebase/setup_custom_dimensions.py --discover
```

Скопируй число из строки `GA4_PROPERTY_ID=...`.

---

## Шаг 6. Запустить регистрацию

Проверка без записи:

```bash
export GA4_PROPERTY_ID="YOUR_NUMERIC_ID"
python3 firebase/setup_custom_dimensions.py --dry-run
```

Реальная регистрация:

```bash
python3 firebase/setup_custom_dimensions.py
```

Ожидаемый вывод: `created EVENT:category`, … или `skip … (already registered)`.

---

## Повторный запуск

Скрипт идempotent: уже существующие dimensions пропускает.

---

## Troubleshooting

| Ошибка | Решение |
|--------|---------|
| `403` / Permission denied | Добавь SA email в GA4 Property access management |
| `No GA4 properties found` | То же + проверь, что Analytics включён в Firebase |
| `analyticsadmin.googleapis.com not enabled` | Шаг 2 |
| `Credentials file not found` | Проверь `GOOGLE_APPLICATION_CREDENTIALS` |

---

## Что регистрируется

10 event-scoped + 2 user-scoped dimensions — см. `GA4_CUSTOM_DIMENSIONS.md`.
