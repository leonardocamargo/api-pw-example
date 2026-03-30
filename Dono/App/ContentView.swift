import SwiftUI

// MARK: - Main Tab View
struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddProvider = false

    enum Tab: String, CaseIterable {
        case home = "Início"
        case calendar = "Calendário"
        case providers = "Prestadores"
        case history = "Histórico"
        case settings = "Ajustes"

        var icon: String {
            switch self {
            case .home: return "house"
            case .calendar: return "calendar"
            case .providers: return "person.2"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gearshape"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .calendar: return "calendar"
            case .providers: return "person.2.fill"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.rawValue,
                          systemImage: selectedTab == .home ? Tab.home.selectedIcon : Tab.home.icon)
                }
                .tag(Tab.home)

            CalendarView()
                .tabItem {
                    Label(Tab.calendar.rawValue,
                          systemImage: selectedTab == .calendar ? Tab.calendar.selectedIcon : Tab.calendar.icon)
                }
                .tag(Tab.calendar)

            // Center "add" button placeholder
            Color.clear
                .tabItem {
                    Label("Novo", systemImage: "plus.circle.fill")
                }
                .tag(Tab.providers) // reusamos temporariamente

            HistoryView()
                .tabItem {
                    Label(Tab.history.rawValue,
                          systemImage: selectedTab == .history ? Tab.history.selectedIcon : Tab.history.icon)
                }
                .tag(Tab.history)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue,
                          systemImage: selectedTab == .settings ? Tab.settings.selectedIcon : Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .providers {
                showAddProvider = true
                // Volta pra tab anterior
                selectedTab = .home
            }
            DonoTheme.Haptics.selection()
        }
        .sheet(isPresented: $showAddProvider) {
            AddProviderView()
        }
    }
}
