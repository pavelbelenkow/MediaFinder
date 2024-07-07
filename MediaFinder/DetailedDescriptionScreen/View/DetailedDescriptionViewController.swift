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
        setupNavigationBar()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollAbility()
    }
}

// MARK: - Setup UI

private extension DetailedDescriptionViewController {
    
    func setupNavigationBar(
        with titleText: String? = nil,
        textColor: UIColor = .black,
        backgroundColor: UIColor = .white
    ) {
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.textColor = textColor
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.standardAppearance.shadowColor = .clear
            navigationBar.standardAppearance.backgroundColor = backgroundColor
        }
    }
    
    func updateScrollAbility() {
        let isFullHeight = view.frame.height >= UIScreen.main.bounds.height * 0.8
        detailedDescriptionView.isScrollEnabled = isFullHeight
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
        setupNavigationBar(
            with: model.mediaName,
            textColor: model.mediaTextColor,
            backgroundColor: model.backgroundColor
        )
        detailedDescriptionView.updateDescriptionLabel(
            with: model.attributedDescription,
            textColor: model.descriptionTextColor,
            backgroundColor: model.backgroundColor
        )
    }
}

// MARK: - UIScrollViewDelegate Methods

extension DetailedDescriptionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustNavigationBarVisibility(scrollOffsetY: scrollView.contentOffset.y)
    }
    
    private func adjustNavigationBarVisibility(scrollOffsetY: CGFloat) {
        guard let navigationController else { return }
        
        let shouldHideNavigationBar = scrollOffsetY > .zero
        navigationController.setNavigationBarHidden(shouldHideNavigationBar, animated: true)
    }
}
