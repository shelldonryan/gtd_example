# Fontes e renderização de texto

O sketch cria a fonte **Segoe UI** no setup. O texto é suavizado; sprites e
imagens pixel art são desenhados sem interpolação.

## Escala

- O buffer de render tem 1280×720 pixels; o layout usa coordenadas lógicas
  640×360 e um fator de render 2×.
- Os helpers de texto convertem o tamanho lógico para o buffer físico e
  aplicam limites de legibilidade. Títulos, HUD, modais e mensagens usam
  tamanhos definidos por tela; botões podem reduzir o texto para caber.
- Prompts de interação e rótulos compactos usam tamanhos menores que o corpo de
  um modal; cada componente define o tamanho adequado ao seu texto.

## Aplicação

HUD, salas e modais chamam os helpers de texto de `last_horizon/ui.pde`.
Os cartões do HUD apresentam os nomes dos seis recursos, valores e ícones PNG;
peças são mostradas por contagem numérica.

Os detalhes de layout e conteúdo estão em [`HUD.md`](HUD.md),
[`FLOW.md`](FLOW.md) e [`ROOMS.md`](ROOMS.md). Os assets estão catalogados em
[`../assets/INVENTORY.md`](../assets/INVENTORY.md).
