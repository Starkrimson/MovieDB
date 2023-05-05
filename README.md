# MovieDB

![](https://img.shields.io/badge/platform-macOS%2013.0%2B-red?logo=apple&style=flat)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Starkrimson/moviedb?display_name=tag&style=flat)](https://github.com/Starkrimson/MovieDB/releases)

探索海量电影、剧集和人物!

![preview](./preview.png)

在 [Releases](https://github.com/Starkrimson/MovieDB/releases) 页面下载。 

### 数据来源

[<img alt="TMDB" src="https://www.themoviedb.org/assets/2/v4/logos/v2/blue_short-8e7b30f73a4020692ccca9c88bafe5dcb6f8a62a4c6bc55cd9ba82bb2cd95f6c.svg" width="120"/>](https://www.themoviedb.org) [themoviedb.org](https://www.themoviedb.org)

### [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) 可组装架构

> [TCA 中文 readme](https://gist.github.com/sh3l6orrr/10c8f7c634a892a9c37214f3211242ad)

* State：即状态，是一个用于描述某个功能的执行逻辑，和渲染界面所需的数据的类。

```swift
struct SearchReducer: ReducerProtocol {
    struct State: Equatable {
        @BindableState var searchQuery = ""
        var list: [Find.City] = []
    }
}
```

* Action：一个代表在功能中所有可能的动作的类，如用户的行为、提醒，和事件源等。

```swift
struct SearchReducer: ReducerProtocol {
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<SearchState>)
        case search(query: String)
        case citiesResponse(Result<[Find.City], AppError>)
    }
}
```

* Environment：一个包含功能的依赖的类，如API客户端，分析客户端等。

```swift
// SearchReducer ...

@Dependency(\.weatherClient) var weatherClient

// ...
```

* Reducer：一个用于描述触发「Action」时，如何从当前状态（state）变化到下一个状态的函数，它同时负责返回任何需要被执行的「Effect」，如API请求（通过返回一个「Effect」实例来完成）。

```swift
struct SearchReducer: ReducerProtocol {
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(let action):
                if action.keyPath == \.$searchQuery, state.searchQuery.count == 0 {
                    state.status = .normal
                    state.list = []
                }
                return .none
                
            case .search(let query):
                struct SearchCityId: Hashable { }
                
                guard state.status != .loading else { return .none }
                state.status = .loading
                return .task {
                    await .citiesResponse(TaskResult<[Find.City]> {
                        try await weatherClient.searchCity(query)
                    })
                }
                
            case .citiesResponse(let result):
                switch result {
                case .success(let list):
                    state.status = list.count > 0 ? .normal : .noResult
                    state.list = list
                case .failure(let error):
                    state.status = .failed(error.localizedDescription)
                    state.list = []
                }
                return .none
            }
        }
    }
}
```

* Store：用于驱动某个功能的运行时（runtime）。将所有用户行为发送到「Store」中，令它运行「Reducer」和「Effects」。同时从「Store」中观测「State」，以更新UI。

```swift
SearchView(
    store: .init(
        initialState: .init(),
        reducer: WeatherReducer()
    )
)
```

```swift
struct SearchView: View {
    let store: StoreOf<WeatherReducer>
    
    var body: some View {
        WithViewStore(searchStore) { viewStore in
            List(viewStore.list) { item in
                Cell(...)
            }
            .searchable(text: viewStore.binding(\.$searchQuery))
            .onSubmit(of: .search) {
                viewStore.send(.search(query: viewStore.searchQuery))
            }
        }
    }
}
```

### 网络请求

```swift
struct WeatherClient {
    var searchCity: @Sendable (String) async throws -> [Find.City]
}

extension WeatherClient {
    static let live = WeatherClient(
        searchCity: { query in
            guard let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://openweathermap.org/data/2.5/find?q=\(q)&appid=\(appid)&units=metric")
                else {
                throw AppError.badURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(Find.self, from: data).list
        }
    )
```
