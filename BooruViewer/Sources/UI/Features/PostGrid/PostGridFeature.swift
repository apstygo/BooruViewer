import ComposableArchitecture

struct PostGridFeature: ReducerProtocol {

    struct State: Equatable {
        var posts: IdentifiedArrayOf<Post> = []
        var feedPhase: FeedPhase = .idle
    }

    enum Action: Equatable {
        case postAppeared(Post)
        case openPost(Post)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        .none
    }

}
