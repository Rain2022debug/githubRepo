//
//  SearchRepositoryServiceTest.swift
//  GithubTests
//
//  Created by yuhe on 2022/10/9.
//

import XCTest
import Combine
@testable import Github

final class SearchServiceTest: XCTestCase {
    private var subscriptions: Set<AnyCancellable> = []

    override func setUpWithError() throws {
    }
    
    func testSearchRepositoryReturnData() throws{
        let expectation = expectation(description: #function)
        let searchText = "test"
        var res = [Repository]()
            SearchService.shared.searchRepository(searchText)
            .sink { error in
                print("error:\(error)")
            } receiveValue: { repos in
                res = repos
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
            wait(for: [expectation], timeout: 10)
        XCTAssert(!res.isEmpty)
    }
}
