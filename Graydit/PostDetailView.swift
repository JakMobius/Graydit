import SwiftUI

struct PostDetailView: View {
    var post: RedditPost
    @StateObject private var avatarLoader: AuthorAvatarLoader

    init(post: RedditPost) {
        self.post = post
        _avatarLoader = StateObject(wrappedValue: AuthorAvatarLoader(username: post.author))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    if let image = avatarLoader.image {
                        Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                    } else {
                        RoundedRectangle(cornerRadius: 50)
                                .fill(Color(uiColor: .systemGray3))
                                .frame(width: 100, height: 100)
                    }
                    VStack {
                        Text(post.author)
                                .font(.largeTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        Text(post.dateString())
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Text(post.title).font(.body)
                ForEach(post.preview?.images ?? []) { image in
                    let source = image.source
                    let urlString = source.url.replacingOccurrences(of: "&amp;", with: "&")
                    if let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(10)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: .systemGray3))
                                    .aspectRatio(CGFloat(source.width) / CGFloat(source.height), contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                        }
                    }
                }
                Spacer()
            }
                    .padding()
        }
    }
}
