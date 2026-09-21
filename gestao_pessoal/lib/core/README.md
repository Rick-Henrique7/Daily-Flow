# `lib/core/` — Infraestrutura compartilhada

Tudo aqui é **horizontal**: pode ser importado por qualquer feature,
mas não importa de feature nenhuma. Se algo aqui precisar de algo de
`features/`, é sinal de que deve ser movido.

## Estrutura

```
core/
├── constants/    # Tokens estáticos — cores, tema, espaçamentos
│   ├── app_colors.dart
│   └── app_theme.dart
├── database/     # Persistência local (SharedPreferences wrapper)
│   ├── prefs_keys.dart
│   └── prefs_store.dart
├── services/     # Serviços singleton (haptics, sound)
│   ├── haptics_service.dart
│   └── sound_service.dart
├── utils/        # Funções puras, sem estado
│   ├── date_formatters.dart
│   └── json_coders.dart
└── widgets/      # Widgets reutilizáveis entre features
    ├── animated_background.dart
    ├── app_shell.dart
    ├── glass_input_field.dart
    ├── glass_nav_bar.dart
    └── liquid_glass_card.dart
```

## Quando criar algo em `core/`

- **`constants/`**: tokens estáticos que mais de uma feature usa
  (cor primária, espaçamentos, tokens de design).
- **`database/`**: qualquer coisa que fale com `SharedPreferences`
  ou outro storage local. Não crie Notifiers aqui — eles ficam
  em `features/<x>/data/`.
- **`services/`**: APIs de plataforma (vibração, som, geolocalização,
  câmera, etc.) encapsuladas em uma classe Dart com interface limpa.
- **`utils/`**: funções puras e formatters sem dependência de framework.
- **`widgets/`**: widgets que aparecem em mais de uma feature. Se
  só uma feature usa, deixe dentro dela.

## Quando **NÃO** criar em `core/`

- Lógica de negócio específica → `features/<x>/data/`
- Modelos → `features/<x>/domain/`
- Telas → `features/<x>/presentation/`
- Constantes usadas em uma única feature → dentro dela mesma
