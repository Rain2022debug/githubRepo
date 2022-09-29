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
//            if !viewModel.errorMessage.isEmpty {
//                Text(viewModel.errorMessage)
//                    .foregroundColor(.red)
//            }
            List(viewModel.repositories) {
                Text("名称:\($0.name)\n描述:\($0.description ?? "")")
            }
            
//            List(viewModel.currentValueSubjectRepository.value) {
//                Text("名称:\($0.name)\n描述:\($0.description ?? "")")
//            }
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
            print("init")
            $searchText
                .filter{ !$0.lowercased().contains("s") }
                .flatMap({SearchService.shared.searchRepository($0)})
                .debounce(for: 1, scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink { error in
                    print(error)
                } receiveValue: { repos in
                    self.repositories = repos
                    print("repo")
                    print(self.repositories)
                }
                .store(in: &self.subscriptions)
            
//            testFailMock()
//            testJustMock()
            
//            currentValueSubjectRepository
//                .sink {[weak self] data in
//                    self?.repositories.removeAll()
//                    self?.repositories.append(contentsOf: data)
//            }.store(in: &subscriptions)
//
//            passthroughSubjectRepository
//                .eraseToAnyPublisher()
//                .sink {[weak self] data in
//                    self?.repositories.removeAll()
//                    self?.repositories.append(contentsOf: data)
//            }.store(in: &subscriptions)
//
//            $searchText
//                .flatMap({SearchService.shared.searchRepository($0)})
//                .debounce(for: 1, scheduler: DispatchQueue.main)
//                .receive(on: DispatchQueue.main)
//                .sink { error in
//                    print(error)
//                } receiveValue: { repos in
//                    self.currentValueSubjectRepository.value = repos
//                    self.passthroughSubjectRepository.send(repos)
//                }
//                .store(in: &self.subscriptions)
            
//                testMap()

        }
        
//        func testMap(){
//            var res = $searchText
//                            .map({SearchService.shared.searchRepository($0)})
//                            .flatMap { $0 }
//                            .receive(on: DispatchQueue.main)
//                            .sink { error in
//                                print(error)
//                            } receiveValue: { repoPublisher in
//                                self.repositories = repoPublisher
//                            }
//            print(res)
//        }

        func testFailMock(){
//            SearchService.shared.searchRepositoryByFail("mock fail")
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { completion in
//                    switch completion {
//                    case .finished: break
//                    case .failure(let error):
//                        // handle the error
//                    }, receiveValue: { response in
//                        // handle the response
//                    })
//                    .store(in: &self.subscriptions)
//                }
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
