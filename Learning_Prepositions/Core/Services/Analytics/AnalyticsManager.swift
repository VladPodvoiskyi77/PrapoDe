import FirebaseAnalytics
import Foundation

/// Firebase Analytics wrapper for PrapoDe.
/// Full event catalog: see `ANALYTICS.md` in the project root.
final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}

    // MARK: - Main activity
    
    func logActivityStarted(mode: Activity, category: String, level: String) {
        let eventName = "\(mode.rawValue)_started"
        
        Analytics.logEvent(eventName, parameters: [
            "category": category,
            "level": level
        ])
    }

    func logActivityFinished(mode: Activity, category: String, level: String, score: Int, total: Int) {
        Analytics.logEvent("\(mode.rawValue)_finished", parameters: [
            "category": category,
            "level": level,
            "score": score,
            "total_questions": total,
            "accuracy": total > 0 ? Double(score) / Double(total) : 0
        ])
    }

    func logActivityAbandoned(mode: Activity, category: String, level: String, answered: Int, total: Int) {
        Analytics.logEvent("\(mode.rawValue)_abandoned", parameters: [
            "category": category,
            "level": level,
            "questions_answered": answered,
            "total_questions": total
        ])
    }

    func logProfileSetupStarted() {
        Analytics.logEvent("profile_setup_started", parameters: nil)
    }

    func logProfileSetupCompleted(countryCode: String) {
        Analytics.logEvent("profile_setup_completed", parameters: [
            "country_code": countryCode
        ])
    }

    func logMyProgressViewed(category: String, level: String) {
        Analytics.logEvent("myProgress_viewed", parameters: [
            "category": category,
            "level": level
        ])
    }

    func logWidgetCustomized(verb: String, isShown: Bool) {
        Analytics.logEvent("widget_word_toggle", parameters: [
            "verb": verb,
            "status": isShown ? "enabled" : "disabled"
        ])
    }

    func logWidgetWordsConfigured(enabledCount: Int, totalCount: Int) {
        Analytics.logEvent("widget_words_configured", parameters: [
            "enabled_count": enabledCount,
            "total_count": totalCount
        ])
        Analytics.setUserProperty(String(enabledCount), forName: "widget_enabled_words")
    }

    func logWidgetInstalled(widgetCount: Int, family: String) {
        Analytics.logEvent("widget_installed", parameters: [
            "widget_count": widgetCount,
            "family": family
        ])
        setWidgetInstalled(true)
    }

    func logWidgetRemoved(previousCount: Int) {
        Analytics.logEvent("widget_removed", parameters: [
            "previous_count": previousCount
        ])
        setWidgetInstalled(false)
    }

    func logWidgetTimelineRefreshed(refreshCount: Int, entryCount: Int) {
        Analytics.logEvent("widget_timeline_refreshed", parameters: [
            "refresh_count": refreshCount,
            "entry_count": entryCount
        ])
    }

    func logWidgetTap(verb: String, level: String) {
        Analytics.logEvent("widget_tap", parameters: [
            "verb": verb,
            "level": level
        ])
    }

    func setWidgetInstalled(_ installed: Bool) {
        Analytics.setUserProperty(installed ? "true" : "false", forName: "has_widget_installed")
    }
    
    func logWrongAnswer(
        mode: Activity,
        wordWithPrap: String,
        level: String,
        category: String,
        userAnswer: String? = nil
    ) {
        var parameters: [String: Any] = [
            "wordWithPrap": wordWithPrap,
            "level": level,
            "category": category
        ]
        if let userAnswer, !userAnswer.isEmpty {
            parameters["user_answer"] = userAnswer
        }
        Analytics.logEvent("\(mode.rawValue)_error", parameters: parameters)
    }

    // MARK: - User Properties
    
    func setUserLevel(_ level: String) {
        Analytics.setUserProperty(level, forName: "current_study_level")
    }
    
    // MARK: - Navigation Tracking
    
    func logAppLaunch(userId: String?, nickname: String?) {
        if let userId, !userId.isEmpty {
            Analytics.setUserID(userId)
        }

        let name = (nickname == nil || nickname?.isEmpty == true) ? "unknown" : nickname!
        Analytics.setUserProperty(name, forName: "nickname")
        Analytics.logEvent("app_launch_custom", parameters: [
            "user_name": name,
            "timestamp": Date().description
        ])
    }

    func logScreenView(_ screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenName
        ])
    }

    // MARK: - Prepositions guide

    func logPrepositionsGuideViewed(prepositionCount: Int, contentLanguage: String) {
        Analytics.logEvent("prepositions_guide_viewed", parameters: [
            "preposition_count": prepositionCount,
            "content_language": contentLanguage
        ])
    }

    func logPrepositionArticleViewed(
        prepositionId: String,
        lemma: String,
        caseGroup: String,
        contentLanguage: String,
        source: PrepositionArticleSource
    ) {
        Analytics.logEvent("preposition_article_viewed", parameters: [
            "preposition_id": prepositionId,
            "lemma": lemma,
            "case_group": caseGroup,
            "content_language": contentLanguage,
            "source": source.rawValue
        ])
    }
}
