enum UpdateResult {
    case updated      // Данные изменились (опечатки исправлены или слова добавлены)
    case noChanges    // Данные на сервере такие же, как в телефоне
    case error(String)
}
