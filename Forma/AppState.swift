import SwiftUI

enum AppView: Equatable { case loading, login, home, editor }
enum HomeLayout: Equatable { case list, grid }
enum EditorLayout: Equatable { case A, B }
enum EditorTab: Equatable { case questions, preview, responses, settings }
enum ResponsesSubTab: Equatable { case summary, question, individual }
enum OverlayKind: Equatable {
    case none, more, search, filter, qtype, importQ, qmenu
    case new, template, naming, confirm, pro, submitAuth
}

class AppState: ObservableObject {
    // MARK: - Navigation
    @Published var view: AppView = .loading
    @Published var homeLayout: HomeLayout = .list
    @Published var editorLayout: EditorLayout = .A
    @Published var editorTab: EditorTab = .questions
    @Published var responsesSubTab: ResponsesSubTab = .summary
    @Published var overlay: OverlayKind = .none

    // MARK: - Auth
    @Published var loggedIn = false

    // MARK: - Editor state
    @Published var homeEmpty = false
    @Published var quizMode = false
    @Published var accepting = true
    @Published var previewSignedIn = false

    @Published var selectedFormId: String? = nil
    @Published var moreFormId: String? = nil
    @Published var selectedQuestionId: String? = nil
    @Published var qMenuId: String? = nil

    // MARK: - Home filters
    @Published var searchQuery = ""
    @Published var sortBy = "edited"
    @Published var formFilter = "all"
    @Published var starred: Set<String> = []
    @Published var proPlan = "annual"

    // MARK: - UI state
    @Published var toast: String? = nil
    @Published var individualIdx = 0
    @Published var responsesQIdx = 0
    @Published var newFormName = ""
    @Published var confirmTitle = ""
    @Published var confirmMessage = ""
    @Published var confirmDestructiveLabel = "Delete"
    @Published var confirmAction: (() -> Void)? = nil

    // MARK: - Data
    @Published var forms: [FormModel] = []
    @Published var isSyncing = false

    private let auth = AuthManager.shared

    init() {
        // Show splash for 1.5 s then navigate to login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { self.view = .login }
        }
    }

    // MARK: - Demo login / logout
    func loginDemo() {
        forms   = FormModel.sampleForms
        starred = ["f1", "f3"]
        loggedIn = true
        withAnimation { view = .home }
    }

    // MARK: - Auth helpers
    var currentUserEmail: String    { auth.userEmail }
    var currentUserInitials: String { auth.userInitials }
    var currentUserName: String     { auth.userDisplayName }

    func signOut() {
        do {
            try auth.signOut()
            loggedIn = false
            forms    = []
            starred  = []
            withAnimation { view = .login }
        } catch {
            showToast("Sign out failed")
        }
    }

    // MARK: - Toast
    func showToast(_ msg: String) {
        withAnimation { toast = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation { self.toast = nil }
        }
    }

    // MARK: - Navigation
    func openEditor(formId: String) {
        selectedFormId   = formId
        editorTab        = .questions
        selectedQuestionId = nil
        withAnimation { view = .editor }
    }

    func goHome() {
        withAnimation { view = .home }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.selectedFormId = nil
            self.overlay        = .none
        }
    }

    func dismissOverlay() { withAnimation { overlay = .none } }

    // MARK: - Data helpers
    var currentForm: FormModel? { forms.first { $0.id == selectedFormId } }

    func currentFormIndex() -> Int? { forms.firstIndex { $0.id == selectedFormId } }

    func currentFormBinding() -> Binding<FormModel>? {
        guard let id = selectedFormId,
              let idx = forms.firstIndex(where: { $0.id == id }) else { return nil }
        return Binding(get: { self.forms[idx] }, set: { self.forms[idx] = $0 })
    }

    func toggleStar(formId: String) {
        if starred.contains(formId) { starred.remove(formId) } else { starred.insert(formId) }
    }

    var filteredForms: [FormModel] {
        var result = forms
        if formFilter == "starred" { result = result.filter { starred.contains($0.id) } }
        if !searchQuery.isEmpty    { result = result.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) } }
        switch sortBy {
        case "name":      result.sort { $0.title.lowercased() < $1.title.lowercased() }
        case "created":   result.sort { $0.createdDate > $1.createdDate }
        case "responses": result.sort { $0.responseCount > $1.responseCount }
        default:          result.sort { $0.editedDate > $1.editedDate }
        }
        return result
    }

    // MARK: - CRUD (local, in-memory)
    func createBlankForm(name: String) {
        let form = FormModel(
            id: UUID().uuidString,
            title: name.isEmpty ? "Untitled form" : name,
            accentHex: "#5b5bd6",
            editedDate: Date(),
            createdDate: Date(),
            questions: [Question(id: UUID().uuidString, type: .short, title: "Question 1", required: true)]
        )
        forms.insert(form, at: 0)
        openEditor(formId: form.id)
    }

    func saveCurrentForm() {
        guard let idx = currentFormIndex() else { return }
        forms[idx].editedDate = Date()
    }

    func deleteForm(formId: String) {
        forms.removeAll { $0.id == formId }
        showToast("Form deleted")
    }

    func duplicateForm(formId: String) {
        guard let form = forms.first(where: { $0.id == formId }),
              let idx  = forms.firstIndex(where: { $0.id == formId }) else { return }
        let copy = FormModel(
            id: UUID().uuidString,
            title: form.title + " (copy)",
            description: form.description,
            accentHex: form.accentHex,
            responseCount: 0,
            editedDate: Date(),
            createdDate: Date(),
            questions: form.questions
        )
        forms.insert(copy, at: idx + 1)
        showToast("Form duplicated")
    }

    // MARK: - Confirm dialog
    func showConfirm(title: String, message: String, destructive: String = "Delete", action: @escaping () -> Void) {
        confirmTitle          = title
        confirmMessage        = message
        confirmDestructiveLabel = destructive
        confirmAction         = action
        withAnimation { overlay = .confirm }
    }
}
