import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let formBinding = state.currentFormBinding() {
                    // Notifications
                    settingsSection(title: "Response Notifications") {
                        SettingsToggleRow(label: "Push notifications", sublabel: "Notify me on this device", isOn: formBinding.pushNotif)
                        SettingsToggleRow(label: "Email notifications", sublabel: "Send to baldwin.houston.74@outlook.com", isOn: formBinding.emailNotif, isLast: true)
                    }

                    // Responses
                    settingsSection(title: "Responses") {
                        SettingsToggleRow(label: "Collect email addresses", isOn: formBinding.collectEmail)
                        SettingsToggleRow(label: "Limit to 1 response", sublabel: "Requires sign-in", isOn: formBinding.limitOne)
                        SettingsToggleRow(label: "Allow response editing", sublabel: "Respondents can change their answers after submitting", isOn: formBinding.allowEdit)
                        SettingsToggleRow(label: "View results summary", sublabel: "Respondents can see charts after submitting", isOn: formBinding.shareSummary, isLast: true)
                    }

                    // Presentation
                    settingsSection(title: "Presentation") {
                        SettingsToggleRow(label: "Show progress bar", isOn: formBinding.progressBar)
                        SettingsToggleRow(label: "Shuffle question order", isOn: formBinding.shuffle)
                        SettingsToggleRow(label: "Show link to submit another response", isOn: formBinding.submitAnother, isLast: true)
                    }

                    // Quiz
                    settingsSection(title: "Quiz") {
                        SettingsToggleRow(label: "Make this a quiz", sublabel: "Assign point values and release grades", isOn: formBinding.makeQuiz, isLast: true)
                    }
                }

                // Editors
                settingsSection(title: "Editors") {
                    // Owner row
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.formaPrimary)
                            .frame(width: 36, height: 36)
                            .overlay(Text("A").font(.system(size: 17, weight: .bold)).foregroundColor(.white))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("baldwin.houston.74@outlook.com")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.formaText)
                                .lineLimit(1)
                            Text("Owner")
                                .font(.system(size: 12.5))
                                .foregroundColor(.formaSecondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 13)
                    .background(Color.white)
                    Divider().padding(.leading, 15)
                    Button {} label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus")
                                .font(.system(size: 17))
                                .foregroundColor(.formaPrimary)
                            Text("Add a collaborator")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.formaPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 13)
                        .background(Color.white)
                    }
                    .buttonStyle(TapFadeStyle())
                }
                .padding(.bottom, 0)

                // Sign out
                Button {
                    state.showConfirm(
                        title: "Sign out?",
                        message: "You'll need to sign in again to access your forms.",
                        destructive: "Sign out"
                    ) {
                        withAnimation {
                            state.loggedIn = false
                            state.view = .login
                        }
                    }
                } label: {
                    Text("Sign out")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.formaDanger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .cornerRadius(14)
                        .cardShadow()
                }
                .buttonStyle(TapFadeStyle())

                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }

    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: title)
            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(14)
            .cardShadow()
        }
    }
}
