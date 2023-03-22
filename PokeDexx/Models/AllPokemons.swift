//
//  AllPokemons.swift
//  PokeDexx
//
//  Created by Talip on 22.03.2023.
//

import Foundation

struct AllPokemons: Codable {
    let count: Int
    let next: String
    let previous: JSONNull?
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let name: String
    let url: String
}
