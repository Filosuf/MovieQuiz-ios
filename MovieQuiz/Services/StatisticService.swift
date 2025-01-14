//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by 1234 on 23.08.2022.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private(set) var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    private(set) var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }


    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        let newAccuracy = Double(count) / Double(amount)
        totalAccuracy = (totalAccuracy * Double((gamesCount - 1)) + newAccuracy) / Double(gamesCount)
        if isRecord(correct: count) {
            bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
    }

    private func isRecord(correct answer: Int) -> Bool {
        answer > bestGame.correct
    }

    private enum Keys: String {
        case correct, totalAccuracy, bestGame, gamesCount
    }
}
