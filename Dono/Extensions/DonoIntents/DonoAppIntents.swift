import AppIntents
import SwiftUI

// MARK: - App Shortcuts
struct DonoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PayProviderIntent(),
            phrases: [
                "Pagar \(\.$providerName) no \(.applicationName)",
                "Pagar o \(\.$providerName)",
                "\(.applicationName) pagar \(\.$providerName)"
            ],
            shortTitle: "Pagar Prestador",
            systemImageName: "brazilianrealsign.circle"
        )

        AppShortcut(
            intent: ShowPendingPaymentsIntent(),
            phrases: [
                "Quanto devo no \(.applicationName)",
                "Pagamentos pendentes no \(.applicationName)",
                "O que falta pagar no \(.applicationName)"
            ],
            shortTitle: "Pagamentos Pendentes",
            systemImageName: "list.bullet.clipboard"
        )

        AppShortcut(
            intent: ShowMonthlySummaryIntent(),
            phrases: [
                "Resumo do mês no \(.applicationName)",
                "Quanto gastei no \(.applicationName)",
                "Relatório \(.applicationName)"
            ],
            shortTitle: "Resumo do Mês",
            systemImageName: "chart.bar"
        )
    }
}

// MARK: - Pay Provider Intent
struct PayProviderIntent: AppIntent {
    static var title: LocalizedStringResource = "Pagar Prestador"
    static var description = IntentDescription("Copia o código Pix e abre o banco para pagar um prestador")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Nome do prestador")
    var providerName: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Find provider by name
        let providers = try await SupabaseService.shared.fetchProviders()

        guard let provider = providers.first(where: {
            $0.name.localizedCaseInsensitiveContains(providerName)
        }) else {
            return .result(dialog: "Não encontrei um prestador com o nome \"\(providerName)\".")
        }

        // Generate and copy Pix
        let brCode = PixService.shared.copyPixToClipboard(
            pixKey: provider.pixKey,
            merchantName: provider.name,
            amount: provider.defaultAmount
        )

        guard !brCode.isEmpty else {
            return .result(dialog: "Erro ao gerar código Pix.")
        }

        // Open bank
        if let preferredBankId = UserDefaults.standard.string(forKey: "preferred_bank_id"),
           let bank = BankApp.allBanks.first(where: { $0.id == preferredBankId }) {
            await BankDeepLinkService.shared.openBank(bank)
        }

        return .result(dialog: "Pix de \(formatBRL(provider.defaultAmount)) para \(provider.name) copiado! Abrindo o banco...")
    }
}

// MARK: - Show Pending Payments Intent
struct ShowPendingPaymentsIntent: AppIntent {
    static var title: LocalizedStringResource = "Pagamentos Pendentes"
    static var description = IntentDescription("Mostra os pagamentos pendentes do mês")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let payments = try await SupabaseService.shared.fetchPendingPayments()

        if payments.isEmpty {
            return .result(dialog: "Você não tem pagamentos pendentes. Tudo em dia!")
        }

        let total = payments.reduce(0.0) { $0 + $1.amount }
        let names = payments.prefix(3).map { $0.notes ?? "Prestador" }.joined(separator: ", ")

        return .result(dialog: "Você tem \(payments.count) pagamentos pendentes totalizando \(formatBRL(total)). Próximos: \(names).")
    }
}

// MARK: - Show Monthly Summary Intent
struct ShowMonthlySummaryIntent: AppIntent {
    static var title: LocalizedStringResource = "Resumo do Mês"
    static var description = IntentDescription("Mostra o resumo de gastos do mês")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let payments = try await SupabaseService.shared.fetchPayments(month: Date())

        let paid = payments.filter { $0.status == "paid" }
        let pending = payments.filter { $0.status == "pending" }
        let totalPaid = paid.reduce(0.0) { $0 + $1.amount }
        let totalPending = pending.reduce(0.0) { $0 + $1.amount }

        return .result(dialog: "Este mês: \(formatBRL(totalPaid)) pagos, \(formatBRL(totalPending)) pendentes. \(paid.count) de \(payments.count) pagamentos realizados.")
    }
}

// MARK: - Spotlight Indexing
import CoreSpotlight
import UniformTypeIdentifiers

final class SpotlightService {

    static let shared = SpotlightService()
    private init() {}

    /// Indexa um prestador no Spotlight
    func indexProvider(_ provider: ProviderDTO) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
        attributeSet.title = provider.name
        attributeSet.contentDescription = "\(provider.category) · \(formatBRL(provider.defaultAmount)) · Dia \(provider.dueDay)"
        attributeSet.keywords = [provider.name, provider.category, "pix", "pagamento", "dono"]

        let item = CSSearchableItem(
            uniqueIdentifier: "provider-\(provider.id.uuidString)",
            domainIdentifier: "com.dono.providers",
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([item])
    }

    /// Indexa um pagamento pendente no Spotlight
    func indexPendingPayment(_ payment: PaymentDTO, providerName: String) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
        attributeSet.title = "Pagar \(providerName)"
        attributeSet.contentDescription = "\(formatBRL(payment.amount)) · Vence \(payment.dueDate)"
        attributeSet.keywords = [providerName, "pagar", "pix", "pendente"]

        let item = CSSearchableItem(
            uniqueIdentifier: "payment-\(payment.id.uuidString)",
            domainIdentifier: "com.dono.payments",
            attributeSet: attributeSet
        )
        item.expirationDate = ISO8601DateFormatter().date(from: payment.dueDate)?.addingTimeInterval(86400 * 7)

        CSSearchableIndex.default().indexSearchableItems([item])
    }

    /// Remove todos os itens do Spotlight
    func removeAll() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }
}

// MARK: - Helper (nonisolated para uso em AppIntents)
private func formatBRL(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
}
