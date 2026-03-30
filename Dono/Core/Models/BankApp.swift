import Foundation
import SwiftUI

// MARK: - Bank App
struct BankApp: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let urlScheme: String
    let iconName: String // SF Symbol ou asset name
    let primaryColor: String // hex

    var color: Color { Color(hex: primaryColor) }

    // Verifica se o app está instalado
    var isInstalled: Bool {
        guard let url = URL(string: urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    // Abre o app do banco
    func open() {
        guard let url = URL(string: urlScheme) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Bancos Brasileiros
    static let allBanks: [BankApp] = [
        BankApp(
            id: "nubank",
            name: "Nubank",
            urlScheme: "nubank://",
            iconName: "n.circle.fill",
            primaryColor: "820AD1"
        ),
        BankApp(
            id: "itau",
            name: "Itaú",
            urlScheme: "itau://",
            iconName: "i.circle.fill",
            primaryColor: "EC7000"
        ),
        BankApp(
            id: "bradesco",
            name: "Bradesco",
            urlScheme: "bradesco://",
            iconName: "b.circle.fill",
            primaryColor: "CC092F"
        ),
        BankApp(
            id: "bb",
            name: "Banco do Brasil",
            urlScheme: "bb://",
            iconName: "b.circle.fill",
            primaryColor: "FEDF00"
        ),
        BankApp(
            id: "inter",
            name: "Inter",
            urlScheme: "bancointer://",
            iconName: "i.circle.fill",
            primaryColor: "FF7A00"
        ),
        BankApp(
            id: "c6",
            name: "C6 Bank",
            urlScheme: "c6bank://",
            iconName: "c.circle.fill",
            primaryColor: "2A2A2A"
        ),
        BankApp(
            id: "santander",
            name: "Santander",
            urlScheme: "santander://",
            iconName: "s.circle.fill",
            primaryColor: "EC0000"
        ),
        BankApp(
            id: "picpay",
            name: "PicPay",
            urlScheme: "picpay://",
            iconName: "p.circle.fill",
            primaryColor: "21C25E"
        ),
        BankApp(
            id: "mercadopago",
            name: "Mercado Pago",
            urlScheme: "mercadopago://",
            iconName: "m.circle.fill",
            primaryColor: "009EE3"
        ),
        BankApp(
            id: "caixa",
            name: "Caixa",
            urlScheme: "caixa://",
            iconName: "c.circle.fill",
            primaryColor: "005CA9"
        ),
        BankApp(
            id: "sicoob",
            name: "Sicoob",
            urlScheme: "sicoob://",
            iconName: "s.circle.fill",
            primaryColor: "003641"
        ),
        BankApp(
            id: "sicredi",
            name: "Sicredi",
            urlScheme: "sicredi://",
            iconName: "s.circle.fill",
            primaryColor: "33B44A"
        ),
    ]

    // Retorna apenas bancos instalados
    static var installedBanks: [BankApp] {
        allBanks.filter { $0.isInstalled }
    }

    // URL Schemes para declarar no Info.plist (LSApplicationQueriesSchemes)
    static var allURLSchemes: [String] {
        allBanks.map { $0.urlScheme.replacingOccurrences(of: "://", with: "") }
    }
}
