import WidgetKit
import SwiftUI

// MARK: - Widget Data
struct PaymentWidgetEntry: TimelineEntry {
    let date: Date
    let payments: [WidgetPayment]
    let totalPending: Double
    let pendingCount: Int
}

struct WidgetPayment: Identifiable {
    let id: UUID
    let providerName: String
    let amount: Double
    let dueDate: Date
    let category: String
    let status: String

    var isToday: Bool { Calendar.current.isDateInToday(dueDate) }
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(dueDate) }

    var dueDateLabel: String {
        if isToday { return "Hoje" }
        if isTomorrow { return "Amanhã" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: dueDate)
    }

    var categoryIcon: String {
        switch category {
        case "casa": return "house.fill"
        case "saude": return "heart.fill"
        case "profissional": return "briefcase.fill"
        case "educacao": return "book.fill"
        case "veiculo": return "car.fill"
        case "pet": return "pawprint.fill"
        default: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Timeline Provider
struct DonoWidgetProvider: TimelineProvider {
    // Shared UserDefaults with the main app (App Groups)
    let sharedDefaults = UserDefaults(suiteName: "group.com.dono.app")

    func placeholder(in context: Context) -> PaymentWidgetEntry {
        PaymentWidgetEntry(
            date: Date(),
            payments: [
                WidgetPayment(id: UUID(), providerName: "Jardineiro", amount: 250, dueDate: Date(), category: "casa", status: "pending"),
                WidgetPayment(id: UUID(), providerName: "Contador", amount: 500, dueDate: Date(), category: "profissional", status: "pending"),
            ],
            totalPending: 750,
            pendingCount: 2
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PaymentWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PaymentWidgetEntry>) -> Void) {
        // Read from shared App Group data
        let entry = loadFromSharedData()

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadFromSharedData() -> PaymentWidgetEntry {
        // In production: read from shared UserDefaults or shared SwiftData container
        return placeholder(in: .init())
    }
}

// MARK: - Small Widget
struct DonoSmallWidget: View {
    let entry: PaymentWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "house")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "C4756E"))
                Text("Dono")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "3D3229"))
            }

            Spacer()

            if let next = entry.payments.first {
                // Next payment
                Text(next.providerName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "3D3229"))
                    .lineLimit(1)

                Text(formatBRL(next.amount))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "3D3229"))

                Text(next.dueDateLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(next.isToday ? Color(hex: "C4756E") : Color(hex: "8C7E6F"))
            } else {
                Text("Tudo em dia!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "7A9E7E"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(hex: "FAFAF8"))
    }

    private func formatBRL(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0"
    }
}

// MARK: - Medium Widget
struct DonoMediumWidget: View {
    let entry: PaymentWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "house")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "C4756E"))
                Text("Dono")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "3D3229"))

                Spacer()

                Text("\(entry.pendingCount) pendentes")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "8C7E6F"))
            }

            // Payment list
            ForEach(entry.payments.prefix(3)) { payment in
                HStack(spacing: 10) {
                    Image(systemName: payment.categoryIcon)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "C4756E"))
                        .frame(width: 16)

                    Text(payment.providerName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "3D3229"))
                        .lineLimit(1)

                    Spacer()

                    Text(payment.dueDateLabel)
                        .font(.system(size: 11))
                        .foregroundColor(payment.isToday ? Color(hex: "C4756E") : Color(hex: "8C7E6F"))

                    Text(formatBRLShort(payment.amount))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "3D3229"))
                }
            }

            if entry.payments.count > 3 {
                Text("+\(entry.payments.count - 3) mais")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8C7E6F"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(hex: "FAFAF8"))
    }

    private func formatBRLShort(_ amount: Double) -> String {
        String(format: "R$%.0f", amount)
    }
}

// MARK: - Lock Screen Widget (Accessory)
struct DonoLockScreenWidget: View {
    let entry: PaymentWidgetEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(entry.pendingCount)")
                .font(.system(size: 24, weight: .bold, design: .monospaced))

            Text("pendentes")
                .font(.system(size: 10))
        }
    }
}

// MARK: - Widget Configuration
struct DonoWidget: Widget {
    let kind: String = "DonoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DonoWidgetProvider()) { entry in
            DonoWidgetEntryView(entry: entry)
                .containerBackground(Color(hex: "FAFAF8"), for: .widget)
        }
        .configurationDisplayName("Dono")
        .description("Seus próximos pagamentos")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct DonoWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PaymentWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            DonoSmallWidget(entry: entry)
        case .systemMedium:
            DonoMediumWidget(entry: entry)
        case .accessoryCircular, .accessoryRectangular:
            DonoLockScreenWidget(entry: entry)
        default:
            DonoSmallWidget(entry: entry)
        }
    }
}
