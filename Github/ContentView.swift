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
        
        private var subscriptions: Set<AnyCancellable> = []
        
        init() {
//            $searchText
//                .flatMap({SearchService.shared.searchRepository($0)})
//                .debounce(for: 1, scheduler: DispatchQueue.main)
//                .receive(on: DispatchQueue.main)
//                .sink { error in
//                    print(error)
//                } receiveValue: { repos in
//                    self.repositories = repos
//                }
//                .store(in: &self.subscriptions)
            
//            testFailMock()
            testJustMock()

        }
        
        func testFailMock(){
            SearchService.shared.searchRepositoryByFail("mock fail")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        print(error)
                    }}, receiveValue: { repos in
                        self.repositories = repos
                    }
                )
                .store(in: &self.subscriptions)
        }
        
        func testJustMock(){
            SearchService.shared.searchRepositoryByJust("mock just")
                .receive(on: DispatchQueue.main)
                .sink { error in
                    print("error:\(error)")
                } receiveValue: { repos in
                    self.repositories = repos
                }
                .store(in: &self.subscriptions)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
