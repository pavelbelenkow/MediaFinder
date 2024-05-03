import UIKit
import Combine

final class ImageLoader {
    
    // MARK: - Static Properties
    
    static let shared = ImageLoader()
    
    // MARK: - Private Properties
    
    private let placeholder = UIImage(systemName: Const.imagePlaceholder)
    private let cache = NSCache<NSString, UIImage>()
    private var cancellables: [String: AnyCancellable] = [:]
    
    private let networkClient: NetworkClient
    
    // MARK: - Private Initialisers
    
    private init(networkClient: NetworkClient = URLSession.shared) {
        self.networkClient = networkClient
    }
    
    // MARK: - Methods
    
    func loadImage(
        from urlString: String,
        completion: @escaping (UIImage?) -> Void
    ) {
        
        if let cachedImage = cache.object(forKey: NSString(string: urlString)) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let request = URLRequest(url: url)
        
        let cancellable = networkClient.publisher(request: request)
            .map { data, _ in UIImage(data: data) }
            .replaceError(with: placeholder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                
                guard let self else { return }
                
                if let image, image != placeholder {
                    cache.setObject(image, forKey: NSString(string: urlString))
                }
                
                completion(image)
            }
        
        cancellables[urlString] = cancellable
    }
    
    func cancelLoading(for urlString: String) {
        cancellables[urlString]?.cancel()
        cancellables.removeValue(forKey: urlString)
    }
}
