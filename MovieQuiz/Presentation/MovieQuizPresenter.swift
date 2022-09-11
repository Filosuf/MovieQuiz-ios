//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by 1234 on 08.09.2022.
//

import UIKit

final class MovieQuizPresenter {
    // MARK: - Properties
    private let moviesLoader = MoviesLoader()
    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(
        moviesLoader: moviesLoader,
        delegate: self
    )
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizeQuestion!
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private (set) var currentCorrectAnswer = 0
    private var numberOfCorruptedQuestions = 0

    // MARK: - Lifecycle
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
    }

    // MARK: - Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func resetCurrentCorrectAnswer() {
        currentCorrectAnswer = 0
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

    func handleAnswer(response: Bool) {
        if response == currentQuestion.correctAnswer {
            currentCorrectAnswer += 1
            viewController?.showCorrectAnswer(response: true)
        } else {
            viewController?.showCorrectAnswer(response: false)
        }
        viewController?.buttonsEnable(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        // код, который вы хотите вызвать через 1 секунду,
        // в нашем случае это просто функция showNextQuestionOrResults()
            self.viewController?.showNextQuestionOrResults()
        }
    }

    // MARK: - DEBUG, QuestionFactory
    func loadData() {
        questionFactory.loadData()
    }

    func requestNextQuestion() {
        questionFactory.requestNextQuestion()
    }
}
    // MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizeQuestion?) {
        if let question = question {
            numberOfCorruptedQuestions = 0
            viewController?.buttonsEnable(true)
            viewController?.hideLoadingIndicator()
            currentQuestion = question
            let viewModel = convert(model: question)
            viewController?.show(quize: viewModel)
        } else {
            if numberOfCorruptedQuestions < 5 {
                print("Corruped Questions")
                numberOfCorruptedQuestions += 1
                questionFactory.requestNextQuestion()
            } else {
                viewController?.showNetworkError(message: "Данные повреждены или их не удалось загрузить")
            }
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator() // скрываем индикатор загрузки
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        // возьмём в качестве сообщения описание ошибки
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
