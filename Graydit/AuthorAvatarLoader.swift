
import SwiftUI
import Combine

class AuthorAvatarLoader: ObservableObject {
    @Published var image: UIImage?

    private var username: String
    private var cancellable: AnyCancellable?

    static var cache = NSCache<NSString, UIImage>()

    init(username: String) {
        self.username = username
        loadAvatar()
    }

    private func loadAvatar() {
        if let cachedImage = AuthorAvatarLoader.cache.object(forKey: self.username as NSString) {
            image = cachedImage
            return
        }

        cancellable = Just(username)
                .flatMap { username -> AnyPublisher<UIImage?, Never> in
                    Future { promise in
                        fetchAuthorAvatarURL(username: username) { avatarURLString in
                            if let avatarURLString = avatarURLString,
                               let avatarURL = URL(string: avatarURLString),
                               let imageData = try? Data(contentsOf: avatarURL),
                               let image = UIImage(data: imageData) {
                                AuthorAvatarLoader.cache.setObject(image, forKey: username as NSString)
                                promise(.success(image))
                            } else {
                                promise(.success(nil))
                            }
                        }
                    }.eraseToAnyPublisher()
                }.receive(on: DispatchQueue.main).assign(to: \.image, on: self)
    }
}