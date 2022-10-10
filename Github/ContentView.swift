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
            TextField("搜索", text: $viewModel.anotherSearchText)
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
        @Published var anotherSearchText: String = ""
        var currentValueSubjectRepository: CurrentValueSubject<[Repository], Never> = .init([])
        let passthroughSubjectRepository: PassthroughSubject<[Repository], Never> = .init()
        private var subscriptions: Set<AnyCancellable> = []
        
        
        init() {
            testMerge()
//            testZip()
        }
        
        func testMerge() {
            var searchText1 = $searchText.removeDuplicates()
                .debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
            var searchText2 = $anotherSearchText.removeDuplicates().debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
            let merge = Publishers.Merge(searchText1, searchText2)
            merge
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .flatMap {SearchService.shared.searchRepository($0)}
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: {[weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                }, receiveValue: {[weak self] value in
                    self?.repositories.append(contentsOf: value)
                })
                .store(in: &self.subscriptions)
        }
        
        func testZip() {
            var searchText1 = $searchText.removeDuplicates()
                .debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
            var searchText2 = $anotherSearchText.removeDuplicates().debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
            let merge = Publishers.Zip(searchText1, searchText2)
            merge
                .filter({ (first, second) in
                    return !first.isEmpty && !second.isEmpty
                })
                .flatMap { SearchService.shared.searchRepository($0, with: $1) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: {[weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                }, receiveValue: {[weak self] value in
                    self?.repositories.append(contentsOf: value)
                })
                .store(in: &self.subscriptions)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
