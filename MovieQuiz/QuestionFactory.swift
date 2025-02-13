import Foundation

final class QuestionFactory {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
}

extension QuestionFactory: QuestionFactoryProtocol {
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let movie = self?.movies.randomElement() else {
                DispatchQueue.main.async {
                    self?.delegate?.didFailToLoadData(
                        with: SimpleError("нет фильмов для вопроса")
                    )
                }
                return
            }
            let imageData = try? Data(contentsOf: movie.resizedImageURL)
            if imageData == nil {
                print("Failed to load image")
            }
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 6?"
            let correctAnswer = rating > 6
            let question = QuizQuestion(
                image: imageData ?? Data(),
                text: text,
                correctAnswer: correctAnswer
            )
            DispatchQueue.main.async {
                self?.delegate?.didReceiveNextQuestion(
                    question: question
                )
            }
        }
    }
}

extension QuestionFactory {
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }
                switch result {
                case let .success(mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case let .failure(error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
