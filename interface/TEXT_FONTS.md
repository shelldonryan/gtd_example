# Fontes e textos

## HUD

- Fonte **Segoe UI**, instalada no Windows, 16 px no render nativo, entrelinha
  de 18 px.
- Os seis cartões de recurso usam ícone de 16×16 + número + barra, **sem rótulo
  de texto** — os únicos cartões com rótulo são DIA e A BORDO. O número é o
  destaque do cartão.

## MENU

- Títulos de tela em Segoe UI a 32 px. Corpo em 16 px.
- Botões podem reduzir até 10 px apenas quando a frase não cabe na largura
  disponível.

## DIALOGS

- Texto de evento, diálogos e avisos em Segoe UI a 16 px.
- A fonte cobre o vocabulário PT-BR e a pontuação usada pelo jogo sem substituir
  caracteres por quadrados.

## Escala

- Resolução canônica do render: **1280×720 (720p)**, proporção 16:9. A janela
  pode ampliar por fator inteiro.
- A grade lógica 640×360 serve apenas para posicionamento; não define uma
  resolução alternativa do render ou dos assets.
- Desenhar tudo num buffer físico de 1280×720. A tipografia visível usa Segoe UI
  com suavização; assets pixel art usam amostragem sem interpolação.
- As regras de suavização do texto e de amostragem dos assets são independentes.
- O sketch usa a família instalada no sistema; não há arquivo de fonte adicional
  nem biblioteca externa.

## Evidência

A fonte foi validada visualmente no sketch e na captura de estados da interface.
