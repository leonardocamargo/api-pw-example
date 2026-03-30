import SwiftUI
import UniformTypeIdentifiers

// MARK: - Share Extension View
// Recebe texto compartilhado (ex: chave Pix do WhatsApp) e oferece cadastro rápido

struct ShareExtensionView: View {
    let sharedText: String
    let detectedKeyType: PixKeyType
    let onSave: (String, String, PixKeyType) -> Void
    let onCancel: () -> Void

    @State private var providerName = ""
    @State private var pixKey: String
    @State private var keyType: PixKeyType

    init(
        sharedText: String,
        detectedKeyType: PixKeyType,
        onSave: @escaping (String, String, PixKeyType) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.sharedText = sharedText
        self.detectedKeyType = detectedKeyType
        self.onSave = onSave
        self.onCancel = onCancel
        self._pixKey = State(initialValue: sharedText)
        self._keyType = State(initialValue: detectedKeyType)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Detected key info
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(Color(hex: "C4756E"))

                    Text("Chave Pix detectada!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "3D3229"))

                    Text(keyType.label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "8C7E6F"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: "F5F0EB"))
                        .clipShape(Capsule())
                }
                .padding(.top, 20)

                // Key value
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chave Pix")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "8C7E6F"))

                    Text(pixKey)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "3D3229"))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "F5F0EB"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Provider name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nome do prestador")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "8C7E6F"))

                    TextField("Ex: João Jardineiro", text: $providerName)
                        .font(.system(size: 16))
                        .padding(12)
                        .background(Color(hex: "F5F0EB"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Spacer()

                // Save
                Button {
                    onSave(providerName, pixKey, keyType)
                } label: {
                    Text("Salvar prestador")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "C4756E"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(providerName.isEmpty)
                .opacity(providerName.isEmpty ? 0.5 : 1)
            }
            .padding(20)
            .background(Color(hex: "FAFAF8"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { onCancel() }
                        .foregroundColor(Color(hex: "8C7E6F"))
                }
            }
        }
    }
}

// MARK: - Pix Key Detection from Shared Text
struct PixKeyDetector {

    /// Detecta chave Pix em um texto compartilhado
    static func detect(from text: String) -> (key: String, type: PixKeyType)? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // CPF: 000.000.000-00 ou 00000000000
        let cpfPatterns = [
            #"\d{3}\.\d{3}\.\d{3}-\d{2}"#,
            #"\b\d{11}\b"#
        ]
        for pattern in cpfPatterns {
            if let match = trimmed.range(of: pattern, options: .regularExpression) {
                let key = String(trimmed[match])
                return (key, .cpf)
            }
        }

        // Email
        let emailPattern = #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        if let match = trimmed.range(of: emailPattern, options: .regularExpression) {
            let key = String(trimmed[match])
            return (key, .email)
        }

        // Telefone: +55 11 99999-9999
        let phonePatterns = [
            #"\+55\s?\d{2}\s?\d{4,5}-?\d{4}"#,
            #"\+55\d{10,11}"#
        ]
        for pattern in phonePatterns {
            if let match = trimmed.range(of: pattern, options: .regularExpression) {
                let key = String(trimmed[match])
                return (key, .telefone)
            }
        }

        // UUID (chave aleatória)
        let uuidPattern = #"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"#
        if let match = trimmed.range(of: uuidPattern, options: .regularExpression) {
            let key = String(trimmed[match])
            return (key, .aleatoria)
        }

        return nil
    }
}
