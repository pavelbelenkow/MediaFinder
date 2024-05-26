import Combine

// MARK: - Protocols

protocol DetailedDescriptionViewModelProtocol: ObservableObject {
    var detailedDescriptionSubject: CurrentValueSubject<DetailedDescription?, Never> { get }
    var cancellables: Set<AnyCancellable> { get set }
}

final class DetailedDescriptionViewModel: DetailedDescriptionViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var detailedDescriptionSubject = CurrentValueSubject<DetailedDescription?, Never>(nil)
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(model: DetailedDescription) {
        detailedDescriptionSubject.send(model)
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
