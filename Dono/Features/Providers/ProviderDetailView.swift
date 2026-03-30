import SwiftUI

// MARK: - Provider Detail View
struct ProviderDetailView: View {
    let provider: Provider

    @State private var payments: [Payment] = []
    @State private var showEditSheet = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DonoTheme.Spacing.xl) {

                // Header
                VStack(spacing: DonoTheme.Spacing.md) {
                    DonoAvatar(provider.name, size: 72)

                    Text(provider.name)
                        .font(.custom("PlayfairDisplay-Bold", size: 24))
                        .foregroundColor(DonoTheme.Colors.textPrimary)

                    HStack(spacing: DonoTheme.Spacing.md) {
                        DonoCategoryIcon(provider.category, size: 24)
                        Text(provider.category.label)
                            .font(DonoTheme.Typography.subheadline)
                            .foregroundColor(DonoTheme.Colors.textSecondary)

                        Text("·")

                        Text(provider.frequency.label)
                            .font(DonoTheme.Typography.subheadline)
                            .foregroundColor(DonoTheme.Colors.textSecondary)

                        Text("·")

                        Text("Dia \(provider.dueDay)")
                            .font(DonoTheme.Typography.subheadline)
                            .foregroundColor(DonoTheme.Colors.textSecondary)
                    }
                }
                .padding(.top, DonoTheme.Spacing.md)

                // Amount
                Text(provider.defaultAmount.brlFormatted)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                // Pix Info
                VStack(alignment: .leading, spacing: DonoTheme.Spacing.md) {
                    DonoSectionHeader("Dados Pix")

                    VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                        DetailRow(label: "Chave", value: provider.pixKey)
                        DonoDivider()
                        DetailRow(label: "Tipo", value: provider.pixKeyType.label)
                    }
                    .padding(DonoTheme.Spacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                            .strokeBorder(DonoTheme.Colors.divider, lineWidth: 1)
                    )
                }
                .padding(.horizontal, DonoTheme.Spacing.md)

                // Notes
                if let notes = provider.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                        DonoSectionHeader("Observações")
                        Text(notes)
                            .font(DonoTheme.Typography.body)
                            .foregroundColor(DonoTheme.Colors.textSecondary)
                            .padding(.horizontal, DonoTheme.Spacing.md)
                    }
                }

                // Payment History
                VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                    DonoSectionHeader("Histórico recente", actionTitle: "Ver tudo") {
                        // Navigate to full history
                    }

                    if payments.isEmpty {
                        Text("Nenhum pagamento registrado")
                            .font(DonoTheme.Typography.subheadline)
                            .foregroundColor(DonoTheme.Colors.textTertiary)
                            .padding(.horizontal, DonoTheme.Spacing.md)
                            .padding(.vertical, DonoTheme.Spacing.lg)
                    } else {
                        ForEach(payments.prefix(5), id: \.id) { payment in
                            HistoryRow(payment: payment)
                        }
                    }
                }

                Spacer(minLength: DonoTheme.Spacing.xxxl)
            }
        }
        .background(DonoTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DonoIconButton("pencil") {
                    showEditSheet = true
                }
            }
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(DonoTheme.Typography.subheadline)
                .foregroundColor(DonoTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(DonoTheme.Typography.bodyMedium)
                .foregroundColor(DonoTheme.Colors.textPrimary)
        }
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let payment: Payment

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                Text(payment.dueDateFormatted)
                    .font(DonoTheme.Typography.bodyMedium)
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                if let paidAt = payment.paidAtFormatted {
                    Text("Pago em \(paidAt)")
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(DonoTheme.Colors.textTertiary)
                }
            }

            Spacer()

            HStack(spacing: DonoTheme.Spacing.sm) {
                Text(payment.amount.brlFormatted)
                    .font(DonoTheme.Typography.moneySmall)
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                DonoStatusBadge(status: payment.status)
            }
        }
        .padding(.horizontal, DonoTheme.Spacing.md)
        .padding(.vertical, DonoTheme.Spacing.sm)
    }
}
