import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle

    @IBOutlet private var previewImageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var indexLabel: UILabel!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!

    private let questionsAmount = 10
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticService?
    private var currentQuestion: QuizQuestion?

    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero

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

    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self else {
                return
            }
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
        let alertPresenter = ResultAlertPresenter(viewController: self, model: model)
        alertPresenter.present()
    }

    private func showAnswerResult(isCorrect: Bool) {
        showLoadingIndicator()
        if isCorrect {
            correctAnswers += 1
            setImageBorder(color: UIColor(named: "YP Green"))
        } else {
            setImageBorder(color: UIColor(named: "YP Red"))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.hideLoadingIndicator()
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
            statisticService?.store(
                correct: correctAnswers,
                total: questionsAmount
            )
            let text = """
            Ваш результат \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
            Рекорд: \(statisticService?.bestGame.description ?? "")
            Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
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
            questionFactory?.requestNextQuestion()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.layer.cornerRadius = 20
        previewImageView.layer.borderWidth = 8
        showLoadingIndicator()
        setImageBorder(color: nil)
        activityIndicator.hidesWhenStopped = true

        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        questionFactory?.loadData()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questionsAmount
        let questionNumber = "\(currentQuestionIndex + 1)/\(total)"
        return .init(
            image: UIImage(data: model.image),
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
        ) { [weak self] in
            self?.setImageBorder(color: nil)
            self?.correctAnswers = 0
            self?.currentQuestionIndex = 0
            self?.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = ResultAlertPresenter(viewController: self, model: model)
        alertPresenter.present()
    }
}

// MARK: QuestionFactoryDelegate

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

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        activityIndicator.stopAnimating()
    }
}
