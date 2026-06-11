import WidgetKit
import SwiftUI
import SwiftData

struct SimpleEntry: TimelineEntry {
    let date: Date
    let verbItem: VerbEntity
    let languageCode: Language
}


struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    private var currentLanguage: Language {
        let sharedDefaults = UserDefaults(suiteName: AppConfig.Constants.appGroupID)
        let langRaw = sharedDefaults?.string(forKey: "selectedLanguage") ?? Language.en.rawValue
        return Language(rawValue: langRaw) ?? .en
    }
    
    func loadVerbsFromSwiftData() -> [VerbEntity] {
        let container = PersistenceController.sharedModelContainer
        let context = ModelContext(container)
        
        // Виджет должен показывать только те слова, уровень которых сейчас выбран
        let sharedDefaults = UserDefaults(suiteName: AppConfig.Constants.appGroupID)
        let currentLevel = sharedDefaults?.string(forKey: "selectedLevel") ?? "A1"
        
        let predicate = #Predicate<VerbEntity> { verb in
            verb.levelRaw == currentLevel && verb.isShow == true
        }
        
        let descriptor = FetchDescriptor<VerbEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.base)]
        )
        
        do {
            let verbs = try context.fetch(descriptor)
            
            if verbs.isEmpty {
                print("⚠️ SwiftData пуста или все слова скрыты. Проверь настройки.")
                return loadFromBundle()
            }
            
            print("✅ Виджет загрузил \(verbs.count) слов из SwiftData для уровня \(currentLevel)")
            return verbs
        } catch {
            print("❌ Ошибка загрузки SwiftData в виджете: \(error)")
            return []
        }
    }
    
    private func loadFromBundle() -> [VerbEntity] {
        guard let bundleURL = Bundle.main.url(forResource: "initial_verbs", withExtension: "json") else {
            print("❌ Ошибка: initial_verbs.json не найден в Bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: bundleURL)
            
            let items = try JSONDecoder().decode([VerbItem].self, from: data)
            
            let entities = items.map { VerbEntity(from: $0) }
            
            print("📦 Загружено и конвертировано \(entities.count) глаголов из встроенного Bundle")
            return entities
            
        } catch {
            print("❌ Ошибка декодирования или маппинга: \(error)")
            return []
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let item = VerbEntity(from: VerbItem(
            base: "Laden...",
            preposition: "",
            translationRu: "Загрузка...",
            translationUa: "",
            translationEn: "",
            exampleSentence: "",
            caseType: .akkusativ,
            level: .a1,
        ))
        return SimpleEntry(date: Date(), verbItem: item, languageCode: currentLanguage)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let item = VerbEntity(from: VerbItem(
            base: "warten",
            preposition: "auf",
            translationRu: "ждать",
            translationUa: "чекати",
            translationEn: "wait",
            exampleSentence: "Ich warte auf dem Bus",
            caseType: .akkusativ, level: .a1,
        ))
        let entry = SimpleEntry(date: Date(), verbItem: item, languageCode: currentLanguage)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: AppConfig.Constants.appGroupID)

        let levelRaw = sharedDefaults?.string(forKey: "selectedLevel") ?? "A1"
        let langRaw = sharedDefaults?.string(forKey: "selectedLanguage") ?? "en"
        let currentLanguage = Language(rawValue: langRaw) ?? .en
        
        let allVerbs = loadVerbsFromSwiftData()
        let filteredVerbs = allVerbs.filter { $0.levelRaw == levelRaw }
        let sourceVerbs = filteredVerbs.isEmpty ? allVerbs : filteredVerbs
    
        let verbsToShow = sourceVerbs.shuffled().prefix(12)
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        for (index, verb) in verbsToShow.enumerated() {
            let entryDate = Calendar.current.date(byAdding: .hour, value: index, to: currentDate)!
            
            let entry = SimpleEntry(date: entryDate, verbItem: verb, languageCode: currentLanguage)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct PrepoWidgetEntryView: View {
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            PrepoSmallWidgetView(entry: entry)
        case .systemMedium:
            PrepoMediumWidgetView(entry: entry)
        default:
            PrepoMediumWidgetView(entry: entry)
        }
    }
}

struct PrepoWidget: Widget {
    let kind: String = "PrepoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PrepoWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        entry.verbItem.caseColor
                    }
            } else {
                PrepoWidgetEntryView(entry: entry)
                    .padding()
                    .background(entry.verbItem.caseColor)
            }
        }
        .configurationDisplayName(WidgetL10n.displayName)
        .description(WidgetL10n.description)
        .supportedFamilies([.systemMedium])
    }
}

private enum WidgetL10n {
    static var displayName: String {
        NSLocalizedString("widget.displayName", bundle: .main, comment: "Widget display name")
    }

    static var description: String {
        NSLocalizedString("widget.description", bundle: .main, comment: "Widget description")
    }
}

