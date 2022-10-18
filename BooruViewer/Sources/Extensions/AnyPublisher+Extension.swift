import Combine
import CombineExt

extension AnyPublisher where Failure == Error {

    init(operation: @escaping () async throws -> Output) {
        self.init { subscriber in
            var task = Task {
                do {
                    let output = try await operation()
                    subscriber.send(output)
                    subscriber.send(completion: .finished)
                }
                catch {
                    subscriber.send(completion: .failure(error))
                }
            }

            return AnyCancellable { task.cancel() }
        }
    }

}
