import SwiftUI

struct PreviewTab: View {
    @EnvironmentObject var state: AppState
    @State private var formQuestions: [Question] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Progress bar (if enabled)
                if let form = state.currentForm, form.progressBar {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color(hex: "#e7e7ef"))
                            Rectangle()
                                .fill(Color.formaPrimary)
                                .frame(width: geo.size.width * 0.35)
                        }
                    }
                    .frame(height: 4)
                }

                // Form header
                if let form = state.currentForm {
                    VStack(spacing: 0) {
                        LinearGradient(colors: [form.accentColor, form.accentColor.opacity(0.7)],
                                       startPoint: .leading, endPoint: .trailing)
                            .frame(height: 8)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(form.title.isEmpty ? "Untitled form" : form.title)
                                .font(.system(size: 23, weight: .black))
                                .foregroundColor(.formaText)
                            if !form.description.isEmpty {
                                Text(form.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.formaSecondary)
                            }
                            if form.collectEmail {
                                Divider().padding(.top, 4)
                                HStack(spacing: 6) {
                                    Image(systemName: "asterisk")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.formaDanger)
                                    Text("Indicates required question")
                                        .font(.system(size: 12))
                                        .foregroundColor(.formaDanger)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .cardShadow()

                    // Sign-in banner
                    if !state.previewSignedIn {
                        SignInBanner()
                    }

                    // Email field
                    if form.collectEmail {
                        EmailCollectionCard()
                    }

                    // Question cards
                    ForEach(form.questions.indices, id: \.self) { i in
                        PreviewQuestionCard(questionIdx: i)
                    }

                    // Submit button
                    PrimaryButton(title: "Submit") {
                        if !state.previewSignedIn && form.collectEmail {
                            withAnimation { state.overlay = .submitAuth }
                        } else {
                            state.showToast("Response submitted!")
                        }
                    }
                    .padding(.top, 4)

                    Text("Never submit passwords through Forma. This content is created by the form owner.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#aeaeb2"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Sign in banner
private struct SignInBanner: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "#f3f3fb"))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: "person").font(.system(size: 17)).foregroundColor(.formaPrimary))

            Text("Sign in to Google to save your progress. ")
                .font(.system(size: 13))
                .foregroundColor(.formaDarkText)
            + Text("Learn more")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.formaPrimary)

            Spacer()

            Button {
                withAnimation { state.previewSignedIn = true }
            } label: {
                Text("Sign in")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(Color.formaPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(TapFadeStyle())
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .cardShadow()
    }
}

// MARK: - Email collection card
private struct EmailCollectionCard: View {
    @State private var email = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Text("Email")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.formaText)
                Text("*").font(.system(size: 14)).foregroundColor(.formaDanger)
            }
            TextField("Your email", text: $email)
                .font(.system(size: 15))
                .foregroundColor(.formaText)
                .padding(.vertical, 6)
                .overlay(Rectangle().fill(Color.formaDivider).frame(height: 1), alignment: .bottom)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
    }
}

// MARK: - Preview question card
struct PreviewQuestionCard: View {
    @EnvironmentObject var state: AppState
    let questionIdx: Int

    private var question: Question? {
        guard let form = state.currentForm,
              questionIdx < form.questions.count else { return nil }
        return form.questions[questionIdx]
    }

    private func bindingForQuestion() -> Binding<Question>? {
        guard let idx = state.currentFormIndex(),
              questionIdx < state.forms[idx].questions.count else { return nil }
        return Binding(
            get: { state.forms[idx].questions[questionIdx] },
            set: { state.forms[idx].questions[questionIdx] = $0 }
        )
    }

    var body: some View {
        guard let q = question, let binding = bindingForQuestion() else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 14) {
                // Title
                HStack(alignment: .top, spacing: 4) {
                    Text(q.title.isEmpty ? "Question" : q.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.formaText)
                        .fixedSize(horizontal: false, vertical: true)
                    if q.required {
                        Text("*").font(.system(size: 14, weight: .semibold)).foregroundColor(.formaDanger)
                    }
                }

                // Question image placeholder
                if q.hasImage {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "#eef0f4"))
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "#b9b9d6"))
                        )
                }

                // Answer input
                answerInput(for: q, binding: binding)
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(16)
            .cardShadow()
        )
    }

    @ViewBuilder
    private func answerInput(for q: Question, binding: Binding<Question>) -> some View {
        switch q.type {
        case .short:
            TextField("Your answer", text: binding.answerText)
                .font(.system(size: 15))
                .foregroundColor(.formaText)
                .padding(.vertical, 6)
                .overlay(Rectangle().fill(Color.formaDivider).frame(height: 1), alignment: .bottom)

        case .paragraph:
            ZStack(alignment: .topLeading) {
                if binding.answerText.wrappedValue.isEmpty {
                    Text("Your answer").font(.system(size: 15)).foregroundColor(Color(hex: "#b6b6c2")).padding(.top, 6)
                }
                TextEditor(text: binding.answerText)
                    .font(.system(size: 15))
                    .frame(minHeight: 80)
            }
            .padding(.vertical, 2)
            .overlay(Rectangle().fill(Color.formaDivider).frame(height: 1), alignment: .bottom)

        case .mc:
            VStack(spacing: 4) {
                ForEach(q.options.indices, id: \.self) { i in
                    RadioOption(label: q.options[i], isSelected: q.selectedOption == i) {
                        binding.wrappedValue.selectedOption = (q.selectedOption == i) ? nil : i
                    }
                }
            }

        case .checkbox:
            VStack(spacing: 4) {
                ForEach(q.options.indices, id: \.self) { i in
                    CheckboxOption(label: q.options[i], isSelected: q.selectedOptions.contains(i)) {
                        if q.selectedOptions.contains(i) {
                            binding.wrappedValue.selectedOptions.remove(i)
                        } else {
                            binding.wrappedValue.selectedOptions.insert(i)
                        }
                    }
                }
            }

        case .dropdown:
            Menu {
                ForEach(q.options.indices, id: \.self) { i in
                    Button(q.options[i]) {
                        binding.wrappedValue.selectedOption = i
                    }
                }
            } label: {
                HStack {
                    Text(q.selectedOption != nil ? q.options[q.selectedOption!] : "Choose")
                        .font(.system(size: 15))
                        .foregroundColor(q.selectedOption != nil ? .formaText : Color(hex: "#b6b6c2"))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13))
                        .foregroundColor(.formaSecondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(11)
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color(hex: "#d6d6de"), lineWidth: 1))
            }

        case .scale:
            VStack(spacing: 8) {
                HStack {
                    Text("\(q.scaleMin)")
                        .font(.system(size: 13))
                        .foregroundColor(.formaSecondary)
                    Spacer()
                    Text("\(q.scaleMax)")
                        .font(.system(size: 13))
                        .foregroundColor(.formaSecondary)
                }
                HStack(spacing: 6) {
                    ForEach(q.scaleMin...q.scaleMax, id: \.self) { n in
                        Button {
                            binding.wrappedValue.selectedOption = n
                        } label: {
                            Circle()
                                .fill(q.selectedOption == n ? Color.formaPrimary : Color.white)
                                .overlay(
                                    Circle().strokeBorder(
                                        q.selectedOption == n ? Color.formaPrimary : Color(hex: "#d6d6de"),
                                        lineWidth: 1.5
                                    )
                                )
                                .overlay(
                                    Text("\(n)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(q.selectedOption == n ? .white : .formaDarkText)
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                        }
                        .buttonStyle(TapFadeStyle())
                    }
                }
            }

        case .rating:
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { n in
                    Button {
                        binding.wrappedValue.ratingValue = n
                    } label: {
                        Image(systemName: n <= q.ratingValue ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundColor(n <= q.ratingValue ? .formaStar : Color(hex: "#d2d2dc"))
                    }
                    .buttonStyle(TapFadeStyle())
                }
            }

        case .date:
            HStack(spacing: 8) {
                dateFieldBox(placeholder: "MM", value: binding.dateMonth, width: 54)
                Text("/").foregroundColor(Color(hex: "#c7c7cc"))
                dateFieldBox(placeholder: "DD", value: binding.dateDay, width: 54)
                Text("/").foregroundColor(Color(hex: "#c7c7cc"))
                dateFieldBox(placeholder: "YYYY", value: binding.dateYear, width: 66)
                Spacer()
            }

        case .time:
            HStack(spacing: 8) {
                dateFieldBox(placeholder: "HH", value: binding.timeHour, width: 54)
                Text(":").foregroundColor(Color(hex: "#c7c7cc"))
                dateFieldBox(placeholder: "MM", value: binding.timeMin, width: 54)
                HStack(spacing: 0) {
                    ampmButton("AM", current: binding.timePeriod)
                    ampmButton("PM", current: binding.timePeriod)
                }
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#d6d6de"), lineWidth: 1))
                Spacer()
            }

        case .section:
            EmptyView()

        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func dateFieldBox(placeholder: String, value: Binding<String>, width: CGFloat) -> some View {
        TextField(placeholder, text: value)
            .font(.system(size: 15))
            .foregroundColor(.formaText)
            .multilineTextAlignment(.center)
            .frame(width: width, height: 42)
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(hex: "#d6d6de"), lineWidth: 1))
    }

    @ViewBuilder
    private func ampmButton(_ label: String, current: Binding<String>) -> some View {
        Button {
            current.wrappedValue = label
        } label: {
            Text(label)
                .font(.system(size: 14, weight: current.wrappedValue == label ? .semibold : .regular))
                .foregroundColor(current.wrappedValue == label ? .white : .formaSecondary)
                .frame(width: 38, height: 42)
                .background(current.wrappedValue == label ? Color.formaPrimary : Color.clear)
        }
        .buttonStyle(TapFadeStyle())
    }
}
