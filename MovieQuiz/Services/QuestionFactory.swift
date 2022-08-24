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
//    private let questionsArray: [QuizeQuestion] = [
//    QuizeQuestion(
//        image: "The Godfather",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true
//    ),
//    QuizeQuestion(
//        image: "The Dark Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true
//    ),
//    QuizeQuestion(
//        image: "Kill Bill",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true
//    ),
//    QuizeQuestion(
//        image: "The Avengers",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true
//    ),
//    QuizeQuestion(
//        image: "Deadpool",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true
//    ),
//    QuizeQuestion(
//        image: "The Green Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true
//    ),
//    QuizeQuestion(
//        image: "Old",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false
//    ),
//    QuizeQuestion(
//        image: "The Ice Age Adventures of Buck Wild",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false
//    ),
//    QuizeQuestion(
//        image: "Tesla",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false
//    ),
//    QuizeQuestion(
//        image: "Vivarium",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false
//    )
//    ]

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

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }

            let rating = Float(movie.rating) ?? 0

            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7

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
