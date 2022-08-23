//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by 1234 on 22.08.2022.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReciveNextQuestion(question: QuizeQuestion?)
}