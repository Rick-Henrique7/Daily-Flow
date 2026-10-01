# 0004 — Regras de negócio como funções puras e `todayProvider`

- **Status:** Aceito
- **Data:** 2026-10-01

## Contexto
Regras importantes estavam dentro das telas: a tela Hoje decidia sozinha o
que era "tarefa de hoje" (diferente do controller), as estatísticas eram
calculadas no `build`, e o calendário refazia um loop de 90 dias a cada
reconstrução. Isso gerou bugs (Hoje e aba Hoje divergindo; gráfico anual
errado) e custo de desempenho. Além disso, `DateTime.now()` com segundos era
usado como chave de provider, criando instâncias novas a cada rebuild.

## Decisão
- Regras viram **funções puras** em `domain/`: `TaskSchedule`,
  `HabitStreak`, `HabitCalendar`, `StatsCalculator`. Recebem dados e a data,
  devolvem resultado. Sem Flutter de UI, sem Riverpod, sem I/O.
- A tela lê resultados prontos de providers memoizados
  (`filteredTasksProvider`, `todayTasksProvider`, `bestStreakProvider`,
  `incompleteDaysProvider`, `statsSummaryProvider`).
- "Hoje" vem de um único `todayProvider` (data sem hora), que se
  invalida sozinho à meia-noite.
- Valores derivados não são gravados: a sequência (streak) é calculada a
  partir das datas concluídas.

## Alternativas consideradas
- **Métodos nos controllers** — continuariam presos ao Riverpod e mais
  difíceis de testar isoladamente.
- **Use cases como classes** — mais cerimônia que valor neste tamanho.

## Consequências
- Uma fonte única para cada regra; os testes cobrem as regras sem montar UI.
- Cálculos só refazem quando os dados ou o dia mudam.
- Modelos de domínio ainda usam tipos do Flutter (`Color`, `IconData`,
  `TimeOfDay`) por praticidade; aceitável enquanto o domínio não for
  compartilhado fora do app.
