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
    private let questionsArray: [QuizeQuestion] = [
    QuizeQuestion(
        imageName: "The Godfather",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizeQuestion(
        imageName: "The Dark Knight",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizeQuestion(
        imageName: "Kill Bill",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizeQuestion(
        imageName: "The Avengers",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizeQuestion(
        imageName: "Deadpool",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizeQuestion(
        imageName: "The Green Knight",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizeQuestion(
        imageName: "Old",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    QuizeQuestion(
        imageName: "The Ice Age Adventures of Buck Wild",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    QuizeQuestion(
        imageName: "Tesla",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    QuizeQuestion(
        imageName: "Vivarium",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    )
    ]

    // MARK: - Lifecycle
    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }

    // MARK: - Methods
    func requestNextQuestion() {
        let index = (0 ..< questionsArray.count).randomElement() ?? 0
        let question = questionsArray[safe: index]
        delegate.didReciveNextQuestion(question: question)
    }
}
