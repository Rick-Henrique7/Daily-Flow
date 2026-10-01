# 0003 — Repositórios com interface no domínio

- **Status:** Aceito
- **Data:** 2026-10-01

## Contexto
Os controllers faziam quatro coisas: guardavam o estado, serializavam JSON,
gravavam no `SharedPreferences` e disparavam som/vibração. Dependiam da
implementação concreta de armazenamento (violando o "S" e o "D" do SOLID) e
não podiam ser testados sem ela.

## Decisão
Cada feature declara um contrato em `domain/`
(`HabitsRepository`, `TasksRepository`, `SettingsRepository`,
`PomodoroSessionsRepository`) e implementa sobre `SharedPreferences` em
`data/` (`Prefs*Repository`). O controller recebe o repositório por um
provider tipado com a **interface**.

A leitura é **síncrona** (`loadAll()`): o `PrefsStore` é aberto antes do
`runApp`, então os dados já estão em memória e as telas não precisam lidar
com estado de carregamento.

## Alternativas consideradas
- **Isar/Hive** (previsto no PRD original) — mais rápido para volumes
  grandes, mas adiciona geração de código e não se justifica com dezenas de
  registros. A interface permite migrar depois sem mexer em controllers.
- **Repositório assíncrono (`Future<List<T>>`)** — mais genérico, mas
  obrigaria `AsyncNotifier` e telas de carregamento sem necessidade hoje.

## Consequências
- Testes usam repositórios em memória
  (`test/features/tasks/tasks_controller_test.dart`).
- Trocar de armazenamento = nova implementação + um override.
- Se um dia houver sincronização com nuvem, o contrato precisará virar
  assíncrono (novo ADR).
