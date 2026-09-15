<div align="center">

<!-- =========================== BANNER =========================== -->

<pre>
 ╔══════════════════════════════════════════════════════════════════╗
 ║                                                                  ║
 ║   ██████╗  █████╗ ██╗██╗  ██╗   ██╗   ██╗   ██████╗ ██╗    ██╗   ║
 ║   ██╔══██╗██╔══██╗██║██║  ╚██╗ ██╔╝   ██║   ██╔══██╗██║    ██║   ║
 ║   ██║  ██║███████║██║██║   ╚████╔╝    ██║   ██████╔╝██║ █╗ ██║   ║
 ║   ██║  ██║██╔══██║██║██║    ╚██╔╝     ██║   ██╔══██╗██║███╗██║   ║
 ║   ██████╔╝██║  ██║██║███████╗██║      ███████╗██║  ██║╚███╔███╔╝  ║
 ║   ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚═╝      ╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝   ║
 ║                                                                  ║
 ║              Daily · Flow  —  Liquid Glass 3D Routine            ║
 ║                                                                  ║
 ╚══════════════════════════════════════════════════════════════════╝
</pre>

<!-- =========================== BADGES ============================ -->

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20Web-FF6F61)
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Repo](https://img.shields.io/badge/GitHub-Rick--Henrique7-181717?logo=github)
![Style](https://img.shields.io/badge/UI-Liquid%20Glass%203D-8B5CF6?style=flat-square)
![State](https://img.shields.io/badge/State-Riverpod-2EA0A6?logo=flutter&logoColor=white)
![Routing](https://img.shields.io/badge/Routing-go__router-FF6F61)
![Storage](https://img.shields.io/badge/Storage-Offline%20First-34D399)

<!-- =============================================================== -->

**Aplicativo pessoal de gestão de rotina** com hábitos, tarefas,
timer Pomodoro e estatísticas — tudo em um visual *Liquid Glass 3D*
fluido, com blobs animados em loop, glassmorphism nativo e feedback
haptic.

[Características](#-características) •
[Telas](#-screenshots) •
[Arquitetura](#-arquitetura) •
[Stack](#-stack) •
[Como rodar](#-como-rodar) •
[Build](#-build) •
[Estrutura](#-estrutura)

</div>

---

## ✨ Características

- 🪟 **Liquid Glass 3D** — cards, nav bar e botões com `liquid_glass_widgets`
- 🌈 **Background animado** — blobs de gradiente em loop infinito
- 📅 **Calendário Syncfusion** — premium com seleção visual custom
- 🧠 **Hábitos** — frequência semanal, lembrete por hora, streaks
- ✅ **Tarefas** — prioridade, data, hora, repetição semanal, sub-tarefas
- ⏱️ **Pomodoro** — Foco / Pausa Curta / Pausa Longa, vincular a tarefa
- 📊 **Estatísticas** — gráficos customizados (sem dependência de fl_chart)
- ⚙️ **Configurações** — wallpaper, cores do Pomodoro, blob intensity
- 💾 **Offline-first** — tudo em `SharedPreferences` (JSON)
- 📳 **Haptic feedback** ao concluir tarefa / hábito
- 🇧🇷 **pt-BR** nativo (via `flutter_localizations` + `intl`)

---

## 📸 Screenshots

> **Cole aqui seus screenshots** (ideal: 1280×720 ou maior, sem status bar).
> Salve em `docs/screenshots/` e o link relativo abaixo funciona direto no GitHub.

<!-- ===============================================================
     📌 CAMPO PARA VOCÊ COLOCAR OS SCREENSHOTS
     Substitua cada placeholder abaixo pelo seu arquivo.
     Sugestão de nomes:
       docs/screenshots/01-dashboard.png
       docs/screenshots/02-habitos.png
       docs/screenshots/03-tarefas.png
       docs/screenshots/04-pomodoro.png
       docs/screenshots/05-stats.png
       docs/screenshots/06-settings.png
================================================================ -->

| Tela | Preview |
|------|---------|
| **Dashboard — Hoje no Radar** | ![Dashboard](docs/screenshots/01-dashboard.png) |
| **Hábitos — Calendário + Lista** | ![Hábitos](docs/screenshots/02-habitos.png) |
| **Tarefas — Filtros + Diálogo** | ![Tarefas](docs/screenshots/03-tarefas.png) |
| **Pomodoro — Timer + Seletor** | ![Pomodoro](docs/screenshots/04-pomodoro.png) |
| **Estatísticas** | ![Stats](docs/screenshots/05-stats.png) |
| **Configurações** | ![Settings](docs/screenshots/06-settings.png) |

<!--
================================================================
📌 OU, SE PREFERIR UM CARROSSEL MAIS COMPACTO:

![Dashboard](docs/screenshots/01-dashboard.png)
![Hábitos](docs/screenshots/02-habitos.png)
![Tarefas](docs/screenshots/03-tarefas.png)
![Pomodoro](docs/screenshots/04-pomodoro.png)
================================================================
-->

---

## 🏛️ Arquitetura

O app adota **Clean Architecture + Feature-First**: cada feature tem
suas camadas isoladas (`presentation` / `data` / `domain`), e a `core/`
compartilha widgets e utilitários. Estado é gerenciado por **Riverpod**
(`NotifierProvider`) e a persistência fica em **`SharedPreferences`**
com JSON — totalmente offline.

```text
                              ┌───────────────────────────────────────┐
                              │       Flutter App (gestao_pessoal)    │
                              └───────────────────────────────────────┘
                                                   │
                ┌──────────────────────────────────┼──────────────────────────────────┐
                │                                  │                                  │
        ┌───────▼────────┐                ┌────────▼─────────┐               ┌───────▼────────┐
        │  presentation/ │                │   presentation/  │               │  presentation/ │
        │   Dashboard    │                │      Habits      │               │     Tasks      │
        └───────┬────────┘                └────────┬─────────┘               └───────┬────────┘
                │                                  │                                  │
                │       ┌──────────────────┐       │       ┌──────────────────┐       │
                │       │   presentation/  │       │       │   presentation/  │       │
                │       │    Pomodoro      │       │       │      Stats       │       │
                │       └────────┬─────────┘       │       └────────┬─────────┘       │
                │                │                 │                │                 │
                │                │ presentation/   │                │ presentation/   │
                │                │   Settings      │                │   Settings      │
                │                └────────┬────────┘                └────────┬────────┘
                │                         │                                 │
                └────────────┬────────────┼─────────────────────────────────┘
                             │            │
                  ┌──────────▼────────────▼─────────────┐
                  │        core/  (compartilhado)       │
                  │   ┌─────────────────────────────┐   │
                  │   │  LiquidGlassCard · Glass    │   │
                  │   │  NavBar · GlassInputField  │   │
                  │   │  AnimatedBackground        │   │
                  │   └─────────────────────────────┘   │
                  │   constants · services · utils      │
                  └──────────────┬──────────────────────┘
                                 │
                  ┌──────────────▼──────────────────────┐
                  │    Riverpod State (Notifiers)       │
                  │   TasksNotifier · HabitsNotifier    │
                  │   PomodoroTimerNotifier · Settings  │
                  └──────────────┬──────────────────────┘
                                 │
                  ┌──────────────▼──────────────────────┐
                  │   Persistence (Offline-First)       │
                  │  SharedPreferences  ←→  JSON Codec  │
                  └─────────────────────────────────────┘
```

### Stack por camada

| Camada | Responsabilidade | Tecnologias |
|--------|------------------|-------------|
| **UI (presentation)** | Telas, widgets, animações, navegação | Flutter · go_router · flutter_animate · liquid_glass_widgets |
| **State** | Estado global, regra de UI, persistência reativa | Riverpod 2 (`NotifierProvider`, `StateProvider`, `Provider`) |
| **Domain** | Entidades imutáveis com `copyWith` + migração JSON | Dart puro (`TaskModel`, `HabitModel`, `SubtaskModel`, `PomodoroSessionModel`, `AppSettings`) |
| **Data** | Repositórios, codecs JSON, leitura/escrita em prefs | SharedPreferences · `JsonCoders` |
| **Native** | Notificações, vibração, wakelock | flutter_local_notifications · vibration · wakelock_plus |

---

## 🧪 Stack

| Categoria | Pacote | Uso |
|-----------|--------|-----|
| Framework | `flutter` 3.x / `dart` 3.11+ | UI |
| Estado | `flutter_riverpod` ^2.5 | Notifiers reativos |
| Roteamento | `go_router` ^14 | ShellRoute + AppShell |
| Persistência | `shared_preferences` ^2.2 | Offline-first |
| UI 3D | `liquid_glass_widgets` ^1.4 | Glassmorphism |
| Calendário | `syncfusion_flutter_calendar` ^28.1 | Calendário mensal |
| Animações | `flutter_animate` ^4.5 | Fade/scale/shimmer |
| Fontes | `google_fonts` ^6.2 | Tipografia |
| Cores | `flex_color_picker` ^3.6 / `flutter_colorpicker` | Paleta + picker |
| Nativo | `flutter_local_notifications` ^18 / `wakelock_plus` ^1.2 / `vibration` ^2 | Lembretes · tela acesa · vibração |
| Utils | `intl` ^0.20 / `uuid` ^4.5 | Datas · IDs |

---

## 🚀 Como rodar

### Pré-requisitos

- **Flutter SDK 3.x** (Dart `^3.11.5`) — [instalação](https://docs.flutter.dev/get-started/install)
- **Java 17+** (recomendado Zulu 21) — para build Android
- **Android SDK** (API 34+) — `ANDROID_HOME` apontando para a pasta

### Instalação

```bash
# 1. Clonar
git clone https://github.com/Rick-Henrique7/Daily-Flow.git
cd Daily-Flow

# 2. Dependências
cd gestao_pessoal
flutter pub get

# 3. Analisar
flutter analyze

# 4. Rodar (com emulador/dispositivo conectado)
flutter run
```

> 💡 **Dica**: o projeto já vem com `mvnw` / Maven Wrapper opcional. Se
> você usa Maven do sistema, garanta `mvn --version` antes do build APK.

---

## 📦 Build

```bash
# 🌐 Web (release, gera build/web/)
flutter build web --release --no-wasm-dry-run

# 🤖 Android APK (release, gera build/app/outputs/flutter-apk/app-release.apk)
flutter build apk --release

# 🍎 iOS (precisa de macOS + Xcode)
flutter build ios --release
```

Saídas:

```text
build/web/                                          ← Web
build/app/outputs/flutter-apk/app-release.apk       ← Android (~57 MB)
build/ios/iphoneos/Runner.app                       ← iOS
```

---

## 📂 Estrutura

```text
Daily-Flow/
├── README.md                ← este arquivo
├── docs/                    ← especificações em PT-BR
│   ├── PRD.md
│   ├── arquitect.md
│   ├── design.md
│   ├── dashboard.md
│   ├── habitos.md
│   ├── to-do.md
│   ├── pomodoro.md
│   └── estatistica.md
└── gestao_pessoal/          ← projeto Flutter
    ├── pubspec.yaml
    ├── android/             ← app Android
    ├── web/                 ← app Web (manifest, index.html)
    ├── assets/              ← ícones do app
    ├── scripts/             ← utilitários (PowerShell + Node)
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── routing/         ← GoRouter + AppShell
        ├── core/            ← widgets, constantes, utils, services, database
        └── features/        ← 1 pasta por feature
            ├── dashboard/   ← presentation · controllers · data
            ├── habits/      ← presentation · data · domain
            ├── tasks/       ← presentation · data · domain
            ├── pomodoro/    ← presentation · data · controllers
            ├── stats/       ← presentation · controllers
            └── settings/    ← presentation · data · domain
```

---

## 🧭 Roadmap

- [ ] Sincronização em nuvem (opcional, opt-in)
- [ ] Temas claro/escuro
- [ ] Widgets de home screen (Android)
- [ ] Relatórios exportáveis (CSV / PDF)
- [ ] Backup/restore via arquivo `.json`

---

## 🤝 Contribuindo

1. Fork este repositório
2. Crie uma branch para sua feature (`git checkout -b feat/minha-feature`)
3. Commit suas mudanças (`git commit -m 'feat: minha feature'`)
4. Push para a branch (`git push origin feat/minha-feature`)
5. Abra um Pull Request

---

## 📄 Licença

Distribuído sob a licença **Apache 2.0**. Veja [`LICENSE`](LICENSE) para mais detalhes.

---

<div align="center">

Feito com 💜 por **[@Rick-Henrique7](https://github.com/Rick-Henrique7)**

![Visitors](https://api.visitorbadge.io/api/visitors?path=Rick-Henrique7.Daily-Flow&label=views&color=8B5CF6&style=flat-square)

</div>