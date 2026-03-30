import Foundation
import SwiftData

// MARK: - Provider Category
enum ProviderCategory: String, Codable, CaseIterable, Identifiable {
    case casa = "casa"
    case saude = "saude"
    case profissional = "profissional"
    case educacao = "educacao"
    case veiculo = "veiculo"
    case pet = "pet"
    case outro = "outro"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .casa: return "Casa"
        case .saude: return "Saúde"
        case .profissional: return "Profissional"
        case .educacao: return "Educação"
        case .veiculo: return "Veículo"
        case .pet: return "Pet"
        case .outro: return "Outro"
        }
    }

    var icon: String {
        switch self {
        case .casa: return "house.fill"
        case .saude: return "heart.fill"
        case .profissional: return "briefcase.fill"
        case .educacao: return "book.fill"
        case .veiculo: return "car.fill"
        case .pet: return "pawprint.fill"
        case .outro: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .casa: return DonoTheme.Colors.accent
        case .saude: return DonoTheme.Colors.success
        case .profissional: return Color(hex: "6BA3BE")
        case .educacao: return Color(hex: "8B7EC8")
        case .veiculo: return DonoTheme.Colors.warning
        case .pet: return Color(hex: "C4A06E")
        case .outro: return DonoTheme.Colors.textSecondary
        }
    }
}

// MARK: - Pix Key Type
enum PixKeyType: String, Codable, CaseIterable, Identifiable {
    case cpf = "cpf"
    case email = "email"
    case telefone = "telefone"
    case aleatoria = "aleatoria"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .cpf: return "CPF"
        case .email: return "E-mail"
        case .telefone: return "Telefone"
        case .aleatoria: return "Chave Aleatória"
        }
    }

    var icon: String {
        switch self {
        case .cpf: return "person.text.rectangle"
        case .email: return "envelope"
        case .telefone: return "phone"
        case .aleatoria: return "key"
        }
    }

    var placeholder: String {
        switch self {
        case .cpf: return "000.000.000-00"
        case .email: return "email@exemplo.com"
        case .telefone: return "+55 11 99999-9999"
        case .aleatoria: return "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .cpf, .telefone: return .numberPad
        case .email: return .emailAddress
        case .aleatoria: return .default
        }
    }
}

// MARK: - Payment Frequency
enum PaymentFrequency: String, Codable, CaseIterable, Identifiable {
    case semanal = "semanal"
    case quinzenal = "quinzenal"
    case mensal = "mensal"
    case bimestral = "bimestral"
    case trimestral = "trimestral"
    case avulso = "avulso"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .semanal: return "Semanal"
        case .quinzenal: return "Quinzenal"
        case .mensal: return "Mensal"
        case .bimestral: return "Bimestral"
        case .trimestral: return "Trimestral"
        case .avulso: return "Avulso"
        }
    }
}

// MARK: - Provider Model
import SwiftUI

@Model
class Provider {
    var id: UUID
    var userId: UUID
    var name: String
    var category: ProviderCategory
    var pixKey: String
    var pixKeyType: PixKeyType
    var defaultAmount: Double
    var frequency: PaymentFrequency
    var dueDay: Int // 1-31
    var notes: String?
    var isActive: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        category: ProviderCategory = .outro,
        pixKey: String,
        pixKeyType: PixKeyType,
        defaultAmount: Double,
        frequency: PaymentFrequency = .mensal,
        dueDay: Int = 1,
        notes: String? = nil,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.category = category
        self.pixKey = pixKey
        self.pixKeyType = pixKeyType
        self.defaultAmount = defaultAmount
        self.frequency = frequency
        self.dueDay = dueDay
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

// MARK: - Supabase DTO
struct ProviderDTO: Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let category: String
    let pixKey: String
    let pixKeyType: String
    let defaultAmount: Double
    let frequency: String
    let dueDay: Int
    let notes: String?
    let isActive: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case category
        case pixKey = "pix_key"
        case pixKeyType = "pix_key_type"
        case defaultAmount = "default_amount"
        case frequency
        case dueDay = "due_day"
        case notes
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}
