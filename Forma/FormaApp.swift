import SwiftUI

@main
struct FormaApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack {
            Group {
                switch state.view {
                case .loading:
                    SplashView()
                        .transition(.opacity)
                case .login:
                    LoginView()
                        .transition(.opacity)
                case .home:
                    HomeView()
                        .transition(.opacity)
                case .editor:
                    EditorView()
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: state.view)

            if let msg = state.toast {
                VStack {
                    Spacer()
                    ToastView(message: msg)
                        .padding(.bottom, 120)
                }
                .transition(.scale(scale: 0.94).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: state.toast)
                .zIndex(200)
                .allowsHitTesting(false)
            }
        }
    }
}
