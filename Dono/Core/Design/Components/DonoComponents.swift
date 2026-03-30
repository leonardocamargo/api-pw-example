import SwiftUI

// MARK: - Status Badge
struct DonoStatusBadge: View {
    let status: PaymentStatus

    var body: some View {
        Text(status.label)
            .font(DonoTheme.Typography.captionMedium)
            .foregroundColor(status.color)
            .padding(.horizontal, DonoTheme.Spacing.sm)
            .padding(.vertical, DonoTheme.Spacing.xs)
            .background(status.backgroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - Category Icon
struct DonoCategoryIcon: View {
    let category: ProviderCategory
    let size: CGFloat

    init(_ category: ProviderCategory, size: CGFloat = 44) {
        self.category = category
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(category.color.opacity(0.12))
                .frame(width: size, height: size)

            Image(systemName: category.icon)
                .font(.system(size: size * 0.38, weight: .medium))
                .foregroundColor(category.color)
        }
    }
}

// MARK: - Avatar / Initial
struct DonoAvatar: View {
    let name: String
    let size: CGFloat

    init(_ name: String, size: CGFloat = 48) {
        self.name = name
        self.size = size
    }

    private var initial: String {
        String(name.prefix(1)).uppercased()
    }

    private var backgroundColor: Color {
        let colors: [Color] = [
            DonoTheme.Colors.accent,
            DonoTheme.Colors.success,
            DonoTheme.Colors.warning,
            Color(hex: "8B7EC8"),
            Color(hex: "6BA3BE"),
        ]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.opacity(0.15))
                .frame(width: size, height: size)

            Text(initial)
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundColor(backgroundColor)
        }
    }
}

// MARK: - Divider
struct DonoDivider: View {
    var body: some View {
        Rectangle()
            .fill(DonoTheme.Colors.divider)
            .frame(height: 1)
    }
}

// MARK: - Empty State
struct DonoEmptyState: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(icon: String, title: String, description: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DonoTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(DonoTheme.Colors.textTertiary)

            VStack(spacing: DonoTheme.Spacing.sm) {
                Text(title)
                    .font(DonoTheme.Typography.headline)
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                Text(description)
                    .font(DonoTheme.Typography.subheadline)
                    .foregroundColor(DonoTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            if let actionTitle, let action {
                DonoPrimaryButton(actionTitle, action: action)
                    .frame(width: 220)
            }
        }
        .padding(DonoTheme.Spacing.xxl)
    }
}

// MARK: - Section Header
struct DonoSectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(_ title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .font(DonoTheme.Typography.captionMedium)
                .foregroundColor(DonoTheme.Colors.textTertiary)
                .textCase(.uppercase)
                .tracking(1)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DonoTheme.Typography.captionMedium)
                        .foregroundColor(DonoTheme.Colors.accent)
                }
            }
        }
        .padding(.horizontal, DonoTheme.Spacing.md)
    }
}

// MARK: - Input Field
struct DonoTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
            Text(label)
                .font(DonoTheme.Typography.captionMedium)
                .foregroundColor(DonoTheme.Colors.textSecondary)

            HStack(spacing: DonoTheme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(DonoTheme.Colors.textTertiary)
                }

                TextField(placeholder, text: $text)
                    .font(DonoTheme.Typography.body)
                    .foregroundColor(DonoTheme.Colors.textPrimary)
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, DonoTheme.Spacing.md)
            .frame(height: 52)
            .background(DonoTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                    .strokeBorder(DonoTheme.Colors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Money Input
struct DonoMoneyInput: View {
    let label: String
    @Binding var amount: Double

    @State private var textValue: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
            Text(label)
                .font(DonoTheme.Typography.captionMedium)
                .foregroundColor(DonoTheme.Colors.textSecondary)

            HStack(spacing: DonoTheme.Spacing.sm) {
                Text("R$")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(DonoTheme.Colors.textTertiary)

                TextField("0,00", text: $textValue)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(DonoTheme.Colors.textPrimary)
                    .keyboardType(.decimalPad)
                    .onChange(of: textValue) { _, newValue in
                        let cleaned = newValue.replacingOccurrences(of: ",", with: ".")
                        amount = Double(cleaned) ?? 0
                    }
            }
            .padding(.horizontal, DonoTheme.Spacing.md)
            .frame(height: 52)
            .background(DonoTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                    .strokeBorder(DonoTheme.Colors.border, lineWidth: 1)
            )
        }
        .onAppear {
            if amount > 0 {
                textValue = String(format: "%.2f", amount).replacingOccurrences(of: ".", with: ",")
            }
        }
    }
}

// MARK: - Toast / Snackbar
struct DonoToast: View {
    let message: String
    let type: ToastType

    enum ToastType {
        case success, error, info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return DonoTheme.Colors.success
            case .error: return DonoTheme.Colors.error
            case .info: return DonoTheme.Colors.accent
            }
        }
    }

    var body: some View {
        HStack(spacing: DonoTheme.Spacing.sm) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)

            Text(message)
                .font(DonoTheme.Typography.subheadline)
                .foregroundColor(DonoTheme.Colors.textPrimary)
        }
        .padding(.horizontal, DonoTheme.Spacing.md)
        .padding(.vertical, DonoTheme.Spacing.sm + 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .donoShadow(DonoTheme.Shadows.medium)
    }
}
