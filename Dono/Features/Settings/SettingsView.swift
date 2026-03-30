import SwiftUI
import Auth

// MARK: - Settings View
struct SettingsView: View {
    @Environment(SupabaseService.self) var supabase
    @Environment(BiometricService.self) var biometric
    @Environment(BankDeepLinkService.self) var bankService

    @State private var showBankSelection = false
    @State private var showPremium = false
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = false
    @State private var calendarSync = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DonoTheme.Spacing.lg) {

                    // MARK: - Profile
                    profileSection

                    // MARK: - Bank
                    bankSection

                    // MARK: - Notifications
                    notificationSection

                    // MARK: - Security
                    securitySection

                    // MARK: - Premium
                    premiumSection

                    // MARK: - Data
                    dataSection

                    // MARK: - About
                    aboutSection

                    // Sign out
                    DonoGhostButton("Sair da conta", icon: "rectangle.portrait.and.arrow.right") {
                        Task {
                            try? await supabase.signOut()
                        }
                    }
                    .padding(.top, DonoTheme.Spacing.lg)

                    Spacer(minLength: DonoTheme.Spacing.xxxl)
                }
                .padding(.horizontal, DonoTheme.Spacing.md)
            }
            .background(DonoTheme.Colors.background)
            .navigationTitle("Ajustes")
        }
    }

    // MARK: - Sections

    private var profileSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Perfil")

            HStack(spacing: DonoTheme.Spacing.md) {
                DonoAvatar(supabase.currentUser?.email ?? "U", size: 52)

                VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                    Text("Leonardo")
                        .font(DonoTheme.Typography.bodyMedium)
                        .foregroundColor(DonoTheme.Colors.textPrimary)

                    Text(supabase.currentUser?.email ?? "")
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(DonoTheme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(DonoTheme.Colors.textTertiary)
            }
            .padding(DonoTheme.Spacing.md)
            .overlay(
                RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                    .strokeBorder(DonoTheme.Colors.divider, lineWidth: 1)
            )
        }
    }

    private var bankSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Banco preferido")

            Button {
                showBankSelection = true
            } label: {
                HStack(spacing: DonoTheme.Spacing.md) {
                    if let bank = bankService.preferredBank {
                        ZStack {
                            Circle()
                                .fill(bank.color.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: bank.iconName)
                                .foregroundColor(bank.color)
                        }

                        Text(bank.name)
                            .font(DonoTheme.Typography.bodyMedium)
                            .foregroundColor(DonoTheme.Colors.textPrimary)
                    } else {
                        Image(systemName: "building.columns")
                            .foregroundColor(DonoTheme.Colors.textSecondary)
                        Text("Selecionar banco")
                            .font(DonoTheme.Typography.body)
                            .foregroundColor(DonoTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(DonoTheme.Colors.textTertiary)
                }
                .padding(DonoTheme.Spacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                        .strokeBorder(DonoTheme.Colors.divider, lineWidth: 1)
                )
            }
        }
        .sheet(isPresented: $showBankSelection) {
            BankPickerView { _ in }
                .presentationDetents([.medium])
        }
    }

    private var notificationSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Notificações")

            SettingsToggle(
                icon: "bell",
                title: "Lembretes de pagamento",
                isOn: $notificationsEnabled
            )

            SettingsToggle(
                icon: "calendar",
                title: "Sincronizar com Calendário",
                isOn: $calendarSync
            )
        }
    }

    private var securitySection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Segurança")

            SettingsToggle(
                icon: biometric.biometricType.icon,
                title: "Bloquear com \(biometric.biometricType.label)",
                isOn: $biometricEnabled
            )
            .onChange(of: biometricEnabled) { _, newValue in
                biometric.isBiometricEnabled = newValue
            }
        }
    }

    private var premiumSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Plano")

            Button {
                showPremium = true
            } label: {
                HStack(spacing: DonoTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(DonoTheme.Colors.warning.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "crown")
                            .font(.system(size: 14))
                            .foregroundColor(DonoTheme.Colors.warning)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dono Premium")
                            .font(DonoTheme.Typography.bodyMedium)
                            .foregroundColor(DonoTheme.Colors.textPrimary)
                        Text("Prestadores ilimitados, relatórios e mais")
                            .font(DonoTheme.Typography.caption)
                            .foregroundColor(DonoTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Text("R$ 9,90/mês")
                        .font(DonoTheme.Typography.captionMedium)
                        .foregroundColor(DonoTheme.Colors.accent)
                        .padding(.horizontal, DonoTheme.Spacing.sm)
                        .padding(.vertical, DonoTheme.Spacing.xs)
                        .background(DonoTheme.Colors.accentSubtle)
                        .clipShape(Capsule())
                }
                .padding(DonoTheme.Spacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                        .strokeBorder(DonoTheme.Colors.warning.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    private var dataSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Dados")

            SettingsRow(icon: "square.and.arrow.up", title: "Exportar relatório PDF") {}
            SettingsRow(icon: "arrow.down.doc", title: "Exportar dados") {}
        }
    }

    private var aboutSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            DonoSectionHeader("Sobre")

            SettingsRow(icon: "star", title: "Avaliar na App Store") {}
            SettingsRow(icon: "envelope", title: "Enviar feedback") {}
            SettingsRow(icon: "doc.text", title: "Termos de uso") {}
            SettingsRow(icon: "hand.raised", title: "Privacidade") {}

            HStack {
                Spacer()
                Text("Dono v1.0.0")
                    .font(DonoTheme.Typography.caption)
                    .foregroundColor(DonoTheme.Colors.textTertiary)
                Spacer()
            }
            .padding(.top, DonoTheme.Spacing.sm)
        }
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: DonoTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(DonoTheme.Colors.textSecondary)
                .frame(width: 20)

            Text(title)
                .font(DonoTheme.Typography.body)
                .foregroundColor(DonoTheme.Colors.textPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(DonoTheme.Colors.accent)
                .labelsHidden()
        }
        .padding(.horizontal, DonoTheme.Spacing.md)
        .padding(.vertical, DonoTheme.Spacing.sm)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DonoTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(DonoTheme.Colors.textSecondary)
                    .frame(width: 20)

                Text(title)
                    .font(DonoTheme.Typography.body)
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(DonoTheme.Colors.textTertiary)
            }
            .padding(.horizontal, DonoTheme.Spacing.md)
            .padding(.vertical, DonoTheme.Spacing.sm)
        }
    }
}
