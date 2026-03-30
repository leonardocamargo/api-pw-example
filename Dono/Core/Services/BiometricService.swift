import Foundation
import LocalAuthentication

// MARK: - Biometric Service
// Gerencia Face ID / Touch ID para proteção do app

import Observation

@Observable
final class BiometricService {

    static let shared = BiometricService()

    var isUnlocked = false
    var biometricType: BiometricType = .none

    enum BiometricType {
        case faceID, touchID, none

        var label: String {
            switch self {
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            case .none: return "Senha"
            }
        }

        var icon: String {
            switch self {
            case .faceID: return "faceid"
            case .touchID: return "touchid"
            case .none: return "lock"
            }
        }
    }

    private init() {
        detectBiometricType()
    }

    // MARK: - Detection

    func detectBiometricType() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricType = .none
            return
        }

        switch context.biometryType {
        case .faceID:
            biometricType = .faceID
        case .touchID:
            biometricType = .touchID
        default:
            biometricType = .none
        }
    }

    // MARK: - Authentication

    /// Autentica o usuário com biometria
    @MainActor
    func authenticate(reason: String = "Desbloqueie o Dono") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"
        context.localizedFallbackTitle = "Usar senha"

        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback para senha do device
            return await authenticateWithDevicePasscode(reason: reason)
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            isUnlocked = success
            return success
        } catch {
            return false
        }
    }

    /// Fallback para senha do device
    @MainActor
    private func authenticateWithDevicePasscode(reason: String) async -> Bool {
        let context = LAContext()

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            isUnlocked = success
            return success
        } catch {
            return false
        }
    }

    /// Lock do app (quando vai pro background)
    func lock() {
        isUnlocked = false
    }

    // MARK: - Settings

    var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometric_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometric_enabled") }
    }
}
