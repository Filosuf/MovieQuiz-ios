import UIKit
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)

    func showCorrectAnswer(response: Bool)
    func buttonsEnable(_ state: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
}


final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Properties
    private lazy var presenter = MovieQuizPresenter(viewController: self)
    private lazy var alertPresenter = AlertPresenter(viewController: self)
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
        presenter.startGame()
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

    func show(quiz step: QuizStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        counterLabel.text = step.questionNumber
        posterImage.image = step.image
        questionLabel.text = step.question
        posterImage.layer.borderWidth = 0
    }

    func show(quiz result: QuizResultsViewModel) {
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
            self?.presenter.restartGame()
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
            self?.presenter.startGame()
            // Запуск индикатора загрузки
            self?.showLoadingIndicator()
            self?.overlayForAlertView.removeFromSuperview()
        }
    }
}
