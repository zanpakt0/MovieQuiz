import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: .none)

        // When
        let loader = MoviesLoader(networkClient: stubNetworkClient)

        let expectation = expectation(description: "Loading expectation")

        loader.loadMovies { result in
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }

        waitForExpectations(timeout: 1)
    }
    func testFailureLoading_networkError() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: .network)

        // When
        let loader = MoviesLoader(networkClient: stubNetworkClient)

        let expectation = expectation(description: "Loading expectation")

        loader.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let error):
                XCTAssertEqual(
                    error as? StubNetworkClient.TestError,
                    .test
                )
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
    func testFailureLoading_badJson() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: .json)

        // When
        let loader = MoviesLoader(networkClient: stubNetworkClient)

        let expectation = expectation(description: "Loading expectation")

        loader.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
    func testFailureLoading_protocol() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: .errorInResponse)

        // When
        let loader = MoviesLoader(networkClient: stubNetworkClient)

        let expectation = expectation(description: "Loading expectation")

        loader.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let error):
                XCTAssertEqual(
                    error as? SimpleError,
                    SimpleError("my test error")
                )
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
}

struct StubNetworkClient {
    enum TestError: Error {
        case test
    }
    enum EmulateError: Error {
        case none, network, errorInResponse, json
    }

    let emulateError: EmulateError
}

extension StubNetworkClient: NetworkRouting {

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        switch emulateError {
        case .network:
            handler(.failure(TestError.test))
        case .errorInResponse:
            handler(.success(errorResponse))
        case .none:
            handler(.success(expectedResponse))
        case .json:
            handler(.success(badJson))
        }
    }
}

private extension StubNetworkClient {
    private var badJson: Data {
        """
        {
           "bad" : []
        }
        """.data(using: .utf8)!
    }
    private var errorResponse: Data {
        """
        {
           "errorMessage" : "my test error",
           "items" : []
        }
        """.data(using: .utf8)!
    }

    private var expectedResponse: Data {
        """
        {
           "errorMessage" : "",
           "items" : [
              {
                 "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                 "fullTitle" : "Prey (2022)",
                 "id" : "tt11866324",
                 "imDbRating" : "7.2",
                 "imDbRatingCount" : "93332",
                 "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "1",
                 "rankUpDown" : "+23",
                 "title" : "Prey",
                 "year" : "2022"
              },
              {
                 "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                 "fullTitle" : "The Gray Man (2022)",
                 "id" : "tt1649418",
                 "imDbRating" : "6.5",
                 "imDbRatingCount" : "132890",
                 "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "2",
                 "rankUpDown" : "-1",
                 "title" : "The Gray Man",
                 "year" : "2022"
              }
            ]
          }
        """.data(using: .utf8) ?? Data()
    }
}
