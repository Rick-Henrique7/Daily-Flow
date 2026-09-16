// generate_trident_icon.js
//
// Gera o ícone minimalista do Daily Flow a partir do tridente de
// referência em `C:\Users\henri\Downloads\icono-tridente.avif`:
//
//   - Fundo branco puro (#FFFFFF)
//   - Tridente em preto — apenas a parte superior:
//       3 pontas (prongs) + parte do cabo (shaft).
//       O terço inferior do cabo original é removido (crop).
//   - Forma 1024×1024 PNG para casar com o pipeline
//     `scripts/generate_icons.js` (que produz todas as variantes
//     Android + Web a partir desse PNG).
//
// Rode com: `node scripts/generate_trident_icon.js`

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SRC = 'C:\\Users\\henri\\Downloads\\icono-tridente.avif';
const PREVIEW = path.join(ROOT, '_trident_preview.png');
const OUT = path.join(ROOT, 'assets/icons/daily_flow_icon.png');

// === Pipeline ===
//
// 1) Carrega o AVIF de referência (996×996, fundo claro, tridente
//    escuro com marca d'água "Magnific" bem sutil no cinza claro).
// 2) Corta a faixa inferior que continha o cabo cheio — mantém só
//    os 3 prongs + parte superior do cabo + ornamento ("bulb").
//    Mantém ~75% da altura original (descarta os últimos ~25%).
// 3) Achata o alpha (se houver) em fundo branco puro.
// 4) Redimensiona para 1024×1024 e centraliza num canvas 1024×1024
//    com padding interno (margem segura para máscaras do Android
//    adaptive icon e web maskable).

async function generate() {
  const srcMeta = await sharp(SRC).metadata();
  console.log(`source: ${srcMeta.width}×${srcMeta.height} (${srcMeta.format})`);

  // 1) Ler o source.
  // 2) Cortar o terço inferior do tridente: manter do topo até
  //    75% da altura. Isso remove o segmento mais fino/longo do
  //    cabo, mantendo os 3 prongs + ornamento + início do cabo.
  const cropHeight = Math.round(srcMeta.height * 0.75);
  const cropped = await sharp(SRC)
    .extract({
      left: 0,
      top: 0,
      width: srcMeta.width,
      height: cropHeight,
    })
    // Threshold agressivo para eliminar a marca d'água "Magnific"
    // do arquivo fonte: qualquer pixel com luminância > 200 vira
    // branco puro, o resto vira preto puro. Resultado: silhueta
    // sólida do tridente em preto sobre fundo branco.
    .threshold(200)
    // Achata em fundo branco para garantir uniformidade do bg.
    .flatten({ background: { r: 255, g: 255, b: 255 } })
    .png()
    .toBuffer();

  const croppedMeta = await sharp(cropped).metadata();
  console.log(`cropped: ${croppedMeta.width}×${croppedMeta.height}`);

  // 3) Compor num canvas 1024×1024 com padding interno generoso
  //    (safe-area para máscaras circulares/adaptive icons).
  //    Reservamos ~15% nas bordas como margem.
  const canvasSize = 1024;
  const safeArea = Math.round(canvasSize * 0.15); // 15% de margem
  const innerSize = canvasSize - safeArea * 2;

  const resized = await sharp(cropped)
    .resize(innerSize, Math.round((croppedMeta.height / croppedMeta.width) * innerSize), {
      fit: 'contain',
      background: { r: 255, g: 255, b: 255, alpha: 1 },
    })
    .png()
    .toBuffer();

  const resizedMeta = await sharp(resized).metadata();
  const offsetTop = Math.round((canvasSize - resizedMeta.height) / 2);

  // 4) Compor no canvas final 1024×1024, fundo branco puro.
  await sharp({
    create: {
      width: canvasSize,
      height: canvasSize,
      channels: 4,
      background: { r: 255, g: 255, b: 255, alpha: 1 },
    },
  })
    .composite([
      {
        input: resized,
        top: offsetTop,
        left: safeArea,
      },
    ])
    .png()
    .toFile(OUT);

  console.log(`✓ Tridente gerado: ${OUT}`);
  // Cleanup do preview.
  if (fs.existsSync(PREVIEW)) {
    fs.unlinkSync(PREVIEW);
    console.log('✓ Preview temporário removido');
  }
}

generate().catch((e) => {
  console.error(e);
  process.exit(1);
});
