import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showAuth = false

    var body: some View {
        ZStack {
            DonoTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "house",
                        title: "Cuide do que\né seu",
                        description: "Organize todos os pagamentos da sua casa em um só lugar. Jardineiro, contador, piscineiro — tudo sob controle.",
                        accentColor: DonoTheme.Colors.accent
                    )
                    .tag(0)

                    OnboardingPage(
                        icon: "bell.badge",
                        title: "Nunca mais\nesqueça",
                        description: "Receba lembretes no dia certo. Com um toque, copie o Pix e abra seu banco. Pagamento feito em segundos.",
                        accentColor: DonoTheme.Colors.success
                    )
                    .tag(1)

                    OnboardingPage(
                        icon: "chart.bar",
                        title: "Veja pra\nonde vai",
                        description: "Acompanhe quanto gasta por mês, por categoria. Tenha clareza sobre seus custos recorrentes.",
                        accentColor: DonoTheme.Colors.warning
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(DonoTheme.Animation.springGentle, value: currentPage)

                // Page Indicator
                HStack(spacing: DonoTheme.Spacing.sm) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(currentPage == index
                                  ? DonoTheme.Colors.accent
                                  : DonoTheme.Colors.divider)
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(DonoTheme.Animation.springGentle, value: currentPage)
                    }
                }
                .padding(.bottom, DonoTheme.Spacing.xl)

                // Buttons
                VStack(spacing: DonoTheme.Spacing.md) {
                    if currentPage < 2 {
                        DonoPrimaryButton("Continuar") {
                            withAnimation {
                                currentPage += 1
                            }
                        }

                        DonoGhostButton("Pular") {
                            showAuth = true
                        }
                    } else {
                        DonoPrimaryButton("Começar", icon: "arrow.right") {
                            showAuth = true
                        }
                    }
                }
                .padding(.horizontal, DonoTheme.Spacing.lg)
                .padding(.bottom, DonoTheme.Spacing.xxl)
            }
        }
        .sheet(isPresented: $showAuth) {
            AuthView()
        }
    }
}

// MARK: - Onboarding Page
struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: DonoTheme.Spacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(accentColor)
            }

            // Text
            VStack(spacing: DonoTheme.Spacing.md) {
                Text(title)
                    .font(.custom("PlayfairDisplay-Bold", size: 32))
                    .foregroundColor(DonoTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text(description)
                    .font(DonoTheme.Typography.body)
                    .foregroundColor(DonoTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, DonoTheme.Spacing.lg)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Auth View
struct AuthView: View {
    @EnvironmentObject var supabase: SupabaseService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: DonoTheme.Spacing.xl) {
                Spacer()

                // Logo
                VStack(spacing: DonoTheme.Spacing.md) {
                    DonoLogoView(size: 64)

                    Text("Dono")
                        .font(.custom("PlayfairDisplay-Bold", size: 32))
                        .foregroundColor(DonoTheme.Colors.textPrimary)

                    Text("Entre para sincronizar seus dados")
                        .font(DonoTheme.Typography.subheadline)
                        .foregroundColor(DonoTheme.Colors.textSecondary)
                }

                Spacer()

                // Auth Buttons
                VStack(spacing: DonoTheme.Spacing.md) {
                    // Sign in with Apple
                    Button {
                        // Apple Sign In flow
                    } label: {
                        HStack(spacing: DonoTheme.Spacing.sm) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18))
                            Text("Continuar com Apple")
                                .font(DonoTheme.Typography.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(DonoTheme.Colors.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.lg))
                    }

                    // Sign in with Google
                    Button {
                        // Google Sign In flow
                    } label: {
                        HStack(spacing: DonoTheme.Spacing.sm) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 18))
                            Text("Continuar com Google")
                                .font(DonoTheme.Typography.headline)
                        }
                        .foregroundColor(DonoTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(DonoTheme.Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.lg))
                        .overlay(
                            RoundedRectangle(cornerRadius: DonoTheme.Radius.lg)
                                .strokeBorder(DonoTheme.Colors.border, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, DonoTheme.Spacing.lg)

                // Skip
                DonoGhostButton("Usar sem conta") {
                    dismiss()
                }
                .padding(.bottom, DonoTheme.Spacing.xxl)
            }
            .background(DonoTheme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DonoIconButton("xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}
