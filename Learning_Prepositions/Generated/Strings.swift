// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum About {
    /// Struggling with German prepositions? PrapoDe is your pocket coach that turns boring grammar lists into an engaging game.
    internal static let intro = L10n.tr("Localizable", "about.intro", fallback: "Struggling with German prepositions? PrapoDe is your pocket coach that turns boring grammar lists into an engaging game.")
    /// Stop guessing. Start mastering German grammar today!
    internal static let outro = L10n.tr("Localizable", "about.outro", fallback: "Stop guessing. Start mastering German grammar today!")
    /// About App
    internal static let title = L10n.tr("Localizable", "about.title", fallback: "About App")
    /// Version 
    internal static let version = L10n.tr("Localizable", "about.version", fallback: "Version ")
    internal enum Feature1 {
      /// From A1 to C1 – study exactly what you need for your current proficiency.
      internal static let text = L10n.tr("Localizable", "about.feature1.text", fallback: "From A1 to C1 – study exactly what you need for your current proficiency.")
      /// 1. All Levels
      internal static let title = L10n.tr("Localizable", "about.feature1.title", fallback: "1. All Levels")
    }
    internal enum Feature2 {
      /// Test your speed: get as many correct answers as possible in just 60 seconds.
      internal static let text = L10n.tr("Localizable", "about.feature2.text", fallback: "Test your speed: get as many correct answers as possible in just 60 seconds.")
      /// 4. Sprint Mode
      internal static let title = L10n.tr("Localizable", "about.feature2.title", fallback: "4. Sprint Mode")
    }
    internal enum Feature3 {
      /// A word is considered 'Mastered' only after 5 correct answers in a row.
      internal static let text = L10n.tr("Localizable", "about.feature3.text", fallback: "A word is considered 'Mastered' only after 5 correct answers in a row.")
      /// 7. 5-Point System
      internal static let title = L10n.tr("Localizable", "about.feature3.title", fallback: "7. 5-Point System")
    }
    internal enum Feature4 {
      /// Monitor your learning growth through detailed statistics and charts.
      internal static let text = L10n.tr("Localizable", "about.feature4.text", fallback: "Monitor your learning growth through detailed statistics and charts.")
      /// 10. Visual Progress
      internal static let title = L10n.tr("Localizable", "about.feature4.title", fallback: "10. Visual Progress")
    }
    internal enum Feature5 {
      /// Compete with students worldwide and see your name on the leaderboards.
      internal static let text = L10n.tr("Localizable", "about.feature5.text", fallback: "Compete with students worldwide and see your name on the leaderboards.")
      /// 9. Global Ranking
      internal static let title = L10n.tr("Localizable", "about.feature5.title", fallback: "9. Global Ranking")
    }
    internal enum Feature6 {
      /// Study words directly on your home screen without even opening the app.
      internal static let text = L10n.tr("Localizable", "about.feature6.text", fallback: "Study words directly on your home screen without even opening the app.")
      /// 8. Smart Widget
      internal static let title = L10n.tr("Localizable", "about.feature6.title", fallback: "8. Smart Widget")
    }
    internal enum FeatureAnalysis {
      /// Break down your mistakes immediately after finishing a test.
      internal static let text = L10n.tr("Localizable", "about.feature_analysis.text", fallback: "Break down your mistakes immediately after finishing a test.")
      /// 6. Error Review
      internal static let title = L10n.tr("Localizable", "about.feature_analysis.title", fallback: "6. Error Review")
    }
    internal enum FeatureQuiz {
      /// Take your time and choose the correct answer from the suggested options.
      internal static let text = L10n.tr("Localizable", "about.feature_quiz.text", fallback: "Take your time and choose the correct answer from the suggested options.")
      /// 3. Classic Quiz
      internal static let title = L10n.tr("Localizable", "about.feature_quiz.title", fallback: "3. Classic Quiz")
    }
    internal enum FeatureTraining {
      /// Browse the full list of words and translations before diving into tests.
      internal static let text = L10n.tr("Localizable", "about.feature_training.text", fallback: "Browse the full list of words and translations before diving into tests.")
      /// 2. Training Mode
      internal static let title = L10n.tr("Localizable", "about.feature_training.title", fallback: "2. Training Mode")
    }
    internal enum FeatureWriting {
      /// Type prepositions manually for maximum memorization and spelling practice.
      internal static let text = L10n.tr("Localizable", "about.feature_writing.text", fallback: "Type prepositions manually for maximum memorization and spelling practice.")
      /// 5. Writing Mode
      internal static let title = L10n.tr("Localizable", "about.feature_writing.title", fallback: "5. Writing Mode")
    }
    internal enum Why {
      /// Why PrapoDE?
      internal static let title = L10n.tr("Localizable", "about.why.title", fallback: "Why PrapoDE?")
    }
  }
  internal enum Alert {
    /// No
    internal static let no = L10n.tr("Localizable", "alert.no", fallback: "No")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "alert.ok", fallback: "Ok")
    /// Repeat
    internal static let `repeat` = L10n.tr("Localizable", "alert.repeat", fallback: "Repeat")
    /// Unknown error
    internal static let unknownError = L10n.tr("Localizable", "alert.unknown_error", fallback: "Unknown error")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "alert.yes", fallback: "Yes")
    internal enum FinishTest {
      /// Your progress will not be saved.
      internal static let description = L10n.tr("Localizable", "alert.finish_test.description", fallback: "Your progress will not be saved.")
      /// Do you want to stop the test?
      internal static let title = L10n.tr("Localizable", "alert.finish_test.title", fallback: "Do you want to stop the test?")
    }
    internal enum FinishTraining {
      /// Do you want to stop the training?
      internal static let title = L10n.tr("Localizable", "alert.finish_training.title", fallback: "Do you want to stop the training?")
    }
    internal enum FinishWriting {
      /// Do you want to stop the writing exercise?
      internal static let title = L10n.tr("Localizable", "alert.finish_writing.title", fallback: "Do you want to stop the writing exercise?")
    }
    internal enum ResetResults {
      /// Are you sure you want to delete all your results?
      internal static let title = L10n.tr("Localizable", "alert.reset_results.title", fallback: "Are you sure you want to delete all your results?")
    }
  }
  internal enum AppErrors {
    /// This guide is not available yet. Try again later.
    internal static let contentNotAvailable = L10n.tr("Localizable", "appErrors.contentNotAvailable", fallback: "This guide is not available yet. Try again later.")
    /// Failed to process the received data.
    internal static let decodingError = L10n.tr("Localizable", "appErrors.decodingError", fallback: "Failed to process the received data.")
    /// No internet connection. Please check your network and try again.
    internal static let noInternet = L10n.tr("Localizable", "appErrors.noInternet", fallback: "No internet connection. Please check your network and try again.")
    /// Server error:
    internal static let serverError = L10n.tr("Localizable", "appErrors.serverError", fallback: "Server error:")
    /// An unknown error occurred
    internal static let unknown = L10n.tr("Localizable", "appErrors.unknown", fallback: "An unknown error occurred")
  }
  internal enum Leaderboard {
    /// Your Best Results
    internal static let title = L10n.tr("Localizable", "leaderboard.title", fallback: "Your Best Results")
    internal enum NoResults {
      /// No results for this level 🙃
      internal static let description = L10n.tr("Localizable", "leaderboard.no_results.description", fallback: "No results for this level 🙃")
    }
    internal enum Picker {
      internal enum Quiz {
        /// Quiz
        internal static let title = L10n.tr("Localizable", "leaderboard.picker.quiz.title", fallback: "Quiz")
      }
      internal enum Sprint {
        /// Sprint
        internal static let title = L10n.tr("Localizable", "leaderboard.picker.sprint.title", fallback: "Sprint")
      }
      internal enum Writing {
        /// Writing
        internal static let title = L10n.tr("Localizable", "leaderboard.picker.writing.title", fallback: "Writing")
      }
    }
  }
  internal enum Mode {
    /// Options
    internal static let title = L10n.tr("Localizable", "mode.title", fallback: "Options")
    internal enum Case {
      internal enum Random {
        /// Random Order
        internal static let title = L10n.tr("Localizable", "mode.case.random.title", fallback: "Random Order")
      }
    }
  }
  internal enum MyProgress {
    internal enum Capsule {
      internal enum All {
        /// All
        internal static let title = L10n.tr("Localizable", "myProgress.capsule.all.title", fallback: "All")
      }
    }
    internal enum Header {
      /// Selected Level: 
      internal static let level = L10n.tr("Localizable", "myProgress.header.level", fallback: "Selected Level: ")
    }
    internal enum Screen {
      /// My Progress
      internal static let title = L10n.tr("Localizable", "myProgress.screen.title", fallback: "My Progress")
    }
    internal enum Search {
      /// Find a word...
      internal static let title = L10n.tr("Localizable", "myProgress.search.title", fallback: "Find a word...")
    }
    internal enum Stats {
      /// Learned: %lld
      internal static func learned(_ p1: Int) -> String {
        return L10n.tr("Localizable", "myProgress.stats.learned", p1, fallback: "Learned: %lld")
      }
      /// Total: %lld
      internal static func total(_ p1: Int) -> String {
        return L10n.tr("Localizable", "myProgress.stats.total", p1, fallback: "Total: %lld")
      }
    }
    internal enum Update {
      internal enum Alert {
        internal enum Confirm {
          /// Update
          internal static let action = L10n.tr("Localizable", "myProgress.update.alert.confirm.action", fallback: "Update")
          /// Do you want to check for new words or fixes? Your progress will be saved.
          internal static let description = L10n.tr("Localizable", "myProgress.update.alert.confirm.description", fallback: "Do you want to check for new words or fixes? Your progress will be saved.")
          /// Update Content?
          internal static let title = L10n.tr("Localizable", "myProgress.update.alert.confirm.title", fallback: "Update Content?")
        }
        internal enum Error {
          /// Update Failed
          internal static let title = L10n.tr("Localizable", "myProgress.update.alert.error.title", fallback: "Update Failed")
        }
        internal enum NoChanges {
          /// You already have the latest version of the dictionary.
          internal static let description = L10n.tr("Localizable", "myProgress.update.alert.noChanges.description", fallback: "You already have the latest version of the dictionary.")
          /// No Updates
          internal static let title = L10n.tr("Localizable", "myProgress.update.alert.noChanges.title", fallback: "No Updates")
        }
        internal enum Success {
          /// New data downloaded successfully. Typos fixed and new items added.
          internal static let description = L10n.tr("Localizable", "myProgress.update.alert.success.description", fallback: "New data downloaded successfully. Typos fixed and new items added.")
          /// Updated!
          internal static let title = L10n.tr("Localizable", "myProgress.update.alert.success.title", fallback: "Updated!")
        }
      }
    }
  }
  internal enum OnboardingProfile {
    /// Save
    internal static let saveButton = L10n.tr("Localizable", "onboardingProfile.saveButton", fallback: "Save")
    /// Enter your details for the ranking
    internal static let subtitle = L10n.tr("Localizable", "onboardingProfile.subtitle", fallback: "Enter your details for the ranking")
    /// Your profile
    internal static let title = L10n.tr("Localizable", "onboardingProfile.title", fallback: "Your profile")
    internal enum Country {
      /// Where are you from?
      internal static let label = L10n.tr("Localizable", "onboardingProfile.country.label", fallback: "Where are you from?")
      /// Select from the list...
      internal static let placeholder = L10n.tr("Localizable", "onboardingProfile.country.placeholder", fallback: "Select from the list...")
    }
    internal enum Nickname {
      /// Nickname
      internal static let label = L10n.tr("Localizable", "onboardingProfile.nickname.label", fallback: "Nickname")
      /// Enter name...
      internal static let placeholder = L10n.tr("Localizable", "onboardingProfile.nickname.placeholder", fallback: "Enter name...")
    }
    internal enum Picker {
      /// Search country...
      internal static let search = L10n.tr("Localizable", "onboardingProfile.picker.search", fallback: "Search country...")
      /// Where are you from?
      internal static let title = L10n.tr("Localizable", "onboardingProfile.picker.title", fallback: "Where are you from?")
    }
  }
  internal enum Prepositions {
    internal enum Detail {
      /// Don't confuse with
      internal static let contrast = L10n.tr("Localizable", "prepositions.detail.contrast", fallback: "Don't confuse with")
      /// Examples
      internal static let examples = L10n.tr("Localizable", "prepositions.detail.examples", fallback: "Examples")
      /// Grammar
      internal static let grammar = L10n.tr("Localizable", "prepositions.detail.grammar", fallback: "Grammar")
      /// Meaning
      internal static let meaning = L10n.tr("Localizable", "prepositions.detail.meaning", fallback: "Meaning")
      /// Common mistakes
      internal static let mistakes = L10n.tr("Localizable", "prepositions.detail.mistakes", fallback: "Common mistakes")
      /// Related prepositions
      internal static let related = L10n.tr("Localizable", "prepositions.detail.related", fallback: "Related prepositions")
      /// When to use
      internal static let whenToUse = L10n.tr("Localizable", "prepositions.detail.whenToUse", fallback: "When to use")
      internal enum Update {
        internal enum Alert {
          internal enum Confirm {
            /// Check Firebase for corrections or new content for this preposition?
            internal static let description = L10n.tr("Localizable", "prepositions.detail.update.alert.confirm.description", fallback: "Check Firebase for corrections or new content for this preposition?")
            /// Update article?
            internal static let title = L10n.tr("Localizable", "prepositions.detail.update.alert.confirm.title", fallback: "Update article?")
          }
          internal enum NoChanges {
            /// You already have the latest version of this article.
            internal static let description = L10n.tr("Localizable", "prepositions.detail.update.alert.noChanges.description", fallback: "You already have the latest version of this article.")
            /// No updates
            internal static let title = L10n.tr("Localizable", "prepositions.detail.update.alert.noChanges.title", fallback: "No updates")
          }
          internal enum Success {
            /// The article was updated with the latest version from the server.
            internal static let description = L10n.tr("Localizable", "prepositions.detail.update.alert.success.description", fallback: "The article was updated with the latest version from the server.")
            /// Updated!
            internal static let title = L10n.tr("Localizable", "prepositions.detail.update.alert.success.title", fallback: "Updated!")
          }
        }
      }
    }
    internal enum List {
      /// German prepositions by case — tap for a detailed guide
      internal static let subtitle = L10n.tr("Localizable", "prepositions.list.subtitle", fallback: "German prepositions by case — tap for a detailed guide")
      /// Prepositions
      internal static let title = L10n.tr("Localizable", "prepositions.list.title", fallback: "Prepositions")
    }
  }
  internal enum Quiz {
    /// Question
    internal static let title = L10n.tr("Localizable", "quiz.title", fallback: "Question")
    internal enum Button {
      /// Finish Test
      internal static let finish = L10n.tr("Localizable", "quiz.button.finish", fallback: "Finish Test")
      /// Next
      internal static let next = L10n.tr("Localizable", "quiz.button.next", fallback: "Next")
    }
  }
  internal enum QuizReview {
    /// Plural format key: "%#@correct@"
    internal static func correctCountFormatted(_ p1: Int) -> String {
      return L10n.tr("Localizable", "quizReview.correct_count_formatted", p1, fallback: "Plural format key: \"%#@correct@\"")
    }
    /// Plural format key: "%#@mistakes@"
    internal static func mistakesCountFormatted(_ p1: Int) -> String {
      return L10n.tr("Localizable", "quizReview.mistakes_count_formatted", p1, fallback: "Plural format key: \"%#@mistakes@\"")
    }
    /// Review Answers
    internal static let title = L10n.tr("Localizable", "quizReview.title", fallback: "Review Answers")
    /// Total questions:
    internal static let totalQuestions = L10n.tr("Localizable", "quizReview.totalQuestions", fallback: "Total questions:")
    /// Your Answer:
    internal static let yourAnswer = L10n.tr("Localizable", "quizReview.yourAnswer", fallback: "Your Answer:")
    internal enum Feedback {
      internal enum Subtitle {
        /// Check your mistakes below to learn the correct prepositions.
        internal static let `default` = L10n.tr("Localizable", "quizReview.feedback.subtitle.default", fallback: "Check your mistakes below to learn the correct prepositions.")
        /// No mistakes. Keep it up!
        internal static let perfect = L10n.tr("Localizable", "quizReview.feedback.subtitle.perfect", fallback: "No mistakes. Keep it up!")
      }
      internal enum Title {
        /// Excellent Result! 🚀
        internal static let excellent = L10n.tr("Localizable", "quizReview.feedback.title.excellent", fallback: "Excellent Result! 🚀")
        /// Good, but some mistakes 🧐
        internal static let good = L10n.tr("Localizable", "quizReview.feedback.title.good", fallback: "Good, but some mistakes 🧐")
        /// Review Needed 📚
        internal static let needsImprovement = L10n.tr("Localizable", "quizReview.feedback.title.needsImprovement", fallback: "Review Needed 📚")
        /// Perfect! 🏆
        internal static let perfect = L10n.tr("Localizable", "quizReview.feedback.title.perfect", fallback: "Perfect! 🏆")
        /// Try Again 🐣
        internal static let tryAgain = L10n.tr("Localizable", "quizReview.feedback.title.tryAgain", fallback: "Try Again 🐣")
      }
    }
  }
  internal enum Result {
    /// Plural format key: "%#@answers@"
    internal static func correctAnswers(_ p1: Int) -> String {
      return L10n.tr("Localizable", "result.correct_answers", p1, fallback: "Plural format key: \"%#@answers@\"")
    }
    /// Result
    internal static let result = L10n.tr("Localizable", "result.result", fallback: "Result")
    internal enum Button {
      internal enum BestResults {
        /// Best Results
        internal static let title = L10n.tr("Localizable", "result.button.best_results.title", fallback: "Best Results")
      }
      internal enum MainMenu {
        /// Main Menu
        internal static let title = L10n.tr("Localizable", "result.button.main_menu.title", fallback: "Main Menu")
      }
      internal enum RepeatTest {
        /// Repeat Test
        internal static let title = L10n.tr("Localizable", "result.button.repeat_test.title", fallback: "Repeat Test")
      }
      internal enum ReviewАnswers {
        /// Review Answers
        internal static let title = L10n.tr("Localizable", "result.button.review_аnswers.title", fallback: "Review Answers")
      }
    }
  }
  internal enum Rules {
    /// How Learning Works
    internal static let title = L10n.tr("Localizable", "rules.title", fallback: "How Learning Works")
    internal enum Button {
      /// Got it
      internal static let close = L10n.tr("Localizable", "rules.button.close", fallback: "Got it")
    }
    internal enum Correct {
      /// Adds **+1 point** to the word's progress.
      internal static let description = L10n.tr("Localizable", "rules.correct.description", fallback: "Adds **+1 point** to the word's progress.")
      /// Correct Answer
      internal static let title = L10n.tr("Localizable", "rules.correct.title", fallback: "Correct Answer")
    }
    internal enum Target {
      /// Reach **5 mastery points** for each **word with a preposition** to consider it learned.
      internal static let description = L10n.tr("Localizable", "rules.target.description", fallback: "Reach **5 mastery points** for each **word with a preposition** to consider it learned.")
      /// Goal
      internal static let title = L10n.tr("Localizable", "rules.target.title", fallback: "Goal")
    }
    internal enum Where {
      /// Points are awarded only in **Quiz**, **Sprint** (Timed Quiz) and **Writing** modes.
      internal static let description = L10n.tr("Localizable", "rules.where.description", fallback: "Points are awarded only in **Quiz**, **Sprint** (Timed Quiz) and **Writing** modes.")
      /// Where to Play?
      internal static let title = L10n.tr("Localizable", "rules.where.title", fallback: "Where to Play?")
    }
    internal enum Writing {
      internal enum Case {
        /// Uppercase and lowercase letters don't matter.
        internal static let desc = L10n.tr("Localizable", "rules.writing.case.desc", fallback: "Uppercase and lowercase letters don't matter.")
        /// Case
        internal static let title = L10n.tr("Localizable", "rules.writing.case.title", fallback: "Case")
      }
      internal enum Sich {
        /// You can skip typing it, the system will handle it.
        internal static let desc = L10n.tr("Localizable", "rules.writing.sich.desc", fallback: "You can skip typing it, the system will handle it.")
        /// Particle **(sich)**
        internal static let title = L10n.tr("Localizable", "rules.writing.sich.title", fallback: "Particle **(sich)**")
      }
      internal enum Umlauts {
        /// Skipping **ä/ö/ü** is allowed, but we'll remind you about it.
        internal static let desc = L10n.tr("Localizable", "rules.writing.umlauts.desc", fallback: "Skipping **ä/ö/ü** is allowed, but we'll remind you about it.")
        /// Umlauts
        internal static let title = L10n.tr("Localizable", "rules.writing.umlauts.title", fallback: "Umlauts")
      }
    }
    internal enum Wrong {
      /// A wrong answer deducts **1 point**.
      /// 
      /// If you make a mistake in an already **learned** word, **2 points** will be deducted, and the word returns to unlearned status.
      internal static let description = L10n.tr("Localizable", "rules.wrong.description", fallback: "A wrong answer deducts **1 point**.\n\nIf you make a mistake in an already **learned** word, **2 points** will be deducted, and the word returns to unlearned status.")
      /// Mistake
      internal static let title = L10n.tr("Localizable", "rules.wrong.title", fallback: "Mistake")
    }
  }
  internal enum Settings {
    /// Settings
    internal static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
    internal enum Section {
      internal enum About {
        /// About App
        internal static let title = L10n.tr("Localizable", "settings.section.about.title", fallback: "About App")
      }
      internal enum AboutUs {
        /// About us
        internal static let description = L10n.tr("Localizable", "settings.section.about_us.description", fallback: "About us")
      }
      internal enum Feedback {
        /// Write to developer / leave feedback
        internal static let description = L10n.tr("Localizable", "settings.section.feedback.description", fallback: "Write to developer / leave feedback")
        /// Feedback
        internal static let title = L10n.tr("Localizable", "settings.section.feedback.title", fallback: "Feedback")
        internal enum Email {
          /// Hello! I would like to leave a review about the app.
          /// 
          /// 
          internal static let text = L10n.tr("Localizable", "settings.section.feedback.email.text", fallback: "Hello! I would like to leave a review about the app.\n\n")
        }
      }
      internal enum General {
        /// General
        internal static let title = L10n.tr("Localizable", "settings.section.general.title", fallback: "General")
      }
      internal enum Language {
        /// Language
        internal static let title = L10n.tr("Localizable", "settings.section.language.title", fallback: "Language")
      }
      internal enum LanguageLevel {
        /// Select a level
        internal static let description = L10n.tr("Localizable", "settings.section.language_level.description", fallback: "Select a level")
        /// Language level
        internal static let title = L10n.tr("Localizable", "settings.section.language_level.title", fallback: "Language level")
      }
      internal enum Quiz {
        /// Number of questions:
        internal static let description = L10n.tr("Localizable", "settings.section.quiz.description", fallback: "Number of questions:")
        /// Quiz
        internal static let title = L10n.tr("Localizable", "settings.section.quiz.title", fallback: "Quiz")
      }
      internal enum ResetProgress {
        /// Reset results
        internal static let description = L10n.tr("Localizable", "settings.section.reset_progress.description", fallback: "Reset results")
      }
      internal enum Results {
        /// View your results
        internal static let description = L10n.tr("Localizable", "settings.section.results.description", fallback: "View your results")
        /// Results
        internal static let title = L10n.tr("Localizable", "settings.section.results.title", fallback: "Results")
      }
      internal enum TranslationLanguage {
        /// Translate to
        internal static let description = L10n.tr("Localizable", "settings.section.translation_language.description", fallback: "Translate to")
      }
      internal enum Widget {
        /// Widget
        internal static let title = L10n.tr("Localizable", "settings.section.widget.title", fallback: "Widget")
        /// Word Selection
        internal static let wordSelection = L10n.tr("Localizable", "settings.section.widget.wordSelection", fallback: "Word Selection")
      }
    }
  }
  internal enum SpeedQuiz {
    /// Question
    internal static let title = L10n.tr("Localizable", "speedQuiz.title", fallback: "Question")
    internal enum Countdown {
      /// GO!
      internal static let go = L10n.tr("Localizable", "speedQuiz.countdown.go", fallback: "GO!")
    }
  }
  internal enum Splash {
    /// Master prepositions the fun way
    internal static let description = L10n.tr("Localizable", "splash.description", fallback: "Master prepositions the fun way")
  }
  internal enum Training {
    internal enum Action {
      /// I know
      internal static let know = L10n.tr("Localizable", "training.action.know", fallback: "I know")
      /// Listen
      internal static let listen = L10n.tr("Localizable", "training.action.listen", fallback: "Listen")
      /// Repeat
      internal static let `repeat` = L10n.tr("Localizable", "training.action.repeat", fallback: "Repeat")
      /// Tap to flip
      internal static let tapToFlip = L10n.tr("Localizable", "training.action.tapToFlip", fallback: "Tap to flip")
    }
    internal enum Finish {
      /// You have reviewed all words in this deck
      internal static let description = L10n.tr("Localizable", "training.finish.description", fallback: "You have reviewed all words in this deck")
      /// Great job!
      internal static let title = L10n.tr("Localizable", "training.finish.title", fallback: "Great job!")
      internal enum Button {
        /// Main Menu
        internal static let home = L10n.tr("Localizable", "training.finish.button.home", fallback: "Main Menu")
      }
    }
    internal enum Screen {
      /// Training
      internal static let title = L10n.tr("Localizable", "training.screen.title", fallback: "Training")
    }
  }
  internal enum UniversalMenu {
    internal enum Activity {
      /// Choose Mode
      internal static let title = L10n.tr("Localizable", "universalMenu.activity.title", fallback: "Choose Mode")
      internal enum Progress {
        /// My Progress
        internal static let title = L10n.tr("Localizable", "universalMenu.activity.progress.title", fallback: "My Progress")
      }
      internal enum Quiz {
        /// Quiz
        internal static let title = L10n.tr("Localizable", "universalMenu.activity.quiz.title", fallback: "Quiz")
      }
      internal enum Sprint {
        /// Sprint
        internal static let title = L10n.tr("Localizable", "universalMenu.activity.sprint.title", fallback: "Sprint")
      }
      internal enum Training {
        /// Training
        internal static let title = L10n.tr("Localizable", "universalMenu.activity.training.title", fallback: "Training")
      }
      internal enum Writing {
        /// Writing
        internal static let title = L10n.tr("Localizable", "universalMenu.activity.writing.title", fallback: "Writing")
      }
    }
    internal enum Category {
      /// Choose Category
      internal static let title = L10n.tr("Localizable", "universalMenu.category.title", fallback: "Choose Category")
      internal enum Hint {
        /// Choose the right level to progress faster
        internal static let description = L10n.tr("Localizable", "universalMenu.category.hint.description", fallback: "Choose the right level to progress faster")
        /// Learn Efficiently
        internal static let title = L10n.tr("Localizable", "universalMenu.category.hint.title", fallback: "Learn Efficiently")
      }
    }
    internal enum Prepositions {
      /// Prepositions
      internal static let title = L10n.tr("Localizable", "universalMenu.prepositions.title", fallback: "Prepositions")
    }
  }
  internal enum WidgetWord {
    /// Search verbs...
    internal static let searchText = L10n.tr("Localizable", "widgetWord.searchText", fallback: "Search verbs...")
    /// Verb Selection
    internal static let title = L10n.tr("Localizable", "widgetWord.title", fallback: "Verb Selection")
    internal enum Header {
      /// Select verbs for the widget
      internal static let description = L10n.tr("Localizable", "widgetWord.header.description", fallback: "Select verbs for the widget")
    }
  }
  internal enum WorldRanking {
    /// Be the first in this Sprint ranking!
    internal static let emptyState = L10n.tr("Localizable", "worldRanking.EmptyState", fallback: "Be the first in this Sprint ranking!")
    /// Could not load the ranking
    internal static let loadError = L10n.tr("Localizable", "worldRanking.loadError", fallback: "Could not load the ranking")
    internal enum Filter {
      /// Show ranking for my country
      internal static let byCountry = L10n.tr("Localizable", "worldRanking.filter.byCountry", fallback: "Show ranking for my country")
      /// Show worldwide ranking
      internal static let worldwide = L10n.tr("Localizable", "worldRanking.filter.worldwide", fallback: "Show worldwide ranking")
    }
    internal enum Sprint {
      /// World Sprint Ranking
      internal static let title = L10n.tr("Localizable", "worldRanking.sprint.Title", fallback: "World Sprint Ranking")
    }
  }
  internal enum Writing {
    /// Enter translation...
    internal static let placeholder = L10n.tr("Localizable", "writing.placeholder", fallback: "Enter translation...")
    /// Task
    internal static let title = L10n.tr("Localizable", "writing.title", fallback: "Task")
    internal enum Button {
      /// Check
      internal static let check = L10n.tr("Localizable", "writing.button.check", fallback: "Check")
      /// Next
      internal static let next = L10n.tr("Localizable", "writing.button.next", fallback: "Next")
    }
    internal enum Hint {
      /// Correct! But don't forget the umlauts ✍️
      internal static let almost = L10n.tr("Localizable", "writing.hint.almost", fallback: "Correct! But don't forget the umlauts ✍️")
      /// You can also say:
      internal static let also = L10n.tr("Localizable", "writing.hint.also", fallback: "You can also say:")
      /// Correct answers:
      internal static let correctVariants = L10n.tr("Localizable", "writing.hint.correct_variants", fallback: "Correct answers:")
      /// Mistake
      internal static let error = L10n.tr("Localizable", "writing.hint.error", fallback: "Mistake")
      /// Correct! But there's an extra umlaut ✍️
      internal static let extraUmlaut = L10n.tr("Localizable", "writing.hint.extra_umlaut", fallback: "Correct! But there's an extra umlaut ✍️")
      /// Great!
      internal static let perfect = L10n.tr("Localizable", "writing.hint.perfect", fallback: "Great!")
    }
    internal enum Rules {
      /// Writing rules
      internal static let title = L10n.tr("Localizable", "writing.rules.title", fallback: "Writing rules")
    }
  }
  internal enum СhooseQuizLevel {
    /// questions
    internal static let numberOfQuestions = L10n.tr("Localizable", "сhooseQuizLevel.numberOfQuestions", fallback: "questions")
    /// Select Difficulty Level
    internal static let title = L10n.tr("Localizable", "сhooseQuizLevel.title", fallback: "Select Difficulty Level")
    internal enum Level {
      /// Hard
      internal static let heavy = L10n.tr("Localizable", "сhooseQuizLevel.level.heavy", fallback: "Hard")
      /// Easy
      internal static let light = L10n.tr("Localizable", "сhooseQuizLevel.level.light", fallback: "Easy")
      /// Medium
      internal static let medium = L10n.tr("Localizable", "сhooseQuizLevel.level.medium", fallback: "Medium")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
