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
    private let statisticService: StatisticService = StatisticServiceImplementation()
    weak var viewController: MovieQuizViewControllerProtocol?
    var currentQuestion: QuizQuestion!
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private (set) var currentCorrectAnswer = 0
    private var numberOfCorruptedQuestions = 0

    // MARK: - Lifecycle
    init(viewController: MovieQuizViewControllerProtocol) {
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

    func startGame() {
        viewController?.buttonsEnable(false)
        resetCurrentCorrectAnswer()
        resetQuestionIndex()
        // Загрузка данных о фильмах из интернета
        questionFactory.loadData()
        // Запуск индикатора загрузки
        viewController?.showLoadingIndicator()
    }

    func restartGame() {
        resetCurrentCorrectAnswer()
        resetQuestionIndex()
        // запросить следующий вопрос
        questionFactory.requestNextQuestion()
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let notAvailableImage = UIImage(systemName: "exclamationmark.icloud.fill") ?? UIImage()
        let image = UIImage(data: model.image) ?? notAvailableImage
        return QuizStepViewModel(
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
            self.showNextQuestionOrResults()
        }
    }

    private func getResultQuize(isBestGame: Bool) -> QuizResultsViewModel {
        var alertTitle = "Этот раунд окончен!"
        if isBestGame {
            alertTitle = "Новый рекорд!"
        }
        if currentCorrectAnswer == questionsAmount {
            alertTitle = "Поздравляем. Лучший результат!"
        }
        let bestGame = statisticService.bestGame
        let resultQuize = QuizResultsViewModel(
            title: alertTitle,
            text: """
            Ваш результат:\(currentCorrectAnswer)/\(questionsAmount)
            Количество сыграных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
            Средняя точность: \(String(format: "%.02f", statisticService.totalAccuracy * 100))%
            """,
            buttonText: "Начать новую игру"
        )
        return resultQuize
    }

    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            let isBestGame = currentCorrectAnswer > statisticService.bestGame.correct
            // запись результатов в память
            statisticService.store(correct: currentCorrectAnswer, total: questionsAmount)
            // показать результат квиза
            let resultQuize = getResultQuize(isBestGame: isBestGame)
            viewController?.show(quiz: resultQuize)
        } else {
            switchToNextQuestion() // увеличиваем индекс текущего вопроса на 1
            // запросить следующий вопрос
            questionFactory.requestNextQuestion()
            viewController?.showLoadingIndicator()
        }
    }
}
    // MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        if let question = question {
            numberOfCorruptedQuestions = 0
            viewController?.buttonsEnable(true)
            viewController?.hideLoadingIndicator()
            currentQuestion = question
            let viewModel = convert(model: question)
            viewController?.show(quiz: viewModel)
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
