# Fontes e textos

## HUD

- Fonte **m5x7** (CC0), 16 px na resolução base, entrelinha de 18 px.
- Os seis cartões de recurso usam ícone de 16×16 + número + barra, **sem rótulo de texto** — os únicos cartões com rótulo são DIA e A BORDO. O número é o destaque do cartão.
- Nunca 24 px: não fecha na grade de 16.

## MENU

- Títulos de tela em m5x7 a 32 px. Corpo em 16 px.
- Botões podem reduzir até 10 px apenas quando a frase não cabe na largura disponível.
- Alternativa de voz para título: Press Start 2P a 16 px (OFL).

## DIALOGS

- Texto de evento e avisos: m5x7 a 16 px. Em 480 px de largura cabem cerca de 85 caracteres; manter as linhas com até 60.
- Pontuação disponível: `-`, `...`, `"`, `'`. A fonte **não** tem travessão, reticências curtas, aspas curvas nem crase.

## Escala

- Resolução base escolhida: **640×360** (16:9). A janela pode ampliar por fator inteiro, como 2× para 1280×720.
- Desenhar tudo num buffer na resolução base, com `noSmooth()` e `pixelDensity(1)`, e ampliar de uma vez em **fator inteiro**.
- Com `noSmooth()` o resultado fica idêntico à ampliação por vizinho mais próximo; sem ele, todo o texto borra.

## Evidência

`research/FONTE_ACENTOS.md` (branch `research/fonte-acentos`) e o ticket de fonte no mapa.
