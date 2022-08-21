import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizeQuestion!
    private var currentQuestionIndex = 0
    private let questionsAmount = 10
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
    // MARK: - Metods
    private func setupView() {
        for button in buttons {
            button.layer.cornerRadius = 15
        }
        posterImage.layer.cornerRadius = 20
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // показать результат квиза
            gameCount += 1
            allCorrectAnswer += currentCorrectAnswer
            let resultQuize = getResultQuize()
            show(quize: resultQuize)
        } else {
            currentQuestionIndex += 1 // увеличиваем индекс текущего вопроса на 1
            // показать следующий вопрос
            guard let nextQuestion = questionFactory.requestNextQuestion() else { return }
            show(quize: convert(model: nextQuestion))
            currentQuestion = nextQuestion
        }
    }

    private func startGame() {
        currentCorrectAnswer = 0
        currentQuestionIndex = 0
        guard let nextQuestion = questionFactory.requestNextQuestion() else { return }
        show(quize: convert(model: nextQuestion))
        currentQuestion = nextQuestion
    }

    private func show(quize step: QuizeStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        counterLabel.text = step.questionNumber
        posterImage.image = step.image
        questionLabel.text = step.question
        posterImage.layer.borderWidth = 0
    }

    private func show(quize result: QuizeResultsViewModel) {
        // здесь мы показываем результат прохождения квиза
        // создаём объекты всплывающего окна
        let alert = UIAlertController(
            title: result.title, // заголовок всплывающего окна
            message: result.text, // текст во всплывающем окне
            preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            // убираем затемнение фона
            UIView.animate(withDuration: 0.25) {
                self?.overlayForAlertView.alpha = 0
            }
            self?.overlayForAlertView.removeFromSuperview()
            self?.startGame()
        }

        // добавляем в алерт кнопки
        alert.addAction(action)

        // затемнение фона
        view.addSubview(overlayForAlertView)
        UIView.animate(withDuration: 0.25) {
            self.overlayForAlertView.alpha = UIColor.YPTheme.background.cgColor.alpha
        }
        // показываем всплывающее окно
        present(alert, animated: true, completion: nil)
    }

    private func convert(model: QuizeQuestion) -> QuizeStepViewModel {
        // swiftlint:disable force_unwrapping
        let notAvailableImage = UIImage(systemName: "exclamationmark.icloud.fill")!
        // swiftlint:enable force_unwrapping
        let image = UIImage(named: model.imageName) ?? notAvailableImage
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

    private func getResultQuize() -> QuizeResultsViewModel {
        var alertTitle = "Этот раунд окончен!"
        var recordDateString = ""
        if currentCorrectAnswer >= recordCorrectAnswer {
            alertTitle = "Новый рекорд!"
            recordCorrectAnswer = currentCorrectAnswer
            recordDateString = Date().dateTimeString
        }

        if currentCorrectAnswer == questionsAmount {
            alertTitle = "Поздравляем. Лучший результат!"
        }
        averageAccuracy = Double(allCorrectAnswer * 100) / Double(questionsAmount * gameCount)
        let resultQuize = QuizeResultsViewModel(
            title: alertTitle,
            text: """
            Ваш результат:\(currentCorrectAnswer)/\(questionsAmount)
            Количество сыграных квизов: \(gameCount)
            Рекорд: \(recordCorrectAnswer)/\(questionsAmount) \(recordDateString)
            Средняя точность: \(String(format: "%.02f", averageAccuracy))%
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
}
