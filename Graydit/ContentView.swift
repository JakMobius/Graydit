import SwiftUI
import SwiftUIRefresh

struct ContentView: View {
    @State private var showAvatars = true
    @State private var showingSettings = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var afterId: String? = nil
    @State private var posts: [RedditPost] = []

    var body: some View {
        NavigationView {
            List(posts.indices, id: \.self) { index in
                NavigationLink(destination: PostDetailView(post: posts[index])) {
                    HStack {
                        PostPreview(post: posts[index], showAvatar: showAvatars)
                    }
                }
                        .onAppear {
                            if index == posts.count - 1 {
                                isLoading = true
                                loadMorePosts(after: self.afterId)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 15))
            }
                    .refreshable(action: {
                        refreshPosts()
                    })
                    .navigationTitle("Posts")
                    .navigationBarItems(trailing: Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gear")
                    })
                    .sheet(isPresented: $showingSettings) {
                        SettingsView(showAvatars: $showAvatars)
                    }
                    .onAppear {
                        refreshPosts()
                    }
        }
    }

    func fetchPosts(after: String? = nil, completion: @escaping ([RedditPost], String?) -> Void) {
        let url = URL(string: "https://www.reddit.com/r/popular/.json?after=\(after ?? "")")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let jsonDecoder = JSONDecoder()

                do {
                    let decodedData = try jsonDecoder.decode(RedditListingData.self, from: data)
                    let posts = decodedData.data.children.map {
                        $0.data
                    }
                    completion(posts, decodedData.data.after)
                } catch {
                    print("Error decoding data: \(error)")
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
            }
        }

        task.resume()
    }

    func refreshPosts() {
        isLoading = true
        fetchPosts { olderPosts, afterId in
            posts = olderPosts
            self.afterId = afterId
            isLoading = false
        }
    }

    func loadMorePosts(after: String? = nil) {
        fetchPosts(after: after) { olderPosts, afterId in
            posts.append(contentsOf: olderPosts)
            self.afterId = afterId
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
