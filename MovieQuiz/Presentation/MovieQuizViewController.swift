import UIKit

struct QuizeQuestion {
    // MARK: - Properties
    let image: String
    let text: String
    let correctAnswer: Bool

    // MARK: - Metods
    static func makeQuizeQuestion() -> [QuizeQuestion] {
        var quizeQuestionArray: [QuizeQuestion] = []
        quizeQuestionArray.append(QuizeQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ))
        quizeQuestionArray.append(QuizeQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ))
        return quizeQuestionArray
    }
}

// для состояния "Вопрос задан"
struct QuizeStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// для состояния "Результат квиза"
struct QuizeResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private var questions = QuizeQuestion.makeQuizeQuestion()
    private var currentQuestionIndex = 0
    private let numberOfQuestionsInGame = 2
    private var currentCorrectAnswer = 0
    private var recordCorrectAnswer = 0
    private var allCorrectAnswer = 0
    private var gameCount = 0
    private var averageAccuracy = 0.0
    private var recordDate = Date()
    private lazy var backgroundView: UIView = {
        let backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = .YPTheme.background
        backgroundView.alpha = 0
        return backgroundView
    }()

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var buttons: [UIButton]!

    @IBAction private func yesTapped() {
        buttonTapped(response: true)
    }

    @IBAction private func noTapped() {
        buttonTapped(response: false)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        setupView()
        startGame()
        super.viewDidLoad()
    }

    // MARK: - Metods
    private func setupView() {
        for button in buttons {
            button.layer.cornerRadius = 15
        }
        posterImage.layer.cornerRadius = 20
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == numberOfQuestionsInGame - 1 {
            // показать результат квиза
            gameCount += 1
            allCorrectAnswer += currentCorrectAnswer
            var alertTitle = "Этот раунд окончен!"
            if currentCorrectAnswer >= recordCorrectAnswer {
                alertTitle = "Новый рекорд!"
                recordCorrectAnswer = currentCorrectAnswer
                recordDate = Date()
            }

            if currentCorrectAnswer == numberOfQuestionsInGame {
                alertTitle = "Поздравляем. Лучший результат!"
            }
            let recordDateString = dateToString(date: recordDate)
            averageAccuracy = Double(allCorrectAnswer * 100) / Double(numberOfQuestionsInGame * gameCount)
            let resultTemp = QuizeResultsViewModel(
                title: alertTitle,
                text: """
                Ваш результат:\(currentCorrectAnswer)/\(numberOfQuestionsInGame)
                Количество сыграных квизов: \(gameCount)
                Рекорд: \(recordCorrectAnswer)/\(numberOfQuestionsInGame) \(recordDateString)
                Средняя точность: \(String(format: "%.02f", averageAccuracy))%
                """,
                buttonText: "Начать новую игру"
            )
            show(quize: resultTemp)
        } else {
            currentQuestionIndex += 1 // увеличиваем индекс текущего вопроса на 1
            // показать следующий вопрос
            show(quize: convert(model: questions[currentQuestionIndex]))
        }
    }

    private func startGame() {
        currentCorrectAnswer = 0
        currentQuestionIndex = 0
        questions.shuffle()
        show(quize: convert(model: questions[currentQuestionIndex]))
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
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            // убираем затемнение фона
            UIView.animate(withDuration: 0.25) {
                self.backgroundView.alpha = 0
            }
            self.backgroundView.removeFromSuperview()
            self.startGame()
        }

        // добавляем в алерт кнопки
        alert.addAction(action)

        // затемнение фона
        view.addSubview(backgroundView)
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = UIColor.YPTheme.background.cgColor.alpha
        }
        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }

    private func convert(model: QuizeQuestion) -> QuizeStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage(systemName: "exclamationmark.icloud.fill")!
        return QuizeStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(numberOfQuestionsInGame)"
        )
    }

    private func buttonTapped(response: Bool) {
        if response == questions[currentQuestionIndex].correctAnswer {
            currentCorrectAnswer += 1
            showCorrectAnswer(response: true)
        } else {
            showCorrectAnswer(response: false)
        }
        for button in buttons {
            button.isEnabled = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        // код, который вы хотите вызвать через 1 секунду,
        // в нашем случае это просто функция showNextQuestionOrResults()
            for button in self.buttons {
                button.isEnabled = true
            }
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

    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YY HH:mm"
        return formatter.string(from: date)
    }
}
