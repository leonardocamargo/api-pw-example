import SwiftUI

// MARK: - History View
struct HistoryView: View {
    @State private var payments: [Payment] = []
    @State private var selectedMonth = Date()
    @State private var filterStatus: PaymentStatus?
    @State private var isLoading = false

    private var filteredPayments: [Payment] {
        guard let status = filterStatus else { return payments }
        return payments.filter { $0.status == status }
    }

    private var summary: MonthlySummary {
        MonthlySummary(
            month: selectedMonth,
            totalPaid: payments.filter { $0.isPaid }.reduce(0) { $0 + $1.amount },
            totalPending: payments.filter { $0.isPending }.reduce(0) { $0 + $1.amount },
            totalOverdue: payments.filter { $0.isOverdue }.reduce(0) { $0 + $1.amount },
            paymentCount: payments.count,
            paidCount: payments.filter { $0.isPaid }.count
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DonoTheme.Spacing.lg) {

                    // Month selector
                    monthSelector

                    // Summary card
                    summaryCard

                    // Status filters
                    statusFilters

                    // Payment list
                    if filteredPayments.isEmpty {
                        DonoEmptyState(
                            icon: "clock.arrow.circlepath",
                            title: "Sem pagamentos",
                            description: "Nenhum pagamento encontrado para este período."
                        )
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredPayments, id: \.id) { payment in
                                HistoryRow(payment: payment)
                                if payment.id != filteredPayments.last?.id {
                                    DonoDivider()
                                        .padding(.leading, DonoTheme.Spacing.md)
                                }
                            }
                        }
                    }

                    Spacer(minLength: DonoTheme.Spacing.xxxl)
                }
                .padding(.horizontal, DonoTheme.Spacing.md)
            }
            .background(DonoTheme.Colors.background)
            .navigationTitle("Histórico")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DonoIconButton("square.and.arrow.up") {
                        // Export PDF
                    }
                }
            }
            .task {
                await loadPayments()
            }
        }
    }

    // MARK: - Month Selector
    private var monthSelector: some View {
        HStack {
            Button {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                }
                Task { await loadPayments() }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(DonoTheme.Colors.textSecondary)
            }

            Spacer()

            Text(summary.monthFormatted)
                .font(.custom("PlayfairDisplay-SemiBold", size: 18))
                .foregroundColor(DonoTheme.Colors.textPrimary)

            Spacer()

            Button {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                }
                Task { await loadPayments() }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(DonoTheme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DonoTheme.Spacing.md)
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: DonoTheme.Spacing.md) {
            HStack(spacing: DonoTheme.Spacing.lg) {
                SummaryItem(
                    label: "Total pago",
                    amount: summary.totalPaid,
                    color: DonoTheme.Colors.success
                )

                SummaryItem(
                    label: "Pendente",
                    amount: summary.totalPending,
                    color: DonoTheme.Colors.warning
                )

                SummaryItem(
                    label: "Atrasado",
                    amount: summary.totalOverdue,
                    color: DonoTheme.Colors.error
                )
            }

            // Progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DonoTheme.Colors.surface)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(DonoTheme.Colors.success)
                        .frame(width: geo.size.width * summary.completionRate, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(summary.paidCount)/\(summary.paymentCount) pagamentos")
                .font(DonoTheme.Typography.caption)
                .foregroundColor(DonoTheme.Colors.textTertiary)
        }
        .padding(DonoTheme.Spacing.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DonoTheme.Radius.lg)
                .strokeBorder(DonoTheme.Colors.divider, lineWidth: 1)
        )
    }

    // MARK: - Status Filters
    private var statusFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DonoTheme.Spacing.sm) {
                FilterChip(label: "Todos", isSelected: filterStatus == nil) {
                    filterStatus = nil
                }
                ForEach(PaymentStatus.allCases, id: \.rawValue) { status in
                    FilterChip(label: status.label, isSelected: filterStatus == status) {
                        filterStatus = filterStatus == status ? nil : status
                    }
                }
            }
        }
    }

    private func loadPayments() async {
        isLoading = true
        defer { isLoading = false }
        // Fetch from Supabase for selectedMonth
    }
}

// MARK: - Summary Item
struct SummaryItem: View {
    let label: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
            Text(label)
                .font(DonoTheme.Typography.caption)
                .foregroundColor(color)
            Text(amount.brlFormatted)
                .font(DonoTheme.Typography.moneySmall)
                .foregroundColor(DonoTheme.Colors.textPrimary)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            DonoTheme.Haptics.selection()
        }) {
            Text(label)
                .font(DonoTheme.Typography.captionMedium)
                .foregroundColor(isSelected ? .white : DonoTheme.Colors.textSecondary)
                .padding(.horizontal, DonoTheme.Spacing.md)
                .padding(.vertical, DonoTheme.Spacing.sm)
                .background(isSelected ? DonoTheme.Colors.accent : DonoTheme.Colors.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : DonoTheme.Colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
