import UIKit

final class DetailedMediaViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var detailedMediaView: DetailedMediaView = {
        let view = DetailedMediaView()
        view.delegate = self
        return view
    }()
    
    private let viewModel: any DetailedMediaViewModelProtocol
    
    // MARK: - Initialisers
    
    init(viewModel: any DetailedMediaViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = detailedMediaView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
}

// MARK: - Private Methods

private extension DetailedMediaViewController {
    
    func bindViewModel() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.detailedMediaView.updateUI(for: state)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.errorMessageSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.detailedMediaView.updateStackView(with: message)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.mediaSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] media in
                self?.detailedMediaView.updateUI(for: media)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.artistSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artist in
                self?.detailedMediaView.updateUI(for: artist.first)
            }
            .store(in: &viewModel.cancellables)
    }
}

// MARK: - DetailedMediaViewDelegate Methods

extension DetailedMediaViewController: DetailedMediaViewDelegate {
    
    func didTapRepeatButton() {
        viewModel.fetchArtist()
    }
}
