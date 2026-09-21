# Changelog

Todas as mudanças notáveis neste projeto serão documentadas aqui.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Performance
- **Pomodoro (aba Foco)**: removidas chamadas a `GoogleFonts.spaceGrotesk()`
  e `GoogleFonts.inter()` que disparavam download sob demanda de `fonts.gstatic.com`
  na primeira entrada na aba, causando delay visível de 1–3s. Agora todo o texto
  do timer usa DM Sans via `Theme.of(context).textTheme`, já cacheado.
- Removida animação `.fadeIn(400ms).scale()` que adicionava 400ms ao iniciar
  o timer.

### Estrutura
- Adicionados `LICENSE` (Apache 2.0), `.editorconfig`, `lib/features/README.md`.
- Limpeza de logs de build temporários (`.log`, `.iml`).
- Documentada a arquitetura em camadas (data/domain/presentation).

## [0.1.0] — 2026-09-21

### Adicionado
- Pomodoro com ciclo completo Foco → Pausa Curta → Pausa Longa (botão
  "próximo" corrigido para ciclar pelos 3 modos).
- Configurações reativas: cor de texto + cor de destaque (accent) editáveis
  pelo usuário, com botões "Restaurar padrão".
- Wallpaper animado **ou** cor sólida (toggle em Configurações).
- Haptics + som de conclusão em tarefa/hábito (toggles independentes).
- Botão de excluir em diálogo de edição de hábito.
- Tridente minimalista (fundo branco + preto) como ícone do app.
- Build web com `Icon-1024` + `Icon-maskable-1024` para PWA/HiDPI.
- Token `textSecondary` clareado para #B0B0B0 e `textTertiary` para
  #8A8A8A (compliance WCAG AA+).
- Documentação: README institucional, diagrama ASCII de arquitetura,
  tabela de tokens de cor, changelog.

### Corrigido
- Filtro "Todas" esconde concluídas com `dueDate` no passado.
- Filtro "Hoje" inclui tarefas ad-hoc (sem data/recorrência).
- Filtro "Próximas" só com pontuais futuras + atrasadas.

## [0.0.1] — 2026-08-15

### Adicionado
- Build base do Daily Flow: 5 telas (Hoje/Hábitos/Tarefas/Foco/Stats) +
  Configurações, com Riverpod + GoRouter.
- Persistência local via SharedPreferences.
- Liquid Glass 3D (shaders + jelly) via `liquid_glass_widgets`.
- Calendário Syncfusion para hábitos (mês com appointments).
- Tema Dark/Green único, fonte DM Sans, sem glassmorphism no conteúdo.

[Não lançado]: https://github.com/Rick-Henrique7/Daily-Flow/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Rick-Henrique7/Daily-Flow/releases/tag/v0.1.0
[0.0.1]: https://github.com/Rick-Henrique7/Daily-Flow/releases/tag/v0.0.1
