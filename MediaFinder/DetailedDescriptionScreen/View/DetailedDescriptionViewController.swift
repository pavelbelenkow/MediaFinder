import UIKit

final class DetailedDescriptionViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var detailedDescriptionView: DetailedDescriptionView = {
        let view = DetailedDescriptionView()
        view.delegate = self
        return view
    }()
    
    private let viewModel: any DetailedDescriptionViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: any DetailedDescriptionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = detailedDescriptionView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        bindViewModel()
    }
}

// MARK: - Setup UI

private extension DetailedDescriptionViewController {
    
    func setupAppearance() {
        
        setupNavigationTitleColor()
    }
    
    func setupNavigationTitleColor(_ color: UIColor = .black) {
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: color
        ]
    }
    
    }
}

// MARK: - Private Methods

private extension DetailedDescriptionViewController {
    
    func bindViewModel() {
        
        viewModel.detailedDescriptionSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] description in
                guard let self, let description else { return }
                updateUI(with: description)
            }
            .store(in: &viewModel.cancellables)
    }
    
    func updateUI(with model: DetailedDescription) {
        title = model.mediaName
        view.backgroundColor = model.backgroundColor
        setupNavigationTitleColor(model.mediaTextColor)
        detailedDescriptionView.updateDescriptionLabel(
            with: model.attributedDescription,
            textColor: model.descriptionTextColor
        )
    }
}

// MARK: - UIScrollViewDelegate Methods

extension DetailedDescriptionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationController else { return }
        
        let offsetY = scrollView.contentOffset.y
        
        if offsetY > .zero && !navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(true, animated: true)
        } else if offsetY < .zero && navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }
}
