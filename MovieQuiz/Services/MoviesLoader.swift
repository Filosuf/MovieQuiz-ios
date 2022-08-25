//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by 1234 on 24.08.2022.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private enum NetworkError: Error {
        case decodeError
        case invalidApiKey
        case unowned
    }

    // MARK: - NetworkClient
    private let networkClient = NetworkClient()

    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_kiwxbi4y") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if !mostPopularMovies.items.isEmpty {
                        handler(.success(mostPopularMovies))
                    } else if mostPopularMovies.errorMessage == "Invalid API Key" {
                        handler(.failure(NetworkError.invalidApiKey))
                    } else {
                        handler(.failure(NetworkError.unowned))
                    }
                } catch {
                    handler(.failure(NetworkError.decodeError))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
