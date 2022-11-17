import Combine

extension AnyPublisher where Output: Mutation, Failure == Never {
    func withStatus(start: Output, finish: Output) -> Self {
        Publishers.Merge(
            Just(start),
            Publishers.Zip(self, Just(finish))
                .flatMap({ Publishers.Sequence(sequence: [$0, $1])
        })).eraseToAnyPublisher()
    }
}
