//
//  SearchService.swift
//  Github
//
//  Created by yuhe on 2022/9/28.
//

import Foundation
import Combine

struct SearchRepositories: Decodable {
    let items: [Repository]?
}

struct Repository: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String?
}

class SearchService{
    static let shared = SearchService()
    let githubURL: String = "https://api.github.com/search/repositories?q="
    
    func searchRepository(_ name: String)-> AnyPublisher<[Repository],Error>{
        let publisher = URLSession.shared.dataTaskPublisher(for: URL(string: makeUrlString(name))!)
            .map{ $0.data }
            .decode(type: SearchRepositories.self, decoder: JSONDecoder())
            .map(\.items)
            .compactMap {$0}
            .eraseToAnyPublisher()
        return publisher
    }
    
    private func makeUrlString(_ name: String) -> String {
        return "\(githubURL)\(name)"
            .replacingOccurrences(of: " ", with: "")
    }
}


