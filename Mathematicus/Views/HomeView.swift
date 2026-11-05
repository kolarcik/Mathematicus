import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @State private var showProfiles = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 18) {
                    if let profile = store.current {
                        Button { showProfiles = true } label: {
                            ProfileHeader(profile: profile, streak: store.activeStreak)
                        }
                        .buttonStyle(PressableStyle())
                    }

                    Text("Kterou třídu jdeš trénovat?")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 6)

                    ForEach(Curriculum.grades) { grade in
                        NavigationLink(value: grade) {
                            GradeCard(grade: grade, stars: store.stars(in: grade), maxStars: store.maxStars(in: grade))
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mathematicus")
            .navigationDestination(for: Grade.self) { GradeView(grade: $0) }
            .navigationDestination(for: Topic.self) { TopicView(topic: $0) }
            .sheet(isPresented: $showProfiles) { ProfilesSheet() }
        }
        #if DEBUG
        .onAppear(perform: DebugLaunch.openTopic { grade, topic in
            path.append(grade)
            if let topic { path.append(topic) }
        })
        #endif
    }
}

struct ProfileHeader: View {
    let profile: Profile
    let streak: Int

    var body: some View {
        HStack(spacing: 14) {
            Text(profile.avatar)
                .font(.system(size: 44))
                .frame(width: 64, height: 64)
                .background(Color.accentColor.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(profile.name).font(.title3.bold()).foregroundStyle(.primary)
                    Spacer()
                    if streak > 0 {
                        Label("\(streak)", systemImage: "flame.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                    }
                }
                Text("Úroveň \(profile.level) · \(profile.rankTitle)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ProgressView(value: profile.levelProgress)
                    .tint(.accentColor)
                Text("\(profile.xp) XP")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .card()
    }
}

struct GradeCard: View {
    let grade: Grade
    let stars: Int
    let maxStars: Int

    var body: some View {
        HStack(spacing: 16) {
            Text("\(grade.number).")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 84)
            VStack(alignment: .leading, spacing: 6) {
                Text(grade.title).font(.title2.bold()).foregroundStyle(.white)
                Text(grade.motto)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("\(stars) / \(maxStars)").font(.subheadline.bold()).foregroundStyle(.white)
                    Spacer()
                    Text(grade.boss.emoji).font(.title2)
                }
            }
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding()
        .background(grade.gradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: grade.colors[0].opacity(0.35), radius: 10, y: 5)
    }
}

// MARK: - Profily

struct ProfilesSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var adding = false
    @State private var toDelete: Profile?

    var body: some View {
        NavigationStack {
            List {
                Section("Hráči") {
                    ForEach(store.profiles) { p in
                        Button {
                            store.currentID = p.id
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text(p.avatar).font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(p.name).font(.headline).foregroundStyle(.primary)
                                    Text("Úroveň \(p.level) · \(p.xp) XP").font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if p.id == store.currentID {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.title2)
                                }
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) { toDelete = p } label: { Label("Smazat", systemImage: "trash") }
                        }
                    }
                }
                Section {
                    Button { adding = true } label: { Label("Přidat hráče", systemImage: "person.badge.plus") }
                }
            }
            .navigationTitle("Kdo hraje?")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Hotovo") { dismiss() } } }
            .sheet(isPresented: $adding) { ProfileEditorView(isOnboarding: false) }
            .alert("Smazat hráče \(toDelete?.name ?? "")?", isPresented: Binding(get: { toDelete != nil }, set: { if !$0 { toDelete = nil } })) {
                Button("Smazat", role: .destructive) {
                    if let p = toDelete { store.deleteProfile(p.id) }
                    toDelete = nil
                }
                Button("Zrušit", role: .cancel) { toDelete = nil }
            } message: {
                Text("Smaže se i všechen jeho postup.")
            }
        }
    }
}

struct ProfileEditorView: View {
    let isOnboarding: Bool
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var avatar = AppStore.avatars.randomElement()!
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isOnboarding {
                    VStack(spacing: 8) {
                        Text("π").font(.system(size: 72, weight: .black, design: .rounded)).foregroundStyle(.tint)
                        Text("Vítej v Mathematicu!").font(.largeTitle.bold())
                        Text("Procvičuj matematiku 6.–9. třídy, sbírej hvězdy a poraz bossy.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 30)
                } else {
                    Text("Nový hráč").font(.largeTitle.bold()).padding(.top, 20)
                }

                Text(avatar)
                    .font(.system(size: 80))
                    .frame(width: 130, height: 130)
                    .background(Color.accentColor.opacity(0.15), in: Circle())

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                    ForEach(AppStore.avatars, id: \.self) { a in
                        Button { avatar = a } label: {
                            Text(a).font(.title)
                                .frame(width: 40, height: 40)
                                .background(a == avatar ? Color.accentColor.opacity(0.25) : .clear, in: Circle())
                        }
                    }
                }

                TextField("Jak se jmenuješ?", text: $name)
                    .font(.title3)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit(save)

                Button("Začít hrát", action: save)
                    .buttonStyle(BigButtonStyle(colors: [.accentColor, .purple]))
                    .disabled(trimmed.isEmpty)
                    .opacity(trimmed.isEmpty ? 0.5 : 1)

                if !isOnboarding {
                    Button("Zrušit") { dismiss() }
                }
            }
            .padding(24)
        }
    }

    private var trimmed: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func save() {
        guard !trimmed.isEmpty else { return }
        store.addProfile(name: trimmed, avatar: avatar)
        if !isOnboarding { dismiss() }
    }
}
