import SwiftUI
import UIKit

struct BibleReaderScreen: View {
    @StateObject private var viewModel: BibleReaderViewModel
    @Environment(\.verbumColors) private var colors
    @State private var selectedVerse: Verse?

    let onAskAi: (String) -> Void

    init(book: BibleBook, onAskAi: @escaping (String) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: BibleReaderViewModel(book: book))
        self.onAskAi = onAskAi
    }

    var body: some View {
        VStack(spacing: 0) {
            // Chapter navigation
            HStack {
                Button { viewModel.previousChapter() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(viewModel.currentChapter > 1 ? colors.primary : colors.onSurfaceVariant.opacity(0.3))
                }
                .disabled(viewModel.currentChapter <= 1)

                Spacer()
                Text("Chapter \(viewModel.currentChapter)")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()

                Button { viewModel.nextChapter() } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(viewModel.currentChapter < viewModel.book.chapterCount ? colors.primary : colors.onSurfaceVariant.opacity(0.3))
                }
                .disabled(viewModel.currentChapter >= viewModel.book.chapterCount)
            }
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.vertical, VerbumSpacing.sm)

            Divider()

            // Verses
            switch viewModel.state {
            case .loading:
                VerbumLoadingView()
            case .error(let message):
                VerbumErrorView(message: message) { viewModel.loadChapter() }
            case .success(let verses):
                ScrollView {
                    VStack(alignment: .leading, spacing: VerbumSpacing.md) {
                        ForEach(verses, id: \.id) { verse in
                            HStack(alignment: .top, spacing: VerbumSpacing.sm) {
                                Text("\(verse.verseNumber)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(colors.primary)
                                    .frame(width: 24, alignment: .trailing)

                                Text(verse.text)
                                    .font(.system(.body, design: .serif))
                                    .fontSize(viewModel.fontSize)
                                    .lineSpacing(6)
                                    .foregroundStyle(colors.onSurface)
                            }
                            .padding(.trailing, VerbumSpacing.screenPadding)
                            .onTapGesture {
                                selectedVerse = verse
                            }
                            .background(
                                viewModel.bookmarkedVerses.contains(verse.id) ?
                                    colors.primaryContainer.opacity(0.2) : Color.clear
                            )
                        }
                    }
                    .padding(.horizontal, VerbumSpacing.screenPadding)
                    .padding(.vertical, VerbumSpacing.lg)
                }
            }
        }
        .navigationTitle(viewModel.book.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { viewModel.increaseFontSize() } label: {
                        Label("Increase Font", systemImage: "textformat.size.larger")
                    }
                    Button { viewModel.decreaseFontSize() } label: {
                        Label("Decrease Font", systemImage: "textformat.size.smaller")
                    }
                } label: {
                    Image(systemName: "textformat.size")
                }
            }
        }
        .confirmationDialog("Verse Actions", isPresented: Binding(
            get: { selectedVerse != nil },
            set: { if !$0 { selectedVerse = nil } }
        ), titleVisibility: .visible) {
            if let verse = selectedVerse {
                Button("Bookmark") {
                    viewModel.toggleBookmark(verseId: verse.id)
                }
                Button("Share") {
                    UIPasteboard.general.string = "\(verse.bookName) \(verse.chapter):\(verse.verseNumber)\n\n\(verse.text)"
                }
                Button("Ask AI") {
                    let context = "Please explain \(verse.bookName) \(verse.chapter):\(verse.verseNumber): \(verse.text)"
                    onAskAi(context)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

private extension View {
    func fontSize(_ size: CGFloat) -> some View {
        self.font(.system(size: size, design: .serif))
    }
}
