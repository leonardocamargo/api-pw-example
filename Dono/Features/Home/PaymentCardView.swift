import SwiftUI

// MARK: - Payment Card
// Card orgânico, sem bordas quadradas, separação por linhas finas

struct PaymentCardView: View {
    let payment: Payment
    var isUrgent: Bool = false
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            DonoTheme.Haptics.light()
            onTap()
        }) {
            HStack(spacing: DonoTheme.Spacing.md) {
                // Avatar / Category icon
                if let provider = payment.provider {
                    DonoAvatar(provider.name)
                } else {
                    DonoAvatar("?")
                }

                // Info
                VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                    Text(payment.provider?.name ?? "Prestador")
                        .font(DonoTheme.Typography.bodyMedium)
                        .foregroundColor(DonoTheme.Colors.textPrimary)

                    HStack(spacing: DonoTheme.Spacing.sm) {
                        Text(payment.dueDateFormatted)
                            .font(DonoTheme.Typography.caption)
                            .foregroundColor(
                                isUrgent ? DonoTheme.Colors.error : DonoTheme.Colors.textSecondary
                            )

                        if let category = payment.provider?.category {
                            Text("·")
                                .foregroundColor(DonoTheme.Colors.textTertiary)
                            Text(category.label)
                                .font(DonoTheme.Typography.caption)
                                .foregroundColor(DonoTheme.Colors.textTertiary)
                        }
                    }
                }

                Spacer()

                // Amount & Status
                VStack(alignment: .trailing, spacing: DonoTheme.Spacing.xs) {
                    Text(payment.amount.brlFormatted)
                        .font(DonoTheme.Typography.moneySmall)
                        .foregroundColor(DonoTheme.Colors.textPrimary)

                    DonoStatusBadge(status: payment.status)
                }
            }
            .padding(.vertical, DonoTheme.Spacing.md)
            .padding(.horizontal, DonoTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DonoTheme.Radius.lg)
                    .fill(isUrgent ? DonoTheme.Colors.accentSubtle.opacity(0.5) : DonoTheme.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DonoTheme.Radius.lg)
                    .strokeBorder(
                        isUrgent ? DonoTheme.Colors.accent.opacity(0.3) : DonoTheme.Colors.divider,
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
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

// MARK: - Payment Card Skeleton (Loading)
struct PaymentCardSkeleton: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: DonoTheme.Spacing.md) {
            Circle()
                .fill(DonoTheme.Colors.surface)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DonoTheme.Colors.surface)
                    .frame(width: 120, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(DonoTheme.Colors.surface)
                    .frame(width: 80, height: 10)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DonoTheme.Spacing.sm) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DonoTheme.Colors.surface)
                    .frame(width: 80, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(DonoTheme.Colors.surface)
                    .frame(width: 60, height: 10)
            }
        }
        .padding(.vertical, DonoTheme.Spacing.md)
        .padding(.horizontal, DonoTheme.Spacing.md)
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear { isAnimating = true }
    }
}
