# Requisitos não funcionais

> Como o app deve se comportar: privacidade, confiabilidade, desempenho,
> acessibilidade e manutenção. Cada requisito tem uma **forma de verificar** —
> sem ela, vira só intenção.

| ID | Requisito | Como verificar | Status |
| --- | --- | --- | --- |
| RNF-01 | **Offline:** todas as funções funcionam sem internet | Modo avião, usar todas as telas nos dois estilos | 🟡 |
| RNF-02 | **Privacidade:** nenhum dado do usuário sai do aparelho; sem conta, sem analytics | Revisão de dependências e permissões; nenhum envio de rede com dados | ✅ |
| RNF-03 | **Persistência imediata:** toda alteração é gravada na hora e sobrevive ao fechamento forçado | Criar item, fechar pelo multitarefa, reabrir | ✅ |
| RNF-04 | **Dados resilientes:** registro corrompido não derruba o app; formatos antigos são migrados | Testes `json_coders_test`, `task_model_test` | ✅ |
| RNF-05 | **Precisão do timer:** erro de no máximo 1 s, inclusive depois de segundo plano | Testes `pomodoro_controller_test` + teste no aparelho | ✅ |
| RNF-06 | **Fluidez:** rolagem e animações sem travadas perceptíveis (meta: 60 fps em aparelho intermediário, modo *profile*) | Flutter DevTools → Performance | 🟡 |
| RNF-07 | **Acessibilidade:** textos legíveis com fonte do sistema aumentada (até 130%), contraste AA e botões de ícone com descrição | Fonte grande no aparelho; TalkBack; testes de widget com fonte larga | 🟡 |
| RNF-08 | **Idioma:** interface, datas e números em português do Brasil | Revisão das telas | ✅ |
| RNF-09 | **Manutenibilidade:** CI verde a cada mudança; regras de arquitetura verificadas; regra nova com teste | GitHub Actions ([ci.yml](../../.github/workflows/ci.yml)) | ✅ |
| RNF-10 | **Plataforma:** Android, com `targetSdk` dentro do exigido pela Play Store no envio | `flutter build appbundle` + Play Console | 🟡 |

## Detalhes e pendências

**RNF-01 — Offline** 🟡
O estilo Editorial usa a fonte Jost embutida no app. O Liquid Glass usa DM Sans
via `google_fonts`, que **baixa a fonte na primeira vez**. Sem internet, o
texto cai na fonte padrão do sistema. O manifesto principal também não declara
a permissão `INTERNET`, então no build de release o download pode nunca
acontecer (confirmar no aparelho).
→ Embutir a DM Sans em `assets/fonts` (como a Jost) e desligar o download em
tempo de execução. Resolve também uma requisição de rede desnecessária
(RNF-02).

**RNF-02 — Privacidade**
Os dados ficam no `SharedPreferences` do aparelho, em JSON. Nenhuma
biblioteca de analytics, anúncios ou login. Isso sustenta a seção "Segurança
dos dados" da Play Store ("nenhum dado coletado ou compartilhado") e a
política de privacidade, que fica para depois.

**RNF-06 — Fluidez** 🟡
Os gargalos conhecidos foram resolvidos na
[etapa 1](../refatoracao/etapa-1-fundacao.md): provider recriado a cada
quadro, cálculos dentro do `build` e calendário refeito a cada
reconstrução. Ainda **falta medir** no aparelho, em modo *profile*: o fundo
animado e o efeito de vidro são os pontos mais caros.

**RNF-07 — Acessibilidade** 🟡
Números grandes encolhem com `FittedBox` e os botões principais têm
`tooltip`. Falta uma revisão com TalkBack e a checagem de contraste do texto
terciário nos dois estilos.

**RNF-10 — Plataforma** 🟡
`minSdk` e `targetSdk` seguem os padrões do Flutter instalado. Antes da
primeira publicação:
- definir o **`applicationId` definitivo**. O atual,
  `com.gestao.pessoal.gestao_pessoal`, é o gerado pelo template e **não pode
  mudar depois** de publicado;
- gerar a chave de upload e assinar o AAB (ver
  [processo de release](../processo/ciclo-de-vida.md#4-processo-de-release-android)).
