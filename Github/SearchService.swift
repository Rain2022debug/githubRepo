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
    
    func searchRepositoryByJust(_ name: String) -> AnyPublisher<[Repository], Error> {
        return Just([Repository(id: 1, name: "mock repository", description: "mock description")])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func searchRepositoryByFail(_ name: String) -> AnyPublisher<[Repository], Error> {
        return Fail(error:
                        NSError(domain: "com.test.ios", code: 400, userInfo: [NSLocalizedDescriptionKey : "网络请求异常"])
                    as Error)
            .eraseToAnyPublisher()
    }
    
    private func makeUrlString(_ name: String) -> String {
        return "\(githubURL)\(name)"
            .replacingOccurrences(of: " ", with: "")
    }
}


