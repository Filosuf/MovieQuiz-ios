//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by 1234 on 20.08.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Properties
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
    )]

    func requestNextQuestion() -> QuizeQuestion? {
        let index = (0 ..< questionsArray.count).randomElement() ?? 0
        return questionsArray[safe: index]
    }
}
