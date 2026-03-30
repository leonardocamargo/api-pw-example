import SwiftUI
import SwiftData

@main
struct DonoApp: App {
    @StateObject private var supabase = SupabaseService.shared
    @StateObject private var biometric = BiometricService.shared
    @StateObject private var bankService = BankDeepLinkService.shared

    @Environment(\.scenePhase) var scenePhase

    // Tracking para detecção de retorno do banco
    @State private var showPaymentConfirmation = false
    @State private var pendingPaymentId: UUID?

    var body: some Scene {
        WindowGroup {
            Group {
                if !supabase.isAuthenticated {
                    OnboardingView()
                } else if biometric.isBiometricEnabled && !biometric.isUnlocked {
                    LockScreenView()
                } else {
                    ContentView()
                        .sheet(isPresented: $showPaymentConfirmation) {
                            if let paymentId = pendingPaymentId {
                                PaymentConfirmationView(paymentId: paymentId)
                            }
                        }
                }
            }
            .environmentObject(supabase)
            .environmentObject(biometric)
            .environmentObject(bankService)
            .preferredColorScheme(.light) // Dono é light-only por design
            .tint(DonoTheme.Colors.accent)
            .onAppear {
                setupApp()
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhaseChange(newPhase)
            }
            .onReceive(NotificationCenter.default.publisher(for: .payNowAction)) { notification in
                handlePayNowAction(notification)
            }
            .onReceive(NotificationCenter.default.publisher(for: .openPayment)) { notification in
                handleOpenPayment(notification)
            }
        }
        .modelContainer(for: [Provider.self, Payment.self])
    }

    // MARK: - Setup

    private func setupApp() {
        // Restore Supabase session
        Task {
            await supabase.restoreSession()
        }

        // Setup notifications
        NotificationService.shared.setup()

        // Detect installed banks
        bankService.detectInstalledBanks()

        // Configure appearance
        configureAppearance()
    }

    private func configureAppearance() {
        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(DonoTheme.Colors.background)
        navAppearance.shadowColor = .clear
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(DonoTheme.Colors.textPrimary)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(DonoTheme.Colors.background)
        tabAppearance.shadowColor = UIColor(DonoTheme.Colors.divider)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    // MARK: - Scene Phase

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // Voltou pro app — verifica se veio do banco
            if bankService.didReturnFromBank() {
                showPaymentConfirmation = true
                bankService.clearBankOpenedMark()
            }

        case .background:
            // Lock se biometria está ativada
            if biometric.isBiometricEnabled {
                biometric.lock()
            }

        case .inactive:
            break

        @unknown default:
            break
        }
    }

    // MARK: - Notification Handlers

    private func handlePayNowAction(_ notification: Foundation.Notification) {
        if let paymentId = notification.userInfo?["payment_id"] as? UUID {
            pendingPaymentId = paymentId
            // A UI vai reagir e iniciar o fluxo de pagamento
        }
    }

    private func handleOpenPayment(_ notification: Foundation.Notification) {
        if let paymentId = notification.userInfo?["payment_id"] as? UUID {
            pendingPaymentId = paymentId
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenView: View {
    @EnvironmentObject var biometric: BiometricService

    var body: some View {
        VStack(spacing: DonoTheme.Spacing.xl) {
            Spacer()

            // Logo
            VStack(spacing: DonoTheme.Spacing.md) {
                DonoLogoView(size: 80)

                Text("Dono")
                    .font(.custom("PlayfairDisplay-Bold", size: 36))
                    .foregroundColor(DonoTheme.Colors.textPrimary)
            }

            Spacer()

            // Unlock button
            Button {
                Task {
                    await biometric.authenticate()
                }
            } label: {
                VStack(spacing: DonoTheme.Spacing.sm) {
                    Image(systemName: biometric.biometricType.icon)
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(DonoTheme.Colors.accent)

                    Text("Desbloquear com \(biometric.biometricType.label)")
                        .font(DonoTheme.Typography.subheadline)
                        .foregroundColor(DonoTheme.Colors.textSecondary)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DonoTheme.Colors.background)
        .onAppear {
            Task {
                await biometric.authenticate()
            }
        }
    }
}

// MARK: - Logo View
struct DonoLogoView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Arco (teto)
            Arc()
                .stroke(DonoTheme.Colors.textPrimary, lineWidth: 2.5)
                .frame(width: size * 0.7, height: size * 0.35)
                .offset(y: -size * 0.15)

            // Dot embaixo do arco
            Circle()
                .fill(DonoTheme.Colors.accent)
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(y: size * 0.05)
        }
        .frame(width: size, height: size)
    }
}

struct Arc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.width / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}
