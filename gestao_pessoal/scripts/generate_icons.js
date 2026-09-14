// generate_icons.js
// Gera todas as variantes do ícone do app (Android + Web) a partir do
// PNG 1024×1024 em assets/icons/daily_flow_icon.png.

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SRC = path.join(ROOT, 'assets/icons/daily_flow_icon.png');

// Tamanhos Android (mdpi = 48, hdpi = 72, xhdpi = 96, xxhdpi = 144, xxxhdpi = 192)
const ANDROID_DENSITIES = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

// Tamanhos Web (manifest.json)
const WEB_SIZES = [192, 512];

async function generate() {
  if (!fs.existsSync(SRC)) {
    console.error(`Ícone fonte não encontrado: ${SRC}`);
    process.exit(1);
  }
  const base = sharp(SRC);

  // === Android ===
  for (const [dir, size] of Object.entries(ANDROID_DENSITIES)) {
    const outDir = path.join(ROOT, `android/app/src/main/res/${dir}`);
    fs.mkdirSync(outDir, { recursive: true });

    // ic_launcher.png (ícone padrão)
    await base
      .clone()
      .resize(size, size)
      .png()
      .toFile(path.join(outDir, 'ic_launcher.png'));
    console.log(`✓ ${dir}/ic_launcher.png (${size}×${size})`);

    // ic_launcher_round.png (ícone circular)
    await base
      .clone()
      .resize(size, size)
      .png()
      .toFile(path.join(outDir, 'ic_launcher_round.png'));
    console.log(`✓ ${dir}/ic_launcher_round.png (${size}×${size})`);

    // ic_launcher_foreground.png (para adaptive icon)
    const fgSize = Math.round(size * 2.5);
    await base
      .clone()
      .resize(fgSize, fgSize)
      .png()
      .toFile(path.join(outDir, 'ic_launcher_foreground.png'));
    console.log(`✓ ${dir}/ic_launcher_foreground.png (${fgSize}×${fgSize})`);
  }

  // === Web ===
  const webDir = path.join(ROOT, 'web/icons');
  fs.mkdirSync(webDir, { recursive: true });
  for (const size of WEB_SIZES) {
    await base
      .clone()
      .resize(size, size)
      .png()
      .toFile(path.join(webDir, `Icon-${size}.png`));
    console.log(`✓ web/icons/Icon-${size}.png`);

    // Maskable (com padding extra nas bordas pra safe area)
    const pad = Math.round(size * 0.18);
    const innerSize = size - pad * 2;
    await sharp(SRC)
      .resize(innerSize, innerSize)
      .extend({
        top: pad,
        bottom: pad,
        left: pad,
        right: pad,
        background: { r: 13, g: 17, b: 23, alpha: 1 }, // #0D1117
      })
      .png()
      .toFile(path.join(webDir, `Icon-maskable-${size}.png`));
    console.log(`✓ web/icons/Icon-maskable-${size}.png (com safe-area)`);
  }

  // === favicon ===
  await base
    .clone()
    .resize(64, 64)
    .png()
    .toFile(path.join(ROOT, 'web/favicon.png'));
  console.log('✓ web/favicon.png');

  console.log('\n🎉 Todos os ícones gerados com sucesso!');
}

generate().catch((e) => {
  console.error(e);
  process.exit(1);
});
