import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes
struct DonoPaymentAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var providerName: String
        var amount: Double
        var status: String // "pending", "paid"
        var timeRemaining: String
    }

    var paymentId: String
    var providerCategory: String
}

// MARK: - Live Activity Widget
struct DonoLiveActivityWidget: Widget {
    let kind: String = "DonoLiveActivity"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DonoPaymentAttributes.self) { context in
            // Lock Screen Banner
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: categoryIcon(context.attributes.providerCategory))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "C4756E"))

                        Text(context.state.providerName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatBRL(context.state.amount))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        // Pay button
                        Button(intent: PayNowIntent(paymentId: context.attributes.paymentId)) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 12))
                                Text("Pagar agora")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "C4756E"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Already paid
                        Button(intent: MarkPaidIntent(paymentId: context.attributes.paymentId)) {
                            Text("Já paguei")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Compact leading
                Image(systemName: categoryIcon(context.attributes.providerCategory))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "C4756E"))
            } compactTrailing: {
                // Compact trailing
                Text(formatBRLShort(context.state.amount))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "C4756E"))
            } minimal: {
                // Minimal (when multiple activities)
                Image(systemName: "brazilianrealsign.circle.fill")
                    .foregroundColor(Color(hex: "C4756E"))
            }
        }
    }

    // MARK: - Lock Screen View
    private func lockScreenView(context: ActivityViewContext<DonoPaymentAttributes>) -> some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "C4756E").opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: categoryIcon(context.attributes.providerCategory))
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "C4756E"))
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.providerName)
                    .font(.system(size: 14, weight: .semibold))

                Text("Pagamento pendente")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Amount
            Text(formatBRL(context.state.amount))
                .font(.system(size: 16, weight: .bold, design: .monospaced))
        }
        .padding(16)
        .background(Color(hex: "F5F0EB"))
    }

    // MARK: - Helpers

    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "casa": return "house.fill"
        case "saude": return "heart.fill"
        case "profissional": return "briefcase.fill"
        default: return "ellipsis.circle.fill"
        }
    }

    private func formatBRL(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0"
    }

    private func formatBRLShort(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "R$%.0fk", amount / 1000)
        }
        return String(format: "R$%.0f", amount)
    }
}

// MARK: - Live Activity Manager
final class LiveActivityManager {

    static let shared = LiveActivityManager()
    private init() {}

    private var currentActivity: Activity<DonoPaymentAttributes>?

    /// Inicia uma Live Activity para um pagamento pendente
    func startActivity(
        paymentId: UUID,
        providerName: String,
        providerCategory: String,
        amount: Double
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = DonoPaymentAttributes(
            paymentId: paymentId.uuidString,
            providerCategory: providerCategory
        )

        let state = DonoPaymentAttributes.ContentState(
            providerName: providerName,
            amount: amount,
            status: "pending",
            timeRemaining: "Vence hoje"
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Error starting live activity: \(error)")
        }
    }

    /// Atualiza quando o pagamento é feito
    func markAsPaid() async {
        guard let activity = currentActivity else { return }

        let updatedState = DonoPaymentAttributes.ContentState(
            providerName: activity.content.state.providerName,
            amount: activity.content.state.amount,
            status: "paid",
            timeRemaining: "Pago!"
        )

        await activity.update(.init(state: updatedState, staleDate: nil))

        // End after 2 seconds
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await activity.end(.init(state: updatedState, staleDate: nil), dismissalPolicy: .immediate)
        currentActivity = nil
    }

    /// Cancela a live activity
    func endActivity() async {
        guard let activity = currentActivity else { return }
        await activity.end(nil, dismissalPolicy: .immediate)
        currentActivity = nil
    }
}

// MARK: - Intents for Live Activity Buttons
import AppIntents

struct PayNowIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pagar Agora"

    @Parameter(title: "Payment ID")
    var paymentId: String

    init() { self.paymentId = "" }
    init(paymentId: String) { self.paymentId = paymentId }

    func perform() async throws -> some IntentResult {
        // Post notification to trigger pay flow
        await MainActor.run {
            if let uuid = UUID(uuidString: paymentId) {
                NotificationCenter.default.post(
                    name: .payNowAction,
                    object: nil,
                    userInfo: ["payment_id": uuid]
                )
            }
        }
        return .result()
    }
}

struct MarkPaidIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Marcar como Pago"

    @Parameter(title: "Payment ID")
    var paymentId: String

    init() { self.paymentId = "" }
    init(paymentId: String) { self.paymentId = paymentId }

    func perform() async throws -> some IntentResult {
        if let uuid = UUID(uuidString: paymentId) {
            try await SupabaseService.shared.markPaymentAsPaid(id: uuid)
            await LiveActivityManager.shared.markAsPaid()
        }
        return .result()
    }
}
