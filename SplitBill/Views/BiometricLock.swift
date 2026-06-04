import SwiftUI
import LocalAuthentication

// MARK: - ViewModifier
struct BiometricLock: ViewModifier {
    @State private var isUnlocked = false
    @State private var showError = false
    @Environment(\.scenePhase) private var scenePhase

    let reason: String

    func body(content: Content) -> some View {
        Group {
            if isUnlocked {
                content
            } else {
                lockedPlaceholder
            }
        }
        .onChange(of: scenePhase){
            if scenePhase == .background || scenePhase == .inactive{
                isUnlocked = false
            }
            
//            
//            if scenePhase == .active && !isUnlocked{
//                authenticate()  // re-lanza al volver de background Memo
//            }
            
        }
//        
//        // Probando automatic faceID Memo
//        .onAppear{
//            authenticate()
//            
//        }
//        .onChange(of: scenePhase) { phase in
//            if phase == .background {
//                isUnlocked = false
//            }
//        }
    }

    // MARK: - Locked UI
    private var lockedPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: biometryIcon)
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(.secondary)

            Text("Contenido protegido")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Autentícate para ver esta sección")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: authenticate) {
                Label("Desbloquear", systemImage: biometryIcon)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .tint(.pink)

            if showError {
                Text("No se pudo autenticar. Intenta de nuevo.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .animation(.easeInOut, value: showError)
    }

    // MARK: - Biometry icon helper
    private var biometryIcon: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .faceID ? "faceid" : "touchid"
    }

    // MARK: - Authentication
    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        // MARK: - ESTO ES ÚNICAMENTE PARA FACE ID
//        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
//            withAnimation { showError = true }
//            return
//        }
//        
//
        // MARK: - POR SI FALLA EL FACE ID, ENTONCES ENTRA EL TECLADO DE CONTRASEÑA DEL DISPOSITIVO
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            withAnimation { showError = true }
            return
        }
        
        // MARK: - SE AGREGA: deviceOwnerAuthentication para tener dos opciones de desbloqueo, primero FACEID y luego Password
        context.evaluatePolicy(
            // para face id: deviceOwnerAuthenticationWithBiometrics
            // uso deviceOwnerAuthentication para activar el teclado de password en case que falle.
            .deviceOwnerAuthentication,
            localizedReason: reason
        ) { success, _ in
            DispatchQueue.main.async {
                withAnimation {
                    isUnlocked = success
                    showError = !success
                }
            }
        }
    }
}

// MARK: - Extension
extension View {
    /// Protege cualquier View con Face ID / Touch ID.
    /// Uso: `MyView().biometricLocked(reason: "Accede a tus ajustes privados")`
    func biometricLocked(reason: String = "Autentícate para continuar") -> some View {
        modifier(BiometricLock(reason: reason))
    }
}

