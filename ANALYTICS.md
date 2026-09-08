# PrapoDe — Analytics Reference

Документ описывает все **кастомные** события Firebase Analytics в приложении PrapoDe: что отправляется, откуда, с какими параметрами и как использовать данные в Firebase Console.

> **Источник правды:** `Learning_Prepositions/Core/Services/Analytics/AnalyticsManager.swift`  
> **Платформа:** Firebase Analytics (`Firebase/Core` + `Firebase/Analytics`)

---

## 1. User properties и идентификация

| Свойство / ID | Когда устанавливается | Значение | Зачем |
|---------------|----------------------|----------|-------|
| `user_id` (Analytics User ID) | Каждый заход на главный экран | **Firebase UID** (если есть) | Стабильная склейка сессий |
| `nickname` | То же | Nickname или `"unknown"` | Отображаемое имя в отчётах |
| `current_study_level` | Смена уровня в настройках, первый запуск, открытие Settings | `"A1"` … `"C1"` | Анализ по уровню учёбы |

**Важно:** `user_id` сейчас = nickname, а не Firebase UID. При смене ника в аналитике появится «новый» пользователь.

---

## 2. Кастомные события

### 2.1 Сессия приложения

| Событие | Триггер | Параметры |
|---------|---------|-----------|
| `app_launch_custom` | `UniversalMenuView` (главное меню), `onAppear` | `user_name`, `timestamp` |

---

### 2.2 Режимы обучения — воронка

Имена формируются динамически: `{mode}_started` / `{mode}_finished`.

| mode (`Activity.rawValue`) | UI-режим | `_started` | `_finished` |
|----------------------------|----------|------------|-------------|
| `quiz` | Quiz | `QuizView.onAppear` → `refreshData()` | `QuizViewModel.saveResult()` |
| `sprint` | Sprint | `SpeedQuizViewModel.restartGame()` | `SpeedQuizViewModel.saveResult()` |
| `writing` | Writing | `WritingViewModel.restartGame()` | `WritingViewModel.saveResult()` |
| `training` | Training (карточки) | `TrainingViewModel.logSessionStarted()` | `TrainingViewModel.logSessionFinished()` |

#### Параметры `_started`

| Параметр | Тип | Пример |
|----------|-----|--------|
| `category` | String | `"Verben mit Präpositionen"` |
| `level` | String | `"B1"` |

#### Параметры `_finished`

| Параметр | Тип | Описание |
|----------|-----|----------|
| `category` | String | Категория слов |
| `level` | String | Уровень CEFR |
| `score` | Int | Правильных ответов (Training: число просмотренных карточек) |
| `total_questions` | Int | Всего вопросов в сессии |
| `accuracy` | Double | `score / total_questions` |

**Не логируются:** My Progress (только просмотр), ранний выход без alert.

---

### 2.3 Onboarding профиля

| Событие | Триггер | Параметры |
|---------|---------|-----------|
| `profile_setup_started` | `OnboardingProfileView.onAppear` | — |
| `profile_setup_completed` | Успешное сохранение профиля в Firestore | `country_code` |

---

### 2.4 Ранний выход (abandoned)

Событие `{mode}_abandoned` — когда пользователь **выходит через alert**, не дойдя до `*_finished`.

| Событие | Режим | Триггер |
|---------|--------|---------|
| `quiz_abandoned` | Quiz | Exit alert → `QuizViewModel.logAbandonedIfNeeded()` |
| `sprint_abandoned` | Sprint | Exit alert |
| `writing_abandoned` | Writing | Exit alert |

**Параметры:** `category`, `level`, `questions_answered`, `total_questions`

> **Зачем:** отличить «бросил на 3-м вопросе» от «прошёл до конца». Completion rate = `finished / started`; abandon rate = `abandoned / started`.

---

### 2.5 My Progress

| Событие | Триггер | Параметры |
|---------|---------|-----------|
| `myProgress_viewed` | `MyProgressView.onAppear` | `category`, `level` |

---

### 2.6 Ошибки по режимам

Единый метод `logWrongAnswer` → событие `{mode}_error`.

| Событие | Режим | Триггер |
|---------|--------|---------|
| `quiz_error` | Quiz | Неверный выбор предлога |
| `sprint_error` | Sprint | Неверный ответ под таймером |
| `writing_error` | Writing | Ответ `.wrong` (не умляут) |

**Параметры:**

| Параметр | Описание |
|----------|----------|
| `wordWithPrap` | Слово + предлог, напр. `"warten auf"` |
| `level` | `"A1"` … `"C1"` |
| `category` | Категория слов |
| `user_answer` | *(опционально)* Ответ пользователя (Quiz, Sprint, Writing) |

Используйте для анализа «сложных» слов: Events → `{mode}_error` → breakdown by `wordWithPrap`.

---

### 2.7 Виджет

| Событие | Триггер | Параметры |
|---------|---------|-----------|
| `widget_word_toggle` | Вкл/выкл слова в настройках виджета | `verb`, `status` (`enabled` / `disabled`) |
| `widget_words_configured` | Экран выбора слов / изменение списка | `enabled_count`, `total_count` |
| `widget_installed` | Виджет добавлен на домашний экран | `widget_count`, `family` |
| `widget_removed` | Виджет удалён с домашнего экрана | `previous_count` |
| `widget_timeline_refreshed` | Обновление timeline (батч при открытии приложения) | `refresh_count`, `entry_count` |
| `widget_tap` | Тап по виджету → открытие приложения | `verb`, `level` |

User properties:

| Свойство | Значение |
|----------|----------|
| `has_widget_installed` | `true` / `false` |
| `widget_enabled_words` | Количество включённых слов |

---

### 2.8 Справочник предлогов

| Событие | Триггер | Параметры |
|---------|---------|-----------|
| `prepositions_guide_viewed` | Успешная загрузка списка предлогов | `preposition_count`, `content_language` |
| `preposition_article_viewed` | Успешная загрузка статьи предлога | `preposition_id`, `lemma`, `case_group`, `content_language` |

**Как смотреть популярные предлоги:** Events → `preposition_article_viewed` → breakdown by `lemma` или `preposition_id`. Фильтр по `case_group` — dativ / akkusativ / genitiv / wechsel.

---

### 2.9 Экраны (screen_view)

Стандартное событие Firebase `screen_view`:

| `screen_name` | Экран |
|---------------|--------|
| `Settings` | Настройки |
| `GlobalRanking` | Глобальный рейтинг |
| `Widget_Word_Selection` | Выбор слов для виджета |
| `PrepositionsList` | Список предлогов |
| `PrepositionDetail` | Статья предлога |

---

## 3. Автоматические события Firebase

Не задаются в коде, но видны в Console:

- `first_open`, `session_start`, `user_engagement`
- `app_update`, `os_update` (при обновлениях)
- другие [рекомендованные события Google](https://support.google.com/analytics/answer/9234069)

---

## 4. KPI → событие → как считать в Firebase

| KPI | Что измеряет | События / свойства | Как посмотреть в Firebase Console |
|-----|--------------|-------------------|-----------------------------------|
| **DAU / MAU** | Активные пользователи | `session_start`, `app_launch_custom` | Analytics → Dashboard или Events → `session_start` → Unique users |
| **Retention D1/D7** | Возвращаемость | `session_start` | Analytics → Retention |
| **Запуски приложения** | Открытия главного экрана | `app_launch_custom` | Events → Count / Users |
| **Старт режима** | Интерес к режиму | `{mode}_started` | Events → фильтр по имени; breakdown по `category`, `level` |
| **Completion rate Quiz** | Дошли до конца Quiz | `quiz_started` vs `quiz_finished` | Explorations: funnel `quiz_started` → `quiz_finished` |
| **Completion rate Sprint** | Дошли до конца Sprint | `sprint_started` vs `sprint_finished` | То же для sprint |
| **Completion rate Writing** | Дошли до конца Writing | `writing_started` vs `writing_finished` | То же для writing |
| **Onboarding conversion** | Завершили профиль | `profile_setup_started` → `profile_setup_completed` | Funnel в Explorations |
| **Abandon rate Quiz** | Бросили квиз | `quiz_abandoned` / `quiz_started` | Custom exploration |
| **My Progress usage** | Открытия прогресса | `myProgress_viewed` | Event count |
| **Accuracy по режиму** | Качество ответов | `{mode}_finished` → param `accuracy` | Events → `{mode}_finished` → Parameter `accuracy` (Avg) |
| **Accuracy по уровню** | Сложность уровней | `{mode}_finished` + `level` | Breakdown by `level` |
| **Популярность категорий** | Verben vs Adjektive vs Nomen | `{mode}_started` → `category` | Breakdown by `category` |
| **Сложные слова** | Где чаще ошибаются | `{mode}_error` → `wordWithPrap` | Events → Top events by parameter (quiz / sprint / writing) |
| **Использование виджета** | Кастомизация | `widget_word_toggle` | Count; filter `status` |
| **Adoption виджета** | Установлен на экран | `widget_installed`, user prop `has_widget_installed` | Events → unique users |
| **Engagement виджета** | Реальное использование | `widget_timeline_refreshed`, `widget_tap` | Events → count / users |
| **Конфигурация слов** | Сколько слов включено | `widget_words_configured` → `enabled_count` | Avg enabled_count |
| **Популярные предлоги** | Какие статьи читают | `preposition_article_viewed` → `lemma` | Events → breakdown by `lemma` |
| **Интерес к справочнику** | Открытия раздела | `prepositions_guide_viewed` | Event count |
| **Интерес к рейтингу** | Открытия рейтинга | `screen_view` where name = `GlobalRanking` | Events → `screen_view` → filter |
| **Распределение по уровню** | Уровень учёбы аудитории | User property `current_study_level` | Analytics → User properties |

### Рекомендуемые Explorations (воронки)

1. **Quiz funnel:** `quiz_started` → `quiz_finished`
2. **Sprint funnel:** `sprint_started` → `sprint_finished`
3. **Writing funnel:** `writing_started` → `writing_finished`
4. **Training funnel:** `training_started` → `training_finished`
5. **Widget adoption:** `screen_view` (Widget_Word_Selection) → `widget_words_configured` → `widget_installed` → `widget_timeline_refreshed` / `widget_tap`
6. **Prepositions:** `prepositions_guide_viewed` → `preposition_article_viewed` → top `lemma`

### BigQuery (опционально)

При включении экспорта в BigQuery:

```sql
-- Completion rate Quiz за 30 дней
SELECT
  COUNTIF(event_name = 'quiz_started') AS starts,
  COUNTIF(event_name = 'quiz_finished') AS finishes,
  SAFE_DIVIDE(COUNTIF(event_name = 'quiz_finished'),
              COUNTIF(event_name = 'quiz_started')) AS completion_rate
FROM `project.dataset.events_*`
WHERE _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
  AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
```

---

## 5. Значения параметров (справочник)

### category

| Значение |
|----------|
| `Verben mit Präpositionen` |
| `Adjektive mit Präpositionen` |
| `Nomen mit Präpositionen` |

### level

| Значение |
|----------|
| `A1`, `A2`, `B1`, `B2`, `C1` |

### Activity.rawValue (mode)

| Значение | Режим |
|----------|--------|
| `quiz` | Quiz |
| `sprint` | Sprint |
| `writing` | Writing |
| `training` | Training |
| `myProgress` | *(не логируется в analytics)* |

---

## 6. Известные ограничения и рекомендации

| Тема | Статус | Рекомендация |
|------|--------|--------------|
| Quiz `_started` на каждый `onAppear` | Может дублироваться при повторном appear | При необходимости — флаг «сессия уже залогирована» |
| `user_id` = nickname | Исправлено: UID + nickname property | — |
| Ранний выход из Training/Quiz | Нет `*_abandoned` | Добавить событие при exit alert |
| My Progress | Нет событий | Добавить `myProgress_viewed` при необходимости |
| Onboarding / abandon | Реализовано | — |
| Custom definitions | Инструкция | `firebase/GA4_CUSTOM_DIMENSIONS.md` |
| Crashlytics | Подключён | `CrashReporter.record` в Firestore, Storage, JSON decode |

### Исторические данные

До исправления в `QuizViewModel` часть завершений Quiz могла уходить как `sprint_finished`. При анализе старых периодов учитывайте это.

---

## 7. Чеклист перед релизом

- [ ] Firebase Console → DebugView: пройти Quiz, Sprint, Writing, Training
- [ ] Проверить `quiz_finished` (не `sprint_finished`)
- [ ] `{mode}_error` только при реальных ошибках (не на правильный ответ)
- [ ] `current_study_level` обновляется при смене уровня
- [ ] Custom definitions зарегистрированы для `accuracy`, `category`, `level` (рекомендуется)

---

## 8. Файлы в коде

| Файл | Роль |
|------|------|
| `Core/Services/Analytics/AnalyticsManager.swift` | Все вызовы Firebase Analytics |
| `Views/Quiz/QuizViewModel.swift` | Quiz start/finish |
| `Views/Sprint/SpeedQuizViewModel.swift` | Sprint start/finish/errors |
| `Views/Writing/WritingViewModel.swift` | Writing start/finish |
| `Views/Training/TrainingViewModel.swift` | Training start/finish |
| `Views/UniversalMenu/UniversalMenu.swift` | App launch |
| `Views/Settings/SettingsView.swift` | Screen view + user level |
| `Views/WidgetWordSelection/*` | Widget analytics |
| `Views/GlobalRanking/GlobalRankingView.swift` | Screen view |
| `Views/Prepositions/PrepositionsListViewModel.swift` | Guide list analytics |
| `Views/Prepositions/PrepositionDetailViewModel.swift` | Article view analytics |
