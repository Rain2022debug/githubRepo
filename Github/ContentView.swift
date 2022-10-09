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
            currentValueSubjectRepository
                .sink {[weak self] data in
                    self?.repositories.removeAll()
                    self?.repositories.append(contentsOf: data)
            }.store(in: &subscriptions)
            
            passthroughSubjectRepository
                .eraseToAnyPublisher()
                .sink {[weak self] data in
                    self?.repositories.removeAll()
                    self?.repositories.append(contentsOf: data)
            }.store(in: &subscriptions)
            
            $searchText
                .debounce(for: 1, scheduler: DispatchQueue.main)
                .flatMap({SearchService.shared.searchRepository($0)})
                .receive(on: DispatchQueue.main)
                .sink { error in
                    print(error)
                } receiveValue: { repos in
                    self.currentValueSubjectRepository.value = repos
//                    self.passthroughSubjectRepository.send(repos)
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
