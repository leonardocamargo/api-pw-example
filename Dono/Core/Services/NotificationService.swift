import Foundation
import UserNotifications
import UIKit

// MARK: - Notification Service
// Gerencia push notifications locais com ações

final class NotificationService: NSObject, ObservableObject {

    static let shared = NotificationService()

    @Published var isAuthorized = false

    // MARK: - Notification Categories & Actions
    private let paymentCategoryID = "PAYMENT_REMINDER"

    private enum ActionID {
        static let payNow = "PAY_NOW"
        static let remindLater = "REMIND_LATER"
        static let markPaid = "MARK_PAID"
    }

    private override init() {
        super.init()
    }

    // MARK: - Setup

    func setup() {
        registerCategories()
        UNUserNotificationCenter.current().delegate = self
    }

    /// Solicita permissão de notificações
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge, .provisional])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            return false
        }
    }

    /// Registra as categorias de notificação com botões de ação
    private func registerCategories() {
        let payNow = UNNotificationAction(
            identifier: ActionID.payNow,
            title: "Pagar agora",
            options: [.foreground],
            icon: UNNotificationActionIcon(systemImageName: "doc.on.clipboard")
        )

        let remindLater = UNNotificationAction(
            identifier: ActionID.remindLater,
            title: "Lembrar em 1h",
            options: [],
            icon: UNNotificationActionIcon(systemImageName: "clock")
        )

        let markPaid = UNNotificationAction(
            identifier: ActionID.markPaid,
            title: "Já paguei",
            options: [.destructive],
            icon: UNNotificationActionIcon(systemImageName: "checkmark.circle")
        )

        let paymentCategory = UNNotificationCategory(
            identifier: paymentCategoryID,
            actions: [payNow, remindLater, markPaid],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Pagamento pendente",
            categorySummaryFormat: "%u pagamentos pendentes",
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([paymentCategory])
    }

    // MARK: - Schedule Payment Reminder

    /// Agenda uma notificação para um pagamento
    func schedulePaymentReminder(
        paymentId: UUID,
        providerName: String,
        amount: Double,
        dueDate: Date,
        reminderTime: Date? = nil
    ) async {
        let content = UNMutableNotificationContent()
        content.title = providerName
        content.body = "Pagamento de \(amount.brlFormatted) vence hoje"
        content.subtitle = "Toque para pagar"
        content.sound = .default
        content.categoryIdentifier = paymentCategoryID
        content.threadIdentifier = "payment-\(paymentId.uuidString)"

        // Dados para usar quando a ação for executada
        content.userInfo = [
            "payment_id": paymentId.uuidString,
            "provider_name": providerName,
            "amount": amount,
            "type": "payment_reminder"
        ]

        // Badge
        content.badge = 1

        // Trigger: no dia do vencimento às 8h (ou horário customizado)
        let targetDate = reminderTime ?? Calendar.current.date(
            bySettingHour: 8, minute: 0, second: 0, of: dueDate
        ) ?? dueDate

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: targetDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "payment-\(paymentId.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }

    /// Agenda lembrete de follow-up (quando pagamento não foi feito)
    func scheduleFollowUp(
        paymentId: UUID,
        providerName: String,
        amount: Double,
        delay: TimeInterval = 3600 // 1 hora default
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "Lembrete: \(providerName)"
        content.body = "Pagamento de \(amount.brlFormatted) ainda pendente"
        content.sound = .default
        content.categoryIdentifier = paymentCategoryID
        content.userInfo = [
            "payment_id": paymentId.uuidString,
            "provider_name": providerName,
            "amount": amount,
            "type": "payment_followup"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)

        let request = UNNotificationRequest(
            identifier: "followup-\(paymentId.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    /// Agenda resumo semanal
    func scheduleWeeklySummary(pendingCount: Int, totalAmount: Double) async {
        let content = UNMutableNotificationContent()
        content.title = "Resumo da Semana"
        content.body = "\(pendingCount) pagamentos pendentes totalizando \(totalAmount.brlFormatted)"
        content.sound = .default

        // Toda segunda às 9h
        var components = DateComponents()
        components.weekday = 2 // Monday
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "weekly-summary",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel

    func cancelReminder(for paymentId: UUID) {
        let identifiers = [
            "payment-\(paymentId.uuidString)",
            "followup-\(paymentId.uuidString)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Badge

    @MainActor
    func updateBadge(count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard let paymentIdString = userInfo["payment_id"] as? String,
              let paymentId = UUID(uuidString: paymentIdString) else { return }

        let providerName = userInfo["provider_name"] as? String ?? ""
        let amount = userInfo["amount"] as? Double ?? 0

        switch response.actionIdentifier {
        case ActionID.payNow:
            // Notifica o app para iniciar o fluxo de pagamento
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .payNowAction,
                    object: nil,
                    userInfo: ["payment_id": paymentId]
                )
            }

        case ActionID.remindLater:
            // Reagenda para 1h
            await scheduleFollowUp(
                paymentId: paymentId,
                providerName: providerName,
                amount: amount,
                delay: 3600
            )

        case ActionID.markPaid:
            // Marca como pago
            try? await SupabaseService.shared.markPaymentAsPaid(id: paymentId)
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .paymentMarkedPaid,
                    object: nil,
                    userInfo: ["payment_id": paymentId]
                )
            }

        default:
            // Toque na notificação (sem ação específica) — abre o app no pagamento
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .openPayment,
                    object: nil,
                    userInfo: ["payment_id": paymentId]
                )
            }
        }
    }

    // Mostra notificação mesmo com app em foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let payNowAction = Notification.Name("com.dono.payNowAction")
    static let paymentMarkedPaid = Notification.Name("com.dono.paymentMarkedPaid")
    static let openPayment = Notification.Name("com.dono.openPayment")
}
