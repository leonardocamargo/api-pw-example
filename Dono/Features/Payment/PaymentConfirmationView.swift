import SwiftUI

// MARK: - Payment Confirmation View
// Mostrado quando o usuário volta do banco

struct PaymentConfirmationView: View {
    let paymentId: UUID

    @Environment(\.dismiss) var dismiss
    @State private var showSuccess = false
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: DonoTheme.Spacing.xl) {
            Spacer()

            if showSuccess {
                successState
            } else {
                questionState
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DonoTheme.Colors.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(isProcessing)
    }

    // MARK: - Question State
    private var questionState: some View {
        VStack(spacing: DonoTheme.Spacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(DonoTheme.Colors.accentSubtle)
                    .frame(width: 80, height: 80)

                Image(systemName: "questionmark")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(DonoTheme.Colors.accent)
            }

            // Text
            VStack(spacing: DonoTheme.Spacing.sm) {
                Text("Pagou?")
                    .font(.custom("PlayfairDisplay-Bold", size: 28))
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                Text("Confirme para atualizar seu histórico")
                    .font(DonoTheme.Typography.subheadline)
                    .foregroundColor(DonoTheme.Colors.textSecondary)
            }

            // Buttons
            VStack(spacing: DonoTheme.Spacing.md) {
                DonoPrimaryButton("Sim, paguei!", icon: "checkmark.circle", isLoading: isProcessing) {
                    Task {
                        await confirmPayment()
                    }
                }

                DonoSecondaryButton("Ainda não") {
                    dismiss()
                }
            }
            .padding(.horizontal, DonoTheme.Spacing.lg)
        }
    }

    // MARK: - Success State
    private var successState: some View {
        VStack(spacing: DonoTheme.Spacing.lg) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(DonoTheme.Colors.successLight)
                    .frame(width: 100, height: 100)
                    .scaleEffect(showSuccess ? 1.0 : 0.5)

                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(DonoTheme.Colors.success)
                    .scaleEffect(showSuccess ? 1.0 : 0.0)
            }
            .animation(DonoTheme.Animation.springBouncy, value: showSuccess)

            Text("Pagamento confirmado!")
                .font(.custom("PlayfairDisplay-SemiBold", size: 22))
                .foregroundColor(DonoTheme.Colors.textPrimary)
                .opacity(showSuccess ? 1.0 : 0.0)
                .animation(DonoTheme.Animation.slow.delay(0.2), value: showSuccess)
        }
        .onAppear {
            // Auto dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func confirmPayment() async {
        isProcessing = true
        DonoTheme.Haptics.success()

        do {
            try await SupabaseService.shared.markPaymentAsPaid(id: paymentId)
            NotificationService.shared.cancelReminder(for: paymentId)

            withAnimation {
                showSuccess = true
            }
        } catch {
            isProcessing = false
        }
    }
}
