import SwiftUI

// MARK: - Home View (Dashboard Principal)
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(BankDeepLinkService.self) var bankService

    @State private var selectedPayment: Payment?
    @State private var showPaymentFlow = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DonoTheme.Spacing.lg) {

                    // MARK: - Header / Greeting
                    headerSection

                    // MARK: - Monthly Summary Card
                    monthlySummaryCard

                    // MARK: - Today's Payments
                    if !viewModel.todayPayments.isEmpty {
                        todaySection
                    }

                    // MARK: - Upcoming Payments
                    if !viewModel.upcomingPayments.isEmpty {
                        upcomingSection
                    }

                    // MARK: - Overdue Payments
                    if !viewModel.overduePayments.isEmpty {
                        overdueSection
                    }

                    // MARK: - Empty State
                    if viewModel.allPayments.isEmpty {
                        DonoEmptyState(
                            icon: "house",
                            title: "Bem-vindo ao Dono",
                            description: "Cadastre seus prestadores de serviço para começar a organizar seus pagamentos.",
                            actionTitle: "Adicionar prestador"
                        ) {
                            // Navigate to add provider
                        }
                    }

                    Spacer(minLength: DonoTheme.Spacing.xxxl)
                }
                .padding(.horizontal, DonoTheme.Spacing.md)
            }
            .background(DonoTheme.Colors.background)
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showPaymentFlow) {
                if let payment = selectedPayment {
                    PaymentFlowView(payment: payment)
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                Text(viewModel.greeting)
                    .font(DonoTheme.Typography.subheadline)
                    .foregroundColor(DonoTheme.Colors.textSecondary)

                Text(viewModel.userName)
                    .font(.custom("PlayfairDisplay-Bold", size: 28))
                    .foregroundColor(DonoTheme.Colors.textPrimary)
            }

            Spacer()

            DonoIconButton("bell") {
                // Notifications
            }
        }
        .padding(.top, DonoTheme.Spacing.md)
    }

    // MARK: - Monthly Summary
    private var monthlySummaryCard: some View {
        VStack(spacing: DonoTheme.Spacing.md) {
            // Month label
            HStack {
                Text(viewModel.currentMonthLabel)
                    .font(DonoTheme.Typography.captionMedium)
                    .foregroundColor(DonoTheme.Colors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1)
                Spacer()
            }

            // Totals
            HStack(spacing: DonoTheme.Spacing.xl) {
                // Paid
                VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                    Text("Pago")
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(DonoTheme.Colors.success)
                    Text(viewModel.totalPaid.brlFormatted)
                        .font(DonoTheme.Typography.moneyMedium)
                        .foregroundColor(DonoTheme.Colors.textPrimary)
                }

                // Divider
                Rectangle()
                    .fill(DonoTheme.Colors.divider)
                    .frame(width: 1, height: 40)

                // Pending
                VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                    Text("Pendente")
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(DonoTheme.Colors.warning)
                    Text(viewModel.totalPending.brlFormatted)
                        .font(DonoTheme.Typography.moneyMedium)
                        .foregroundColor(DonoTheme.Colors.textPrimary)
                }

                Spacer()
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DonoTheme.Colors.surface)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(DonoTheme.Colors.success)
                        .frame(width: geo.size.width * viewModel.completionRate, height: 6)
                        .animation(DonoTheme.Animation.springGentle, value: viewModel.completionRate)
                }
            }
            .frame(height: 6)

            // Count
            HStack {
                Text("\(viewModel.paidCount) de \(viewModel.totalCount) pagamentos realizados")
                    .font(DonoTheme.Typography.caption)
                    .foregroundColor(DonoTheme.Colors.textTertiary)
                Spacer()
            }
        }
        .padding(DonoTheme.Spacing.lg)
        .background(DonoTheme.Colors.background)
        .overlay(
            RoundedRectangle(cornerRadius: DonoTheme.Radius.lg)
                .strokeBorder(DonoTheme.Colors.divider, lineWidth: 1)
        )
    }

    // MARK: - Today Section
    private var todaySection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Hoje", actionTitle: nil, action: nil)

            ForEach(viewModel.todayPayments, id: \.id) { payment in
                PaymentCardView(payment: payment) {
                    selectedPayment = payment
                    showPaymentFlow = true
                }
            }
        }
    }

    // MARK: - Upcoming Section
    private var upcomingSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Próximos", actionTitle: "Ver todos") {
                // Navigate to calendar
            }

            ForEach(viewModel.upcomingPayments.prefix(5), id: \.id) { payment in
                PaymentCardView(payment: payment) {
                    selectedPayment = payment
                    showPaymentFlow = true
                }
            }
        }
    }

    // MARK: - Overdue Section
    private var overdueSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Atrasados")

            ForEach(viewModel.overduePayments, id: \.id) { payment in
                PaymentCardView(payment: payment, isUrgent: true) {
                    selectedPayment = payment
                    showPaymentFlow = true
                }
            }
        }
    }
}
