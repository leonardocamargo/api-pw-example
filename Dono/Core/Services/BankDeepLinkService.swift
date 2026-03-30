import Foundation
import UIKit

// MARK: - Bank Deep Link Service
// Gerencia a detecção de bancos instalados e abertura via deep link

final class BankDeepLinkService: ObservableObject {

    static let shared = BankDeepLinkService()

    @Published var installedBanks: [BankApp] = []
    @Published var preferredBank: BankApp?

    private init() {
        detectInstalledBanks()
        loadPreferredBank()
    }

    // MARK: - Detection

    /// Detecta quais apps de banco estão instalados no device
    /// Precisa dos URL schemes declarados no Info.plist (LSApplicationQueriesSchemes)
    func detectInstalledBanks() {
        installedBanks = BankApp.allBanks.filter { bank in
            guard let url = URL(string: bank.urlScheme) else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }

    // MARK: - Open Bank

    /// Copia o Pix para o clipboard e abre o banco
    /// - Parameters:
    ///   - payment: Dados do pagamento
    ///   - provider: Prestador de serviço
    ///   - bank: Banco a ser aberto (usa preferido se nil)
    @MainActor
    func copyPixAndOpenBank(
        payment: Payment,
        provider: Provider,
        bank: BankApp? = nil
    ) async -> Bool {
        let targetBank = bank ?? preferredBank

        // 1. Gera e copia o BR Code
        let brCode = PixService.shared.copyPixToClipboard(
            pixKey: provider.pixKey,
            merchantName: provider.name,
            amount: payment.amount
        )

        guard !brCode.isEmpty else { return false }

        // 2. Pequeno delay para o clipboard ser processado
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s

        // 3. Abre o banco
        if let targetBank {
            return await openBank(targetBank)
        } else {
            // Se não tem banco preferido, mostra todos os instalados
            // (tratado pela UI que chama esse método)
            return false
        }
    }

    /// Abre o app de um banco específico
    @MainActor
    func openBank(_ bank: BankApp) async -> Bool {
        guard let url = URL(string: bank.urlScheme) else { return false }

        if UIApplication.shared.canOpenURL(url) {
            await UIApplication.shared.open(url)
            return true
        }

        return false
    }

    // MARK: - Preferred Bank

    func setPreferredBank(_ bank: BankApp) {
        preferredBank = bank
        UserDefaults.standard.set(bank.id, forKey: "preferred_bank_id")

        // Salva também no App Group para acesso dos Widgets/Extensions
        let sharedDefaults = UserDefaults(suiteName: "group.com.dono.app")
        sharedDefaults?.set(bank.id, forKey: "preferred_bank_id")
    }

    private func loadPreferredBank() {
        if let bankId = UserDefaults.standard.string(forKey: "preferred_bank_id") {
            preferredBank = BankApp.allBanks.first { $0.id == bankId }
        }
    }

    // MARK: - Return Detection

    /// Detecta quando o usuário volta do banco para o app
    /// Chamado quando o scenePhase muda para .active
    func didReturnFromBank() -> Bool {
        // Verifica se houve uma navegação recente para um banco
        let lastOpenedAt = UserDefaults.standard.object(forKey: "last_bank_opened_at") as? Date
        guard let lastOpenedAt else { return false }

        let elapsed = Date().timeIntervalSince(lastOpenedAt)
        // Se voltou em menos de 5 minutos, provavelmente veio do banco
        return elapsed < 300 && elapsed > 3
    }

    func markBankOpened() {
        UserDefaults.standard.set(Date(), forKey: "last_bank_opened_at")
    }

    func clearBankOpenedMark() {
        UserDefaults.standard.removeObject(forKey: "last_bank_opened_at")
    }

    // MARK: - Info.plist Helper

    /// Lista de URL schemes que devem ser declarados no Info.plist
    /// Adicionar em LSApplicationQueriesSchemes
    static var requiredURLSchemes: [String] {
        [
            "nubank", "itau", "bradesco", "bb",
            "bancointer", "c6bank", "santander",
            "picpay", "mercadopago", "caixa",
            "sicoob", "sicredi"
        ]
    }
}
