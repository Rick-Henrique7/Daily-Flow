# `lib/features/` — Arquitetura por Feature

Cada pasta aqui dentro representa uma **feature vertical** do Daily Flow
(tarefas, hábitos, pomodoro, etc). Uma feature é **auto-contida**: tudo
que ela precisa para funcionar vive dentro dela, e ela não depende
horizontalmente de outras features — apenas de `lib/core/`.

## Estrutura padrão

```
features/<nome>/
├── data/          # Camada de dados — Notifiers Riverpod, acesso a SharedPreferences
│   └── *_controller.dart
├── domain/        # Modelos de domínio — imutáveis, com copyWith + fromJson
│   └── *_model.dart
└── presentation/  # Telas + widgets + diálogo de criação/edição
    └── *_screen.dart
```

Algumas features têm variações legítimas:

- `pomodoro/` e `stats/` usam `controllers/` em vez de `data/` para a
  camada de estado. Mantido por consistência histórica.
- `pomodoro/` não tem `domain/` porque os tipos (`PomodoroType`,
  `PomodoroTimerState`, `PomodoroSessionModel`) ficaram dentro de
  `data/` e `controllers/` por proximidade de uso.

E algumas têm **diretórios vazios reservados** para expansão futura
(ainda não populados, mas já estruturados na arquitetura correta):

- `dashboard/controllers/` — reservado para extrair a lógica de
  progresso diário quando crescer.
- `dashboard/data/` — reservado para cache/preferências do dashboard.
- `stats/controllers/` — reservado para extrair agregações de gráficos
  (atualmente inline em `presentation/stats_screen.dart`).

A presença deles não é bug — é um sinal de **onde a feature vai
crescer**. Removê-los só porque estão vazios agora seria voltar
atrás quando precisarmos.

## Regras de dependência

```
presentation/  ──►  data/  ──►  domain/
        │
        └────────►  core/  (constants, widgets, services, utils)
```

- `presentation/` **nunca** importa de outra feature.
- `data/` **nunca** importa de `presentation/`.
- `domain/` **nunca** importa de `data/` nem `presentation/` —
  é a camada mais interna e estável.
- Todas as features podem importar de `core/` (é compartilhado por
  definição).

## Adicionando uma nova feature

1. Crie `features/<nome>/` com as 3 subpastas.
2. Defina o modelo em `domain/<nome>_model.dart` (imutável, com
   `copyWith`, `toJson`, `fromJson`).
3. Implemente o controller em `data/<nome>_controller.dart` usando
   Riverpod (`Notifier<T>` ou `AsyncNotifier<T>`).
4. Implemente a UI em `presentation/<nome>_screen.dart`.
5. Registre a rota em `routing/app_router.dart`.
