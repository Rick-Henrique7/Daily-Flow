# Architecture Spec — Daily Flow App

> Especificação de arquitetura. Adota **Clean Architecture** combinada com
> **Feature-First Architecture** em Flutter, mantendo código modularizado,
> testável e fácil de manter.

---

## 1. Visão Geral da Arquitetura

O app adota a **Clean Architecture** combinada com **Feature-First Architecture** em Flutter. O objetivo é manter código modularizado, testável e fácil de manter, separando claramente as responsabilidades de UI, regras de negócio e persistência de dados.

---

## 2. Estrutura de Pastas (Project Structure)

```text
lib/
├── main.dart                   # Ponto de entrada do aplicativo
├── app.dart                    # Configuração de temas, rotas e inicialização de providers
├── core/                       # Módulos compartilhados e utilitários
│   ├── constants/              # Cores, fontes, espaçamentos e temas (Dark Theme)
│   ├── database/               # Configuração e inicialização do Isar DB / Hive
│   ├── network/                # Serviços de rede local / utilitários de notificação
│   ├── services/               # Serviço de Notificação Local e Haptic Feedback
│   └── utils/                  # Formatadores de data, extensões e helpers
├── features/                   # Módulos divididos por funcionalidade
│   ├── dashboard/              # Tela principal e resumo diário
│   │   ├── presentation/       # Widgets e UI (Screens, Cards, Animações)
│   │   ├── controllers/        # Providers (Riverpod) para estado do Dashboard
│   │   └── data/               # Repositórios e agregações de dados
│   ├── habits/                 # Gestão e rastreamento de hábitos
│   │   ├── domain/             # Models (HabitModel) e entidades
│   │   ├── presentation/       # Calendário semanal, Heatmap e Cards de Hábitos
│   │   └── data/               # Isar Repositories e providers de hábitos
│   ├── tasks/                  # Gerenciador de Tarefas (To-Do)
│   │   ├── domain/             # Models (TaskModel, SubtaskModel)
│   │   ├── presentation/       # Listas, Drag & Drop, Bottom Sheets de edição
│   │   └── data/               # Repositórios de Tarefas
│   ├── pomodoro/               # Timer de Foco
│   │   ├── presentation/       # Relógio circular, controles de foco e som
│   │   └── controllers/        # TimerStateNotifier (gerenciamento do tempo ativo)
│   └── stats/                  # Relatórios e Estatísticas
│       └── presentation/       # Gráficos (fl_chart) e telas de métricas
```

---

## 3. Dependências Principais (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Gerenciamento de Estado
  flutter_riverpod: ^2.5.1

  # Roteamento
  go_router: ^14.0.0

  # Banco de Dados Local (Offline First)
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  path_provider: ^2.1.2

  # Interface, Animações e Gráficos
  flutter_animate: ^4.5.0
  fl_chart: ^0.68.0
  google_fonts: ^6.2.0
  flutter_colorpicker: ^1.1.0

  # Recursos Nativos e Utilitários
  flutter_local_notifications: ^17.0.0
  wakelock_plus: ^1.2.0
  vibration: ^2.0.0
  intl: ^0.19.0
```

---

## 4. Padrões de Código e Diretrizes para IA

### 4.1 State Management (Riverpod)

- Utilize obrigatoriamente `NotifierProvider` ou `AsyncNotifierProvider` para gerenciar estados mutáveis da UI.
- Não utilizar `setState` para estados globais ou que envolvam persistência no banco de dados.

### 4.2 Interface (UI/UX)

- **Dark Mode NATIVO:** Use a paleta padrão baseada em cores escuras profundas (ex: `#121212` ou `#0D1117`) com destaques em cores neon/pastel.
- **Animações:** Aplique `.animate().fade().scale()` usando `flutter_animate` nas entradas de cards e listas.
- **Haptic Feedback:** Chame `HapticFeedback.lightImpact()` ao concluir tarefas ou hábitos.

### 4.3 Modelos de Dados

- Mantenha os models imutáveis utilizando a anotação do Isar DB ou do Freezed.
- Todas as operações de leitura e escrita no banco de dados devem ser assíncronas (`async`/`await`).
