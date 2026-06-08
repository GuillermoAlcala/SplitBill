import SwiftUI

struct SettingsView: View {
    @Binding  var mostrarVista : Bool
    @AppStorage("isDarkMode") private var isDarkMode : Bool = false
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
             //       PrivateSettingsSection()
                    HiddenFeatures(isDeveloperTabVisible: $mostrarVista)
                    ToggleColorScheme
                        
                }.biometricLocked(reason: "Accede a tu configuración privada")

            } //List
            .navigationTitle("Ajustes")
        }
    }
    @ViewBuilder
    private var ToggleColorScheme : some View{
        Toggle(isOn: $isDarkMode, label: {
                Label(isDarkMode ? "Dark Mode" : "Light Mode",
                      systemImage: isDarkMode ? "moon" : "sun.min")
            }).toggleStyle(.automatic)
             //   .contentTransition(.symbolEffect)
                .contentTransition(.symbolEffect(.replace)) // Animate symbol smoothly

                .tint(.mint)
                
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
    SettingsView(mostrarVista: .constant(false))
}
