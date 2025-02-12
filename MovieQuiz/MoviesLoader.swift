import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

private var mostPopularMoviesUrl = URL(
    string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
)!

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case let .success(data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    guard mostPopularMovies.errorMessage == "" else {
                        throw SimpleError(mostPopularMovies.errorMessage)
                    }
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }
}
