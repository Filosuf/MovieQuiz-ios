import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private let moviesLoader = MoviesLoader()
    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(
        moviesLoader: moviesLoader,
        delegate: self
    )
    private let presenter = MovieQuizPresenter()
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let statisticService: StatisticService = StatisticServiceImplementation()
    private var currentQuestion: QuizeQuestion!
//    private var currentQuestionIndex = 0
//    private let questionsAmount = 10
    private var currentCorrectAnswer = 0
    private var recordCorrectAnswer = 0
    private var allCorrectAnswer = 0
    private var gameCount = 0
    private var averageAccuracy = 0.0
    private var recordDate = Date()
    private var numberOfCorruptedQuestions = 0

    private lazy var overlayForAlertView: UIView = {
        let backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = .YPTheme.background
        backgroundView.alpha = 0
        return backgroundView
    }()

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    @IBAction private func yesTapped() {
        handleAnswer(response: true)
    }

    @IBAction private func noTapped() {
        handleAnswer(response: false)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        setupView()
        startGame()
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Methods
    private func setupView() {
        for button in buttons {
            button.layer.cornerRadius = 15
        }
        posterImage.layer.cornerRadius = 20
    }

    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let isBestGame = currentCorrectAnswer > statisticService.bestGame.correct
            // запись результатов в память
            statisticService.store(correct: currentCorrectAnswer, total: presenter.questionsAmount)
            // показать результат квиза
            let resultQuize = getResultQuize(isBestGame: isBestGame)
            show(quize: resultQuize)
        } else {
            presenter.switchToNextQuestion() // увеличиваем индекс текущего вопроса на 1
            // запросить следующий вопрос
            questionFactory.requestNextQuestion()
            activityIndicator.startAnimating()
        }
    }

    private func startGame() {
        buttonsEnable(false)
        currentCorrectAnswer = 0
        presenter.resetQuestionIndex()
        // Загрузка данных о фильмах из интернета
        questionFactory.loadData()
        // Запуск индикатора загрузки
        showLoadingIndicator()
    }

    private func restartGame() {
        currentCorrectAnswer = 0
        presenter.resetQuestionIndex()
        // запросить следующий вопрос
        questionFactory.requestNextQuestion()
    }
    private func show(quize step: QuizeStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        counterLabel.text = step.questionNumber
        posterImage.image = step.image
        questionLabel.text = step.question
        posterImage.layer.borderWidth = 0
    }

    private func show(quize result: QuizeResultsViewModel) {
        // затемнение фона
        view.addSubview(overlayForAlertView)
        UIView.animate(withDuration: 0.25) {
            self.overlayForAlertView.alpha = UIColor.YPTheme.background.cgColor.alpha
        }

        // здесь мы показываем результат прохождения квиза
        alertPresenter.showResultAlert(result: result) { [weak self] in
            // убираем затемнение фона
            UIView.animate(withDuration: 0.25) {
                self?.overlayForAlertView.alpha = 0
            }
            self?.overlayForAlertView.removeFromSuperview()
            self?.restartGame()
        }
    }

    private func handleAnswer(response: Bool) {
        if response == currentQuestion.correctAnswer {
            currentCorrectAnswer += 1
            showCorrectAnswer(response: true)
        } else {
            showCorrectAnswer(response: false)
        }
        buttonsEnable(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        // код, который вы хотите вызвать через 1 секунду,
        // в нашем случае это просто функция showNextQuestionOrResults()
            self.showNextQuestionOrResults()
        }
    }

    private func showCorrectAnswer(response: Bool) {
        posterImage.layer.borderWidth = 8
        if response {
            posterImage.layer.borderColor = UIColor.YPTheme.green.cgColor
        } else {
            posterImage.layer.borderColor = UIColor.YPTheme.red.cgColor
        }
    }

    private func getResultQuize(isBestGame: Bool) -> QuizeResultsViewModel {
        var alertTitle = "Этот раунд окончен!"
        if isBestGame {
            alertTitle = "Новый рекорд!"        }

        if currentCorrectAnswer == presenter.questionsAmount {
            alertTitle = "Поздравляем. Лучший результат!"
        }
        let bestGame = statisticService.bestGame
        let resultQuize = QuizeResultsViewModel(
            title: alertTitle,
            text: """
            Ваш результат:\(currentCorrectAnswer)/\(presenter.questionsAmount)
            Количество сыграных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
            Средняя точность: \(String(format: "%.02f", statisticService.totalAccuracy * 100))%
            """,
            buttonText: "Начать новую игру"
        )
        return resultQuize
    }

    private func buttonsEnable(_ state: Bool) {
        for button in self.buttons {
            button.isEnabled = state
        }
    }

    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }

    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true // скрываем индикатор загрузки

        // затемнение фона
        view.addSubview(overlayForAlertView)
        UIView.animate(withDuration: 0.25) {
            self.overlayForAlertView.alpha = UIColor.YPTheme.background.cgColor.alpha
        }

        // здесь мы показываем ошибку
        alertPresenter.showErrorAlert(message: message) { [weak self] in
            // убираем затемнение фона
            UIView.animate(withDuration: 0.25) {
                self?.overlayForAlertView.alpha = 0
            }
            // Загрузка данных о фильмах из интернета
            self?.questionFactory.loadData()
            // Запуск индикатора загрузки
            self?.showLoadingIndicator()
            self?.overlayForAlertView.removeFromSuperview()
        }
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizeQuestion?) {
        if let question = question {
            numberOfCorruptedQuestions = 0
            buttonsEnable(true)
            activityIndicator.stopAnimating()
            currentQuestion = question
            let viewModel = presenter.convert(model: question)
            show(quize: viewModel)
        } else {
            if numberOfCorruptedQuestions < 5 {
                print("Corruped Questions")
                numberOfCorruptedQuestions += 1
                questionFactory.requestNextQuestion()
            } else {
                showNetworkError(message: "Данные повреждены или их не удалось загрузить")
            }
        }
    }

    func didLoadDataFromServer() {
        activityIndicator.stopAnimating() // скрываем индикатор загрузки
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}
