import SwiftUI

extension View {
    func showAlert(title: String, description: String = "", isPresented: Binding<Bool>, onExit: @escaping () -> Void) -> some View {
        self.alert(title, isPresented: isPresented) {
            Button(L10n.Alert.yes, role: .destructive) {
                onExit()
                }
            Button(L10n.Alert.no, role: .cancel) { }
        } message: {
            Text(description)
        }
    }
    
    func errorAlert(isPresented: Binding<Bool>, error: AppError?, retryAction: (() -> Void)? = nil) -> some View {
            let titleText = error?.errorDescription ?? L10n.Alert.unknownError
        
            return self.alert(titleText, isPresented: isPresented) {
                Button(L10n.Alert.ok, role: .cancel) { }
                
                if let action = retryAction {
                    Button(L10n.Alert.repeat) { action() }
            }
        }
    }
    
    func statusAlert(title: String, description: String = "", isPresented: Binding<Bool>) -> some View {
        self.alert(title, isPresented: isPresented) {
            Button(L10n.Alert.ok, role: .cancel) { }
        } message: {
            if !description.isEmpty {
                Text(description)
            }
        }
    }
    
    func blockInteraction(for delay: TimeInterval = 0.5) -> some View {
            modifier(InteractionBlockerModifier(delay: delay))
        }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func NavigationChevron() -> some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary) // Едва заметный серый (адаптивный)
            .fontWeight(.semibold)
    }
}
