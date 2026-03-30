import Foundation
import UniformTypeIdentifiers
import UIKit

// MARK: - Pix BR Code Generator (EMV Standard)
// Segue o padrão EMV definido pelo Banco Central do Brasil
// Documentação: https://www.bcb.gov.br/estabilidadefinanceira/pix

final class PixService {

    static let shared = PixService()
    private init() {}

    // MARK: - EMV Tag IDs
    private enum EMVTag {
        static let payloadFormatIndicator = "00"
        static let merchantAccountInfo = "26"
        static let merchantCategoryCode = "52"
        static let transactionCurrency = "53"
        static let transactionAmount = "54"
        static let countryCode = "58"
        static let merchantName = "59"
        static let merchantCity = "60"
        static let additionalData = "62"
        static let crc16 = "63"

        // Sub-tags dentro do Merchant Account Info (26)
        static let gui = "00"           // br.gov.bcb.pix
        static let pixKey = "01"        // chave pix

        // Sub-tags dentro do Additional Data (62)
        static let txid = "05"          // ID da transação
    }

    // MARK: - Generate BR Code (Pix Copia e Cola)

    /// Gera o código Pix Copia e Cola completo no padrão EMV
    /// - Parameters:
    ///   - pixKey: Chave Pix do recebedor (CPF, email, telefone ou aleatória)
    ///   - merchantName: Nome do recebedor (máx 25 chars)
    ///   - merchantCity: Cidade do recebedor (máx 15 chars)
    ///   - amount: Valor da transação (nil para valor aberto)
    ///   - txid: ID da transação (opcional, máx 25 chars)
    /// - Returns: String do BR Code pronto para copiar
    func generateBRCode(
        pixKey: String,
        merchantName: String,
        merchantCity: String = "SAO PAULO",
        amount: Double? = nil,
        txid: String? = nil
    ) -> String {
        var payload = ""

        // Payload Format Indicator (obrigatório)
        payload += buildEMVField(tag: EMVTag.payloadFormatIndicator, value: "01")

        // Merchant Account Info
        let gui = buildEMVField(tag: EMVTag.gui, value: "br.gov.bcb.pix")
        let key = buildEMVField(tag: EMVTag.pixKey, value: pixKey)
        payload += buildEMVField(tag: EMVTag.merchantAccountInfo, value: gui + key)

        // Merchant Category Code (0000 = não informado)
        payload += buildEMVField(tag: EMVTag.merchantCategoryCode, value: "0000")

        // Transaction Currency (986 = BRL)
        payload += buildEMVField(tag: EMVTag.transactionCurrency, value: "986")

        // Transaction Amount (opcional)
        if let amount, amount > 0 {
            let amountStr = String(format: "%.2f", amount)
            payload += buildEMVField(tag: EMVTag.transactionAmount, value: amountStr)
        }

        // Country Code
        payload += buildEMVField(tag: EMVTag.countryCode, value: "BR")

        // Merchant Name (máx 25 chars, sem acentos)
        let cleanName = sanitize(merchantName, maxLength: 25)
        payload += buildEMVField(tag: EMVTag.merchantName, value: cleanName)

        // Merchant City (máx 15 chars, sem acentos)
        let cleanCity = sanitize(merchantCity, maxLength: 15)
        payload += buildEMVField(tag: EMVTag.merchantCity, value: cleanCity)

        // Additional Data (txid)
        if let txid {
            let txidField = buildEMVField(tag: EMVTag.txid, value: String(txid.prefix(25)))
            payload += buildEMVField(tag: EMVTag.additionalData, value: txidField)
        } else {
            let txidField = buildEMVField(tag: EMVTag.txid, value: "***")
            payload += buildEMVField(tag: EMVTag.additionalData, value: txidField)
        }

        // CRC16 placeholder (4 chars)
        payload += EMVTag.crc16 + "04"

        // Calcula CRC16 e adiciona
        let crc = calculateCRC16(payload)
        payload += crc

        return payload
    }

    // MARK: - Copy to Clipboard

    /// Gera o BR Code e copia para o clipboard
    func copyPixToClipboard(
        pixKey: String,
        merchantName: String,
        merchantCity: String = "SAO PAULO",
        amount: Double? = nil
    ) -> String {
        let brCode = generateBRCode(
            pixKey: pixKey,
            merchantName: merchantName,
            merchantCity: merchantCity,
            amount: amount
        )

        UIPasteboard.general.string = brCode
        return brCode
    }

    // MARK: - Detect Pix Key Type

    /// Detecta automaticamente o tipo de chave Pix
    func detectPixKeyType(_ key: String) -> PixKeyType {
        let cleaned = key.trimmingCharacters(in: .whitespacesAndNewlines)

        // CPF: 11 dígitos
        let cpfPattern = #"^\d{11}$|^\d{3}\.\d{3}\.\d{3}-\d{2}$"#
        if cleaned.range(of: cpfPattern, options: .regularExpression) != nil {
            return .cpf
        }

        // Telefone: +55...
        let phonePattern = #"^\+?55?\d{10,11}$|^\+55\s?\d{2}\s?\d{4,5}-?\d{4}$"#
        if cleaned.range(of: phonePattern, options: .regularExpression) != nil {
            return .telefone
        }

        // Email
        let emailPattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if cleaned.range(of: emailPattern, options: .regularExpression) != nil {
            return .email
        }

        // Chave aleatória (UUID format)
        if UUID(uuidString: cleaned) != nil {
            return .aleatoria
        }

        return .aleatoria // default
    }

    // MARK: - Private Helpers

    /// Constrói um campo EMV: TAG + LENGTH + VALUE
    private func buildEMVField(tag: String, value: String) -> String {
        let length = String(format: "%02d", value.count)
        return tag + length + value
    }

    /// Remove acentos e caracteres especiais, limita tamanho
    private func sanitize(_ text: String, maxLength: Int) -> String {
        let folded = text.folding(options: .diacriticInsensitive, locale: .current)
        let uppercased = folded.uppercased()
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        let filtered = uppercased.unicodeScalars.filter { allowed.contains($0) }
        let result = String(String.UnicodeScalarView(filtered))
        return String(result.prefix(maxLength))
    }

    /// Calcula CRC16 CCITT-FALSE (padrão EMV)
    private func calculateCRC16(_ payload: String) -> String {
        let polynomial: UInt16 = 0x1021
        var crc: UInt16 = 0xFFFF

        for byte in payload.utf8 {
            crc ^= UInt16(byte) << 8
            for _ in 0..<8 {
                if crc & 0x8000 != 0 {
                    crc = (crc << 1) ^ polynomial
                } else {
                    crc <<= 1
                }
            }
        }

        return String(format: "%04X", crc & 0xFFFF)
    }
}

// MARK: - QR Code Generation
import CoreImage.CIFilterBuiltins

extension PixService {

    /// Gera imagem QR Code a partir do BR Code
    func generateQRCode(from brCode: String, size: CGFloat = 250) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        guard let data = brCode.data(using: .utf8) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        let scale = size / outputImage.extent.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
