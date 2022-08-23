//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by 1234 on 22.08.2022.
//

import Foundation
import UIKit

final class ResultAlertPresenter {
    private let viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showAlert(result: QuizeResultsViewModel, action: @escaping () -> Void) {
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
}
