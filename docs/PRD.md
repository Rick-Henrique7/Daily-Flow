# Product Requirements Document (PRD) — Daily Flow App

> Documento de requisitos do produto. Define visão, objetivos, arquitetura,
> requisitos funcionais e não-funcionais e os modelos de dados do **Daily Flow**.

---

## 1. Visão Geral do Produto

O **Daily Flow** é um aplicativo mobile de uso pessoal desenvolvido em Flutter, projetado para consolidar a gestão da rotina diária em uma única plataforma elegante, fluida e de alto desempenho[cite: 1]. O foco central está no apelo visual (UI/UX Premium), suporte offline total e utilização de micro-interações animadas para promover o engajamento diário[cite: 1].

---

## 2. Objetivos Principais

- **Centralizar a Produtividade:** Unificar Dashboard diário, rastreador de hábitos, gerenciador de tarefas e timer Pomodoro[cite: 1].
- **Experiência Visual Incrível:** Garantir suporte a Dark Mode nativo, micro-interações fluidas e haptic feedback nas ações concluídas[cite: 1].
- **Privacidade e Funcionamento Offline:** Persistir todos os dados localmente usando banco de dados no-SQL ultrarrápido (Isar/Hive)[cite: 1].
- **Facilidade de Uso:** Oferecer fluxos rápidos de inclusão com suporte a gestos (Swipe) e ordenação por atrito mínimo[cite: 1].

---

## 3. Arquitetura e Tech Stack

| Camada / Componente | Tecnologia Escolhida | Descrição / Papel |
| :--- | :--- | :--- |
| **Framework Mobile** | Flutter (Dart 3+) | Multiplataforma com renderização nativa de 60fps+[cite: 1] |
| **Gerenciamento de Estado** | Riverpod (NotifierProvider) | Separação clara entre regras de negócio e camada visual[cite: 1] |
| **Banco de Dados Local** | Isar DB ou Hive | Armazenamento leve, síncrono/assíncrono e 100% offline[cite: 1] |
| **Roteamento** | GoRouter | Navegação declarativa com rotas nomeadas[cite: 1] |
| **Animações e UI** | `flutter_animate` + `fl_chart` | Animações declarativas e geração de gráficos estatísticos[cite: 1] |
| **Notificações Locais** | `flutter_local_notifications` | Lembretes agendados sem necessidade de servidor backend[cite: 1] |

---

## 4. Especificações das Telas e Requisitos Funcionais

### 4.1 Tela de Dashboard (Hoje)

Visão panorâmica imediata do dia do usuário, integrando hábitos, tarefas e indicadores visuais de progresso[cite: 1].

- **RF-DB-01:** Calcular dinamicamente a taxa de progresso diário combinando hábitos e tarefas do dia[cite: 1].
- **RF-DB-02:** Permitir a conclusão rápida de qualquer item diretamente pelo Dashboard sem mudança de contexto[cite: 1].
- **RF-DB-03:** Exibir um menu suspenso ou bottom-sheet de criação rápida ao acionar o botão flutuante (+)[cite: 1].
- **RF-DB-04:** Atualizar o header com saudações dinâmicas baseadas no relógio local[cite: 1].

### 4.2 Tela de Gestão de Hábitos

Acompanhamento de rotinas diárias/semanais com suporte a sequências de consistência (Streaks) e personalização[cite: 1].

- **RF-HB-01:** Exibir hábitos filtrados pelo dia selecionado na fita semanal do calendário[cite: 1].
- **RF-HB-02:** Registrar a conclusão parcial ou total de hábitos com feedback tátil (haptic)[cite: 1].
- **RF-HB-03:** Calcular dinamicamente a contagem de dias seguidos (Streak) de cada hábito[cite: 1].
- **RF-HB-04:** Permitir criação, edição e remoção de hábitos configurando nome, ícone, cor e horário de lembrete[cite: 1].

### 4.3 Tela de Gerenciador de Tarefas (To-Do)

Organização flexível de afazeres diários e projetos por prioridade, datas e sub-tarefas[cite: 1].

- **RF-TD-01:** Suportar operações de CRUD completo para tarefas e checklists de sub-tarefas[cite: 1].
- **RF-TD-02:** Permitir reordenamento manual de tarefas através de gestos Drag & Drop[cite: 1].
- **RF-TD-03:** Disponibilizar filtros por aba (Todas, Hoje, Próximas, Concluídas) e por categoria[cite: 1].
- **RF-TD-04:** Permitir ações de conclusão e remoção via gestos de deslizamento (Swipe)[cite: 1].

### 4.4 Tela de Timer de Foco (Pomodoro)

Ambiente focado e minimalista para execução contínua de tarefas por meio de ciclos configuráveis[cite: 1].

- **RF-PO-01:** Cronômetro regressivo com modos configuráveis de Foco, Pausa Curta e Pausa Longa[cite: 1].
- **RF-PO-02:** Alternar o estado da sessão automaticamente ao término do tempo estipulado[cite: 1].
- **RF-PO-03:** Vincular uma sessão ativa a uma tarefa pré-existente no banco de dados[cite: 1].
- **RF-PO-04:** Disparar alarmes visuais e sonoros com suporte a execução em segundo plano[cite: 1].
- **RF-PO-05:** Manter a tela do dispositivo ativa durante a execução via `wakelock_plus`[cite: 1].

### 4.5 Tela de Estatísticas & Progresso

Relatórios visuais e gráficos com histórico de desempenho e engajamento pessoal[cite: 1].

- **RF-ST-01:** Exibir métricas agregadas por filtros de período (Semanal, Mensal, Anual)[cite: 1].
- **RF-ST-02:** Renderizar gráfico de barras de produtividade diária usando `fl_chart`[cite: 1].
- **RF-ST-03:** Apresentar grade de consistência (Heatmap) baseada no histórico dos hábitos salvos[cite: 1].
- **RF-ST-04:** Agrupar o tempo e volume de tarefas concluídas por categoria em gráfico de rosca[cite: 1].

---

## 5. Requisitos Não-Funcionais (RNF)

- **RNF-01 (Desempenho):** A interface deve manter taxa de quadros consistente a 60fps, sem engasgos durante animações e rolagens[cite: 1].
- **RNF-02 (Arquitetura):** Todos os dados do app devem ser salvos offline com persistência instantânea em banco NoSQL local[cite: 1].
- **RNF-03 (UI/UX):** O design system deve utilizar paleta Dark Mode por padrão, fontes modernas e suporte a micro-interações responsivas[cite: 1].
- **RNF-04 (Notificações):** Os lembretes devem funcionar confiavelmente sem necessidade de conexão com a internet[cite: 1].

---

## 6. Modelos de Dados (Entities / Data Models)

```dart
// HabitModel
class HabitModel {
  final String id;
  final String title;
  final String category;
  final String icon;
  final String colorHex;
  final List<int> frequencyDays; // 1 (Segunda) a 7 (Domingo)
  final int targetValue;
  final String unit;
  final List<DateTime> completedDates;
  final int streakCount;
}

// TaskModel
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority; // low, medium, high
  final String category;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<SubtaskModel> subtasks;
  final int orderIndex;
}

// PomodoroSessionModel
class PomodoroSessionModel {
  final String id;
  final String? taskId;
  final DateTime startTime;
  final int durationMinutes;
  final bool isCompleted;
  final PomodoroType type; // focus, shortBreak, longBreak
}
```
