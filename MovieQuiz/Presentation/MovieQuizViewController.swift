import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private lazy var presenter = MovieQuizPresenter(viewController: self)
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let statisticService: StatisticService = StatisticServiceImplementation()
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
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    @IBAction private func yesTapped() {
        presenter.handleAnswer(response: true)
    }

    @IBAction private func noTapped() {
        presenter.handleAnswer(response: false)
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

    func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let isBestGame = presenter.currentCorrectAnswer > statisticService.bestGame.correct
            // запись результатов в память
            statisticService.store(correct: presenter.currentCorrectAnswer, total: presenter.questionsAmount)
            // показать результат квиза
            let resultQuize = getResultQuize(isBestGame: isBestGame)
            show(quize: resultQuize)
        } else {
            presenter.switchToNextQuestion() // увеличиваем индекс текущего вопроса на 1
            // запросить следующий вопрос
            presenter.requestNextQuestion()
            activityIndicator.startAnimating()
        }
    }

    private func startGame() {
        buttonsEnable(false)
        presenter.resetCurrentCorrectAnswer()
        presenter.resetQuestionIndex()
        // Загрузка данных о фильмах из интернета
        presenter.loadData()
        // Запуск индикатора загрузки
        showLoadingIndicator()
    }

    private func restartGame() {
        presenter.resetCurrentCorrectAnswer()
        presenter.resetQuestionIndex()
        // запросить следующий вопрос
        presenter.requestNextQuestion()
    }

    func show(quize step: QuizeStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        counterLabel.text = step.questionNumber
        posterImage.image = step.image
        questionLabel.text = step.question
        posterImage.layer.borderWidth = 0
    }

    func show(quize result: QuizeResultsViewModel) {
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

    func showCorrectAnswer(response: Bool) {
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

        if presenter.currentCorrectAnswer == presenter.questionsAmount {
            alertTitle = "Поздравляем. Лучший результат!"
        }
        let bestGame = statisticService.bestGame
        let resultQuize = QuizeResultsViewModel(
            title: alertTitle,
            text: """
            Ваш результат:\(presenter.currentCorrectAnswer)/\(presenter.questionsAmount)
            Количество сыграных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
            Средняя точность: \(String(format: "%.02f", statisticService.totalAccuracy * 100))%
            """,
            buttonText: "Начать новую игру"
        )
        return resultQuize
    }

    func buttonsEnable(_ state: Bool) {
        for button in self.buttons {
            button.isEnabled = state
        }
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки

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
            self?.presenter.loadData()
            // Запуск индикатора загрузки
            self?.showLoadingIndicator()
            self?.overlayForAlertView.removeFromSuperview()
        }
    }
}
