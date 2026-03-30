import Foundation
import SwiftData
import SwiftUI

// MARK: - Payment Status
enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case paid = "paid"
    case overdue = "overdue"
    case skipped = "skipped"

    var label: String {
        switch self {
        case .pending: return "Pendente"
        case .paid: return "Pago"
        case .overdue: return "Atrasado"
        case .skipped: return "Pulado"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .paid: return "checkmark.circle.fill"
        case .overdue: return "exclamationmark.triangle.fill"
        case .skipped: return "arrow.right.circle"
        }
    }

    var color: Color {
        switch self {
        case .pending: return DonoTheme.Colors.warning
        case .paid: return DonoTheme.Colors.success
        case .overdue: return DonoTheme.Colors.error
        case .skipped: return DonoTheme.Colors.textTertiary
        }
    }

    var backgroundColor: Color {
        switch self {
        case .pending: return DonoTheme.Colors.warningLight
        case .paid: return DonoTheme.Colors.successLight
        case .overdue: return DonoTheme.Colors.accentSubtle
        case .skipped: return DonoTheme.Colors.surface
        }
    }
}

// MARK: - Payment Model
@Model
class Payment {
    var id: UUID
    var userId: UUID
    var providerId: UUID
    var amount: Double
    var dueDate: Date
    var paidAt: Date?
    var status: PaymentStatus
    var notes: String?
    var receiptURL: String?
    var createdAt: Date

    // Transient — não persiste, associado em runtime
    @Transient var provider: Provider?

    init(
        id: UUID = UUID(),
        userId: UUID,
        providerId: UUID,
        amount: Double,
        dueDate: Date,
        paidAt: Date? = nil,
        status: PaymentStatus = .pending,
        notes: String? = nil,
        receiptURL: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.providerId = providerId
        self.amount = amount
        self.dueDate = dueDate
        self.paidAt = paidAt
        self.status = status
        self.notes = notes
        self.receiptURL = receiptURL
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    var isPending: Bool { status == .pending }
    var isPaid: Bool { status == .paid }
    var isOverdue: Bool { status == .overdue }

    var isToday: Bool {
        Calendar.current.isDateInToday(dueDate)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(dueDate)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var dueDateFormatted: String {
        if isToday { return "Hoje" }
        if isTomorrow { return "Amanhã" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")

        if isThisWeek {
            formatter.dateFormat = "EEEE" // "segunda-feira"
            return formatter.string(from: dueDate).capitalized
        }

        formatter.dateFormat = "d 'de' MMMM"
        return formatter.string(from: dueDate)
    }

    var paidAtFormatted: String? {
        guard let paidAt else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d 'de' MMMM 'às' HH:mm"
        return formatter.string(from: paidAt)
    }

    func markAsPaid() {
        status = .paid
        paidAt = Date()
    }

    func markAsSkipped() {
        status = .skipped
    }
}

// MARK: - Supabase DTO
struct PaymentDTO: Codable {
    let id: UUID
    let userId: UUID
    let providerId: UUID
    let amount: Double
    let dueDate: String
    let paidAt: String?
    let status: String
    let notes: String?
    let receiptUrl: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case providerId = "provider_id"
        case amount
        case dueDate = "due_date"
        case paidAt = "paid_at"
        case status
        case notes
        case receiptUrl = "receipt_url"
        case createdAt = "created_at"
    }
}

// MARK: - Monthly Summary
struct MonthlySummary {
    let month: Date
    let totalPaid: Double
    let totalPending: Double
    let totalOverdue: Double
    let paymentCount: Int
    let paidCount: Int

    var totalDue: Double { totalPending + totalOverdue }
    var completionRate: Double {
        guard paymentCount > 0 else { return 0 }
        return Double(paidCount) / Double(paymentCount)
    }

    var monthFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month).capitalized
    }
}
