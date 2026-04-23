//
//  ReadingToolbarView.swift
//  Verbum
//
//  Created by Meshack Bwire on 23/04/2026.
//
import SwiftUI
import UIKit

struct ReadingToolbarView: View {
    let bookName: String
    let chapter: Int
    let totalChapters: Int
    let readingMode: ReadingMode
    let theme: ReadingTheme

    let onBack: () -> Void
    let onPrevChapter: () -> Void
    let onNextChapter: () -> Void
    let onOpenChapterNav: () -> Void
    let onToggleSearch: () -> Void
    let onReadingModeChange: (ReadingMode) -> Void
    let onThemeTap: () -> Void

    @State private var showModeMenu = false

    var body: some View {
        HStack(spacing: 4) {

            // Back
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(theme.toolbarContent)
                    .frame(width: 36, height: 36)
            }

            // Previous chapter
            Button(action: onPrevChapter) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(
                        theme.toolbarContent.opacity(chapter > 1 ? 1 : 0.3)
                    )
                    .frame(width: 30, height: 36)
            }
            .disabled(chapter <= 1)

            // Title (tap → chapter nav)
            Button(action: onOpenChapterNav) {
                Text("\(bookName) \(chapter)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.toolbarContent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.clear))
            }

            // Next chapter
            Button(action: onNextChapter) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(
                        theme.toolbarContent.opacity(chapter < totalChapters ? 1 : 0.3)
                    )
                    .frame(width: 30, height: 36)
            }
            .disabled(chapter >= totalChapters)

            Spacer()

            // Search
            Button(action: onToggleSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(theme.toolbarContent)
                    .frame(width: 36, height: 36)
            }

            // Reading mode picker
            Button { showModeMenu = true } label: {
                Image(systemName: readingMode == .scroll ? "rectangle.3.group" : "book")
                    .font(.system(size: 16))
                    .foregroundStyle(theme.toolbarContent)
                    .frame(width: 36, height: 36)
            }
            .popover(isPresented: $showModeMenu, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                if #available(iOS 16.4, *) {
                    modePickerPopoverContent
                        .presentationCompactAdaptation(.popover)
                } else {
                    modePickerPopoverContent
                }
            }

            // Theme picker
            Button(action: onThemeTap) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 16))
                    .foregroundStyle(theme.toolbarContent)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(theme.toolbarBackground)
    }

    private var modePickerPopoverContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            let allowedModes = theme.allowedModes
            ForEach(ReadingMode.allCases.filter { allowedModes == nil || allowedModes?.contains($0) == true }) { mode in
                Button {
                    onReadingModeChange(mode)
                    showModeMenu = false
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: mode == readingMode ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(theme.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mode.displayName)
                                .font(VerbumTypography.labelLarge)
                                .foregroundStyle(theme.toolbarContent)
                            Text(mode.description)
                                .font(VerbumTypography.labelSmall)
                                .foregroundStyle(theme.toolbarContent.opacity(0.7))
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                if mode != ReadingMode.allCases.filter({ allowedModes == nil || allowedModes?.contains($0) == true }).last {
                    Divider()
                }
            }
        }
        .frame(minWidth: 280)
        .background(theme.toolbarBackground)
    }
}

struct ReaderSearchResultRow: View {
    let result: SearchResult
    let theme: ReadingTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("\(result.verse.bookName) \(result.verse.chapter):\(result.verse.verseNumber)")
                    .font(VerbumTypography.labelLarge)
                    .foregroundStyle(theme.accentColor)
                
                if result.rank == .reference {
                    Text("REF")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(theme.accentColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(theme.accentColor.opacity(0.14))
                        )
                }
            }
            Text(result.verse.text)
                .font(VerbumTypography.bodySmall)
                .foregroundStyle(theme.textColor.opacity(0.8))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, VerbumSpacing.screenPadding)
        .padding(.vertical, 10)
    }
}
