import UIKit

final class DetailedMediaViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var detailedMediaView: DetailedMediaView = {
        let view = DetailedMediaView()
        view.interactionDelegate = self
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
        setupNavigationBar()
        bindViewModel()
    }
}

// MARK: - Private Methods

private extension DetailedMediaViewController {
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func bindViewModel() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.detailedMediaView.updateUI(for: state)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.mediaSubject
            .zip(viewModel.artistSubject, viewModel.artistCollectionSubject)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] media, artist, collection in
                
                self?.detailedMediaView.updateUI(
                    for: media,
                    artist: artist.first,
                    collection: collection
                )
            }
            .store(in: &viewModel.cancellables)
    }
}

// MARK: - UIViewControllerTransitioningDelegate Methods

extension DetailedMediaViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        SheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SheetDismissAnimationController()
    }
}

// MARK: - DetailedMediaViewDelegate Methods

extension DetailedMediaViewController: DetailedMediaViewDelegate {
    
    func didTapMoreButton(_ model: DetailedDescription) {
        let viewModel = DetailedDescriptionViewModel(model: model)
        let viewController = DetailedDescriptionViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self
        present(navigationController, animated: true)
    }
    
    func didTapArtistCollectionItem(at index: Int) {
        guard
            let urlString = viewModel.artistCollectionSubject.value[index].collectionView,
            let url = URL(string: urlString)
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    func didTapRepeatButton() {
        viewModel.fetchData()
    }
}
