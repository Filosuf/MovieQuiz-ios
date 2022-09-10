//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by 1234 on 08.09.2022.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizeQuestion) -> QuizeStepViewModel {
        let notAvailableImage = UIImage(systemName: "exclamationmark.icloud.fill") ?? UIImage()
        let image = UIImage(data: model.image) ?? notAvailableImage
        return QuizeStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
