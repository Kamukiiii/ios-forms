import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var showSearch = false

    private var columns: [GridItem] { [GridItem(.flexible()), GridItem(.flexible())] }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.formaBg.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        VStack(spacing: 0) {
                            // Banner
                            PromoBanner()
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                .padding(.bottom, 14)

                            // Search + filters
                            SearchFilterBar(showSearch: $showSearch)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)

                            // Layout toggle & filter label
                            HStack {
                                Text(filterLabel)
                                    .font(.system(size: 13))
                                    .foregroundColor(.formaSecondary)
                                Spacer()
                                LayoutToggle()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        }
                    } header: {
                        VStack(spacing: 0) {
                            Color.formaBg.frame(height: 0)
                            HomeNavBar()
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 12)
                                .background(Color.formaBg)
                        }
                    }

                    // Content
                    if state.homeEmpty || (state.loggedIn && state.filteredForms.isEmpty && !state.homeEmpty) {
                        emptyStateView
                            .padding(.top, 60)
                    } else if !state.loggedIn {
                        signedOutState
                            .padding(.top, 60)
                    } else if state.homeLayout == .list {
                        FormsListView()
                            .padding(.horizontal, 20)
                    } else {
                        FormsGridView()
                            .padding(.horizontal, 20)
                    }

                    Color.clear.frame(height: 120)
                }
            }

            // FAB
            if state.loggedIn {
                FABButton()
                    .padding(.trailing, 22)
                    .padding(.bottom, 34)
            }

            // Overlays
            overlayLayer
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Filter label
    private var filterLabel: String {
        var parts: [String] = []
        if state.formFilter == "starred" { parts.append("Favorites") }
        let sortMap = ["edited": "Last edited", "created": "Date created", "name": "Name A–Z", "responses": "Most responses"]
        parts.append(sortMap[state.sortBy] ?? "Last edited")
        return parts.joined(separator: " · ")
    }

    // MARK: - Empty state
    @ViewBuilder
    private var emptyStateView: some View {
        EmptyStateView(
            symbol: "doc.badge.plus",
            title: "No forms yet",
            subtitle: "Tap the + button to create your first form or start from a template.",
            buttonLabel: "Create a form",
            buttonAction: { withAnimation { state.overlay = .new } }
        )
    }

    @ViewBuilder
    private var signedOutState: some View {
        EmptyStateView(
            symbol: "doc.text",
            title: "Sign in to see your forms",
            subtitle: "Sign in with your Google account to access and create forms.",
            buttonLabel: "Sign in",
            buttonAction: { withAnimation { state.view = .login } }
        )
    }

    // MARK: - Overlay layer
    @ViewBuilder
    private var overlayLayer: some View {
        if state.overlay != .none {
            DimBackground()
                .ignoresSafeArea()
                .onTapGesture {
                    if ![.confirm, .naming].contains(state.overlay) {
                        withAnimation { state.overlay = .none }
                    }
                }
                .zIndex(80)
        }

        switch state.overlay {
        case .more:
            VStack {
                Spacer()
                MoreMenuSheet()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .zIndex(90)

        case .filter:
            VStack {
                Spacer()
                FilterSortSheet()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .zIndex(90)

        case .new:
            VStack {
                Spacer()
                CreateFormSheet()
                    .transition(.move(edge: .bottom))
            }
            .zIndex(90)

        case .naming:
            NamingDialog()
                .transition(.scale(scale: 0.94).combined(with: .opacity))
                .zIndex(100)

        case .confirm:
            ConfirmDialog()
                .transition(.scale(scale: 0.94).combined(with: .opacity))
                .zIndex(100)

        case .search:
            SearchOverlay()
                .transition(.opacity)
                .zIndex(85)

        case .pro:
            ProSubscriptionView()
                .transition(.move(edge: .bottom))
                .zIndex(95)

        default:
            EmptyView()
        }
    }
}

// MARK: - Nav bar
private struct HomeNavBar: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack {
            Text("My Forms")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.formaText)
                .tracking(-0.5)
            Spacer()
            if state.loggedIn {
                Button {
                    // settings
                } label: {
                    Circle()
                        .fill(Color.formaPrimary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("A")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.formaPrimary.opacity(0.5), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(TapFadeStyle())
            }
        }
    }
}

// MARK: - Promo banner
private struct PromoBanner: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        Button {
            withAnimation { state.overlay = .pro }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Color.white.opacity(0.2).frame(width: 40, height: 40).cornerRadius(10)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Forma Pro")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Unlimited forms, custom themes & more")
                        .font(.system(size: 11.5))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(LinearGradient.formaPrimaryDiag)
            .cornerRadius(14)
            .shadow(color: Color.formaPrimary.opacity(0.6), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Search filter bar
private struct SearchFilterBar: View {
    @EnvironmentObject var state: AppState
    @Binding var showSearch: Bool

    var hasActiveFilter: Bool {
        state.formFilter != "all" || state.sortBy != "edited"
    }

    var body: some View {
        HStack(spacing: 8) {
            // Search button (tapping opens overlay)
            Button {
                withAnimation { state.overlay = .search }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#8a8a94"))
                    Text("Search")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#8a8a94"))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(Color.formaInputBg)
                .cornerRadius(11)
            }
            .buttonStyle(TapFadeStyle())

            // Starred filter
            Button {
                withAnimation {
                    state.formFilter = state.formFilter == "starred" ? "all" : "starred"
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: state.formFilter == "starred" ? "star.fill" : "star")
                        .font(.system(size: 12))
                    Text("Starred")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(state.formFilter == "starred" ? .white : Color(hex: "#8a8a94"))
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(state.formFilter == "starred" ? Color.formaPrimary : Color.formaInputBg)
                .cornerRadius(11)
            }
            .buttonStyle(TapFadeStyle())

            // Filter button
            Button {
                withAnimation { state.overlay = .filter }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 16))
                        .foregroundColor(.formaPrimary)
                        .frame(width: 38, height: 38)
                        .background(hasActiveFilter ? Color(hex: "#eeeefd") : Color.formaInputBg)
                        .cornerRadius(11)
                    if hasActiveFilter {
                        Circle()
                            .fill(Color.formaDanger)
                            .frame(width: 7, height: 7)
                            .offset(x: -3, y: 3)
                    }
                }
            }
            .buttonStyle(TapFadeStyle())
        }
    }
}

// MARK: - Layout toggle
private struct LayoutToggle: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack(spacing: 2) {
            ForEach([(HomeLayout.list, "list.bullet"), (HomeLayout.grid, "square.grid.2x2")], id: \.0) { (layout, sym) in
                Button {
                    withAnimation { state.homeLayout = layout }
                } label: {
                    Image(systemName: sym)
                        .font(.system(size: 14))
                        .foregroundColor(state.homeLayout == layout ? .formaPrimary : Color(hex: "#8a8a94"))
                        .frame(width: 32, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(state.homeLayout == layout ? Color.white : Color.clear)
                        )
                }
                .buttonStyle(TapFadeStyle())
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color.formaInputBg)
        )
    }
}

// MARK: - FAB
private struct FABButton: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        Button {
            withAnimation { state.overlay = .new }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.formaPrimary)
                .cornerRadius(20)
                .fabShadow()
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Forms list
private struct FormsListView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(state.filteredForms) { form in
                FormCardList(form: form)
            }
        }
    }
}

// MARK: - Forms grid
private struct FormsGridView: View {
    @EnvironmentObject var state: AppState
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(state.filteredForms) { form in
                FormCardGrid(form: form)
            }
        }
    }
}

// MARK: - Form card (list)
struct FormCardList: View {
    @EnvironmentObject var state: AppState
    let form: FormModel

    var body: some View {
        Button {
            state.openEditor(formId: form.id)
        } label: {
            HStack(spacing: 14) {
                FormThumbnail(accentColor: form.accentColor)

                VStack(alignment: .leading, spacing: 3) {
                    Text(form.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.formaText)
                        .lineLimit(1)
                    Text(form.metaString)
                        .font(.system(size: 13))
                        .foregroundColor(.formaSecondary)
                }

                Spacer()

                StarButton(isStarred: state.starred.contains(form.id)) {
                    state.toggleStar(formId: form.id)
                }

                Button {
                    state.moreFormId = form.id
                    withAnimation { state.overlay = .more }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#c1c1c9"))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(TapFadeStyle())
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .cardShadow()
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Form card (grid)
struct FormCardGrid: View {
    @EnvironmentObject var state: AppState
    let form: FormModel

    var body: some View {
        Button {
            state.openEditor(formId: form.id)
        } label: {
            VStack(spacing: 0) {
                FormThumbnailLarge(accentColor: form.accentColor)

                VStack(spacing: 0) {
                    Text(form.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.formaText)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)

                    HStack(spacing: 0) {
                        Text(form.metaString)
                            .font(.system(size: 11.5))
                            .foregroundColor(.formaSecondary)
                            .lineLimit(1)
                        Spacer()
                        StarButton(isStarred: state.starred.contains(form.id)) {
                            state.toggleStar(formId: form.id)
                        }
                        Button {
                            state.moreFormId = form.id
                            withAnimation { state.overlay = .more }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#c1c1c9"))
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(TapFadeStyle())
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 12)
            }
            .background(Color.white)
            .cornerRadius(16)
            .cardShadow()
        }
        .buttonStyle(TapFadeStyle())
    }
}
