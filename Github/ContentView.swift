//
//  ContentView.swift
//  Github
//
//  Created by Jian on 2022/2/15.
//

import SwiftUI
import Combine


struct ContentView: View {
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        VStack {
            TextField("搜索", text: $viewModel.searchText)
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
            List(viewModel.repositories) {
                Text("名称:\($0.name)\n描述:\($0.description ?? "")")
            }
        }
    }
}

extension ContentView {
    @MainActor final class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var repositories: [Repository] = []
        @Published var errorMessage: String = ""
        var currentValueSubjectRepository: CurrentValueSubject<[Repository], Never> = .init([])
        let passthroughSubjectRepository: PassthroughSubject<[Repository], Never> = .init()
        private var subscriptions: Set<AnyCancellable> = []
        
        init() {
//            testReplaceError()
            testFailCatch()
        }
        
        func testReplaceError(){
            SearchService.shared.searchRepositoryByRelaceError("mock replace")
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { print ("\($0)") },
                        receiveValue: { repos in
                            self.repositories = repos
                        }
                    )
                    .store(in: &self.subscriptions)
        }
        
        func testFailCatch(){
            SearchService.shared.searchRepositoryByFirstFailed("swift")
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { print ("\($0)") },
                    receiveValue: { repos in
                        self.repositories = repos
                    }
                )
                .store(in: &self.subscriptions)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
