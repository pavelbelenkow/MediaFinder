import UIKit

final class MediaListSearchViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel: any MediaListSearchViewModelProtocol
    
    // MARK: - Initialisers
    
    init(viewModel: any MediaListSearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
}

// MARK: - Setup Navigation Bar

private extension MediaListSearchViewController {
    
    func setupNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.standardAppearance.shadowColor = .clear
        navigationBar?.standardAppearance.backgroundColor = .mediaBackground
        
        setupTitle(for: navigationBar)
    }
    
    func setupTitle(for navigationBar: UINavigationBar?) {
        title = Const.navigationBarTitle
        navigationBar?.tintColor = .black
        navigationBar?.prefersLargeTitles = true
        navigationBar?.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar?.standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
}
