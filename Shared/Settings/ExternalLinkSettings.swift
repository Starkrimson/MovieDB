//
//  ExternalLinkSettings.swift
//  MovieDB
//
//  Created by allie on 27/4/2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct ExternalLinkReducer: ReducerProtocol {

    struct State: Equatable {
        var list: IdentifiedArrayOf<ExternalLink> = []

        @BindingState var newName: String = ""
        @BindingState var isNameValid: Bool = true
        @BindingState var newURL: String = ""
        @BindingState var isURLValid: Bool = true
    }

    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
        case fetchExternalLinkList
        case fetchExternalLinkListDone(TaskResult<[ExternalLink]>)
        case saveURL
        case saveURLDone(TaskResult<ExternalLink?>)
        case deleteLink(ExternalLink)
        case deleteLinkDone(TaskResult<ExternalLink?>)
    }

    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(let action):
                if action.keyPath == \.$newName {
                    state.isNameValid = true
                }
                if action.keyPath == \.$newURL {
                    state.isURLValid = true
                }
                return .none

            case .fetchExternalLinkList:
                return .task {
                    await .fetchExternalLinkListDone(TaskResult<[ExternalLink]> {
                        try persistenceClient.externalLinks()
                    })
                }

            case .fetchExternalLinkListDone(.success(let links)):
                state.list = .init(uniqueElements: links)
                return .none

            case .fetchExternalLinkListDone(.failure(let error)):
                customDump(error)
                return .none

            case .saveURL:
                guard !state.newName.isEmpty else {
                    state.isNameValid = false
                    return .none
                }
                var url = state.newURL.lowercased()
                guard url.count > 2, url.contains("*") else {
                    state.isURLValid = false
                    return .none
                }
                if !url.hasPrefix("http") {
                    url = "https://\(url)"
                }
                return .task { [url, name = state.newName] in
                    await .saveURLDone(TaskResult<ExternalLink?> {
                        try persistenceClient.addItemToDatabase(.externalLink(name: name, url: url)) as? ExternalLink
                    })
                }

            case .saveURLDone(.success(let link)):
                state.newName = ""
                state.isNameValid = true
                state.newURL = ""
                state.isURLValid = true
                if let link {
                    state.list.append(link)
                }
                return .none

            case .saveURLDone(.failure(let error)):
                customDump(error)
                return .none

            case .deleteLink(let link):
                return .task {
                    await .deleteLinkDone(TaskResult<ExternalLink?> {
                        try persistenceClient.deleteFromDatabase(link) as? ExternalLink
                    })
                }

            case .deleteLinkDone:
                return .task {
                    .fetchExternalLinkList
                }
            }
        }
    }
}

struct ExternalLinkSettingView: View {
    let store: StoreOf<ExternalLinkReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            VStack {
                Form {
                    Section("DEFAULT".localized) {
                        ForEach([
                            ("HOMEPAGE".localized, "https://homepage.com"),
                            ("TMDB", "https://www.themoviedb.org/**/*"),
                            ("IMDb", "https://www.imdb.com/**/*"),
                            ("Facebook", "https://www.facebook.com/*"),
                            ("Twitter", "https://twitter.com/*"),
                            ("Instagram", "https://instagram.com/*")
                        ], id: \.0) { (name, url) in
                            HStack {
                                Text(name)
                                Spacer()
                                Text(url)
                            }
                        }
                    }

                    if !viewStore.list.isEmpty {
                        Section("CUSTOM".localized) {
                            ForEach(viewStore.list) { link in
                                HStack {
                                    Text(link.name ?? "")
                                    Spacer()
                                    Text(link.url ?? "")
                                    Button(role: .destructive) {
                                        viewStore.send(.deleteLink(link))
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    Section {
                        TextField(text: viewStore.binding(\.$newName), prompt: Text("Name")) {
                            HStack {
                                Text("Name")
                                if !viewStore.isNameValid {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        TextField(text: viewStore.binding(\.$newURL), prompt: Text("https://example.com/*")) {
                            HStack {
                                Text("URL")
                                if !viewStore.isURLValid {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        HStack {
                            Spacer()
                            Button("Save") {
                                viewStore.send(.saveURL)
                            }
                        }
                    } header: {
                        Text("ADD NEW ITEM".localized)
                    } footer: {
                        Text("* REPRESENTS MEDIA NAME".localized)
                    }
                }
                .formStyle(.grouped)
            }
            .task {
                viewStore.send(.fetchExternalLinkList)
            }
            .tabItem {
                Label("VISIT".localized, systemImage: "link")
            }
        }
    }
}

struct ExternalLinkSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalLinkSettingView(store: .init(
            initialState: .init(),
            reducer: ExternalLinkReducer()
        ))
    }
}
