import SwiftUI

struct ResponsesTab: View {
    @EnvironmentObject var state: AppState

    private let subTabs: [(ResponsesSubTab, String)] = [
        (.summary, "Summary"),
        (.question, "Question"),
        (.individual, "Individual"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Stats card
                StatsCard()
                    .padding(.horizontal, 16)
                    .padding(.top, 14)

                // Not accepting warning
                if let form = state.currentForm, !state.accepting {
                    NotAcceptingBanner()
                        .padding(.horizontal, 16)
                }

                // Sub-tab selector
                HStack(spacing: 3) {
                    ForEach(subTabs, id: \.0) { (tab, label) in
                        Button {
                            withAnimation { state.responsesSubTab = tab }
                        } label: {
                            Text(label)
                                .font(.system(size: 13.5, weight: .semibold))
                                .foregroundColor(state.responsesSubTab == tab ? .formaPrimary : Color(hex: "#8a8a94"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .background(
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .fill(state.responsesSubTab == tab ? Color.white : Color.clear)
                                )
                        }
                        .buttonStyle(TapFadeStyle())
                    }
                }
                .padding(3)
                .background(RoundedRectangle(cornerRadius: 11).fill(Color.formaInputBg))
                .padding(.horizontal, 16)

                // Content
                switch state.responsesSubTab {
                case .summary:  SummaryContent().padding(.horizontal, 16)
                case .question: QuestionContent().padding(.horizontal, 16)
                case .individual: IndividualContent().padding(.horizontal, 16)
                }

                Color.clear.frame(height: 40)
            }
        }
    }
}

// MARK: - Stats card
private struct StatsCard: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(state.currentForm?.responseCount ?? 0)")
                    .font(.system(size: 30, weight: .black, design: .default))
                    .foregroundColor(.formaText)
                    .tracking(-0.5)
                Text("responses")
                    .font(.system(size: 13))
                    .foregroundColor(.formaSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(state.accepting ? "Accepting" : "Closed")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(state.accepting ? .formaSuccess : .formaSecondary)
                FormaToggle(isOn: $state.accepting, tint: .formaSuccess)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
    }
}

// MARK: - Not accepting banner
private struct NotAcceptingBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 17))
                .foregroundColor(.formaWarning)
            Text("Your form is not accepting responses. New submissions are paused.")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#8a5a14"))
                .lineSpacing(3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color(hex: "#fff4e6"))
        .cornerRadius(14)
    }
}

// MARK: - Summary content
private struct SummaryContent: View {
    @EnvironmentObject var state: AppState
    private let chartData: [(String, Double, Color)] = [
        ("Very satisfied", 0.42, Color(hex: "#5b5bd6")),
        ("Satisfied", 0.28, Color(hex: "#2bb3a3")),
        ("Neutral", 0.15, Color(hex: "#f0a23b")),
        ("Dissatisfied", 0.10, Color(hex: "#e8638a")),
        ("Very dissatisfied", 0.05, Color(hex: "#8a7de8")),
    ]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(state.currentForm?.questions ?? [], id: \.id) { q in
                if q.type == .mc || q.type == .dropdown {
                    ResponseChartCard(title: q.title, type: .bar, data: chartData)
                } else if q.type == .rating {
                    ResponseChartCard(title: q.title, type: .vertical, data: [
                        ("★1", 0.05, Color(hex: "#5b5bd6")),
                        ("★2", 0.08, Color(hex: "#5b5bd6")),
                        ("★3", 0.14, Color(hex: "#5b5bd6")),
                        ("★4", 0.35, Color(hex: "#5b5bd6")),
                        ("★5", 0.38, Color(hex: "#5b5bd6")),
                    ])
                } else if q.type == .short || q.type == .paragraph {
                    TextResponseCard(title: q.title)
                }
            }
        }
    }
}

// MARK: - Chart card
enum ChartType { case bar, vertical, pie }

private struct ResponseChartCard: View {
    let title: String
    let type: ChartType
    let data: [(String, Double, Color)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text(title.isEmpty ? "Question" : title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.formaText)
                    .lineLimit(2)
                Text("\(Int.random(in: 180...248)) responses")
                    .font(.system(size: 12.5))
                    .foregroundColor(.formaSecondary)
            }
            .padding(.bottom, 8)

            // Tool buttons
            HStack(spacing: 6) {
                Spacer()
                ForEach(["chart.bar", "photo", "doc.on.doc", "arrow.up.left.and.arrow.down.right"], id: \.self) { sym in
                    Image(systemName: sym)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#8a8a94"))
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "#f4f4f7"))
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 12)

            // Chart
            switch type {
            case .bar:
                VStack(spacing: 13) {
                    ForEach(data, id: \.0) { (label, pct, color) in
                        HStack(spacing: 8) {
                            Text(label)
                                .font(.system(size: 13))
                                .foregroundColor(.formaDarkText)
                                .frame(width: 120, alignment: .leading)
                                .lineLimit(1)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color(hex: "#f0f0f4")).frame(height: 9)
                                    Capsule().fill(Color.formaPrimary)
                                        .frame(width: geo.size.width * pct, height: 9)
                                }
                            }
                            .frame(height: 9)
                            Text("\(Int(pct * 100))%")
                                .font(.system(size: 12))
                                .foregroundColor(.formaSecondary)
                                .frame(width: 34, alignment: .trailing)
                        }
                    }
                }

            case .vertical:
                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(data, id: \.0) { (label, pct, color) in
                        VStack(spacing: 4) {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4)
                                .fill(color)
                                .frame(maxWidth: .infinity)
                                .frame(height: max(pct * 108, 8))
                            Text(label)
                                .font(.system(size: 10))
                                .foregroundColor(.formaSecondary)
                        }
                    }
                }
                .frame(height: 130)

            case .pie:
                EmptyView()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
    }
}

// MARK: - Text response card
private struct TextResponseCard: View {
    let title: String
    private let responses = ["Great service, very responsive team!", "Could improve wait times", "Overall happy with the experience", "Excellent support staff"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.isEmpty ? "Question" : title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.formaText)
            ForEach(responses.prefix(3), id: \.self) { r in
                HStack(spacing: 10) {
                    Text("1")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.formaPrimary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#ececfb"))
                        .cornerRadius(6)
                    Text(r)
                        .font(.system(size: 14))
                        .foregroundColor(.formaDarkText)
                        .lineLimit(2)
                }
                .padding(11)
                .background(Color(hex: "#f7f7fb"))
                .cornerRadius(10)
            }
            Text("Scroll to see more")
                .font(.system(size: 12.5))
                .foregroundColor(.formaSecondary)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
    }
}

// MARK: - Question tab content
private struct QuestionContent: View {
    @EnvironmentObject var state: AppState
    @State private var qIdx = 0

    private var total: Int { state.currentForm?.questions.count ?? 0 }

    var body: some View {
        VStack(spacing: 14) {
            // Question navigator
            HStack {
                Button {
                    if qIdx > 0 { withAnimation { qIdx -= 1 } }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(qIdx == 0 ? .formaDisabled : .formaPrimary)
                }
                .buttonStyle(TapFadeStyle())
                .disabled(qIdx == 0)

                Spacer()
                Text("Question \(qIdx + 1) of \(max(total, 1))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.formaText)
                Spacer()

                Button {
                    if qIdx < total - 1 { withAnimation { qIdx += 1 } }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(qIdx >= total - 1 ? .formaDisabled : .formaPrimary)
                }
                .buttonStyle(TapFadeStyle())
                .disabled(qIdx >= total - 1)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .cardShadow()

            if let q = state.currentForm?.questions[safe: qIdx] {
                ResponseChartCard(title: q.title, type: .bar, data: [
                    ("Option A", 0.45, .formaPrimary),
                    ("Option B", 0.30, .formaPrimary),
                    ("Option C", 0.25, .formaPrimary),
                ])
            }
        }
    }
}

// MARK: - Individual tab content
private struct IndividualContent: View {
    @EnvironmentObject var state: AppState

    private var total: Int { state.currentForm?.responseCount ?? 0 }

    var body: some View {
        VStack(spacing: 14) {
            // Navigator
            HStack {
                Button {
                    if state.individualIdx > 0 { withAnimation { state.individualIdx -= 1 } }
                } label: {
                    Circle()
                        .fill(state.individualIdx == 0 ? Color.formaInputBg : Color(hex: "#f3f3fb"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(state.individualIdx == 0 ? .formaDisabled : .formaPrimary)
                        )
                }
                .buttonStyle(TapFadeStyle())
                .disabled(state.individualIdx == 0)

                Spacer()
                Text("\(state.individualIdx + 1) of \(max(total, 1))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.formaText)
                Spacer()

                HStack(spacing: 10) {
                    CircleIconButton(symbol: "printer", size: 36, iconSize: 16, fg: .formaSecondary, bg: Color.formaInputBg) {}
                    CircleIconButton(symbol: "trash", size: 36, iconSize: 16, fg: .formaDanger, bg: Color(hex: "#ffeeed")) {
                        // delete this response
                    }
                }

                Button {
                    if state.individualIdx < total - 1 { withAnimation { state.individualIdx += 1 } }
                } label: {
                    Circle()
                        .fill(state.individualIdx >= total - 1 ? Color.formaInputBg : Color(hex: "#f3f3fb"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(state.individualIdx >= total - 1 ? .formaDisabled : .formaPrimary)
                        )
                }
                .buttonStyle(TapFadeStyle())
                .disabled(state.individualIdx >= total - 1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(14)
            .cardShadow()

            // Response answers
            if let form = state.currentForm {
                ForEach(form.questions.prefix(3)) { q in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(q.title.isEmpty ? "Question" : q.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.formaText)
                        Text(sampleAnswer(for: q))
                            .font(.system(size: 15))
                            .foregroundColor(.formaDarkText)
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)
                    .cardShadow()
                }
            }
        }
    }

    private func sampleAnswer(for q: Question) -> String {
        switch q.type {
        case .mc: return q.options.first ?? "Option A"
        case .rating: return "⭐⭐⭐⭐⭐"
        case .scale: return "\(q.scaleMax)"
        default: return "Sample response answer for this question."
        }
    }
}
