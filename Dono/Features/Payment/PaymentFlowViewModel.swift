import Foundation
import SwiftUI

@MainActor
final class PaymentFlowViewModel: ObservableObject {

    @Published var isProcessing = false
    @Published var error: String?

    // MARK: - Pay with Bank

    /// Copia o Pix para o clipboard e abre o banco
    func payWithBank(payment: Payment, bank: BankApp) async {
        guard let provider = payment.provider else { return }

        isProcessing = true
        defer { isProcessing = false }

        // 1. Gera e copia o BR Code
        let brCode = PixService.shared.copyPixToClipboard(
            pixKey: provider.pixKey,
            merchantName: provider.name,
            amount: payment.amount
        )

        guard !brCode.isEmpty else {
            error = "Erro ao gerar código Pix"
            return
        }

        // 2. Marca que abriu o banco (para detectar retorno)
        BankDeepLinkService.shared.markBankOpened()

        // 3. Pequeno delay para clipboard processar
        try? await Task.sleep(nanoseconds: 300_000_000)

        // 4. Abre o banco
        let opened = await BankDeepLinkService.shared.openBank(bank)

        if !opened {
            error = "\(bank.name) não está instalado"
            BankDeepLinkService.shared.clearBankOpenedMark()
        }
    }

    // MARK: - Mark as Paid

    func markAsPaid(payment: Payment) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await SupabaseService.shared.markPaymentAsPaid(id: payment.id)
            payment.markAsPaid()

            // Cancel notification
            NotificationService.shared.cancelReminder(for: payment.id)

        } catch {
            self.error = "Erro ao marcar como pago"
        }
    }

    // MARK: - Mark as Skipped

    func markAsSkipped(payment: Payment) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await SupabaseService.shared.markPaymentAsSkipped(id: payment.id)
            payment.markAsSkipped()

            NotificationService.shared.cancelReminder(for: payment.id)

        } catch {
            self.error = "Erro ao pular pagamento"
        }
    }

    // MARK: - Copy Pix Only

    func copyPixOnly(payment: Payment) -> String? {
        guard let provider = payment.provider else { return nil }

        return PixService.shared.copyPixToClipboard(
            pixKey: provider.pixKey,
            merchantName: provider.name,
            amount: payment.amount
        )
    }
}
