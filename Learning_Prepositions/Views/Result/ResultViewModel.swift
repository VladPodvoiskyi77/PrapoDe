import SwiftUI

final class ResultViewModel: BaseDataViewModel {

    var quizResultContext: QuizResultContext
    
    init(quizResultContext: QuizResultContext) {
        self.quizResultContext = quizResultContext
    }
    
}
