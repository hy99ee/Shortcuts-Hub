import Combine

extension AnyPublisher where Output: Mutation, Failure == Never {
    func withStatus(start: Output, finish: Output) -> Self {
        Publishers.Merge(
            Just(start),
            Publishers.Zip(
                Just(finish),
                self
            )
            .flatMap {
                Publishers.Sequence(sequence: [$0, $1])
            }
        ).eraseToAnyPublisher()
    }
}
