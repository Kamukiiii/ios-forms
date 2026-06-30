import SwiftUI

// MARK: - More menu sheet (home context menu)
struct MoreMenuSheet: View {
    @EnvironmentObject var state: AppState
    @State private var showShareSheet = false

    private var form: FormModel? { state.forms.first { $0.id == state.moreFormId } }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(form?.title ?? "Form")
                .font(.system(size: 12.5))
                .foregroundColor(.formaSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.8))
                .overlay(Rectangle().fill(Color.black.opacity(0.12)).frame(height: 1), alignment: .bottom)

            // Items
            menuItem(label: "Open", symbol: "arrow.up.right.square") {
                if let id = state.moreFormId { state.openEditor(formId: id) }
            }
            menuItem(label: "Share link", symbol: "link") {
                withAnimation { state.overlay = .none }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showShareSheet = true
                }
            }
            menuItem(label: "Duplicate", symbol: "doc.on.doc") {
                if let id = state.moreFormId { state.duplicateForm(formId: id) }
                withAnimation { state.overlay = .none }
            }
            menuItem(label: "Star", symbol: state.starred.contains(state.moreFormId ?? "") ? "star.fill" : "star") {
                if let id = state.moreFormId { state.toggleStar(formId: id) }
                withAnimation { state.overlay = .none }
            }
            menuItem(label: "Delete", symbol: "trash", color: .formaDanger) {
                withAnimation { state.overlay = .none }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    state.showConfirm(
                        title: "Delete form?",
                        message: "\u{201C}\(form?.title ?? "This form")\u{201D} and all its responses will be permanently deleted.",
                        destructive: "Delete"
                    ) {
                        if let id = state.moreFormId { state.deleteForm(formId: id) }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        )

        // Cancel
        Button {
            withAnimation { state.overlay = .none }
        } label: {
            Text("Cancel")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.formaPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(16)
        }
        .buttonStyle(TapFadeStyle())
        .padding(.top, 8)
        .sheet(isPresented: $showShareSheet) {
            if let form {
                ShareSheet(items: [
                    "Fill out my form: \(form.title)",
                    URL(string: "https://forma-app.web.app/f/\(form.id)")!,
                ])
            }
        }
    }

    @ViewBuilder
    private func menuItem(label: String, symbol: String, color: Color = .formaText, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label).font(.system(size: 17)).foregroundColor(color)
                Spacer()
                Image(systemName: symbol).font(.system(size: 17)).foregroundColor(color.opacity(0.7))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(Color.clear)
        }
        .buttonStyle(TapFadeStyle())
        Rectangle().fill(Color.black.opacity(0.08)).frame(height: 1)
    }
}

// MARK: - Filter/sort sheet
struct FilterSortSheet: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 8) {
            // Show section
            VStack(spacing: 0) {
                sectionLabel("Show")
                showOption("All forms", value: "all")
                showOption("Favorites only", value: "starred")
            }
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.92))
                    .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16))
            )

            // Sort section
            VStack(spacing: 0) {
                sectionLabel("Sort forms by")
                sortOption("Last edited", value: "edited")
                sortOption("Date created", value: "created")
                sortOption("Name A–Z", value: "name")
                sortOption("Most responses", value: "responses")
            }
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.92))
                    .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16))
            )

            // Cancel
            Button { withAnimation { state.overlay = .none } } label: {
                Text("Cancel")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.formaPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
            }
            .buttonStyle(TapFadeStyle())
        }
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(.formaSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(Rectangle().fill(Color.black.opacity(0.12)).frame(height: 1), alignment: .bottom)
    }

    @ViewBuilder
    private func showOption(_ label: String, value: String) -> some View {
        Button { withAnimation { state.formFilter = value; state.overlay = .none } } label: {
            HStack {
                Text(label)
                    .font(.system(size: 17, weight: state.formFilter == value ? .semibold : .regular))
                    .foregroundColor(state.formFilter == value ? .formaPrimary : .formaText)
                Spacer()
                if state.formFilter == value {
                    Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold)).foregroundColor(.formaPrimary)
                }
            }
            .padding(.horizontal, 18).padding(.vertical, 15)
        }
        .buttonStyle(TapFadeStyle())
        Rectangle().fill(Color.black.opacity(0.08)).frame(height: 0.5)
    }

    @ViewBuilder
    private func sortOption(_ label: String, value: String) -> some View {
        Button { withAnimation { state.sortBy = value; state.overlay = .none } } label: {
            HStack {
                Text(label)
                    .font(.system(size: 17, weight: state.sortBy == value ? .semibold : .regular))
                    .foregroundColor(state.sortBy == value ? .formaPrimary : .formaText)
                Spacer()
                if state.sortBy == value {
                    Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold)).foregroundColor(.formaPrimary)
                }
            }
            .padding(.horizontal, 18).padding(.vertical, 15)
        }
        .buttonStyle(TapFadeStyle())
        Rectangle().fill(Color.black.opacity(0.08)).frame(height: 0.5)
    }
}

// MARK: - Create form sheet
struct CreateFormSheet: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle().padding(.top, 10).padding(.bottom, 2)
            Text("Create a form")
                .font(.system(size: 18, weight: .black))
                .padding(.vertical, 14)

            VStack(spacing: 12) {
                createOption(
                    symbol: "square.and.pencil",
                    color: Color.formaPrimary,
                    title: "Blank form",
                    subtitle: "Start from scratch"
                ) {
                    withAnimation { state.overlay = .naming }
                }
                createOption(
                    symbol: "doc.text",
                    color: Color(hex: "#2bb3a3"),
                    title: "From template",
                    subtitle: "Pick a ready-made form",
                    isPro: false
                ) {
                    withAnimation { state.overlay = .template }
                }
                createOption(
                    symbol: "square.and.arrow.down",
                    color: Color(hex: "#f0a23b"),
                    title: "Import questions",
                    subtitle: "Copy from another form",
                    isPro: true
                ) {
                    withAnimation { state.overlay = .pro }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 34)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .sheetShadow()
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func createOption(symbol: String, color: Color, title: String, subtitle: String, isPro: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: symbol)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.formaText)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.formaSecondary)
                }
                Spacer()
                if isPro { ProBadge() }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.formaDivider, lineWidth: 1.5))
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Naming dialog
struct NamingDialog: View {
    @EnvironmentObject var state: AppState
    @State private var name = ""

    var body: some View {
        ZStack {
            DimBackground()
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text("Name your form")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.formaText)
                    Text("You can rename it any time.")
                        .font(.system(size: 13))
                        .foregroundColor(.formaSecondary)
                    TextField("Form name", text: $name)
                        .font(.system(size: 15))
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .background(Color.white)
                        .cornerRadius(9)
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(hex: "#d6d6de"), lineWidth: 1))
                        .padding(.top, 8)
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)
                .padding(.bottom, 14)
                Divider()
                HStack(spacing: 0) {
                    Button {
                        withAnimation { state.overlay = .none }
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 17))
                            .foregroundColor(.formaPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(TapFadeStyle())
                    Divider().frame(height: 44)
                    Button {
                        withAnimation { state.overlay = .none }
                        state.createBlankForm(name: name)
                        name = ""
                    } label: {
                        Text("Create")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.formaPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(TapFadeStyle())
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "#fafafc").opacity(0.96))
            )
            .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 20)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Confirm dialog
struct ConfirmDialog: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack {
            DimBackground()
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text(state.confirmTitle)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.formaText)
                        .multilineTextAlignment(.center)
                    if !state.confirmMessage.isEmpty {
                        Text(state.confirmMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.formaSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)
                .padding(.bottom, 14)
                Divider()
                HStack(spacing: 0) {
                    Button {
                        withAnimation { state.overlay = .none }
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 17))
                            .foregroundColor(.formaPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(TapFadeStyle())
                    Divider().frame(height: 44)
                    Button {
                        withAnimation { state.overlay = .none }
                        state.confirmAction?()
                        state.confirmAction = nil
                    } label: {
                        Text(state.confirmDestructiveLabel)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.formaDanger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(TapFadeStyle())
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "#fafafc").opacity(0.96))
            )
            .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 20)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Search overlay
struct SearchOverlay: View {
    @EnvironmentObject var state: AppState
    @State private var query = ""
    @FocusState private var focused: Bool

    private var results: [FormModel] {
        if query.isEmpty { return [] }
        return state.forms.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ZStack {
            Color.formaBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundColor(Color(hex: "#8a8a94"))
                        TextField("Search forms", text: $query)
                            .font(.system(size: 16))
                            .foregroundColor(.formaText)
                            .focused($focused)
                        if !query.isEmpty {
                            Button { query = "" } label: {
                                Circle().fill(Color(hex: "#c7c7d0")).frame(width: 20, height: 20)
                                    .overlay(Image(systemName: "xmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white))
                            }
                            .buttonStyle(TapFadeStyle())
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(Color(hex: "#eef0f4"))
                    .cornerRadius(11)

                    Button { withAnimation { state.overlay = .none } } label: {
                        Text("Cancel").font(.system(size: 16)).foregroundColor(.formaPrimary)
                    }
                    .buttonStyle(TapFadeStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(Rectangle().fill(Color.formaDivider).frame(height: 1), alignment: .bottom)
                .padding(.top, safeTop)

                ScrollView {
                    VStack(spacing: 0) {
                        if query.isEmpty {
                            // Recent
                            if !state.forms.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("RECENT").font(.system(size: 12.5, weight: .bold)).foregroundColor(.formaTertiary)
                                        .tracking(0.5)
                                        .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 8)
                                    ForEach(state.forms.prefix(3)) { form in
                                        Button {
                                            state.openEditor(formId: form.id)
                                            withAnimation { state.overlay = .none }
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: "clock").font(.system(size: 17)).foregroundColor(Color(hex: "#9a9aa8")).frame(width: 22)
                                                Text(form.title).font(.system(size: 15, weight: .medium)).foregroundColor(.formaText).lineLimit(1)
                                                Spacer()
                                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.formaDisabled)
                                            }
                                            .padding(.horizontal, 16).padding(.vertical, 12)
                                        }
                                        .buttonStyle(TapFadeStyle())
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        } else if results.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "magnifyingglass").font(.system(size: 40)).foregroundColor(Color(hex: "#c7c7d0"))
                                Text("No matching forms").font(.system(size: 16, weight: .semibold)).foregroundColor(.formaDarkText)
                                Text("Try a different name or keyword.").font(.system(size: 14)).foregroundColor(.formaSecondary)
                            }
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(results) { form in
                                    FormCardList(form: form)
                                }
                            }
                            .padding(.horizontal, 16).padding(.top, 14)
                        }
                    }
                }
            }
        }
        .onAppear { focused = true }
    }

    private var safeTop: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.top ?? 44
    }
}

// MARK: - Question type sheet
struct QuestionTypeSheet: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle().padding(.top, 10).padding(.bottom, 4)
            HStack {
                Button("Cancel") { withAnimation { state.overlay = .none } }
                    .font(.system(size: 16))
                    .foregroundColor(.formaPrimary)
                    .frame(width: 60, alignment: .leading)
                Spacer()
                Text("Question type").font(.system(size: 16, weight: .bold)).foregroundColor(.formaText)
                Spacer()
                Color.clear.frame(width: 60)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .overlay(Rectangle().fill(Color.formaSubDiv).frame(height: 1), alignment: .bottom)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(QuestionType.allCases) { type in
                        Button {
                            changeType(to: type)
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#f3f3fb"))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: type.sfSymbol)
                                        .font(.system(size: 19))
                                        .foregroundColor(.formaPrimary)
                                }
                                Text(type.label)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.formaText)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13))
                                    .foregroundColor(.formaDisabled)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(TapFadeStyle())
                        Rectangle().fill(Color.formaSubDiv).frame(height: 1).padding(.leading, 64)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.78)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .sheetShadow()
        .ignoresSafeArea(edges: .bottom)
    }

    private func changeType(to type: QuestionType) {
        guard let formIdx = state.currentFormIndex(),
              let qId = state.qMenuId,
              let qIdx = state.forms[formIdx].questions.firstIndex(where: { $0.id == qId })
        else { withAnimation { state.overlay = .none }; return }
        state.forms[formIdx].questions[qIdx].type = type
        if type.hasOptions && state.forms[formIdx].questions[qIdx].options.isEmpty {
            state.forms[formIdx].questions[qIdx].options = ["Option 1", "Option 2"]
        }
        withAnimation { state.overlay = .none }
    }
}

// MARK: - Question menu sheet
struct QuestionMenuSheet: View {
    @EnvironmentObject var state: AppState

    private var question: Question? {
        guard let formIdx = state.currentFormIndex(), let qId = state.qMenuId else { return nil }
        return state.forms[formIdx].questions.first { $0.id == qId }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(question?.title.isEmpty == false ? (question?.title ?? "Question") : "Question")
                .font(.system(size: 12.5))
                .foregroundColor(.formaSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .overlay(Rectangle().fill(Color.black.opacity(0.12)).frame(height: 1), alignment: .bottom)

            menuRow(label: "Change question type", symbol: "arrow.triangle.2.circlepath") {
                withAnimation { state.overlay = .qtype }
            }
            menuRow(label: "Add description", symbol: "text.alignleft") {
                toggleDesc(); withAnimation { state.overlay = .none }
            }
            menuRow(label: "Add image", symbol: "photo") {
                toggleImage(); withAnimation { state.overlay = .none }
            }
            menuRow(label: "Duplicate", symbol: "doc.on.doc") {
                duplicateQ(); withAnimation { state.overlay = .none }
            }
            menuRow(label: "Delete", symbol: "trash", color: .formaDanger) {
                withAnimation { state.overlay = .none }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    guard let formIdx = state.currentFormIndex(), let qId = state.qMenuId else { return }
                    state.showConfirm(title: "Delete question?", message: "This question will be permanently removed.") {
                        state.forms[formIdx].questions.removeAll { $0.id == qId }
                        state.selectedQuestionId = nil
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.94))
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16))
        )

        Button { withAnimation { state.overlay = .none } } label: {
            Text("Cancel")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.formaPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(16)
        }
        .buttonStyle(TapFadeStyle())
        .padding(.top, 8)
    }

    @ViewBuilder
    private func menuRow(label: String, symbol: String, color: Color = .formaText, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: symbol).font(.system(size: 20)).foregroundColor(color).frame(width: 24)
                Text(label).font(.system(size: 16)).foregroundColor(color)
                Spacer()
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
        }
        .buttonStyle(TapFadeStyle())
        Rectangle().fill(Color.black.opacity(0.08)).frame(height: 0.5)
    }

    private func toggleDesc() {
        guard let formIdx = state.currentFormIndex(),
              let qId = state.qMenuId,
              let qIdx = state.forms[formIdx].questions.firstIndex(where: { $0.id == qId }) else { return }
        state.forms[formIdx].questions[qIdx].hasDesc.toggle()
    }

    private func toggleImage() {
        guard let formIdx = state.currentFormIndex(),
              let qId = state.qMenuId,
              let qIdx = state.forms[formIdx].questions.firstIndex(where: { $0.id == qId }) else { return }
        state.forms[formIdx].questions[qIdx].hasImage.toggle()
    }

    private func duplicateQ() {
        guard let formIdx = state.currentFormIndex(),
              let qId = state.qMenuId,
              let qIdx = state.forms[formIdx].questions.firstIndex(where: { $0.id == qId }) else { return }
        var copy = state.forms[formIdx].questions[qIdx]
        copy = Question(id: UUID().uuidString, type: copy.type, title: copy.title,
                        description: copy.description, required: copy.required, options: copy.options)
        state.forms[formIdx].questions.insert(copy, at: qIdx + 1)
    }
}

// MARK: - Submit auth sheet
struct SubmitAuthSheet: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle().padding(.top, 10).padding(.bottom, 4)
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#f3f3fb")).frame(width: 54, height: 54)
                    Image(systemName: "lock.fill").font(.system(size: 24)).foregroundColor(.formaPrimary)
                }
                Text("Sign in to submit")
                    .font(.system(size: 19, weight: .black))
                    .foregroundColor(.formaText)
                    .tracking(-0.3)
                Text("This form requires you to sign in to Google before submitting your response.")
                    .font(.system(size: 14))
                    .foregroundColor(.formaSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: 290)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)

            VStack(spacing: 0) {
                Button {
                    withAnimation { state.overlay = .none; state.previewSignedIn = true }
                } label: {
                    HStack(spacing: 10) {
                        Text("G").font(.system(size: 17, weight: .bold)).foregroundColor(Color(hex: "#4285F4"))
                        Text("Sign in with Google")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.formaText)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#e0e0e8"), lineWidth: 1))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(TapFadeStyle())

                Button { withAnimation { state.overlay = .none } } label: {
                    Text("Not now")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.formaSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(TapFadeStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 34)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .sheetShadow()
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Pro subscription view
struct ProSubscriptionView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // Hero
                ZStack(alignment: .topTrailing) {
                    LinearGradient.formaPrimaryHero
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 54)
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.18)).frame(width: 56, height: 56)
                                    Image(systemName: "crown.fill").font(.system(size: 28)).foregroundColor(.white)
                                }
                                Text("Forma Pro")
                                    .font(.system(size: 28, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(.top, 16)
                                    .tracking(-0.5)
                                Text("Everything you need to build\nand share unlimited forms.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineSpacing(4)
                                    .padding(.top, 6)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 26)
                    }
                    Button { withAnimation { state.overlay = .none } } label: {
                        Circle().fill(Color.white.opacity(0.18)).frame(width: 32, height: 32)
                            .overlay(Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundColor(.white))
                    }
                    .buttonStyle(TapFadeStyle())
                    .padding(.top, 50).padding(.trailing, 18)
                }
                .frame(height: 240)

                // Body
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Features
                        VStack(spacing: 14) {
                            featureRow(title: "Unlimited forms", subtitle: "Create as many forms as you need")
                            featureRow(title: "Custom themes", subtitle: "Match your brand with colors & fonts")
                            featureRow(title: "Remove Forma branding", subtitle: "Professional look for your forms")
                            featureRow(title: "Advanced analytics", subtitle: "Detailed charts and export options")
                        }

                        // Plans
                        HStack(spacing: 12) {
                            planCard(period: "Yearly", price: "$4.99/mo", billing: "Billed $59.88 yearly", badge: "SAVE 37%", isSelected: state.proPlan == "annual") {
                                state.proPlan = "annual"
                            }
                            planCard(period: "Monthly", price: "$7.99/mo", billing: "Billed monthly", badge: nil, isSelected: state.proPlan == "monthly") {
                                state.proPlan = "monthly"
                            }
                        }

                        Text("7-day free trial, cancel anytime. Subscription renews automatically.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#aeaeb2"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(22)
                }

                // Footer
                VStack(spacing: 14) {
                    Button {
                        withAnimation { state.overlay = .none }
                        state.showToast("Welcome to Forma Pro!")
                    } label: {
                        Text("Start free trial")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.formaPrimary)
                            .cornerRadius(14)
                            .deepShadow()
                    }
                    .buttonStyle(TapFadeStyle())

                    HStack(spacing: 18) {
                        ForEach(["Restore", "Terms", "Privacy"], id: \.self) { label in
                            Button { } label: {
                                Text(label).font(.system(size: 12)).foregroundColor(.formaSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 34)
                .background(Color.white)
                .overlay(Rectangle().fill(Color.formaSubDiv).frame(height: 1), alignment: .top)
            }
        }
    }

    @ViewBuilder
    private func featureRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.formaPrimary)
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 28, height: 28)      // 固定宽高，防止压缩
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(.formaText)
                Text(subtitle).font(.system(size: 13)).foregroundColor(.formaSecondary)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func planCard(period: String, price: String, billing: String, badge: String?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(period)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .formaPrimary : .formaSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price.components(separatedBy: "/").first ?? "")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(isSelected ? .formaText : .formaSecondary)
                    Text("/mo").font(.system(size: 13)).foregroundColor(.formaSecondary)
                }
                Text(billing)
                    .font(.system(size: 11.5))
                    .foregroundColor(.formaSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.formaPrimary : Color(hex: "#e0e0e8"), lineWidth: isSelected ? 2 : 1)
            )
            .overlay(
                badge.map { text in
                    Text(text)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.formaPrimary)
                        .cornerRadius(8)
                        .offset(y: -10)
                }
                , alignment: .top
            )
        }
        .buttonStyle(TapFadeStyle())
    }
}
