# Firestore Security Rules — PrapoDe

Project: **prapode-bf274**

## Что защищено

| Коллекция | Read | Write / Delete |
|-----------|------|----------------|
| `global_leaderboard` | Любой авторизованный пользователь (в т.ч. anonymous) | Create/update/delete только своих документов `{uid}_{gameType}_{total}_{level}` |
| `users` | Свой профиль; list коллекции закрыт | Create/update/delete только своего профиля |
| Всё остальное | Запрещено | Запрещено |

### Валидация рейтинга

- `score` от 0 до `total`
- `total` от 5 до 30
- `gameType`: `quiz` | `sprint` | `writing`
- `level`: `A1` … `C1`
- `category`: три категории приложения
- `userId` = Firebase Auth UID
- ID документа совпадает с данными

## Деплой (один раз перед релизом)

```bash
cd Learning_Prepositions_is_easy
npm install -g firebase-tools   # если ещё нет
firebase login
firebase use prapode-bf274
firebase deploy --only firestore:rules,firestore:indexes
```

Проверка в [Firebase Console → Firestore → Rules](https://console.firebase.google.com/project/prapode-bf274/firestore/rules).

## После деплоя

1. Пройди Sprint и проверь, что результат попадает в рейтинг
2. Открой глобальный рейтинг — чтение должно работать
3. Нажми флаг страны справа вверху — рейтинг по стране (нужен второй индекс с `countryCode`)
4. Если ошибка `permission-denied` — проверь, что пользователь авторизован (anonymous Auth)
