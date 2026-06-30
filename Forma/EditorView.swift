import SwiftUI

struct EditorView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack {
            Color.formaBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation bar
                EditorNavBar()

                // Tab selector
                EditorTabBar()
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)

                // Tab content
                tabContent
            }

            // Toolbar (Layout A)
            if state.editorLayout == .A && state.editorTab == .questions {
                VStack {
                    Spacer()
                    EditorToolbarDock()
                        .padding(.bottom, 30)
                }
            }

            // Overlays
            editorOverlays
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch state.editorTab {
        case .questions:  QuestionsTab()
        case .preview:    PreviewTab()
        case .responses:  ResponsesTab()
        case .settings:   SettingsTab()
        }
    }

    @ViewBuilder
    private var editorOverlays: some View {
        switch state.overlay {
        case .qtype:
            ZStack {
                DimBackground()
                VStack { Spacer(); QuestionTypeSheet().transition(.move(edge: .bottom)) }
            }
            .ignoresSafeArea(edges: .bottom)
            .zIndex(90)

        case .qmenu:
            ZStack {
                DimBackground()
                VStack { Spacer(); QuestionMenuSheet().padding(.horizontal, 10).padding(.bottom, 12).transition(.move(edge: .bottom).combined(with: .opacity)) }
            }
            .ignoresSafeArea(edges: .bottom)
            .zIndex(90)

        case .confirm:
            ConfirmDialog().transition(.scale(scale: 0.94).combined(with: .opacity)).zIndex(100)

        case .pro:
            ProSubscriptionView().transition(.move(edge: .bottom)).zIndex(95)

        case .submitAuth:
            ZStack {
                DimBackground()
                VStack { Spacer(); SubmitAuthSheet().transition(.move(edge: .bottom)) }
            }
            .ignoresSafeArea(edges: .bottom)
            .zIndex(91)

        default: EmptyView()
        }
    }
}

// MARK: - Editor nav bar
private struct EditorNavBar: View {
    @EnvironmentObject var state: AppState
    @State private var showShareSheet = false

    var body: some View {
        HStack {
            NavBackButton(title: "Forms") {
                // Auto-save before leaving
                state.saveCurrentForm()
                state.goHome()
            }
            Spacer()
            VStack(spacing: 1) {
                Text(state.currentForm?.title ?? "Untitled form")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.formaText)
                    .lineLimit(1)
                Text("All changes saved")
                    .font(.system(size: 11))
                    .foregroundColor(.formaSuccess)
            }
            Spacer()
            Button { showShareSheet = true } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.formaPrimary)
            }
            .buttonStyle(TapFadeStyle())
            .sheet(isPresented: $showShareSheet) {
                if let form = state.currentForm {
                    ShareSheet(items: shareItems(for: form))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.white.ignoresSafeArea(edges: .top))
    }

    private func shareItems(for form: FormModel) -> [Any] {
        // Replace with your real Firebase Hosting / Universal Link domain
        let urlString = "https://forma-app.web.app/f/\(form.id)"
        let url = URL(string: urlString)!
        let text = "Fill out my form: \(form.title)"
        return [text, url]
    }

}

// MARK: - Editor tab bar
private struct EditorTabBar: View {
    @EnvironmentObject var state: AppState

    private let tabs: [(EditorTab, String)] = [
        (.questions, "Questions"),
        (.preview, "Preview"),
        (.responses, "Responses"),
        (.settings, "Settings"),
    ]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(tabs, id: \.0) { (tab, label) in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { state.editorTab = tab }
                } label: {
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(state.editorTab == tab ? .formaPrimary : Color(hex: "#8a8a94"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(state.editorTab == tab ? Color.white : Color.clear)
                        )
                }
                .buttonStyle(TapFadeStyle())
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.formaBg)
        )
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
    }
}

// MARK: - Toolbar dock (Layout A)
struct EditorToolbarDock: View {
    @EnvironmentObject var state: AppState

    private let items: [(String, String)] = [
        ("square.and.pencil", "Question"),
        ("square.and.arrow.down", "Import"),
        ("textformat", "Text"),
        ("photo", "Image"),
        ("video", "Video"),
        ("minus.rectangle", "Section"),
    ]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items, id: \.1) { (sym, label) in
                Button {
                    if label == "Question" { addQuestion() }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: sym)
                            .font(.system(size: 20))
                            .foregroundColor(.formaText)
                        Text(label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#7a7a86"))
                    }
                    .frame(width: 52)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.clear)
                    )
                }
                .buttonStyle(TapFadeStyle())
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.86))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .floatingShadow()
    }

    private func addQuestion() {
        guard let idx = state.currentFormIndex() else { return }
        let q = Question(id: UUID().uuidString, type: .short, title: "")
        state.forms[idx].questions.append(q)
        state.selectedQuestionId = q.id
    }
}
