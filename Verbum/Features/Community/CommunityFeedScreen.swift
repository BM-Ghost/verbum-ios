import SwiftUI

struct CommunityFeedScreen: View {
    @ObservedObject var viewModel: CommunityViewModel
    @Environment(\.verbumColors) private var colors

    let onCreatePost: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Community")
                        .font(VerbumTypography.headlineSmall)
                    Text("Share reflections and encourage one another")
                        .font(VerbumTypography.bodySmall)
                        .foregroundStyle(colors.onSurfaceVariant)
                }
                .padding(.horizontal, VerbumSpacing.screenPadding)
                .padding(.top, VerbumSpacing.md)

                switch viewModel.state {
                case .loading:
                    VerbumLoadingView()
                case .error(let message):
                    VerbumErrorView(message: message) { viewModel.loadFeed() }
                case .success(let posts):
                    ScrollView {
                        LazyVStack(spacing: VerbumSpacing.md) {
                            ForEach(posts, id: \.id) { post in
                                CommunityPostCardView(
                                    authorName: post.author.displayName,
                                    timeAgo: "Recently",
                                    verseReference: post.verseReference,
                                    reflectionText: post.content,
                                    amenCount: post.amenCount,
                                    commentCount: post.commentCount,
                                    tags: post.tags,
                                    onAmen: { viewModel.toggleAmen(postId: post.id) },
                                    onComment: {},
                                    onProfile: {}
                                )
                                .padding(.horizontal, VerbumSpacing.screenPadding)
                            }
                        }
                        .padding(.vertical, VerbumSpacing.lg)
                    }
                }
            }

            Button(action: onCreatePost) {
                Image(systemName: "plus")
                    .font(VerbumTypography.headlineSmall)
                    .foregroundStyle(colors.onPrimary)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(colors.primary))
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
            .padding(.trailing, VerbumSpacing.screenPadding)
            .padding(.bottom, VerbumSpacing.lg)
        }
    }
}
