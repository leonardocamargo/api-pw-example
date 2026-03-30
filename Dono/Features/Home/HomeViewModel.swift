import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var allPayments: [Payment] = []
    @Published var providers: [Provider] = []
    @Published var isLoading = false

    // MARK: - Computed

    var userName: String {
        "Leonardo" // TODO: Pull from Supabase profile
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bom dia,"
        case 12..<18: return "Boa tarde,"
        default: return "Boa noite,"
        }
    }

    var currentMonthLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    var todayPayments: [Payment] {
        allPayments.filter { $0.isToday && $0.isPending }
    }

    var upcomingPayments: [Payment] {
        allPayments.filter { $0.isPending && !$0.isToday && $0.dueDate > Date() }
    }

    var overduePayments: [Payment] {
        allPayments.filter { $0.isOverdue }
    }

    var totalPaid: Double {
        allPayments.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    var totalPending: Double {
        allPayments.filter { $0.isPending || $0.isOverdue }.reduce(0) { $0 + $1.amount }
    }

    var paidCount: Int {
        allPayments.filter { $0.isPaid }.count
    }

    var totalCount: Int {
        allPayments.count
    }

    var completionRate: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(paidCount) / CGFloat(totalCount)
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch from Supabase
            let paymentDTOs = try await SupabaseService.shared.fetchPayments(month: Date())
            let providerDTOs = try await SupabaseService.shared.fetchProviders()

            // Map DTOs to domain models
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate]

            providers = providerDTOs.map { dto in
                Provider(
                    id: dto.id,
                    userId: dto.userId,
                    name: dto.name,
                    category: ProviderCategory(rawValue: dto.category) ?? .outro,
                    pixKey: dto.pixKey,
                    pixKeyType: PixKeyType(rawValue: dto.pixKeyType) ?? .aleatoria,
                    defaultAmount: dto.defaultAmount,
                    frequency: PaymentFrequency(rawValue: dto.frequency) ?? .mensal,
                    dueDay: dto.dueDay
                )
            }

            allPayments = paymentDTOs.compactMap { dto in
                guard let dueDate = dateFormatter.date(from: dto.dueDate) else { return nil }

                let payment = Payment(
                    id: dto.id,
                    userId: dto.userId,
                    providerId: dto.providerId,
                    amount: dto.amount,
                    dueDate: dueDate,
                    paidAt: dto.paidAt.flatMap { dateFormatter.date(from: $0) },
                    status: PaymentStatus(rawValue: dto.status) ?? .pending
                )

                // Associate provider
                payment.provider = providers.first { $0.id == dto.providerId }
                return payment
            }

            // Check for overdue
            updateOverdueStatus()

        } catch {
            print("Error loading data: \(error)")
        }
    }

    func refresh() async {
        await loadData()
    }

    // MARK: - Helpers

    private func updateOverdueStatus() {
        let today = Calendar.current.startOfDay(for: Date())
        for payment in allPayments {
            if payment.isPending && payment.dueDate < today {
                payment.status = .overdue
            }
        }
    }
}
