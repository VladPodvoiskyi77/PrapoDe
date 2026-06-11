# GA4 Custom Dimensions — PrapoDe

Firebase Analytics (GA4) **не регистрирует custom dimensions из iOS-кода**. Их нужно один раз настроить в [Firebase Console](https://console.firebase.google.com) → **Analytics** → **Custom definitions**.

## Event-scoped dimensions (параметры событий)

| Parameter name | Scope | События | Зачем |
|----------------|-------|---------|-------|
| `category` | Event | `*_started`, `*_finished`, `*_abandoned`, `*_error`, `myProgress_viewed` | Verben / Adjektive / Nomen |
| `level` | Event | те же | A1–C1 |
| `accuracy` | Event | `*_finished` | Средняя точность по режимам |
| `score` | Event | `*_finished` | Баллы |
| `total_questions` | Event | `*_finished`, `*_abandoned` | Длина сессии |
| `questions_answered` | Event | `*_abandoned` | Сколько успели до выхода |
| `wordWithPrap` | Event | `*_error` | Сложные слова |
| `user_answer` | Event | `*_error` | Что выбрал пользователь |
| `country_code` | Event | `profile_setup_completed` | География onboarding |
| `status` | Event | `widget_word_toggle` | enabled / disabled |
| `preposition_id` | Event | `preposition_article_viewed` | ID статьи (fur, in, …) |
| `lemma` | Event | `preposition_article_viewed` | Немецкий предлог (für, in, …) |
| `case_group` | Event | `preposition_article_viewed` | dativ / akkusativ / genitiv / wechsel |
| `content_language` | Event | `prepositions_guide_viewed`, `preposition_article_viewed` | ru / ua / en |
| `preposition_count` | Event | `prepositions_guide_viewed` | Число предлогов в справочнике |

## User-scoped properties

| Property name | Scope | Устанавливается в коде |
|---------------|-------|------------------------|
| `nickname` | User | `logAppLaunch` |
| `current_study_level` | User | `setUserLevel` |

## User ID

- В коде: `Analytics.setUserID(firebaseUID)` — стабильный ID пользователя.
- `nickname` остаётся отдельным user property.

## Пошагово в Console

1. **Analytics → Custom definitions → Create custom dimensions**
2. Dimension name: например `Study category`
3. Scope: **Event**
4. Event parameter: `category`
5. Повторить для таблицы выше

После регистрации новые данные появятся в Explorations и отчётах через **24–48 часов**.

## Автоматическая регистрация (рекомендуется)

Без пароля в чате — через **service account** и скрипт:

```bash
cd Learning_Prepositions_is_easy
# см. firebase/README_SETUP.md — полная инструкция (5–10 мин один раз)
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/firebase/keys/prapode-sa.json"
python3 firebase/setup_custom_dimensions.py --discover
export GA4_PROPERTY_ID="525311318"
python3 firebase/setup_custom_dimensions.py
```

Подробно: [`firebase/README_SETUP.md`](README_SETUP.md)

## Ручная регистрация в Console

См. раздел «Пошагово в Console» выше.

## Рекомендуемые Explorations

- Funnel: `quiz_started` → `quiz_finished` → filter by `category`
- Abandon rate: `quiz_abandoned` / `quiz_started`
- Onboarding: `profile_setup_started` → `profile_setup_completed`
- Top prepositions: `preposition_article_viewed` → breakdown by `lemma`

См. также `ANALYTICS.md` в корне Xcode-проекта.
