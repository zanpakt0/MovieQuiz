import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() {
        // Given
        let sut = MovieQuizPresenter(viewController: nil)
        let question = QuizQuestion(
            imageData: nil,
            text: "Question Text",
            correctAnswer: true
        )

        // When
        let viewModel = sut.convert(model: question)

        // Then
        XCTAssertNil(viewModel.imageData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    func testPresenterConvertModel_nextQuestion() {
        // Given
        let sut = MovieQuizPresenter(viewController: nil)
        let question = QuizQuestion(
            imageData: nil,
            text: "Question Text",
            correctAnswer: true
        )

        // When
        sut.showNextQuestionOrResults()
        let viewModel = sut.convert(model: question)

        // Then
        XCTAssertNil(viewModel.imageData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "2/10")
    }
}
