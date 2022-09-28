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
        
        private var subscriptions: Set<AnyCancellable> = []
        
        init() {
            $searchText
//                .removeDuplicates()
                .flatMap({SearchService.shared.searchRepository($0)})
//                .debounce(for: 1, scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink { error in
                    print(error)
                } receiveValue: { repos in
                    self.repositories = repos
                }
                .store(in: &self.subscriptions)

//            $searchText
//                .removeDuplicates()
//                .map {
//                    URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.github.com/search/repositories?q=\($0)")!)
//                        .map(\.data)
//                        .decode(type: SearchRepositories.self, decoder: JSONDecoder())
//                }
//                .flatMap {$0}
//                .map(\.items)
//                .compactMap {$0}
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { completion in
//                }, receiveValue: { value in
//                    self.repositories.removeAll()
//                    self.repositories.append(contentsOf: value)
//                })
//                .store(in: &self.subscriptions)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
