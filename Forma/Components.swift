import SwiftUI

// MARK: - FormaToggle
struct FormaToggle: View {
    @Binding var isOn: Bool
    var size: ToggleSize = .standard
    var tint: Color = .formaSuccess

    enum ToggleSize {
        case standard   // 51×31, knob 27
        case small      // 38×23, knob 19
    }

    private var width: CGFloat  { size == .standard ? 51 : 38 }
    private var height: CGFloat { size == .standard ? 31 : 23 }
    private var knob: CGFloat   { size == .standard ? 27 : 19 }
    private var onOff: CGFloat  { size == .standard ? 22 : 17 }

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            RoundedRectangle(cornerRadius: height/2, style: .continuous)
                .fill(isOn ? tint : Color.formaInputBg)
                .frame(width: width, height: height)
                .animation(.easeInOut(duration: 0.2), value: isOn)

            Circle()
                .fill(Color.white)
                .frame(width: knob, height: knob)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .padding(2)
        }
        .frame(width: width, height: height)
        .onTapGesture { withAnimation { isOn.toggle() } }
    }
}

// MARK: - FormaSegmentedControl
struct FormaSegmentedControl<T: Hashable>: View {
    let items: [(label: String, value: T)]
    @Binding var selection: T
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(items, id: \.value) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selection = item.value }
                } label: {
                    Text(item.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selection == item.value ? .formaPrimary : Color(hex: "#8a8a94"))
                        .frame(maxWidth: .infinity)
                        .frame(height: compact ? 28 : 32)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(selection == item.value ? Color.white : Color.clear)
                        )
                }
                .buttonStyle(TapFadeStyle())
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.formaInputBg)
        )
    }
}

// MARK: - ToastView
struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.88))
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)
            )
    }
}

// MARK: - FormThumbnail (mini preview card)
struct FormThumbnail: View {
    let accentColor: Color
    var size: CGSize = CGSize(width: 50, height: 62)

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.formaGhostBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(hex: "#ededf3"), lineWidth: 1)
                )

            VStack(spacing: 0) {
                // accent top bar
                accentColor
                    .frame(height: max(size.height * 0.22, 12))

                // placeholder lines
                VStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "#e3e3ea"))
                            .frame(height: 3)
                            .padding(.horizontal, i == 2 ? 12 : 6)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }
}

// MARK: - FormThumbnailLarge (grid card top)
struct FormThumbnailLarge: View {
    let accentColor: Color

    var body: some View {
        ZStack(alignment: .top) {
            Color.formaFaintBg
            VStack(spacing: 0) {
                accentColor.frame(height: 10)
                VStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "#e3e3ea"))
                            .frame(height: 3)
                            .padding(.horizontal, i == 3 ? 24 : 12)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 100)
        .background(
            Rectangle()
                .fill(Color(hex: "#f0f0f5"))
                .frame(height: 1), alignment: .bottom
        )
    }
}

// MARK: - StarButton
struct StarButton: View {
    var isStarred: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isStarred ? "star.fill" : "star")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isStarred ? .formaStar : Color(hex: "#c1c1c9"))
                .frame(width: 34, height: 34)
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Icon circle button
struct CircleIconButton: View {
    let symbol: String
    var size: CGFloat = 36
    var iconSize: CGFloat = 17
    var fg: Color = .formaPrimary
    var bg: Color = Color(hex: "#f3f3fb")
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: iconSize, weight: .regular))
                .foregroundColor(fg)
                .frame(width: size, height: size)
                .background(
                    Circle().fill(bg)
                )
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Primary button
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon).font(.system(size: 17, weight: .semibold)) }
                Text(title).font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(LinearGradient.formaPrimaryDiag)
            .cornerRadius(14)
            .deepShadow()
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Settings toggle row
struct SettingsToggleRow: View {
    let label: String
    var sublabel: String? = nil
    @Binding var isOn: Bool
    var isLast: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.formaText)
                if let sub = sublabel {
                    Text(sub)
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundColor(.formaSecondary)
                }
            }
            Spacer()
            FormaToggle(isOn: $isOn)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(Color.white)
        if !isLast {
            Divider()
                .background(Color(hex: "#f2f2f5"))
                .padding(.leading, 15)
        }
    }
}

// MARK: - Section header label
struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12.5, weight: .bold))
            .foregroundColor(.formaTertiary)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Radio option
struct RadioOption: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.formaPrimary : Color(hex: "#c7c7d2"), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.formaPrimary)
                            .frame(width: 12, height: 12)
                    }
                }
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.formaDarkText)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color(hex: "#f4f4fd") : Color.clear)
            )
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Checkbox option
struct CheckboxOption: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(isSelected ? Color.formaPrimary : Color(hex: "#c7c7d2"), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(isSelected ? Color.formaPrimary : Color.clear)
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.formaDarkText)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color(hex: "#f4f4fd") : Color.clear)
            )
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Nav bar back button
struct NavBackButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .regular))
            }
            .foregroundColor(.formaPrimary)
        }
        .buttonStyle(TapFadeStyle())
    }
}

// MARK: - Pro badge
struct ProBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10, weight: .bold))
            Text("PRO")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 9)
        .frame(height: 24)
        .background(LinearGradient.formaPrimaryDiag)
        .clipShape(Capsule())
    }
}

// MARK: - Empty state
struct EmptyStateView: View {
    let symbol: String
    let title: String
    let subtitle: String
    var buttonLabel: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(hex: "#e9e9f3"))
                    .frame(width: 96, height: 96)
                Image(systemName: symbol)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(Color(hex: "#9a9aa8"))
            }
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.formaText)
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(.formaSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 280)
            if let label = buttonLabel, let action = buttonAction {
                Button(action: action) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 46)
                        .background(Color.formaPrimary)
                        .cornerRadius(13)
                }
                .buttonStyle(TapFadeStyle())
                .padding(.top, 6)
            }
        }
        .padding(.horizontal, 24)
    }
}
