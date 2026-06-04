import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {

                // ── Sección siempre visible ──────────────────────────
                Section("General") {
                    Label("Idioma", systemImage: "globe")
                    Label("Notificaciones", systemImage: "bell")
                    Label("Apariencia", systemImage: "paintbrush")
                }

                // ── Sección protegida con Face ID ────────────────────
                Section("Privado") {
                    PrivateSettingsSection()
                        .biometricLocked(reason: "Accede a tu configuración privada")
                }

            }
            .navigationTitle("Ajustes")
        }
    }
}

// MARK: - Contenido privado (solo se muestra tras autenticarse)
struct PrivateSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Cambiar contraseña", systemImage: "key")
            Divider()
            Label("Vincular cuenta bancaria", systemImage: "creditcard")
            Divider()
            Label("Exportar mis datos", systemImage: "square.and.arrow.up")
            Divider()
            Label("Eliminar cuenta", systemImage: "trash")
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
