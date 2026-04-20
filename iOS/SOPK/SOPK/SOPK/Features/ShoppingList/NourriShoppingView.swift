import SwiftUI

struct NourriShoppingView: View {
    let palette: Palette
    let isDark: Bool

    @EnvironmentObject private var shoppingStore: ShoppingStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showAddItem = false
    @State private var newItemName = ""

    private var familyId: UUID? { authViewModel.currentProfile?.familyId }
    private var total: Int { shoppingStore.totalItems }
    private var done: Int { shoppingStore.checkedItems }
    private var progress: Double { total > 0 ? Double(done) / Double(total) : 0 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Liste de courses")
                            .font(.custom("Fraunces", size: 30))
                            .foregroundColor(palette.ink)
                            .kerning(-0.5)
                        Spacer()
                        if done > 0 {
                            Button {
                                Task { await shoppingStore.clearChecked(familyId: familyId) }
                            } label: {
                                Text("Effacer cochés")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(palette.sageDeep)
                            }
                        }
                    }

                    // Progress bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(done) sur \(total) éléments")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(palette.ink)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(palette.inkSoft)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(palette.line)
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(palette.sageDeep)
                                    .frame(width: geo.size.width * progress, height: 6)
                                    .animation(.easeInOut(duration: 0.3), value: progress)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(16)
                    .background(palette.cardAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    // Add item button
                    Button { showAddItem = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(palette.sageDeep)
                            Text("Ajouter un article")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(palette.sageDeep)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(palette.sageWash)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.top, 62)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                if shoppingStore.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if shoppingStore.categories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 40))
                            .foregroundColor(palette.inkMuted)
                        Text("Liste vide")
                            .font(.custom("Fraunces", size: 20))
                            .foregroundColor(palette.ink)
                        Text("Ajoutez vos articles ou générez depuis le plan de repas.")
                            .font(.system(size: 13))
                            .foregroundColor(palette.inkSoft)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .padding(.horizontal, 40)
                } else {
                    // Shopping categories
                    VStack(spacing: 22) {
                        ForEach(shoppingStore.categories) { cat in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(cat.id.capitalized)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(palette.inkMuted)
                                        .kerning(0.5)
                                        .textCase(.uppercase)
                                    Spacer()
                                    Text("\(cat.items.filter(\.isChecked).count)/\(cat.items.count)")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(palette.inkMuted)
                                }
                                .padding(.horizontal, 6)

                                VStack(spacing: 0) {
                                    ForEach(Array(cat.items.enumerated()), id: \.offset) { idx, item in
                                        let on = item.isChecked
                                        Button {
                                            Task { await shoppingStore.toggle(entryId: item.id, familyId: familyId) }
                                        } label: {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 7)
                                                        .fill(on ? palette.sageDeep : Color.clear)
                                                        .frame(width: 22, height: 22)
                                                    RoundedRectangle(cornerRadius: 7)
                                                        .stroke(on ? Color.clear : palette.lineStrong, lineWidth: 2)
                                                        .frame(width: 22, height: 22)
                                                    if on {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 13, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }
                                                }

                                                VStack(alignment: .leading, spacing: 1) {
                                                    Text(item.name)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(palette.ink)
                                                        .strikethrough(on, color: palette.inkMuted)
                                                }
                                                Spacer()
                                                if !item.qty.isEmpty {
                                                    Text(item.qty)
                                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                                        .foregroundColor(palette.inkSoft)
                                                }
                                            }
                                            .padding(.horizontal, 16).padding(.vertical, 14)
                                            .opacity(on ? 0.5 : 1)
                                        }
                                        .buttonStyle(.plain)
                                        .animation(.easeInOut(duration: 0.15), value: on)

                                        if idx < cat.items.count - 1 {
                                            Divider().padding(.horizontal, 16)
                                        }
                                    }
                                }
                                .background(palette.card)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 110)
        }
        .background(palette.bg.ignoresSafeArea())
        .task { await shoppingStore.load(familyId: familyId) }
        .sheet(isPresented: $showAddItem) {
            NourriAddShoppingItemSheet(palette: palette, familyId: familyId)
        }
    }
}

struct NourriAddShoppingItemSheet: View {
    let palette: Palette
    let familyId: UUID?
    @EnvironmentObject private var shoppingStore: ShoppingStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var qty = ""
    @State private var category = "autre"

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nom de l'article")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("ex: Épinards", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantité (optionnel)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("ex: 200 g", text: $qty)
                        .textFieldStyle(.roundedBorder)
                }
                Spacer()
                Button {
                    guard !name.isEmpty else { return }
                    Task {
                        await shoppingStore.addItem(name: name, qty: qty, category: category, familyId: familyId)
                        dismiss()
                    }
                } label: {
                    Text("Ajouter")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(name.isEmpty ? Color.gray : palette.sageDeep)
                        .clipShape(Capsule())
                }
            }
            .padding(24)
            .navigationTitle("Ajouter un article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }
}
