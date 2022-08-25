import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private let moviesLoader = MoviesLoader()
    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(
        moviesLoader: moviesLoader,
        delegate: self
    )
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let statisticService: StatisticService = StatisticServiceImplementation()
    private var currentQuestion: QuizeQuestion!
    private var currentQuestionIndex = 0
    private let questionsAmount = 3
    private var currentCorrectAnswer = 0
    private var recordCorrectAnswer = 0
    private var allCorrectAnswer = 0
    private var gameCount = 0
    private var averageAccuracy = 0.0
    private var recordDate = Date()

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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
        if currentQuestionIndex == questionsAmount - 1 {
            let isBestGame = currentCorrectAnswer > statisticService.bestGame.correct
            // запись результатов в память
            statisticService.store(correct: currentCorrectAnswer, total: questionsAmount)
            // показать результат квиза
            let resultQuize = getResultQuize(isBestGame: isBestGame)
            show(quize: resultQuize)
        } else {
            currentQuestionIndex += 1 // увеличиваем индекс текущего вопроса на 1
            // запросить следующий вопрос
            questionFactory.requestNextQuestion()
        }
    }

    private func startGame() {
        currentCorrectAnswer = 0
        currentQuestionIndex = 0
        // Загрузка данных о фильмах из интернета
        questionFactory.loadData()
        // Запуск индикатора загрузки
        showLoadingIndicator()
    }

    private func restartGame() {
        currentCorrectAnswer = 0
        currentQuestionIndex = 0
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

    private func convert(model: QuizeQuestion) -> QuizeStepViewModel {
        // swiftlint:disable force_unwrapping
        let notAvailableImage = UIImage(systemName: "exclamationmark.icloud.fill")!
        // swiftlint:enable force_unwrapping
        let image = UIImage(data: model.image) ?? notAvailableImage
        return QuizeStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
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
            self.buttonsEnable(true)
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

        if currentCorrectAnswer == questionsAmount {
            alertTitle = "Поздравляем. Лучший результат!"
        }
        let bestGame = statisticService.bestGame
        let resultQuize = QuizeResultsViewModel(
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

    private func buttonsEnable(_ state: Bool) {
        for button in self.buttons {
            button.isEnabled = state
        }
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
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
            self?.startGame()
            self?.overlayForAlertView.removeFromSuperview()
        }
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizeQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quize: viewModel)
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
