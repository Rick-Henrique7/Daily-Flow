# `lib/core/` — Infraestrutura compartilhada

Tudo aqui é **horizontal**: pode ser importado por qualquer feature,
mas não importa de feature nenhuma. Se algo aqui precisar de algo de
`features/`, é sinal de que deve ser movido.

## Estrutura

```
core/
├── constants/    # Paleta por estilo, estilo visual, tema
│   ├── app_colors.dart
│   ├── app_style.dart
│   └── app_theme.dart
├── database/     # Persistência local (SharedPreferences wrapper)
│   ├── prefs_keys.dart
│   └── prefs_store.dart
├── providers/    # Providers de infraestrutura (armazenamento, hoje, vibração, som)
│   └── core_providers.dart
├── services/     # Serviços singleton (haptics, sound)
│   ├── haptics_service.dart
│   └── sound_service.dart
├── utils/        # Funções puras, sem estado
│   ├── date_formatters.dart
│   ├── date_only.dart
│   └── json_coders.dart
└── widgets/      # Widgets reutilizáveis entre features
    ├── animated_background.dart
    ├── app_shell.dart
    ├── app_snackbar.dart
    ├── glass_input_field.dart
    ├── glass_nav_bar.dart
    ├── liquid_glass_card.dart
    └── screen_header.dart
```

## Quando criar algo em `core/`

- **`constants/`**: tokens estáticos que mais de uma feature usa
  (cor primária, espaçamentos, tokens de design).
- **`database/`**: acesso de baixo nível ao `SharedPreferences`. Quem
  serializa modelos são os repositórios em `features/<x>/data/`.
- **`providers/`**: providers usados por várias features. O core não
  conhece features: quando precisa de algo delas (ex.: preferências de
  vibração/som), declara uma "porta" (`FeedbackPreferences`) que o
  `main.dart` liga com um override.
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
