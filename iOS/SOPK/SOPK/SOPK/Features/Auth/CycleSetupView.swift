import SwiftUI

struct CycleSetupView: View {
    let palette: Palette
    @EnvironmentObject private var cycleStore: CycleStore
    @Environment(\.dismiss) private var dismiss

    @State private var lastPeriodDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    @State private var cycleLength: Double = 28

    var computedPhase: String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastPeriodDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0
        let day = max(1, (days % Int(cycleLength)) + 1)
        return CycleStore.phaseFor(day: day, length: Int(cycleLength))
    }

    var computedDay: Int {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastPeriodDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0
        return max(1, (days % Int(cycleLength)) + 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Preview card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Aperçu")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Jour \(computedDay) sur \(Int(cycleLength))")
                                    .font(.custom("Fraunces", size: 22).weight(.medium))
                                    .foregroundColor(palette.ink)
                                Text("Phase \(computedPhase.lowercased())")
                                    .font(.system(size: 14))
                                    .foregroundColor(palette.terracottaDeep)
                            }
                            Spacer()
                            CycleDial(day: computedDay, of: Int(cycleLength), palette: palette)
                                .frame(width: 60, height: 60)
                        }
                        .padding(16)
                        .background(palette.cardAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    // Last period date
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Premier jour de vos dernières règles")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)

                        DatePicker(
                            "",
                            selection: $lastPeriodDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .accentColor(palette.sageDeep)
                        .labelsHidden()
                        .background(palette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    // Cycle length slider
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Durée du cycle")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(palette.inkMuted)
                                .kerning(0.5)
                                .textCase(.uppercase)
                            Spacer()
                            Text("\(Int(cycleLength)) jours")
                                .font(.custom("Fraunces", size: 18).weight(.medium))
                                .foregroundColor(palette.ink)
                        }

                        Slider(value: $cycleLength, in: 21...45, step: 1)
                            .accentColor(palette.sageDeep)

                        HStack {
                            Text("21 j")
                                .font(.system(size: 11))
                                .foregroundColor(palette.inkMuted)
                            Spacer()
                            Text("45 j")
                                .font(.system(size: 11))
                                .foregroundColor(palette.inkMuted)
                        }
                    }
                    .padding(16)
                    .background(palette.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    // Phase legend
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Les 4 phases")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)

                        let len = Int(cycleLength)
                        let ovDay = max(len - 14, 7)
                        let phases: [(String, String, Color)] = [
                            ("Menstruelle",  "J1–J5",                    palette.terracotta),
                            ("Folliculaire", "J6–J\(ovDay - 2)",         palette.sage),
                            ("Ovulatoire",   "J\(ovDay - 1)–J\(ovDay + 2)", palette.sageDeep),
                            ("Lutéale",      "J\(ovDay + 3)–J\(len)",    palette.terracottaDeep),
                        ]
                        ForEach(phases, id: \.0) { name, range, color in
                            HStack {
                                Circle().fill(color).frame(width: 10, height: 10)
                                Text(name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(palette.ink)
                                Spacer()
                                Text(range)
                                    .font(.system(size: 12))
                                    .foregroundColor(palette.inkSoft)
                            }
                        }
                    }
                    .padding(16)
                    .background(palette.cardAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    // Save button
                    Button {
                        cycleStore.save(lastPeriod: lastPeriodDate, length: Int(cycleLength))
                        dismiss()
                    } label: {
                        Text("Enregistrer")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(palette.sageDeep)
                            .clipShape(Capsule())
                    }

                    // RGPD
                    Text("🔒 Tes données de santé sont stockées de façon sécurisée et ne sont jamais partagées avec des tiers. Tu peux les supprimer à tout moment dans les Réglages.")
                        .font(.system(size: 11))
                        .foregroundColor(palette.inkMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(palette.bg.ignoresSafeArea())
            .navigationTitle("Mon cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(palette.ink)
                    }
                }
            }
            .onAppear {
                if let saved = cycleStore.lastPeriodDate { lastPeriodDate = saved }
                cycleLength = Double(cycleStore.cycleLength)
            }
        }
    }
}
