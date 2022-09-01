//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by 1234 on 20.08.2022.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Properties
    private let delegate: QuestionFactoryDelegate
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []

    // MARK: - Lifecycle
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    // MARK: - Methods
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData: Data?

            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }

            guard let imageData = imageData, let rating = Float(movie.rating) else {
                self.delegate.didReceiveNextQuestion(question: nil)
                return
            }

            // swiftlint:disable force_unwrapping
            let ratingInQuestion = [5, 6, 6, 7, 7, 7, 7, 8].randomElement()!
            // swiftlint:enable force_unwrapping
            let text = "Рейтинг этого фильма больше чем \(ratingInQuestion)?"
            let correctAnswer = rating > Float(ratingInQuestion)

            let question = QuizeQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate.didReceiveNextQuestion(question: question)
            }
        }
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                DispatchQueue.main.async {
                    self.delegate.didLoadDataFromServer() // сообщаем, что данные загрузились
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
}
