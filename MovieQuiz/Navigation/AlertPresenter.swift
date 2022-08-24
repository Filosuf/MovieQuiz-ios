//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by 1234 on 22.08.2022.
//

import Foundation
import UIKit

final class AlertPresenter {
    private let viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showResultAlert(result: QuizeResultsViewModel, action: @escaping () -> Void) {
        guard let viewController = viewController else { return }

        // создаём объекты всплывающего окна
        let alert = UIAlertController(
            title: result.title, // заголовок всплывающего окна
            message: result.text, // текст во всплывающем окне
            preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            action()
        }

        // добавляем в алерт кнопки
        alert.addAction(action)

        // показываем всплывающее окно
        viewController.present(alert, animated: true, completion: nil)
    }

    func showErrorAlert(message: String, action: @escaping () -> Void) {
        guard let viewController = viewController else { return }

        // создаём объекты всплывающего окна
        let alert = UIAlertController(
            title: "Что-то пошло не так(", // заголовок всплывающего окна
            message: message, // текст во всплывающем окне
            preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: "Попробовать еще раз", style: .default) { _ in
            action()
        }

        // добавляем в алерт кнопки
        alert.addAction(action)

        // показываем всплывающее окно
        viewController.present(alert, animated: true, completion: nil)
    }
}
