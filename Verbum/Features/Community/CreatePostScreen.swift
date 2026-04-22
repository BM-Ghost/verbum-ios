import SwiftUI

struct CreatePostScreen: View {
    @Environment(\.verbumColors) private var colors
    @Environment(\.dismiss) private var dismiss
    let onSubmit: (String, String, String, [String]) -> Void

    @State private var verseReference = ""
    @State private var verseText = ""
    @State private var reflection = ""
    @State private var tagsText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: VerbumSpacing.lg) {
                    Group {
                        Text("Verse Reference")
                            .font(VerbumTypography.labelLarge)
                            .foregroundStyle(colors.primary)
                        TextField("e.g., John 3:16", text: $verseReference)
                            .textFieldStyle(.roundedBorder)
                    }

                    Group {
                        Text("Verse Text")
                            .font(VerbumTypography.labelLarge)
                            .foregroundStyle(colors.primary)
                        TextEditor(text: $verseText)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colors.onSurfaceVariant.opacity(0.3))
                            )
                    }

                    Group {
                        Text("Your Reflection")
                            .font(VerbumTypography.labelLarge)
                            .foregroundStyle(colors.primary)
                        TextEditor(text: $reflection)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colors.onSurfaceVariant.opacity(0.3))
                            )
                    }

                    Group {
                        Text("Tags (comma-separated)")
                            .font(VerbumTypography.labelLarge)
                            .foregroundStyle(colors.primary)
                        TextField("e.g., faith, hope, love", text: $tagsText)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(VerbumSpacing.screenPadding)
            }
            .navigationTitle("Share Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        onSubmit(verseReference, verseText, reflection, tags)
                        dismiss()
                    }
                    .disabled(reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
