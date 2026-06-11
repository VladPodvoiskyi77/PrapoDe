import SwiftUI

struct HeaderView: View {
    let title: String
    @Binding var showExitAlert: Bool
    
    var onInfoAction: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 6) {
            if let action = onInfoAction {
                Button(action: action) {
                    infoButtonLabel
                }
            } else {
                closeButtonLabel
                    .opacity(0)
                    .accessibilityHidden(true)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                showExitAlert = true
            } label: {
                closeButtonLabel
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .navigationBarBackButtonHidden(true)
    }
    
    private var closeButtonLabel: some View {
        Image(systemName: "xmark")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
    }
    
    private var infoButtonLabel: some View {
        Image(systemName: "questionmark.circle")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
    }
}
