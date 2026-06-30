import SwiftUI

struct QuestionsTab: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 14) {
                    if let formIdx = state.currentFormIndex() {
                        FormHeaderCard(form: $state.forms[formIdx])
                        ForEach(state.forms[formIdx].questions) { question in
                            QuestionCard(
                                formIdx: formIdx,
                                question: question,
                                isSelected: state.selectedQuestionId == question.id
                            )
                            .id(question.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 200)
            }
            .onChange(of: state.selectedQuestionId) { newId in
                guard let id = newId else { return }
                // 短暂延迟确保新问题已渲染
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: - Form header card
private struct FormHeaderCard: View {
    @Binding var form: FormModel

    var body: some View {
        VStack(spacing: 0) {
            // Gradient top bar
            LinearGradient(colors: [form.accentColor, form.accentColor.opacity(0.7)],
                           startPoint: .leading, endPoint: .trailing)
                .frame(height: 8)

            VStack(alignment: .leading, spacing: 0) {
                TextField("Form title", text: $form.title)
                    .font(.system(size: 23, weight: .black))
                    .foregroundColor(.formaText)
                    .padding(.vertical, 2)
                    .overlay(Rectangle().fill(Color.formaPrimary).frame(height: 2), alignment: .bottom)

                TextField("Form description (optional)", text: $form.description)
                    .font(.system(size: 14))
                    .foregroundColor(.formaSecondary)
                    .padding(.vertical, 4)
                    .padding(.top, 6)
                    .overlay(Rectangle().fill(Color.formaSubDiv).frame(height: 1), alignment: .bottom)

                HStack(spacing: 6) {
                    Image(systemName: "asterisk")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.formaDanger)
                    Text("Indicates required question")
                        .font(.system(size: 12))
                        .foregroundColor(.formaDanger)
                }
                .padding(.top, 12)
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
    }
}

// MARK: - Question card
struct QuestionCard: View {
    @EnvironmentObject var state: AppState
    let formIdx: Int
    let question: Question
    let isSelected: Bool

    private var qIdx: Int? { state.forms[formIdx].questions.firstIndex(where: { $0.id == question.id }) }

    var body: some View {
        VStack(spacing: 0) {
            // Section top border
            if question.type == .section {
                Rectangle()
                    .fill(Color.formaPrimary)
                    .frame(height: 3)
            }

            VStack(spacing: 0) {
                // Type selector row
                if question.type != .section {
                    HStack(spacing: 8) {
                        TypeSelectorButton(question: question)
                        Spacer()
                        if isSelected {
                            Button {
                                guard let qi = qIdx else { return }
                                state.forms[formIdx].questions[qi].hasImage.toggle()
                            } label: {
                                Image(systemName: question.hasImage ? "photo.fill" : "photo")
                                    .font(.system(size: 19))
                                    .foregroundColor(question.hasImage ? .formaPrimary : Color(hex: "#9a9aa8"))
                                    .frame(width: 32, height: 32)
                                    .background(question.hasImage ? Color(hex: "#f3f3fb") : Color.clear)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(TapFadeStyle())
                        }
                        Button {
                            state.qMenuId = question.id
                            withAnimation { state.overlay = .qmenu }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18))
                                .foregroundColor(isSelected ? .formaPrimary : Color(hex: "#9a9aa8"))
                                .rotationEffect(.degrees(90))
                                .frame(width: 32, height: 32)
                                .background(isSelected ? Color(hex: "#f3f3fb") : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(TapFadeStyle())
                    }
                    .padding(.bottom, 12)
                }

                // Title
                if question.type == .section {
                    sectionContent
                } else {
                    questionContent
                }

                // Footer (for real questions)
                if !question.type.isContentBlock {
                    questionFooter
                }
            }
            .padding(14)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? Color.formaPrimary : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: isSelected ? Color.formaPrimary.opacity(0.3) : .black.opacity(0.05),
            radius: isSelected ? 10 : 1, x: 0, y: isSelected ? 4 : 1
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                state.selectedQuestionId = (state.selectedQuestionId == question.id) ? nil : question.id
            }
        }
    }

    // MARK: - Section content
    @ViewBuilder
    private var sectionContent: some View {
        if let qi = qIdx {
            TextField("Section title", text: Binding(
                get: { state.forms[formIdx].questions[qi].title },
                set: { state.forms[formIdx].questions[qi].title = $0 }
            ))
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.formaText)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Question content
    @ViewBuilder
    private var questionContent: some View {
        if let qi = qIdx {
            let qBinding = Binding(
                get: { state.forms[formIdx].questions[qi] },
                set: { state.forms[formIdx].questions[qi] = $0 }
            )
            // Title input
            TextField("Question", text: qBinding.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.formaText)
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
                .overlay(
                    Rectangle().fill(isSelected ? Color.formaPrimary : Color.formaDivider).frame(height: isSelected ? 2 : 1),
                    alignment: .bottom
                )

            // Description
            if question.hasDesc {
                TextField("Description", text: qBinding.description)
                    .font(.system(size: 13))
                    .foregroundColor(.formaSecondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 2)
                    .padding(.top, 4)
                    .overlay(Rectangle().fill(Color.formaSubDiv).frame(height: 1), alignment: .bottom)
            }

            // Image upload area
            if question.hasImage {
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(hex: "#d6d6e0"), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .frame(height: 140)
                        .overlay(
                            VStack(spacing: 6) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(hex: "#a9a9b8"))
                                Text("Add image")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#a9a9b8"))
                            }
                        )
                        .background(Color.formaFaintBg.cornerRadius(12))
                    TextField("Image caption (optional)", text: qBinding.description)
                        .font(.system(size: 13))
                        .foregroundColor(.formaSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 2)
                        .overlay(Rectangle().fill(Color.formaSubDiv).frame(height: 1), alignment: .bottom)
                }
                .padding(.top, 14)
            }

            // Question body
            questionBody(qBinding: qBinding)
                .padding(.top, 14)
        }
    }

    // MARK: - Question body by type
    @ViewBuilder
    private func questionBody(qBinding: Binding<Question>) -> some View {
        switch question.type {
        case .short:
            Text("Short answer text")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#b6b6c2"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
                .overlay(Rectangle().fill(Color.formaDivider).frame(height: 1), alignment: .bottom)

        case .paragraph:
            Text("Long answer text")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#b6b6c2"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                .overlay(Rectangle().fill(Color.formaDivider).frame(height: 1), alignment: .bottom)

        case .mc, .checkbox:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(question.options.indices, id: \.self) { i in
                    HStack(spacing: 11) {
                        if question.type == .mc {
                            Circle()
                                .strokeBorder(Color(hex: "#c7c7d2"), lineWidth: 2)
                                .frame(width: 20, height: 20)
                        } else {
                            RoundedRectangle(cornerRadius: 5).strokeBorder(Color(hex: "#c7c7d2"), lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                        if let qi = qIdx {
                            TextField("Option \(i+1)", text: Binding(
                                get: { state.forms[formIdx].questions[qi].options[safe: i] ?? "" },
                                set: { if i < state.forms[formIdx].questions[qi].options.count { state.forms[formIdx].questions[qi].options[i] = $0 } }
                            ))
                            .font(.system(size: 15))
                            .foregroundColor(.formaDarkText)
                        }
                        Spacer()
                    }
                }
                if let qi = qIdx {
                    HStack(spacing: 14) {
                        Button {
                            state.forms[formIdx].questions[qi].options.append("Option \(state.forms[formIdx].questions[qi].options.count + 1)")
                        } label: {
                            Text("Add option")
                                .font(.system(size: 14))
                                .foregroundColor(.formaSecondary)
                        }
                        .buttonStyle(TapFadeStyle())
                        Text("or")
                            .font(.system(size: 14))
                            .foregroundColor(.formaSecondary)
                        Button {
                            state.forms[formIdx].questions[qi].options.append("Other…")
                        } label: {
                            Text("Add \u{201C}Other\u{201D}")
                                .font(.system(size: 14))
                                .foregroundColor(.formaPrimary)
                        }
                        .buttonStyle(TapFadeStyle())
                    }
                }
            }

        case .dropdown:
            VStack(alignment: .leading, spacing: 8) {
                ForEach(question.options.indices, id: \.self) { i in
                    HStack(spacing: 10) {
                        Text("\(i+1).")
                            .font(.system(size: 14))
                            .foregroundColor(.formaSecondary)
                            .frame(width: 22)
                        if let qi = qIdx {
                            TextField("Option \(i+1)", text: Binding(
                                get: { state.forms[formIdx].questions[qi].options[safe: i] ?? "" },
                                set: { if i < state.forms[formIdx].questions[qi].options.count { state.forms[formIdx].questions[qi].options[i] = $0 } }
                            ))
                            .font(.system(size: 15))
                            .foregroundColor(.formaDarkText)
                        }
                    }
                }
            }

        case .scale:
            VStack(spacing: 12) {
                HStack {
                    Text("Min: \(question.scaleMin)")
                        .font(.system(size: 14))
                        .foregroundColor(.formaSecondary)
                    Spacer()
                    Text("Max: \(question.scaleMax)")
                        .font(.system(size: 14))
                        .foregroundColor(.formaSecondary)
                }
                HStack(spacing: 6) {
                    ForEach(question.scaleMin...question.scaleMax, id: \.self) { n in
                        Circle()
                            .strokeBorder(Color(hex: "#d6d6de"), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                            .overlay(Text("\(n)").font(.system(size: 13)).foregroundColor(.formaDarkText))
                    }
                }
            }

        case .rating:
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { _ in
                    Image(systemName: "star")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: "#d2d2dc"))
                }
            }

        case .date:
            HStack(spacing: 6) {
                dateBox("MM", width: 54)
                Text("/").foregroundColor(Color(hex: "#c7c7cc"))
                dateBox("DD", width: 54)
                Text("/").foregroundColor(Color(hex: "#c7c7cc"))
                dateBox("YYYY", width: 66)
                Spacer()
            }

        case .time:
            HStack(spacing: 6) {
                dateBox("HH", width: 54)
                Text(":").foregroundColor(Color(hex: "#c7c7cc"))
                dateBox("MM", width: 54)
                HStack(spacing: 0) {
                    Text("AM").font(.system(size: 14)).foregroundColor(.formaDarkText)
                        .frame(width: 38, height: 42)
                        .overlay(Rectangle().stroke(Color(hex: "#d6d6de"), lineWidth: 1).cornerRadius(8))
                    Text("PM").font(.system(size: 14)).foregroundColor(.formaSecondary)
                        .frame(width: 38, height: 42)
                        .overlay(Rectangle().stroke(Color(hex: "#d6d6de"), lineWidth: 1).cornerRadius(8))
                }
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#d6d6de"), lineWidth: 1))
            }

        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func dateBox(_ placeholder: String, width: CGFloat) -> some View {
        Text(placeholder)
            .font(.system(size: 15))
            .foregroundColor(Color(hex: "#b6b6c2"))
            .frame(width: width, height: 42)
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(hex: "#d6d6de"), lineWidth: 1))
    }

    // MARK: - Question footer
    @ViewBuilder
    private var questionFooter: some View {
        if let qi = qIdx {
            HStack(spacing: 6) {
                if state.quizMode {
                    Button {} label: {
                        HStack(spacing: 5) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#e8870b"))
                            Text("Answer key")
                                .font(.system(size: 12.5, weight: .semibold))
                                .foregroundColor(Color(hex: "#e8870b"))
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 30)
                        .background(Color(hex: "#fff4e6"))
                        .cornerRadius(8)
                    }
                    .buttonStyle(TapFadeStyle())
                }

                Spacer()

                Text("Required")
                    .font(.system(size: 13))
                    .foregroundColor(.formaSecondary)

                FormaToggle(isOn: Binding(
                    get: { state.forms[formIdx].questions[qi].required },
                    set: { state.forms[formIdx].questions[qi].required = $0 }
                ), size: .small, tint: .formaPrimary)

                Rectangle().fill(Color.formaDivider).frame(width: 1, height: 22)

                Button {
                    let copy = Question(
                        id: UUID().uuidString,
                        type: question.type,
                        title: question.title,
                        description: question.description,
                        required: question.required,
                        options: question.options
                    )
                    state.forms[formIdx].questions.insert(copy, at: qi + 1)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "#9a9aa8"))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(TapFadeStyle())

                Button {
                    state.showConfirm(title: "Delete question?",
                                      message: "\u{201C}\(question.title.isEmpty ? "This question" : question.title)\u{201D} will be permanently removed.",
                                      destructive: "Delete") {
                        state.forms[formIdx].questions.remove(at: qi)
                        state.selectedQuestionId = nil
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "#c4c4cf"))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(TapFadeStyle())
            }
            .padding(.top, 12)
            .overlay(Rectangle().fill(Color.formaSubDiv).frame(height: 1), alignment: .top)
        }
    }
}

// MARK: - Type selector button
private struct TypeSelectorButton: View {
    @EnvironmentObject var state: AppState
    let question: Question

    var body: some View {
        Button {
            state.qMenuId = question.id
            withAnimation { state.overlay = .qtype }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: question.type.sfSymbol)
                    .font(.system(size: 17))
                    .foregroundColor(.formaPrimary)
                Text(question.type.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.formaPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11))
                    .foregroundColor(.formaPrimary)
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(Color(hex: "#f3f3fb"))
            .cornerRadius(9)
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
