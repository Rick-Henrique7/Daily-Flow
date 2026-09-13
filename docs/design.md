# Módulo Visual — Liquid Glass Guidelines

> Diretrizes de UI/UX para o **Daily Flow**. Todos os componentes visuais
> (cards, botões, barras de navegação) devem seguir estritamente o estilo
> **Liquid Glass 3D / Skeuomorphic Glassmorphism**, com `BackdropFilter`
> para desfoque de fundo, múltiplas `BoxShadow` profundas para simular
> relevo realista no espaço 3D, gradientes iridescentes/suaves de fundo
> e bordas finas com refletividade de luz (`Colors.white.withOpacity(0.5)`).

---

## 1. Atributos da Interface (UI Elements)

### 1.1 Refração & Transparência (Backdrop Filter)

- Uso do widget `BackdropFilter` com `ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0)` para gerar o efeito fosco.
- Fundo dos cards em `Colors.white.withOpacity(0.15)` a `0.35` sobre superfícies neutras ilimitadas.

### 1.2 Bordas & Brilhos de Refratariedade (Glass Borders)

- Bordas finas (**1.2px**) com gradientes em arco para simular a luz incidindo no vidro: `LinearGradient` variando de `Colors.white.withOpacity(0.6)` no topo/esquerda até `Colors.white.withOpacity(0.1)` no rodapé.
- `BorderRadius.circular(24.0)` até `30.0` (formato pílula fluida).

### 1.3 Sombras 3D Difusas e Projetadas (Multi-layered Drop Shadows)

Combinação de duas ou três camadas de `BoxShadow` no mesmo container:

- **Sombra interna/suave:** `BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, spreadRadius: 2, offset: Offset(0, 10))`.
- **Sombra projetada difusa:** `BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 40, spreadRadius: 5, offset: Offset(10, 20))`.

### 1.4 Paleta de Cores e Gradientes Fluídos

- **Fundo base:** Off-white cremoso/prata suave (`#EFEFEF` a `#E0E5EC`) ou Dark Mode profundo translúcido.
- **Cores de destaque em gradiente vítreo:**
  - **Roxo Fluído:** `#8B5CF6` → `#C084FC`
  - **Ciano/Verde Água:** `#06B6D4` → `#34D399`
  - **Rosa/Iridescente:** `#F43F5E` → `#FB7185` → `#818CF8`

---

## 2. Exemplo de Componente Flutter (Liquid Glass Card)

```dart
import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Sombra projetada difusa
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(12, 18),
          ),
          // Sombra suave de profundidade
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              // Cor de preenchimento do vidro translúcido
              color: Colors.white.withOpacity(0.25),
              // Borda com efeito de reflexo de luz
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

> **Instrução para incluir no `SYSTEM_PROMPT.md`:**
>
> *Diretriz Adicional de UI:* "Todos os componentes visuais (cards, botões, barras de navegação) devem seguir estritamente o estilo **Liquid Glass 3D / Skeuomorphic Glassmorphism**. Utilize `BackdropFilter` para desfoque de fundo, múltiplas `BoxShadow` profundas para simular relevo realista no espaço 3D, gradientes iridescentes/suaves de fundo e bordas finas com refletividade de luz (`Colors.white.withOpacity(0.5)`)."

---

## 3. Pacotes Recomendados

### 3.1 Pacotes para Efeitos de Vidro e Difração (Glassmorphism)

- **`glassmorphic` / `glass`:** Pacotes que facilitam a aplicação de desfoque de fundo (`BackdropFilter`), gradientes de borda com reflexo de luz e transparência vítrea sem precisar escrever código repetitivo.
- **`glass_kit`:** Oferece containers pré-configurados com bordas iridescentes e sombras em camadas para simular profundidade 3D em superfícies de vidro.

### 3.2 Renderização 3D Nativa e Shaders (Para o Efeito "Liquid/4D")

Para obter o aspecto fluido, refrativo e com sombras realistas em tempo real, os pacotes de Shaders e 3D são os mais indicados:

- **Custom GLSL Shaders (Impeller / Skia Shaders):** A forma mais performática no Flutter 3+ de criar refração de fluido e distorção em tempo real é escrevendo shaders customizados em GLSL (passados via `FragmentShader`). Isso permite criar o efeito de "líquido se movendo dentro do vidro".
- **`flutter_scene` (3D no Flutter):** Utiliza o novo motor gráfico Impeller do Flutter para carregar elementos 3D com iluminação e sombras reais projetadas sob o glassmorphism.
- **`rive`:** Excelente alternativa no-code/low-code para desenhar componentes fluídos e tridimensionais com física interativa e exportá-los diretamente para o Flutter com alta performance.

### 3.3 Animações e Micro-interações (O elemento "4D" / Tempo)

- **`flutter_animate`:** Essencial para adicionar movimento contínuo às luzes, refrações e cores passantes no fundo do vidro (`.animate().shimmer()`, `.tint()`, `.scale()`).
- **`sensors_plus`:** Permite conectar os sensores de giroscópio do celular ao deslocamento das sombras e luzes do Liquid Glass, fazendo o efeito de vidro reagir à inclinação física do aparelho.
