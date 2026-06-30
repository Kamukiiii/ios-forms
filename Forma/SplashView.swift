import SwiftUI

struct SplashView: View {
    @EnvironmentObject var state: AppState
    @State private var pulse = false
    @State private var rotate = false

    var body: some View {
        ZStack {
            LinearGradient.formaPrimaryHero
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)

                    Text("F")
                        .font(.system(size: 48, weight: .black, design: .default))
                        .foregroundColor(.formaPrimary)
                }
                .scaleEffect(pulse ? 1.04 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)

                // App name
                Text("Forma")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)
                    .padding(.top, 18)

                Spacer()

                // Loading indicator
                VStack(spacing: 14) {
                    // Spinner
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 26, height: 26)
                        .rotationEffect(.degrees(rotate ? 360 : 0))
                        .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: rotate)

                    Text("Loading your workspace…")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.bottom, 72)
            }
        }
        .onAppear {
            pulse = true
            rotate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation {
                    state.view = state.loggedIn ? .home : .login
                }
            }
        }
    }
}
