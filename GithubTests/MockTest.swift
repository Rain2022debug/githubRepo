//
//  MockTest.swift
//  GithubTests
//
//  Created by yuhe on 2022/10/9.
//

import XCTest
import Combine
@testable import Github

final class MockTest: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []

    override func setUpWithError() throws {
    }
    
    func testJustMockReturnCorrectData() throws{
        let expectation = expectation(description: #function)
        var mockValue: [Repository] = []
        SearchService.shared.searchRepositoryByJust("mock just")
            .sink { error in
                print("error:\(error)")
            } receiveValue: { repos in
                mockValue = repos
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
            wait(for: [expectation], timeout: 5)
        XCTAssertEqual(mockValue,
                       [Repository(id: 1, name: "mock repository", description: "mock description")])
    }
    
    func testFailMockReturnCorrectData() throws{
        let expectation = expectation(description: #function)
        var mockValue: String = ""
        SearchService.shared.searchRepositoryByFail("mock fail")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    mockValue = error.localizedDescription
                    expectation.fulfill()
                }}, receiveValue: { repos in
                    print(repos)
                })
            .store(in: &self.subscriptions)
            wait(for: [expectation], timeout: 5)
        XCTAssertEqual(mockValue,"网络请求异常")
    }
}

