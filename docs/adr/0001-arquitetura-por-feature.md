# 0001 — Organização por feature com camadas

- **Status:** Aceito
- **Data:** 2026-09-14 (registrado em 2026-10-01)

## Contexto
O app tem funcionalidades independentes (hábitos, tarefas, foco,
estatísticas). Organizar por tipo técnico (`screens/`, `models/`,
`providers/`) espalha uma mesma funcionalidade por várias pastas e dificulta
encontrar e mudar código.

## Decisão
Cada funcionalidade é uma pasta em `lib/features/<nome>/` com três camadas:
`presentation/` (UI), `data/` (estado e persistência) e `domain/` (modelos,
regras e contratos). O que é compartilhado fica em `lib/core/`.
Dependência sempre para dentro: presentation → data → domain.

## Alternativas consideradas
- **Por tipo técnico** — simples no início, escala mal.
- **Clean Architecture completa (use cases, entities, DTOs separados)** —
  burocrática demais para um app local de uma pessoa; adotamos as partes que
  pagam o custo (contratos de repositório e regras puras no domínio).

## Consequências
- Uma mudança em "tarefas" quase sempre toca só `features/tasks/`.
- Regra a vigiar: `domain/` não importa `data/`, `presentation/` nem Riverpod.
