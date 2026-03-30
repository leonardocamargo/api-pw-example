import SwiftUI

// MARK: - Primary Button
struct DonoPrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, icon: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            DonoTheme.Haptics.medium()
            action()
        }) {
            HStack(spacing: DonoTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(DonoTheme.Typography.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(DonoTheme.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.lg))
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(DonoTheme.Animation.springGentle, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Secondary Button
struct DonoSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            DonoTheme.Haptics.light()
            action()
        }) {
            HStack(spacing: DonoTheme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(DonoTheme.Typography.bodyMedium)
            }
            .foregroundColor(DonoTheme.Colors.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(DonoTheme.Colors.accentSubtle)
            .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DonoTheme.Radius.lg)
                    .strokeBorder(DonoTheme.Colors.accent.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(DonoTheme.Animation.springGentle, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Ghost Button
struct DonoGhostButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            DonoTheme.Haptics.light()
            action()
        }) {
            HStack(spacing: DonoTheme.Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(DonoTheme.Typography.bodyMedium)
            }
            .foregroundColor(DonoTheme.Colors.textSecondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Icon Button
struct DonoIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(_ icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            DonoTheme.Haptics.selection()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DonoTheme.Colors.textSecondary)
                .frame(width: size, height: size)
                .background(DonoTheme.Colors.surface)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(DonoTheme.Animation.springBouncy, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Pay Button (the hero button)
struct DonoPayButton: View {
    let bankName: String
    let amount: Double
    let isLoading: Bool
    let action: () -> Void

    init(bankName: String, amount: Double, isLoading: Bool = false, action: @escaping () -> Void) {
        self.bankName = bankName
        self.amount = amount
        self.isLoading = isLoading
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            DonoTheme.Haptics.medium()
            action()
        }) {
            VStack(spacing: DonoTheme.Spacing.sm) {
                HStack(spacing: DonoTheme.Spacing.sm) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Copiar Pix e abrir \(bankName)")
                        .font(DonoTheme.Typography.headline)
                }

                Text(amount.brlFormatted)
                    .font(DonoTheme.Typography.moneySmall)
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                LinearGradient(
                    colors: [DonoTheme.Colors.accent, DonoTheme.Colors.accent.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.xl))
            .donoShadow(ShadowStyle(
                color: DonoTheme.Colors.accent.opacity(0.3),
                radius: 16,
                x: 0,
                y: 8
            ))
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(DonoTheme.Animation.springBouncy, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Previews
#Preview("Buttons") {
    VStack(spacing: 16) {
        DonoPrimaryButton("Adicionar Prestador", icon: "plus") {}
        DonoSecondaryButton("Ver Histórico", icon: "clock") {}
        DonoPayButton(bankName: "Nubank", amount: 250.0) {}
        DonoGhostButton("Pular", icon: "arrow.right") {}
    }
    .padding(24)
    .background(Color(hex: "FAFAF8"))
}
