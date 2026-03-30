import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var payments: [Payment] = []
    @State private var selectedPayment: Payment?
    @State private var showPaymentFlow = false

    private let calendar = Calendar.current
    private let daysOfWeek = ["D", "S", "T", "Q", "Q", "S", "S"]

    var paymentsForSelectedDate: [Payment] {
        payments.filter { calendar.isDate($0.dueDate, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month navigation
                monthHeader

                // Days of week header
                daysOfWeekHeader

                // Calendar grid
                calendarGrid

                DonoDivider()

                // Payments for selected day
                selectedDayPayments
            }
            .background(DonoTheme.Colors.background)
            .navigationTitle("Calendário")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaymentFlow) {
                if let payment = selectedPayment {
                    PaymentFlowView(payment: payment)
                }
            }
            .task {
                await loadPayments()
            }
        }
    }

    // MARK: - Month Header
    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(DonoTheme.Animation.springGentle) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DonoTheme.Colors.textSecondary)
            }

            Spacer()

            Text(monthYearString)
                .font(.custom("PlayfairDisplay-SemiBold", size: 18))
                .foregroundColor(DonoTheme.Colors.textPrimary)

            Spacer()

            Button {
                withAnimation(DonoTheme.Animation.springGentle) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DonoTheme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DonoTheme.Spacing.lg)
        .padding(.vertical, DonoTheme.Spacing.md)
    }

    // MARK: - Days of Week
    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(DonoTheme.Typography.captionMedium)
                    .foregroundColor(DonoTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, DonoTheme.Spacing.md)
        .padding(.bottom, DonoTheme.Spacing.sm)
    }

    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        let days = generateDays()

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: DonoTheme.Spacing.sm) {
            ForEach(days, id: \.self) { date in
                if let date {
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        payments: paymentsForDate(date)
                    ) {
                        withAnimation(DonoTheme.Animation.springGentle) {
                            selectedDate = date
                        }
                        DonoTheme.Haptics.selection()
                    }
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal, DonoTheme.Spacing.md)
    }

    // MARK: - Selected Day Payments
    private var selectedDayPayments: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DonoTheme.Spacing.sm) {
                HStack {
                    Text(selectedDateFormatted)
                        .font(DonoTheme.Typography.headline)
                        .foregroundColor(DonoTheme.Colors.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, DonoTheme.Spacing.md)
                .padding(.top, DonoTheme.Spacing.md)

                if paymentsForSelectedDate.isEmpty {
                    Text("Nenhum pagamento neste dia")
                        .font(DonoTheme.Typography.subheadline)
                        .foregroundColor(DonoTheme.Colors.textTertiary)
                        .padding(.vertical, DonoTheme.Spacing.xl)
                } else {
                    ForEach(paymentsForSelectedDate, id: \.id) { payment in
                        PaymentCardView(payment: payment) {
                            selectedPayment = payment
                            showPaymentFlow = true
                        }
                        .padding(.horizontal, DonoTheme.Spacing.md)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth).capitalized
    }

    private var selectedDateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d 'de' MMMM"
        return formatter.string(from: selectedDate)
    }

    private func paymentsForDate(_ date: Date) -> [Payment] {
        payments.filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
    }

    private func generateDays() -> [Date?] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: start) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: start)!.count

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: start) {
                days.append(date)
            }
        }

        // Pad remaining
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func loadPayments() async {
        // Load from Supabase
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let payments: [Payment]
    let action: () -> Void

    private var dayNumber: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    private var hasPayments: Bool { !payments.isEmpty }
    private var hasPending: Bool { payments.contains { $0.isPending } }
    private var hasOverdue: Bool { payments.contains { $0.isOverdue } }
    private var allPaid: Bool { hasPayments && payments.allSatisfy { $0.isPaid } }

    private var dotColor: Color {
        if hasOverdue { return DonoTheme.Colors.error }
        if hasPending { return DonoTheme.Colors.warning }
        if allPaid { return DonoTheme.Colors.success }
        return .clear
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                    .foregroundColor(
                        isSelected ? .white :
                        isToday ? DonoTheme.Colors.accent :
                        DonoTheme.Colors.textPrimary
                    )

                Circle()
                    .fill(dotColor)
                    .frame(width: 5, height: 5)
                    .opacity(hasPayments ? 1 : 0)
            }
            .frame(width: 36, height: 44)
            .background(
                Circle()
                    .fill(isSelected ? DonoTheme.Colors.accent : Color.clear)
                    .frame(width: 36, height: 36)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
