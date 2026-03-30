import Foundation
import Supabase

// MARK: - Supabase Service
// Gerencia autenticação, CRUD e sync com Supabase

final class SupabaseService: ObservableObject {

    static let shared = SupabaseService()

    // MARK: - Client
    // Substituir pelas suas credenciais do Supabase
    let client = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )

    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private init() {}

    // MARK: - Auth

    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        await MainActor.run {
            currentUser = session.user
            isAuthenticated = true
        }
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .google, idToken: idToken)
        )
        await MainActor.run {
            currentUser = session.user
            isAuthenticated = true
        }
    }

    func signOut() async throws {
        try await client.auth.signOut()
        await MainActor.run {
            currentUser = nil
            isAuthenticated = false
        }
    }

    func restoreSession() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                currentUser = session.user
                isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                isAuthenticated = false
            }
        }
    }

    // MARK: - Profile

    func upsertProfile(name: String, preferredBank: String?) async throws {
        guard let userId = currentUser?.id else { return }

        let profile: [String: AnyJSON] = [
            "id": .string(userId.uuidString),
            "name": .string(name),
            "preferred_bank": preferredBank.map { .string($0) } ?? .null
        ]

        try await client
            .from("profiles")
            .upsert(profile)
            .execute()
    }

    // MARK: - Providers (Prestadores)

    func fetchProviders() async throws -> [ProviderDTO] {
        guard let userId = currentUser?.id else { return [] }

        let response: [ProviderDTO] = try await client
            .from("providers")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .order("name")
            .execute()
            .value

        return response
    }

    func insertProvider(_ provider: ProviderDTO) async throws {
        try await client
            .from("providers")
            .insert(provider)
            .execute()
    }

    func updateProvider(_ provider: ProviderDTO) async throws {
        try await client
            .from("providers")
            .update(provider)
            .eq("id", value: provider.id.uuidString)
            .execute()
    }

    func deleteProvider(id: UUID) async throws {
        // Soft delete — marca como inativo
        try await client
            .from("providers")
            .update(["is_active": false])
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Payments

    func fetchPayments(month: Date? = nil) async throws -> [PaymentDTO] {
        guard let userId = currentUser?.id else { return [] }

        var query = client
            .from("payments")
            .select()
            .eq("user_id", value: userId.uuidString)

        if let month {
            let calendar = Calendar.current
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]

            query = query
                .gte("due_date", value: formatter.string(from: start))
                .lt("due_date", value: formatter.string(from: end))
        }

        let response: [PaymentDTO] = try await query
            .order("due_date")
            .execute()
            .value

        return response
    }

    func fetchPendingPayments() async throws -> [PaymentDTO] {
        guard let userId = currentUser?.id else { return [] }

        let response: [PaymentDTO] = try await client
            .from("payments")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "pending")
            .order("due_date")
            .execute()
            .value

        return response
    }

    func insertPayment(_ payment: PaymentDTO) async throws {
        try await client
            .from("payments")
            .insert(payment)
            .execute()
    }

    func markPaymentAsPaid(id: UUID) async throws {
        let now = ISO8601DateFormatter().string(from: Date())
        try await client
            .from("payments")
            .update([
                "status": "paid",
                "paid_at": now
            ])
            .eq("id", value: id.uuidString)
            .execute()
    }

    func markPaymentAsSkipped(id: UUID) async throws {
        try await client
            .from("payments")
            .update(["status": "skipped"])
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Generate Monthly Payments

    /// Gera os pagamentos do mês para todos os prestadores ativos
    func generateMonthlyPayments(for month: Date) async throws {
        guard let userId = currentUser?.id else { return }

        let providers = try await fetchProviders()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: month)
        let monthNum = calendar.component(.month, from: month)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        for provider in providers {
            // Verifica se já existe pagamento para esse provider nesse mês
            let existing: [PaymentDTO] = try await client
                .from("payments")
                .select()
                .eq("provider_id", value: provider.id.uuidString)
                .gte("due_date", value: "\(year)-\(String(format: "%02d", monthNum))-01")
                .lt("due_date", value: "\(year)-\(String(format: "%02d", monthNum + 1))-01")
                .execute()
                .value

            guard existing.isEmpty else { continue }

            // Calcula a data de vencimento
            let dueDay = min(provider.dueDay, calendar.range(of: .day, in: .month, for: month)?.count ?? 28)
            var components = DateComponents()
            components.year = year
            components.month = monthNum
            components.day = dueDay

            guard let dueDate = calendar.date(from: components) else { continue }

            let payment = PaymentDTO(
                id: UUID(),
                userId: userId,
                providerId: provider.id,
                amount: provider.defaultAmount,
                dueDate: formatter.string(from: dueDate),
                paidAt: nil,
                status: "pending",
                notes: nil,
                receiptUrl: nil,
                createdAt: formatter.string(from: Date())
            )

            try await insertPayment(payment)
        }
    }
}
