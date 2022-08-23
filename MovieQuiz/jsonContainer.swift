//
//  jsonContainer.swift
//  MovieQuiz
//
//  Created by 1234 on 23.08.2022.
//

import Foundation

struct JsonContainer: Codable {
    let items: [Movie]
}
struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}
struct Movie: Codable {
    let id: String
//    let title: String
//    let year: String
//    let image: String
//    let releaseDate: String
//    let runtimeMins: String
//    let directors: String
//    let actorList: [Actor]
}
