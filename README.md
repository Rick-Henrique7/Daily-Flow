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
 ║              Daily · Flow  —  Dark fintech routine               ║
 ║                                                                  ║
 ╚══════════════════════════════════════════════════════════════════╝
</pre>

<!-- =========================== BADGES ============================ -->

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20Web-FF6F61)
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Repo](https://img.shields.io/badge/GitHub-Rick--Henrique7-181717?logo=github)
![Design](https://img.shields.io/badge/Design-Dark%2FGreen%20System-00E676?style=flat-square)
![Font](https://img.shields.io/badge/Font-DM%20Sans-8B5CF6)
![State](https://img.shields.io/badge/State-Riverpod-2EA0A6?logo=flutter&logoColor=white)
![Routing](https://img.shields.io/badge/Routing-go__router-FF6F61)
![Storage](https://img.shields.io/badge/Storage-Offline%20First-34D399)

<!-- =============================================================== -->

**Aplicativo pessoal de gestão de rotina** com hábitos, tarefas,
timer Pomodoro e estatísticas — visual **Dark/Green** flat (DM Sans),
single accent neon green, sem glassmorphism, sem sombras, offline-first.

[Características](#-características) •
[Telas](#-screenshots) •
[Arquitetura](#-arquitetura) •
[Stack](#-stack) •
[Design System](#-design-system) •
[Como rodar](#-como-rodar) •
[Build](#-build) •
[Estrutura](#-estrutura)

</div>

---

## ✨ Características

### Hábitos
- 🟢 **Calendário Syncfusion** com dias incompletos destacados em muted
- 🟢 **Frequência semanal** customizável (S T Q Q S S D)
- 🟢 **Estimativa de duração** por hábito (ex: "30 min" pra meditar)
- 🟢 **Lembrete por horário** opcional
- 🟢 **Streak** automático baseado em datas consecutivas
- 🟢 **Marcar/desmarcar** por dia no calendário
- 🟢 **Swipe-to-delete** com confirmação + "Desfazer"

### Tarefas
- ✅ **Prioridade** baixa/média/alta (escala verde→cinza)
- ✅ **Data + hora + repetição semanal** por tarefa
- ✅ **Sub-tarefas** com check individual
- ✅ **Filtros**: Todas / Hoje / Próximas / Concluídas
  - **Hoje** inclui tarefas pontuais com `dueDate == hoje` **e** recorrentes
  - **Próximas** inclui futuras + atrasadas + recorrentes (ordenado por data)
- ✅ **Empty states contextuais** (ícone + dica por filtro)
- ✅ **Editar tarefa** (tap no card)
- ✅ **Swipe-to-delete** com aviso explícito de recorrência + "Desfazer"

### Timer Pomodoro
- ⏱️ **3 modos**: Foco (25min) / Pausa Curta (5min) / Pausa Longa (15min)
- ⏱️ **Seletor de modo** com chips visuais
- ⏱️ **Vincular a uma tarefa** específica
- ⏱️ **Cores customizáveis** por modo (default = paleta verde)
- ⏱️ **Auto-progressão**: a cada 4 focados → Pausa Longa

### Configurações
- ⚙️ **Papel de parede**: gradiente animado OU cor sólida (mais leve p/ bateria)
- ⚙️ **Cor-base dos blobs** + intensidade (modo animado)
- ⚙️ **Vibração ao tocar** (toggle on/off)
- ⚙️ **Som de conclusão** (toggle on/off) — toca "ding" ao concluir
- ⚙️ **Modo Escuro** fixo
- ⚙️ **Restore defaults** one-click

### Cross-cutting
- 📳 **Vibração** em conclusão de tarefa/hábito (configurável)
- 🔔 **Som de sucesso** gerado por IA (assets/sounds/success.mp3)
- 🎨 **Single accent**: neon green (#00E676) usado com parcimônia
- 🌑 **Dark mode** nativo (per design system)
- 🇧🇷 **pt-BR** nativo (via `flutter_localizations` + `intl`)
- 💾 **Offline-first**: tudo em `SharedPreferences` (JSON)
- 📱 **Persistência**: tasks/habits/sessions/settings sobrevivem restart

---

## 📸 Screenshots

> **Cole aqui seus screenshots** (ideal: 1280×720 ou maior).
> Salve em `docs/screenshots/` e o link relativo funciona direto no GitHub.

| Tela | Preview |
|------|---------|
| **Dashboard — Hoje no Radar** | ![Dashboard](docs/screenshots/01-dashboard.png) |
| **Hábitos — Calendário + Lista** | ![Hábitos](docs/screenshots/02-habitos.png) |
| **Tarefas — Filtros + Diálogo** | ![Tarefas](docs/screenshots/03-tarefas.png) |
| **Pomodoro — Timer + Seletor** | ![Pomodoro](docs/screenshots/04-pomodoro.png) |
| **Estatísticas** | ![Stats](docs/screenshots/05-stats.png) |
| **Configurações** | ![Settings](docs/screenshots/06-settings.png) |

---

## 🏛️ Arquitetura

O app adota **Clean Architecture + Feature-First**. Cada feature tem
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
                  │   │  AppCard · AppNavBar · App   │   │
                  │   │  InputField · SolidBackground│   │
                  │   │  AnimatedBackground (opt)   │   │
                  │   └─────────────────────────────┘   │
                  │   constants · services · utils      │
                  │   (DM Sans · 00E676 accent)          │
                  └──────────────┬──────────────────────┘
                                 │
                  ┌──────────────▼──────────────────────┐
                  │    Riverpod State (Notifiers)       │
                  │   Tasks · Habits · Pomodoro ·        │
                  │   Settings · Haptics · Sound         │
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
| **UI (presentation)** | Telas, widgets, animações, navegação | Flutter · go_router · flutter_animate |
| **State** | Estado global, regra de UI, persistência reativa | Riverpod 2 (`NotifierProvider`, `StateProvider`, `Provider`) |
| **Domain** | Entidades imutáveis com `copyWith` + migração JSON | Dart puro (`TaskModel`, `HabitModel`, `SubtaskModel`, `PomodoroSessionModel`, `AppSettings`) |
| **Data** | Repositórios, codecs JSON, leitura/escrita em prefs | SharedPreferences · `JsonCoders` |
| **Native** | Notificações, vibração, wakelock, áudio | flutter_local_notifications · vibration · wakelock_plus · audioplayers |

---

## 🧪 Stack

| Categoria | Pacote | Uso |
|-----------|--------|-----|
| Framework | `flutter` 3.x / `dart` 3.11+ | UI |
| Estado | `flutter_riverpod` ^2.5 | Notifiers reativos |
| Roteamento | `go_router` ^14 | ShellRoute + AppShell |
| Persistência | `shared_preferences` ^2.2 | Offline-first JSON |
| Animações | `flutter_animate` ^4.5 | Fade/scale/shimmer |
| Fontes | `google_fonts` ^6.2 | **DM Sans** (geometric sans-serif) |
| Cores | `flex_color_picker` ^3.6 | Paleta + picker |
| Calendário | `syncfusion_flutter_calendar` ^28.1 | Calendário mensal |
| Áudio | `audioplayers` ^6.1 | Som de conclusão (`success.mp3`) |
| Nativo | `flutter_local_notifications` ^18 / `wakelock_plus` ^1.2 / `vibration` ^2 | Lembretes · tela acesa · vibração |
| Utils | `intl` ^0.20 / `uuid` ^4.5 | Datas · IDs |

---

## 🎨 Design System

Base: **"Financial App — Dark/Green"** (single accent, sem sombras).

### Tokens de cor

| Token | Valor | Uso |
|-------|-------|-----|
| `--color-background` | `#0D0D0D` | Fundo da tela |
| `--color-surface` | `#141414` | Cards, nav bar, modais |
| `--color-surface-2` | `#1C1C1C` | Inputs, nested elements |
| `--color-foreground` | `#FFFFFF` | Texto primário |
| `--color-muted-foreground` | `#7A7A7A` | Texto secundário |
| `--color-border` | `#1E1E1E` | Borda 1px low-contrast |
| `--color-primary` | `#00E676` | **Único accent** (neon green) |
| `--color-primary-muted` | `#1A3D2B` | Primary com opacity |
| `--color-accent-dim` | `#00B85A` | Primary escurecido |
| `--color-chart-bar-1/2` | `#0D2B1A` / `#1A4D2E` | Barras de gráfico |

### Tipografia (DM Sans)

| Token | px | Weight | Uso |
|-------|----|--------|-----|
| text-xs | 11 | 400 | Caption/meta |
| text-sm | 13 | 400-600 | Label |
| text-base | 15 | 400 | Body |
| text-lg | 18 | 600 | H3 |
| text-xl | 22 | 600 | H2 |
| text-3xl | 36 | 700 | H1 |
| text-4xl | 48 | 700 | Display |

**Regra**: minimum weight 400, sem thin (100–300).

### Radius

| Token | px | Uso |
|-------|----|-----|
| `radius-sm` | 8 | Botões, tags, ícones |
| `radius-md` | 16 | Cards (default) |
| `radius-lg` | 24 | Modais, nav bar |
| `radius-xl` | 32 | Screen-edge |

### Regras estéticas

**✓ Do**
- Surface `#0D–#1C` (quase-preto, nunca puro)
- Neon green **apenas** como accent único
- Bold para valores importantes, medium p/ resto
- Borders low-contrast (estrutura via profundidade, não linhas)
- Round generous (mínimo 8px)
- DM Sans (geometric sans-serif)

**✗ Don't**
- Backgrounds claros / light mode
- Múltiplos accent colors
- Drop shadows
- Uppercase labels (sentence case only)
- Font weights < 400
- Gradientes entre hues (apenas opacity fades)
- **Red/orange p/ estados negativos** (usar muted gray)

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

> 💡 **Dica**: o projeto usa Maven Wrapper opcional. Se você usa Maven do sistema, garanta `mvn --version` antes do build APK.

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
build/app/outputs/flutter-apk/app-release.apk       ← Android (~58 MB)
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
    ├── assets/
    │   ├── icons/daily_flow_icon.png   ← ícone edge-to-edge com coroa
    │   └── sounds/success.mp3          ← som de conclusão
    ├── scripts/             ← utilitários (PowerShell + Node)
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── routing/         ← GoRouter + AppShell
        ├── core/            ← widgets, constantes, utils, services, database
        │   ├── constants/app_colors.dart  ← tokens do design system
        │   ├── constants/app_theme.dart    ← DM Sans + tema dark
        │   ├── widgets/liquid_glass_card.dart   ← agora flat dark (compat)
        │   ├── widgets/glass_nav_bar.dart       ← agora flat dark (compat)
        │   ├── widgets/glass_input_field.dart   ← agora flat dark (compat)
        │   └── widgets/animated_background.dart ← solid + animated (opt)
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
- [ ] Widgets de home screen (Android)
- [ ] Relatórios exportáveis (CSV / PDF)
- [ ] Backup/restore via arquivo `.json`
- [ ] Subtarefas drag-and-drop

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

![Visitors](https://api.visitorbadge.io/api/visitors?path=Rick-Henrique7.Daily-Flow&label=views&color=00E676&style=flat-square)

</div>