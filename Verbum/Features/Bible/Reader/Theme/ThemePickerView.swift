//
//  ThemePickerView.swift
//  Verbum
//
//  Created by Meshack Bwire on 23/04/2026.
//

import SwiftUI

struct ThemePickerView: View {

    @StateObject var viewModel: ThemePickerViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var previewMode: ReadingMode = .scroll
    @State private var animateScroll = false
    @State private var livePreviewEnabled = false

    private var selectedTheme: ReadingTheme {
        viewModel.draftTheme.resolve(isDark: colorScheme == .dark)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Reading Appearance")
                        .font(VerbumTypography.headlineSmall)
                        .foregroundStyle(selectedTheme.chapterTitleColor)

                    previewControls
                    immersivePreview
                    themeGrid
                }
                .padding(16)
                .padding(.bottom, 84)
            }
            .background(selectedTheme.pageBackground)
            .navigationTitle("Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(VerbumTypography.labelLarge)
                    .foregroundStyle(selectedTheme.accentColor)
                }
            }
            .safeAreaInset(edge: .bottom) {
                footerActions
            }
        }
        .onAppear {
            // Simulate an in-page auto scroll for immersive preview in scroll mode.
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                animateScroll = true
            }
        }
        .onChange(of: viewModel.draftTheme) { _, _ in
            guard livePreviewEnabled else { return }
            viewModel.previewCurrentDraft()
        }
        .onChange(of: viewModel.draftTypography) { _, _ in
            guard livePreviewEnabled else { return }
            viewModel.previewCurrentDraft()
        }
        .onChange(of: livePreviewEnabled) { _, isEnabled in
            if isEnabled {
                viewModel.previewCurrentDraft()
            } else {
                viewModel.previewCommittedValues()
            }
        }
        .onDisappear {
            // Revert temporary live preview changes unless user explicitly applied.
            if livePreviewEnabled && viewModel.hasChanges {
                viewModel.previewCommittedValues()
            }
        }
    }

    private var previewControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview Style")
                .font(VerbumTypography.labelLarge)
                .foregroundStyle(selectedTheme.chapterTitleColor.opacity(0.85))

            Picker("Reading Mode", selection: $previewMode) {
                ForEach(ReadingMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Picker(
                "Typography",
                selection: Binding(
                    get: { viewModel.draftTypography },
                    set: { viewModel.selectTypography($0) }
                )
            ) {
                ForEach(viewModel.typographyOptions) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Live Preview", isOn: $livePreviewEnabled)
                .font(VerbumTypography.labelMedium)
                .tint(selectedTheme.accentColor)
        }
    }

    private var immersivePreview: some View {
        let theme = selectedTheme

        return ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.pageBackground)
                .shadow(color: theme.scrollShadowTint.opacity(0.24), radius: 14, y: 8)

            if previewMode == .scroll {
                scrollPreview(theme: theme)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                codexPreview(theme: theme)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .frame(height: 300)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(theme.toolbarContent.opacity(0.12), lineWidth: 1)
        )
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: previewMode)
        .animation(.easeInOut(duration: 0.25), value: viewModel.draftTypography)
    }

    private func scrollPreview(theme: ReadingTheme) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(theme.toolbarContent.opacity(0.18))
                .frame(width: 42, height: 4)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 12) {
                Text("John 1")
                    .font(VerbumTypography.titleLarge)
                    .foregroundStyle(theme.chapterTitleColor)

                previewTextBlock(theme: theme)
                    .offset(y: animateScroll ? -22 : 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .clipped()
        }
    }

    private func codexPreview(theme: ReadingTheme) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.toolbarBackground.opacity(0.6))
                .frame(width: 8)
                .padding(.vertical, 18)

            VStack(alignment: .leading, spacing: 10) {
                Text("John 1")
                    .font(VerbumTypography.titleLarge)
                    .foregroundStyle(theme.chapterTitleColor)

                previewTextBlock(theme: theme)
            }
            .padding(.trailing, 12)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(theme.toolbarBackground.opacity(0.35))
        )
        .padding(14)
    }

    private func previewTextBlock(theme: ReadingTheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("16")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(theme.verseNumberColor)

                Text("For God so loved the world, that he gave his only begotten Son.")
                    .font(viewModel.draftTypography.readingFont(size: 16))
                    .foregroundStyle(theme.textColor)
                    .lineSpacing(viewModel.draftTypography.lineSpacing(base: 3))
            }

            Text("that whosoever believeth in him should not perish, but have everlasting life.")
                .font(viewModel.draftTypography.readingFont(size: 16))
                .foregroundStyle(theme.textColor.opacity(0.92))
                .lineSpacing(viewModel.draftTypography.lineSpacing(base: 3))
        }
    }

    private var themeGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Theme")
                .font(VerbumTypography.labelLarge)
                .foregroundStyle(selectedTheme.chapterTitleColor.opacity(0.85))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(viewModel.themes) { theme in
                    Button {
                        viewModel.selectTheme(theme)
                    } label: {
                        ThemeCard(
                            theme: theme,
                            isSelected: theme == viewModel.draftTheme
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var footerActions: some View {
        HStack(spacing: 10) {
            Button("Reset") {
                viewModel.reset()
                if livePreviewEnabled {
                    viewModel.previewCommittedValues()
                }
            }
            .buttonStyle(.bordered)
            .tint(selectedTheme.toolbarContent.opacity(0.8))
            .disabled(!viewModel.hasChanges)

            Button("Apply") {
                viewModel.apply()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(selectedTheme.accentColor)
            .disabled(!viewModel.hasChanges)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

struct ThemeCard: View {
    let theme: ReadingThemeType
    let isSelected: Bool

    @Environment(\.colorScheme) private var colorScheme

    private var resolvedTheme: ReadingTheme {
        theme.resolve(isDark: colorScheme == .dark)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(resolvedTheme.pageBackground)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(resolvedTheme.chapterTitleColor.opacity(0.5), lineWidth: 1)
                    )

                Circle()
                    .fill(resolvedTheme.accentColor)
                    .frame(width: 10, height: 10)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(resolvedTheme.accentColor)
                }
            }

            Text(theme.displayName)
                .font(VerbumTypography.labelLarge)
                .foregroundStyle(resolvedTheme.textColor)

            Text(theme.description)
                .font(VerbumTypography.labelSmall)
                .foregroundStyle(resolvedTheme.textColor.opacity(0.7))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isSelected ? resolvedTheme.accentColor.opacity(0.16) : resolvedTheme.toolbarBackground.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? resolvedTheme.accentColor.opacity(0.55) : resolvedTheme.toolbarContent.opacity(0.12), lineWidth: 1)
        )
    }
}

