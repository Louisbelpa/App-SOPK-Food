import SwiftUI

struct FamilySetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FamilyViewModel()
    @State private var mode: Mode = .choose
    @State private var familyName = ""
    @State private var inviteCode = ""
    @State private var createdCode: String? = nil

    enum Mode { case choose, create, join }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color("AccentGreen"))
                        Text("Votre famille")
                            .font(.title.bold())
                        Text("Partagez le planificateur et la liste de courses avec vos proches")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    switch mode {
                    case .choose:
                        chooseView

                    case .create:
                        if let code = createdCode {
                            codeDisplayView(code: code)
                        } else {
                            createView
                        }

                    case .join:
                        joinView
                    }

                    if let error = viewModel.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Subviews
    private var chooseView: some View {
        VStack(spacing: 14) {
            FamilyOptionButton(
                title: "Créer une famille",
                subtitle: "Générez un code à partager avec vos proches",
                icon: "plus.circle.fill",
                color: Color("AccentGreen")
            ) { mode = .create }

            FamilyOptionButton(
                title: "Rejoindre une famille",
                subtitle: "Entrez le code d'invitation reçu",
                icon: "person.badge.plus.fill",
                color: .blue
            ) { mode = .join }

            Button("Continuer sans famille") {
                UserDefaults.standard.set(true, forKey: "family_setup_skipped")
            }
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            .padding(.top, 8)
        }
    }

    private var createView: some View {
        VStack(spacing: 16) {
            TextField("Nom de la famille (ex : Famille Martin)", text: $familyName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                guard let userId = authViewModel.currentUser?.id else { return }
                viewModel.isLoading = true
                Task {
                    do {
                        let family = try await viewModel.createFamily(name: familyName, userId: userId)
                        createdCode = family.inviteCode
                        await authViewModel.refreshProfile()
                    } catch {
                        viewModel.error = error.localizedDescription
                    }
                    viewModel.isLoading = false
                }
            } label: {
                actionLabel(title: "Créer")
            }
            .disabled(familyName.isEmpty || viewModel.isLoading)

            backButton
        }
    }

    private var joinView: some View {
        VStack(spacing: 16) {
            TextField("Code d'invitation (6 caractères)", text: $inviteCode)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onChange(of: inviteCode) { _, v in inviteCode = String(v.prefix(6)).uppercased() }

            Button {
                guard let userId = authViewModel.currentUser?.id else { return }
                viewModel.isLoading = true
                viewModel.error = nil
                Task {
                    do {
                        try await viewModel.joinFamilyByCode(code: inviteCode, userId: userId)
                        await authViewModel.refreshProfile()
                    } catch {
                        viewModel.error = error.localizedDescription
                    }
                    viewModel.isLoading = false
                }
            } label: {
                actionLabel(title: "Rejoindre")
            }
            .disabled(inviteCode.count < 6 || viewModel.isLoading)

            backButton
        }
    }

    private func codeDisplayView(code: String) -> some View {
        VStack(spacing: 20) {
            Text("Famille créée !")
                .font(.title2.bold())

            VStack(spacing: 8) {
                Text("Code d'invitation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(code)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color("AccentGreen"))
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    UIPasteboard.general.string = code
                } label: {
                    Label("Copier le code", systemImage: "doc.on.doc")
                        .font(.subheadline)
                }
                .foregroundStyle(Color("AccentGreen"))
            }

            Text("Partagez ce code avec vos proches pour qu'ils rejoignent votre famille.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await authViewModel.refreshProfile() }
            } label: {
                Text("Commencer")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentGreen"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func actionLabel(title: String) -> some View {
        Group {
            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else {
                Text(title).fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("AccentGreen"))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var backButton: some View {
        Button("Retour") { mode = .choose; viewModel.error = nil }
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

struct FamilyOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .foregroundStyle(.primary)
    }
}
