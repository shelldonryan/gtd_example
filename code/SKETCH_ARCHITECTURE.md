# Arquitetura do sketch

Este documento descreve o esqueleto inicial do ticket [#9](https://github.com/shelldonryan/gtd_example/issues/9).
Ele continua válido para o viewport, o HUD e o estado global. O mapa macro agora
abre salas 2D jogáveis, e o técnico é controlável dentro delas.


A especificação vigente das salas e intervenções está em `interface/ROOMS.md`.
O sketch permanece plano e implementa D-073 a D-103 e D-108 a D-110.

## Onde o código mora

`last_horizon/` na branch `prototype/sketch-architecture`. A pasta é o pacote da
disciplina: `last_horizon.pde` + abas + `data/` (fonte) + `output/` (PNGs de prova).
Quando a arquitetura for validada com playtest, a pasta sobe para a `main` como está.

## Abas

| Aba | O que tem |
| --- | --- |
| `last_horizon.pde` | canvas, telas, ações, regras, paleta, estado da partida, viewport, input |
| `ui.pde` | painéis, diálogos, retratos procedurais, texto, botões, hit-test e AABB |
| `hud.pde` | cartões do topo, faixa do problema mais urgente e rodapé |
| `screens.pde` | máquina de estados, camadas modais, menus, vinheta, pausa e desfechos |
| `ship.pde` | hub, quatro salas, portas por convés, mapa consultável, plataformas, escadas, NPCs e estações |
| `game.pde` | calendário, turno, incidentes, consumo, crises e condições de término |
| `tasks.pde` | problemas persistentes, contenções, sobreviventes, políticas, componentes e intervenções |
| `capture.pde` | captura visual e verificações de ciclo, hub, clique e escada |

## Pipeline de assets

- A origem Aseprite, quando disponível, pode permanecer em `last_horizon/data/`
  junto das exportações. O runtime não depende do arquivo `.aseprite`.
- Para qualquer animação do jogo, a exportação oficial usa uma spritesheet única
  em PNG com JSON de metadados; não há PNG separado por quadro.
- O sketch carrega os assets de produção com `loadImage()` e
  `loadJSONObject()` em `loadPlayerAssets()` durante `setup()`. A pasta `data/`
  é o diretório de assets do Processing.
- `player_sheet.png` mede 640×64 e contém 10 quadros de 64×64.
- `player_sheet.json` registra `idle` nos quadros 0–1 e `walk` nos quadros 2–9,
  com 500 ms por quadro parado e 100 ms por quadro em movimento.
- `playerCurrentFrame()` soma as durações da faixa selecionada e usa módulo
  pelo total para repetir `idle` e `walk` continuamente.
- A física mantém o personagem em 16×24 na grade lógica. O quadro visual é
  desenhado em 32×32 lógicos e centralizado sobre a caixa de colisão.
- A direção usa `player_facing`: `1` para a direita e `-1` para a esquerda.
  O valor acompanha A/D e setas, é espelhado na camada sem interpolação e é
  redefinido conforme a entrada pela porta ou o reinício da sala.
- Se o carregamento falhar, `drawPlayerFallback()` preserva a execução e a
  caixa física, sem alterar o contrato de movimento.
- O modo de prova `--asset-pipeline-test` continua separado dos assets do jogo.
- `pipeline_probe.aseprite` e `pipeline_probe_frame_1.png` são o fixture do
  ticket #10, não assets finais nem convenção de produção. O probe tem 16×16
  pixels e é exibido duas vezes na grade lógica, no render físico 1280×720.
- O modo de prova prepara uma camada `PGraphics` sem interpolação antes de
  `beginDraw()`. A camada é composta no buffer principal, preservando a
  suavização do texto.
- A prova do pipeline é:
  `"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --asset-pipeline-test`
  Ela salva `last_horizon/output/pipeline_probe.png` e
  `pipeline_probe_window.png`.


## Contrato de gameplay implementado

Incidentes nos dias 2, 4, 6, 8 e 10 usam cinco dos sete problemas embaralhados
sem reposição. Toda contenção cria um problema persistente com perda, prazo e
crise; falta de recursos para ambas as contenções dispara a crise imediatamente.

Uma intervenção principal por dia corrige, recupera ou acelera. Políticas,
conversas e coleta de kit ou fusível são livres. Custos comuns são pagos na
estação; somente os dois componentes especiais ficam em `held_item`.

O Comando é o hub com Dormitório no convés superior, Depósito no médio e
Máquinas no inferior. HUD e mapa leem o mesmo conjunto de problemas ativos. O
empate de urgência preserva o problema ativado primeiro.

Vera, Bento, Neusa e Sílvia possuem vida e risco individuais. Crises escolhem a
pessoa pela regra determinística do modelo; o beliche temporário prioriza menor
prazo e depois ordem de criação. A morte reduz `A BORDO` e remove o benefício,
sem bloquear a intervenção.

D-097 continua integrado: dano no casco recebe ponto livre e alcançável em
qualquer sala. D-098 fornece todos os números; D-099 a D-103 fecham as decisões
de implementação confirmadas na #21.

## Implementação atual

- **Mapa:** preserva sala, posição e componente carregado; agrupa todos os
  problemas por cômodo e mostra perda, prazo e crise.
- **Hub:** três portas do lado direito do Comando, uma por convés; cada sala
  periférica possui somente o retorno ao mesmo convés do Comando.
- **Interação:** os pontos respondem ao estado dos problemas. Não há briefing,
  aceite ou cadeia universal por NPC.
- **Intervenções:** toda intervenção principal abre o painel de confirmação
  (`pending_intervention_point`) com problema, perda, prazo, crise e custo;
  `CONFIRMAR (ENTER)` aplica e `VOLTAR (ESC)` fecha sem gastar a intervenção.
  Reparos pagam o custo na estação; kit e fusível são conferidos e consumidos
  quando necessários. A coleta de kit ou fusível tem painel próprio
  (`pending_collect_point`) que explica o uso do componente, o requisito do
  reparo correspondente e a troca do item na mão; `CONFIRMAR (ENTER)` guarda o
  componente. Cuidado, socorro e potência compartilham o limite de uma
  intervenção diária.
- **Políticas:** economia e racionamento podem ser alternados livremente e usam
  os custos de Bento vivo ou morto.
- **Ciclo:** dormir aplica políticas, consumo, perdas, moral, riscos, crises e
  término nessa ordem. `Aumentar potência` elimina o próximo dia completo.

Números do movimento (grade lógica 640×360; render 1280×720 / 720p): personagem
16×24, andar 1,5 px/quadro, pulo de 48 px, gravidade 0,5, escada 1,0 e
plataformas atravessáveis por baixo.

**Sem classes e sem hierarquia.** O Processing junta todas as abas numa classe
só; o estilo permanece em globais agrupadas, funções curtas e `update` separado
de `draw`.

## Estado da partida

Globais planas mantêm recursos, dia, sala e movimento. `tasks.pde` agrupa
`problem_active`, `problem_deadline`, ordem de ativação, sequência de incidentes,
estado individual da tripulação, riscos, `intervention_used`, `skip_next_day` e
os dois componentes possíveis em `held_item`.

Nenhuma tela recebe parâmetro: as abas compartilham o mesmo estado do sketch.

## Números

`mechanics/ACTIONS.md` é a fonte de regras. As constantes e tabelas de
`game.pde` e `tasks.pde` implementam os valores confirmados na issue #20 e as
decisões D-099 a D-103 da #21.

## Viewport e input

- O buffer de render é 1280×720 (720p). A grade lógica 640×360 é usada apenas
  para posicionamento e é transformada por 2×; a janela mantém ampliação inteira
  e letterbox centralizado.
- `view_scale = max(1, int(min(width / 1280, height / 720)))`; a conversão da
  janela para a grade lógica divide também pelo fator 2.
- O mouse aciona apenas controles da interface, como `MAPA` e opções modais. O
  mapa preserva a sala e a posição; a movimentação entre cômodos usa portas e
  interação por `E`.
- **Teclas modais:** `ENTER` avança diálogos e confirma políticas, potência e
  sono; `E` interage com os pontos da sala.
- Os botões repetem no próprio rótulo os atalhos disponíveis: `INICIAR (ENTER)`,
  `CONTINUAR (ENTER)`, `CONTINUAR (ESC)`, `CONFIRMAR (ENTER)`,
  `ENCERRAR DIA (ENTER)`, `VOLTAR (ESC)` e `FECHAR (ESC)`.
- **Camadas de input**: menu, sala jogável, mapa, diálogo, painel técnico, evento
  e pausa. Todas as camadas modais bloqueiam movimento e interação da sala.
- **ESC** é consumido pelo sketch (`key = 0`) antes de alternar a pausa; não
  encerra mais a janela.
- Enquanto há evento pendente, o modal técnico mostra as duas consequências e
  bloqueia exploração, mapa e objetivos.
- **Cursor**: `HAND` sobre controles ativos, `WAIT` sobre controles desabilitados
  e `ARROW` no restante.

## Legibilidade

O playtest inicial mostrou que 8–10 px na base eram microtexto na janela 2×. A
tipografia visível é **Segoe UI**, instalada no Windows, criada com suavização e
renderizada no buffer 1280×720 (720p); a grade lógica 640×360 continua
organizando as posições.
Assets pixel art, quando entrarem, devem usar amostragem sem interpolação. A
regra de suavização do texto não se aplica a esses assets.
Os helpers tipográficos usam **16 px** para leitura, com **entrelinha de 18 px**.
Os botões tentam 16 px e reduzem somente quando a frase não cabe na largura
disponível; o limite é 10 px. `COL_MUTED` e `COL_DIM` também foram clareados
para manter contraste com o fundo.

Nenhum desenho de texto chama `g.textSize` direto: o HUD, as salas e os modais
passam por `text`, `textCentered` ou `drawTextWrapped`, que aplicam o piso de
16 px. Só `drawButton` reduz, pelo `fitTextSize`, e só quando a frase não cabe.

O HUD implementa os seis cartões de recurso com **ícone de 16×16 + número + barra**,
sem rótulo de texto; o cartão de quantos estão a bordo usa **A BORDO**; e o recurso
crítico pisca a borda e ganha ícone de aviso. O mapa macro não imprime nome de nave.

As capturas atualizadas ficam em `last_horizon/output/` na branch do protótipo.

## Leitura das regras (onde o vault deixou em aberto)

| Ponto | Leitura adotada |
| --- | --- |
| Moral −1 por recurso em vermelho | energia, oxigênio, água e comida entre 1 e 29 |
| Oxigênio caro (10/dia) | verifica a energia após o consumo base de energia, como no modelo aprovado |
| Chegada | ocorre depois de processar o dia 10; potência pode eliminar um dia futuro completo |
| Sorteio de incidentes | embaralha os 7 uma vez e usa 5 sem reposição nos dias 2, 4, 6, 8 e 10 |
| Painel de distribuição | ponto único que abre as opções de reparo e economia quando a falha elétrica está ativa; sem a falha, alterna apenas a economia |
| Seleção de quem entra em risco | mesma ordem de declaração dos problemas no modelo aprovado, combinada com o dia |
| Ordem de derrota | energia, oxigênio, moral, motor e, por último, nenhum sobrevivente vivo |
| Nome vazio no `MENU_INIT` | `INICIAR` desabilitado; "Técnico" só quando o campo tem espaços |

Nenhum sobrevivente vivo encerra a partida com mensagem própria: é a quinta causa
de derrota, documentada em `README.md`, `mechanics/ACTIONS.md` e
`interface/MENU_GAME_OVER.md`. O técnico não entra na conta dos quatro.

## Como rodar

Na instalação usada, `processing-java` não existe e também não existe
`C:\Program Files\Processing\runtime\bin\java.exe`. O launcher suportado é o
CLI embutido no `Processing.exe`. Os comandos abaixo são executados a partir da
raiz do repositório:

```
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --capture
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --hit-test
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --ladder-test
```

`--capture` percorre 27 estados, salva `output/NN_estado.png` em 1280×720
(720p) e `output/NN_estado_window.png`, e roda 70 verificações: dia 1 sem
incidente, incidente no dia 2, confirmação de reparo, de coleta e de socorro,
problema persistente, mapa, hub, intervenção, beliche, crise imediata, empate de
urgência, especialista morto, dano no casco, painel de distribuição com reparo e
economia, risco visível e resumo com vários problemas.
`--hit-test` abre 1400×900 e prova as quatro fichas do mapa e o letterbox.
`--ladder-test` mantém os cinco casos de saída e reentrada. As regras também
geram `output/map_dense.png`, a sala mais carregada possível no mapa.

Limitações observadas:

- A rota manual solicitada pelo ticket seria verificada com
  `Test-Path 'C:\Program Files\Processing\runtime\bin\java.exe'`. O resultado
  nesta instalação é `False`; portanto não há comando manual executável de
  compilação usando esse runtime. O launcher suportado é o CLI do Processing.
- A captura não usa bibliotecas externas do sketch: usa somente o core carregado
  pelo CLI e a família Segoe UI instalada no Windows. Não há biblioteca adicional
  ausente bloqueando o harness.
- O CLI emite os avisos `display count needs to be implemented for non-AWT` e
  `AWT disabled`, mas compila, executa, salva as imagens e encerra com sucesso.
  A execução headless não foi validada nesta sessão.

## Estado da revisão

- **Código atual:** D-048 a D-103 e D-108 a D-110 estão implementadas no protótipo.
- **Ciclo:** cinco incidentes sem reposição nos dias 2, 4, 6, 8 e 10, problemas
  persistentes, perdas, prazos, crises, riscos individuais e uma intervenção
  principal por dia.
- **Espaço:** Comando em hub, mapa consultável com todos os problemas e estações
  físicas para correção, recuperação, aceleração e políticas.
- **Evidência:** `--capture` com 70 verificações e nenhuma falha, `--hit-test` e
  `--ladder-test` com 5 verificações cada, `git diff --check` limpo e
  `node prototype/balance-model.mjs --simulate` com `BALANCE CHECK: PASS`.
- **Textos:** transmissões e textos finais ainda possuem pendências de
  implementação registradas no #11 e em `SESSION_START.md`.
