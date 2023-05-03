
import Foundation

struct RedditPost: Codable, Identifiable {
    let id: String
    let title: String
    let author: String
    let created_utc: TimeInterval
    let preview: RedditPreview?

    func dateString() -> String {
        let date = Date(timeIntervalSince1970: created_utc)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct RedditImageSource : Codable {
    let url: String
    let width: Int
    let height: Int
}

struct RedditImage : Codable, Identifiable {
    var id: String {
        get { source.url }
    }
    let source: RedditImageSource
    let resolutions: [RedditImageSource]
}

struct RedditPreview : Codable {
    let images: [RedditImage]
}

struct RedditListingData: Codable {
    let data: RedditListing
}

struct RedditUserData: Codable {
    let data: RedditUser
}

struct RedditListing: Codable {
    let children: [RedditChild]
    let after: String?
}

struct RedditChild: Codable {
    let data: RedditPost
}

struct RedditUser: Codable {
    let icon_img: String
}

func fetchAuthorAvatarURL(username: String, completion: @escaping (String?) -> Void) {
    let url = URL(string: "https://www.reddit.com/user/\(username)/about/.json")!

    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data {
            let jsonDecoder = JSONDecoder()

            do {
                let decodedData = try jsonDecoder.decode(RedditUserData.self, from: data)
                let avatarURL = decodedData.data.icon_img
                completion(avatarURL)
            } catch {
                print("Error decoding data: \(error)")
            }
        } else if let error = error {
            print("Error fetching data: \(error)")
        }
    }

    task.resume()
}
