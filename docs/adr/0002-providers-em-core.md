# 0002 — Providers de infraestrutura em `core/` e features agregadoras

- **Status:** Aceito
- **Data:** 2026-10-01

## Contexto
`prefsStoreProvider`, `hapticsServiceProvider` e `soundServiceProvider`
estavam declarados dentro de `habits_controller.dart` (o de som, duplicado em
`tasks_controller.dart`). Resultado: tarefas, foco e configurações importavam
a feature de hábitos só para acessar o armazenamento, e havia um ciclo
`settings → habits → settings`.

## Decisão
1. Providers de infraestrutura moram em `lib/core/providers/core_providers.dart`.
2. O `core` não conhece configurações. Ele declara a "porta"
   `FeedbackPreferences`, e o `main.dart` a liga às configurações do usuário
   com um override — inversão de dependência.
3. Features de domínio não importam umas às outras. **Hoje** (`dashboard`) e
   **Estatísticas** (`stats`) são *agregadoras* e podem ler os controllers
   das outras features, porque juntar dados é o propósito delas.
   Exceção pontual: o Foco lê a lista de tarefas para vincular uma sessão.

## Alternativas consideradas
- **Manter em `habits`** — mantém o acoplamento e o ciclo.
- **Proibir qualquer leitura entre features** — exigiria duplicar dados ou
  criar uma camada de "aplicação" só para Hoje e Estatísticas.

## Consequências
- Nenhuma dependência circular entre features.
- Testes sobrescrevem `hapticsServiceProvider`/`soundServiceProvider` sem
  tocar em configurações.
- Novas features agregadoras precisam ser declaradas aqui.
