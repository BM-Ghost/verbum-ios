import SwiftUI

struct AiChatScreen: View {
    @StateObject private var viewModel = AiChatViewModel()
    @Environment(\.verbumColors) private var colors
    @FocusState private var isInputFocused: Bool
    let initialPrompt: String?

    init(initialPrompt: String? = nil) {
        self.initialPrompt = initialPrompt
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Verbum AI")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Scripture and catechism guided reflections")
                    .font(.caption)
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.top, VerbumSpacing.sm)

            if viewModel.messages.isEmpty {
                // Empty state with quick prompts
                ScrollView {
                    VStack(spacing: VerbumSpacing.lg) {
                        Spacer().frame(height: VerbumSpacing.xxl)

                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(colors.primary)

                        Text("Verbum AI")
                            .font(.system(.title2, design: .serif))
                            .fontWeight(.bold)

                        Text("Your Catholic faith companion. Ask about Scripture, doctrine, prayer, and more.")
                            .font(.subheadline)
                            .foregroundStyle(colors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, VerbumSpacing.xl)

                        Spacer().frame(height: VerbumSpacing.lg)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: VerbumSpacing.sm) {
                            ForEach(AiQuickPrompt.defaults, id: \.title) { prompt in
                                Button {
                                    viewModel.sendQuickPrompt(prompt)
                                } label: {
                                    HStack(spacing: VerbumSpacing.xs) {
                                        Image(systemName: prompt.icon)
                                            .font(.system(size: 12))
                                            .foregroundStyle(colors.primary)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(prompt.title)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundStyle(colors.onSurface)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, VerbumSpacing.sm)
                                    .padding(.vertical, VerbumSpacing.sm)
                                    .background(
                                        Capsule().fill(colors.surfaceVariant.opacity(0.5))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, VerbumSpacing.screenPadding)
                    }
                }
            } else {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: VerbumSpacing.md) {
                            ForEach(viewModel.messages, id: \.id) { message in
                                AiChatBubbleView(message: message.content, isFromUser: message.role == .user)
                                    .id(message.id)
                            }
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding(VerbumSpacing.md)
                                    Spacer()
                                }
                                .padding(.horizontal, VerbumSpacing.screenPadding)
                                .id("loading")
                            }
                        }
                        .padding(.vertical, VerbumSpacing.lg)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id ?? "loading", anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            Divider()
            HStack(spacing: VerbumSpacing.sm) {
                TextField("Ask Verbum AI…", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colors.surfaceVariant.opacity(0.5))
                    )

                Button(action: viewModel.sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                colors.onSurfaceVariant.opacity(0.3) : colors.primary
                        )
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.vertical, VerbumSpacing.sm)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let initialPrompt {
                viewModel.seedAndSend(prompt: initialPrompt)
            }
        }
        .toolbar {
            if !viewModel.messages.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { viewModel.clearChat() } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}
