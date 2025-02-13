import Foundation

class MovieQuizPresenter {
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = .zero
    var correctAnswers: Int = .zero
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?

    weak var viewController: MovieQuizViewController?
    init(viewController: MovieQuizViewController?) {
        self.viewController = viewController
        self.statisticService = StatisticServiceImplementation()
        self.questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        self.questionFactory?.loadData()
    }
}

extension MovieQuizPresenter {
    func set(answer: Bool) {
        guard let currentQuestion else { return }
        let correctAnswer = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questionsAmount
        let questionNumber = "\(currentQuestionIndex + 1)/\(total)"
        return .init(
            imageData: model.imageData,
            question: model.text,
            questionNumber: questionNumber
        )
    }
    func showAnswerResult(isCorrect: Bool) {
        viewController?.showLoadingIndicator()
        if isCorrect {
            correctAnswers += 1
            viewController?.indicateCorrectAnswer()
        } else {
            viewController?.indicateWrongAnswer()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.showNextQuestionOrResults()
        }
    }
    func showNextQuestionOrResults() {
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
            show(quiz: viewModel)
        } else {
            viewController?.removeAnswerCorrectnessIndication()
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.viewController?.removeAnswerCorrectnessIndication()
            self?.correctAnswers = 0
            self?.currentQuestionIndex = 0
            self?.questionFactory?.requestNextQuestion()
        }
        if let viewController {
            let alertPresenter = ResultAlertPresenter(model: model)
            alertPresenter.present(on: viewController)
        }
    }
    func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        if let viewController {
            let alertPresenter = ResultAlertPresenter(model: model)
            alertPresenter.present(on: viewController)
        }
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.hideLoadingIndicator()
    }
}
