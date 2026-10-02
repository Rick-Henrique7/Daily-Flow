# Requisitos — Daily Flow

> O que o app precisa fazer, o que já faz e como verificar. A
> [visão de produto](../PRD.md) diz **por quê**; este conjunto diz **o quê**,
> com critérios de aceite, e liga cada item ao código e aos testes.

| Documento | Conteúdo |
| --- | --- |
| [Requisitos funcionais](funcionais.md) | 38 requisitos em 6 áreas, com critérios Dado / Quando / Então |
| [Requisitos não funcionais](nao-funcionais.md) | Privacidade, offline, desempenho, acessibilidade, manutenção |
| [Casos de uso](casos-de-uso.md) | 7 fluxos do dia a dia, com caminhos alternativos |
| [Rastreabilidade](rastreabilidade.md) | Requisito → código → teste → caso de uso, e lacunas de teste |

## 1. Escopo

**Dentro:** app Android de uso pessoal para hábitos, tarefas, timer de foco e
estatísticas, 100% no aparelho.

**Fora (por decisão):** conta de usuário, sincronização em nuvem, uso
compartilhado, anúncios, coleta de dados.

**Ator único:** a pessoa dona do aparelho.

## 2. Convenções

**IDs:** `RF-<área>-<nº>` para funcionais e `RNF-<nº>` para não funcionais.
Áreas: `DB` Hoje · `HB` Hábitos · `TD` Tarefas · `PO` Foco · `ST`
Estatísticas · `CF` Configurações. Um ID nunca é reaproveitado: requisito
abandonado fica como **Won't**.

**Prioridade (MoSCoW):**
- **Must:** sem isso o app não cumpre o propósito.
- **Should:** importante; entra assim que possível.
- **Could:** desejável.
- **Won't (v0.x):** fora desta fase, registrado para não se perder.

**Status:**
- ✅ **Implementado:** todos os critérios de aceite passam.
- 🟡 **Parcial:** parte dos critérios passa; os que faltam estão marcados com ⬜
  no próprio requisito.
- ⬜ **Backlog:** ainda não implementado.

Situação atual (v0.1, etapa 4):

| | ✅ | 🟡 | ⬜ | Total |
| --- | --- | --- | --- | --- |
| Funcionais | 25 | 6 | 7 | 38 |
| Não funcionais | 6 | 4 | 0 | 10 |

## 3. Backlog

Ordem de ataque para a v0.2, da mais urgente para a menos urgente. Os dois
primeiros itens **bloqueiam a publicação**.

| # | Item | Requisitos | Por quê |
| --- | --- | --- | --- |
| 1 | Definir o `applicationId` final | RNF-10 | Não pode mudar depois da 1ª publicação |
| 2 | Embutir a fonte DM Sans | RNF-01, RNF-02 | O Liquid Glass perde a fonte sem internet, e talvez no build de release |
| 3 | Backup: exportar e importar os dados | RF-CF-07 | Sem nuvem, trocar de celular hoje perde tudo |
| 4 | Notificações locais: lembrete de hábito, horário de tarefa, fim do foco em segundo plano | RF-HB-05, RF-TD-05, RF-PO-04 | Uma dependência resolve os três |
| 5 | **+** da tela Hoje abre o formulário direto | RF-DB-03 | Um toque a menos no fluxo mais comum |
| 6 | Subtarefas e descrição no formulário de tarefa | RF-TD-01 | Modelo e controller prontos; falta a tela |
| 7 | Indicadores das Estatísticas pelo período | RF-ST-01 | O filtro hoje só muda o gráfico |
| 8 | Sequência por hábito no cartão | RF-HB-03 | Regra pronta e testada; falta exibir |
| 9 | Tempo de foco por tarefa | RF-PO-03 | Sessões já guardam a tarefa |
| — | Durações do foco configuráveis · rosca por categoria · busca e filtros | RF-PO-08, RF-ST-04, RF-TD-08 | Could |
| — | Reordenar tarefas arrastando | RF-TD-02 | Won't nesta fase |

## 4. Como um requisito muda

1. Pedido novo ou mudança → item no backlog com ID, prioridade e critérios de
   aceite ([pronto para começar](../processo/ciclo-de-vida.md#3-critérios-de-pronto)).
2. Implementado → teste cobrindo os critérios, linha na
   [rastreabilidade](rastreabilidade.md) e status atualizado aqui.
3. Mudou a arquitetura → ADR em [`adr/`](../adr/README.md).
