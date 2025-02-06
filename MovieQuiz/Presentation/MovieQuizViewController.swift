import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle

    @IBOutlet private var previewImageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        )
    ]

    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    @IBAction private func noButtonClicked(_: UIButton) {
        let answer = false
        let question = questions[currentQuestionIndex]
        let correctAnswer = question.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }

    @IBAction private func yesButtonClicked(_: UIButton) {
        let answer = true
        let question = questions[currentQuestionIndex]
        let correctAnswer = question.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            setImageBorder(color: UIColor(named: "YP Green"))
        } else {
            setImageBorder(color: UIColor(named: "YP Red"))
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func setImageBorder(color: UIColor?) {
        guard let color else {
            previewImageView.layer.borderColor = UIColor.clear.cgColor
            return
        }
        previewImageView.layer.borderColor = color.cgColor
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз"
            )
            showResult(quiz: viewModel)
        } else {
            setImageBorder(color: nil)
            currentQuestionIndex += 1
            show(
                quiz: convert(
                    model: questions[currentQuestionIndex]
                )
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.layer.cornerRadius = 20
        previewImageView.layer.borderWidth = 8
        show(
            quiz: convert(
                model: questions[currentQuestionIndex]
            )
        )
    }

    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }

    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }

    struct QuizStepViewModel {
        let image: UIImage?
        let question: String
        let questionNumber: String
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questions.count
        let questionNumber = "\(currentQuestionIndex + 1)/\(total)"
        return .init(
            image: UIImage(named: model.image),
            question: model.text,
            questionNumber: questionNumber
        )
    }

    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImageView.image = step.image
        questionLabel.text = step.question
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ) { _ in
            self.setImageBorder(color: nil)
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.show(
                quiz: self.convert(
                    model: self.questions[self.currentQuestionIndex]
                )
            )
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
}
