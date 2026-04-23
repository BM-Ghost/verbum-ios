//
//  ThemePickerViewModel.swift
//  Verbum
//
//  Created by Meshack Bwire on 23/04/2026.
//

import SwiftUI

@MainActor
final class ThemePickerViewModel: ObservableObject {

    @Published var draftTheme: ReadingThemeType
    @Published var draftTypography: ReadingTypographyStyle

    let themes: [ReadingThemeType]
    let typographyOptions: [ReadingTypographyStyle]

    private var committedTheme: ReadingThemeType
    private var committedTypography: ReadingTypographyStyle

    private let onApply: (ReadingThemeType, ReadingTypographyStyle) -> Void
    private let onPreview: (ReadingThemeType, ReadingTypographyStyle) -> Void

    init(
        selectedTheme: ReadingThemeType,
        selectedTypography: ReadingTypographyStyle,
        themes: [ReadingThemeType] = ReadingThemeType.allCases,
        typographyOptions: [ReadingTypographyStyle] = ReadingTypographyStyle.allCases,
        onApply: @escaping (ReadingThemeType, ReadingTypographyStyle) -> Void,
        onPreview: @escaping (ReadingThemeType, ReadingTypographyStyle) -> Void = { _, _ in }
    ) {
        self.draftTheme = selectedTheme
        self.draftTypography = selectedTypography
        self.themes = themes
        self.typographyOptions = typographyOptions
        self.committedTheme = selectedTheme
        self.committedTypography = selectedTypography
        self.onApply = onApply
        self.onPreview = onPreview
    }

    var hasChanges: Bool {
        draftTheme != committedTheme || draftTypography != committedTypography
    }

    func selectTheme(_ theme: ReadingThemeType) {
        draftTheme = theme
    }

    func selectTypography(_ typography: ReadingTypographyStyle) {
        draftTypography = typography
    }

    func apply() {
        committedTheme = draftTheme
        committedTypography = draftTypography
        onApply(draftTheme, draftTypography)
    }

    func reset() {
        draftTheme = committedTheme
        draftTypography = committedTypography
    }

    func previewCurrentDraft() {
        onPreview(draftTheme, draftTypography)
    }

    func previewCommittedValues() {
        onPreview(committedTheme, committedTypography)
    }
}
