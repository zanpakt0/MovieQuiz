import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle

    @IBOutlet private var previewImageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!

    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticService?
    private var currentQuestion: QuizQuestion?

    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    @IBAction private func noButtonClicked(_: UIButton) {
        let answer = false
        guard let currentQuestion else {
                    return
                }
        let correctAnswer = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }

    @IBAction private func yesButtonClicked(_: UIButton) {
        let answer = true
        guard let currentQuestion else {
                    return
                }
        let correctAnswer = currentQuestion.correctAnswer
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
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
        if currentQuestionIndex == questionsAmount - 1 {
            self.statisticService?.store(
                correct: self.correctAnswers,
                total: self.questionsAmount
            )
            let text = """
                Ваш результат \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(self.statisticService?.gamesCount ?? 0)
                Рекорд: \(self.statisticService?.bestGame.description ?? "")
                Средняя точность: \(String(format: "%.2f", self.statisticService?.totalAccuracy ?? 0))%
                """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            showResult(quiz: viewModel)
        } else {
            setImageBorder(color: nil)
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion(currentQuestionIndex: currentQuestionIndex)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.layer.cornerRadius = 20
        previewImageView.layer.borderWidth = 8

        self.statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactoryImplementation(delegate: self)
        questionFactory?.requestNextQuestion(currentQuestionIndex: currentQuestionIndex)
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questionsAmount
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
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        )
        let alertPresenter = ResultAlertPresenter(model: model, viewController: self, delegate: self)
        alertPresenter.present()
    }
}

// MARK:  QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

// MARK: AlertPresenterDelegate
extension MovieQuizViewController: ResultAlertPresenterDelegate {
    func onButtonTapped() {
        setImageBorder(color: nil)
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion(currentQuestionIndex: currentQuestionIndex)

    }
}
