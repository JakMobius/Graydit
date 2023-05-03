import SwiftUI

struct PostPreview: View {
    var post: RedditPost
    var showAvatar: Bool
    @StateObject private var avatarLoader: AuthorAvatarLoader

    init(post: RedditPost, showAvatar: Bool) {
        self.post = post
        self.showAvatar = showAvatar
        _avatarLoader = StateObject(wrappedValue: AuthorAvatarLoader(username: post.author))
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if showAvatar {
                    if let image = avatarLoader.image {
                        Image(uiImage: image)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                    } else {
                        RoundedRectangle(cornerRadius: 25)
                                .fill(Color(uiColor: .systemGray3))
                                .frame(width: 50, height: 50)
                    }
                }
                VStack {
                    Text(post.author)
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                    Text(post.dateString())
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Spacer()
            HStack {
                Text(post.title)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                if (post.preview?.images.count ?? 0) > 0 {
                    let urlString = post.preview!.images[0].resolutions[0].url.replacingOccurrences(of: "&amp;", with: "&")
                    if let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                    .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(uiColor: .systemGray3))
                                    .frame(width: 35, height: 35)
                        }
                                .frame(width: 35, height: 35)
                                .cornerRadius(3)
                    }
                }
            }
        }
                .padding()
    }
}