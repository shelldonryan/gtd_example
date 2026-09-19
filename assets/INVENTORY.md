# Inventário de assets

Lista final de imagens a produzir no Aseprite, com canvas, onde cada uma aparece
e se é estática ou animada — mais a ordem de produção.

O que decide tamanho: **1 pixel de arte = 1 pixel no render 1280×720**. A grade
640×360 só posiciona; o sketch desenha em unidades lógicas e o render
multiplica por 2. Portanto **canvas = tamanho que a peça ocupa na tela**, sem
escala: o quadro do técnico tem 64×64 e é desenhado em 32×32 lógicos = 64×64
pixels reais. Um objeto desenhado com 24 px de altura dentro de um canvas de
64×64 aparece com 24 px.

O sketch já carrega por esses nomes de arquivo e cai no desenho geométrico
quando o arquivo não existe ([[SKETCH_ARCHITECTURE]]), então este inventário é o
**contrato de drop-in da arte**: criar o PNG no caminho indicado basta para a
peça entrar no jogo.

Convenções que continuam valendo: nomes ASCII em `snake_case`, `.aseprite`
acompanha a exportação quando disponível, e todo asset **animado** é uma
spritesheet PNG única com JSON de metadados, no mesmo padrão de
`data/player/player_sheet.png` ([[PLAYER]]). Animação é só onde foi decidido:
NPCs, porta e casco.

## Origem da arte

- **Arte gerada por IA é proibida** pelo professor.
- Arte com licença aberta **CC0 ou CC-BY** e spritesheets são permitidas, com o
  crédito e a licença registrados junto do arquivo.
- A seleção da arte é do usuário: o agente não escolhe nem produz arte.


## Posições congeladas (entrada para a pintura)

O piso e as escadas passam a ser **pintados no fundo**; o código mantém a
colisão. Escadas e conveses abaixo são definitivos:

| Sala | Escadas (x) | Estações por convés (x) |
| --- | --- | --- |
| Comando | 127 e 532 | Vera 575 (superior); console da rota 260 (médio); antena 598 (inferior) |
| Sala de máquinas | 468 e 136 | suporte 454 (superior); Sílvia 570 e distribuição 215 (médio); bancada do motor 271 (inferior) |
| Depósito | 520 (inferior) e 130 (superior) | reserva 530 (superior); Bento 310 (médio); estoque de comida 85 (inferior) |
| Dormitório | 542 e 243 | seu beliche 185 e mesa comum 525 (superior); Neusa 330 e mesa do grupo 440 (médio); socorro 85 (inferior) |

Conveses em `y = 128`, `202` e `278`; a faixa útil da sala é `x` de 8 a 632 e
`y` de 56 a 284. As portas continuam sendo sprites e podem mudar de lugar sem
repintura. Regra de folga: nenhuma estação fica a menos de 40 px do eixo de uma
escada. Os pontos de interação de cada sala estão em [[ROOMS]].

## 1. Fundos das salas — 4 imagens, 1280×456, estáticas

Pintados em `data/rooms/`. O canvas cobre a faixa `y` de 112 a 568 do render
(8 px lógicos de sangria de cada lado) e traz paredes, tubulação, telas
decorativas, iluminação, **o piso e as escadas**. Não traz portas, estações,
objetos nem NPCs: tudo isso é sprite desenhado por cima.

| Arquivo | Sala | Escadas pintadas em |
| --- | --- | --- |
| `rooms/command.png` | Sala de comando | x = 127 e 532 |
| `rooms/machines.png` | Sala de máquinas | x = 468 (inferior) e 136 (superior) |
| `rooms/depot.png` | Depósito | x = 520 (inferior) e 130 (superior) |
| `rooms/dormitory.png` | Dormitório | x = 542 (inferior) e 243 (superior) |

## 2. Estações — 11 imagens + 1 spritesheet, canvas 64×64

Ancoragem: base no convés (`point_y`) e centro no `x` do ponto; o desenho ocupa
a parte de baixo do canvas. Substituem o retângulo genérico de 24×18 que existe
hoje; o rótulo de texto acima do ponto continua.

| Arquivo | Estação | Sala e convés |
| --- | --- | --- |
| `stations/antena.png` | antena | Comando, inferior (integrado com `Pillars.png`, 33×109 px) |
| `stations/console_rota.png` | console da rota | Comando, médio (integrado com `BioComputer.png`, 181×117 px) |
| `stations/painel_suporte.png` | painel de suporte de vida | Máquinas, superior (integrado com `Board 1.png` + `Health Pack 1.png` + `Props 4.png`, 93×74 px) |
| `stations/painel_distribuicao.png` | painel de distribuição | Máquinas, médio (integrado com `CryoBox.png` + `Electric wall.png` + `CryoBox.png`, 165×111 px) |
| `stations/bancada_motor.png` | bancada do motor | Máquinas, inferior (integrado com `Desk 1.png` + `Screen device.png` + `Small Machine 1.png`, 121×75 px) |
| `stations/prateleira_reserva.png` | prateleira de reserva | Depósito, superior (integrado com `Lockers 1.png`, 104×83 px, armários com compartimento aberto e ferramentas) |
| `stations/estoque_comida.png` | estoque de comida | Depósito, inferior (integrado com 4x `Locker.png`, 110×77 px, armários modulares com indicadores LED) |
| `stations/mesa_comum.png` | mesa comum | Dormitório, superior (integrado com `Desk 1.png` + `Chair.png` + `Props 4.png`, 118×48 px) |
| `stations/beliche_tecnico.png` | seu beliche | Dormitório, superior (sprite interativo com `Bed-1.png` isolado sobre canvas 142×112 px, contorno ciano exclusivo no leito) |
| `stations/mesa_grupo.png` | mesa do grupo | Dormitório, médio (integrado com `Small machine 3-1.png` + `Desk 1.png` + 2x `Chair.png` + `books.png`, 140×46 px) |
| `stations/beliche_socorro.png` | beliche de socorro | Dormitório, inferior (integrado com `Bed.png`, 99×47 px, leito médico com monitores) |
| `stations/casco_sheet.png` + `.json` | casco avariado | **animado**, 2 quadros, sheet 128×64 |

O casco é sorteado em qualquer sala, convés e `x` a cada problema, então o
desenho precisa se sustentar sozinho em cima de qualquer trecho do piso
pintado, sem moldura de parede e sem depender de um canto específico.

## 3. Objetos de quest — 16 imagens, 64×64, estáticas

Em `data/objects/`. Desenhados no tamanho real dentro do canvas, como o
técnico: a chave de torque ocupa pouco, a caixa de provisões quase tudo. O
mesmo PNG é usado no ponto de coleta, na mão do técnico (com a linha
`NA MÃO: [objeto]`) e como ícone nos painéis de `COLETAR` e `ENTREGAR`.

| Arquivo | Objeto | Usado em |
| --- | --- | --- |
| `objects/bobina_transmissao.png` | bobina de transmissão | V-01, COM-A |
| `objects/cartao_rota.png` | cartão de rota | V-02 |
| `objects/caixa_provisoes.png` | caixa de provisões | B-01, FOOD-A |
| `objects/chave_torque.png` | chave de torque | B-02, ENG-A |
| `objects/filtro_agua.png` | filtro de água | N-01 |
| `objects/cartoes_mediacao.png` | cartões de mediação | N-02, CON-A |
| `objects/modulo_rele.png` | módulo de relé | S-01, PWR-B |
| `objects/cartucho_oxigenio.png` | cartucho de oxigênio | S-02, LIFE-A |
| `objects/atuador_motor.png` | atuador do motor | ENG-B |
| `objects/kit_vedacao.png` | kit de vedação | HUL-A |
| `objects/placa_blindagem.png` | placa de blindagem | HUL-B |
| `objects/filtro_co2.png` | filtro de CO2 | LIFE-B |
| `objects/fusivel_potencia.png` | fusível de potência | PWR-A |
| `objects/celula_sinal.png` | célula de sinal | COM-B |
| `objects/selante_estoque.png` | selante de estoque | FOOD-B |
| `objects/refeicao_quente.png` | refeição quente | CON-B |

## 4. NPCs — 4 spritesheets (integrados em data/npc/)

Em `data/npc/` com `LICENSE.txt`. Mesmo enquadramento do técnico: quadro 64×64
desenhado em 32×32 lógicos, centrado na caixa de 16×24. Suporta os formatos
Universal LPC e Aseprite. No LPC, o NPC vira dinamicamente na direção do técnico
(linha 23 para a esquerda, linha 25 para a direita, linha 24 frontal), com idle
de 2 quadros de respiração a 500 ms por quadro. Os sobreviventes não andam por contrato.
Quando o técnico entra no raio de interação, o destaque é um contorno/halo cyan
gerado em runtime a partir da transparência do frame; ele não é gravado no PNG.

Integrados: `npc/vera.png`, `npc/bento.png`, `npc/neusa.png` e `npc/silvia.png`.
## 5. Porta — 1 spritesheet, 210×97 (2 quadros de 105×97, integrada)

`doors/door_sheet.png` + `doors/door_sheet.json`. Quadros `fechada` (`Doors 1.png`) e `aberta` (`Doors 2.png`), renderizados em 52.5×48.5 lógicos (105×97 reais em 720p, proporção 1:1 pixel-perfect).
A base fica no limiar (`door_y`) e o centro em `door_x`; uma única arte serve as seis portas.
Quando o técnico entra no alcance da porta, um contorno/halo cyan gerado em runtime a partir da transparência do frame é desenhado ao redor do asset (efeito idêntico aos NPCs em D-155), e o texto `E - [sala]` é exibido centralizado acima do topo da porta (`y - ART_DOOR_H - 6`), com ajuste proporcional (`fitTextSize`) para nunca sobrepor escadas ou bordas da tela.
A travessia executa a animação em 2 quadros: abrir o quadro `aberta`, trocar de sala e fechar no destino.

## 6. Ícones do HUD — 6 imagens, 32×32, estáticas

Em `data/icons/`, substituindo os vetores atuais na caixa de 16×16 lógicos:
`energia.png`, `oxigenio.png`, `agua.png`, `comida.png`, `pecas.png` e
`moral.png`.
O cartão mantém rótulo, número e barra: só o ícone troca ([[HUD]]). O alerta
crítico (`aviso`) permanece desenhado exclusivamente em código; não há
`aviso.png`.

## 7. Retratos — 4 imagens, 224×276, estáticas

Em `data/portraits/`, no diálogo com sobrevivente: `vera.png`, `bento.png`,
`neusa.png`, `silvia.png`. Substituem o bloco geométrico atual de 112×138
lógicos; uma expressão por personagem.

## 8. Telas — 3 imagens, 1280×720, estáticas

Em `data/screens/`.

| Arquivo | Onde aparece | Conteúdo |
| --- | --- | --- |
| `screens/menu_space.png` | menu inicial e as três páginas da vinheta | a nave vista de fora, pequena contra o espaço, com a Terra alaranjada ao fundo |
| `screens/victory_mars.png` | tela de vitória | a base marciana vista de fora, com a nave já pousada e luzes acesas |
| `screens/defeat_space.png` | tela de derrota | espaço vazio, frio, com um ponto de luz se apagando |

Pausa, ajuda, transmissões, ordens, incidente, coleta, entrega e o resumo de
dormir continuam em painel de texto, sem arte nova.

## 9. Mapa — 4 miniaturas, 240×144, estáticas

Em `data/map/`: `command.png`, `machines.png`, `depot.png` e `dormitory.png`.
Uma miniatura por cômodo dentro do cartão do mapa consultável; a moldura, os
textos e o `VOCÊ ESTÁ AQUI` continuam por código.

## 10. Áudio — uma pasta por evento

Os sons vivem em `data/audio/<evento>/`, cada pasta com o seu `LICENSE.txt`:

| Pasta | Arquivos | Quando toca |
| --- | --- | --- |
| `audio/door/` | `door.wav` | uma vez no início da travessia de porta |
| `audio/walk/` | `step_01..04.wav` | passos na caminhada, decolagem e aterrissagem |
| `audio/run/` | `step_01..04.wav` | passos durante a corrida |
| `audio/ladder/` | `ladder.wav`, `step_01..04.wav` | saída e passos durante a subida/descida |

Formato de todos: WAV PCM 16 bits, 44,1 kHz, mono. A caminhada dispara no
início e no meio do ciclo visual de 800 ms — um contato a cada 400 ms — usando
apenas o primeiro ataque de cada take de botas, com cauda até 12 ms e sem
impacto adicional. A corrida mantém a combinação `var_02`, com impacto curto
de metal, pico próximo de −22 dBFS e cadência de 27 px lógicos. Na escada, os
takes metálicos originais da issue #28 permanecem separados; o primeiro passo
avisa o início após 1 px lógico e os seguintes tocam a cada 27 px,
sincronizados à animação.

Créditos e receitas ficam no `LICENSE.txt` de cada pasta. Caminhada usa
`footsteps/boots/` derivados de swuing (CC-BY 3.0); corrida usa os mesmos takes
com `impactMetal_000.ogg` de Kenney (CC0). A escada mantém os takes metálicos
de congusbongus/Eelke (CC-BY 3.0) e `ladder.wav` com impacto da Kenney (CC0).

Clique de UI, alerta de recurso crítico e os demais eventos ficaram fora — o
alerta continua apenas visual ([[HUD]]).

## Ordem de produção

Cada bloco é utilizável sozinho; a ordem segue o que desbloqueia leitura de jogo
mais rápido e o que depende de posição já congelada.

1. **Ícones (6)** — troca direta no HUD, sem mexer em layout.
2. **Porta (1 sheet) e casco (1 sheet)** — fecham a leitura de interação; a
   porta pede o estado de travessia no sketch.
3. **Objetos (16)** — fecham a leitura das 22 quests: ponto de coleta, mão e
   painéis.
4. **NPCs (4 sheets)** — substituem os retângulos; o idle pede o carregamento
   da spritesheet no lugar do desenho geométrico.
5. **Estações (13 + casco)** — posições congeladas nesta sessão.
6. **Retratos (4)** — diálogo de confirmação e conversa.
7. **Fundos (4)** — a peça maior; pintados por último dentro do jogo, com
   escadas, conveses e estações já definitivos.
8. **Telas (3) e miniaturas do mapa (4)** — desfechos e mapa; não bloqueiam
   nada.
9. **Áudio** — porta, caminhada, corrida e escada decididos e integrados em
   `data/audio/door/`, `data/audio/walk/`, `data/audio/run/` e `data/audio/ladder/`.

## O que continua em código

Nada do que já funciona vira asset: painéis, cartões de recurso, barras,
faixas, rodapé, botões, o selo `!` pulsante, o modal de ajuda, as estrelas dos
menus, a moldura do mapa e todo o texto (Segoe UI). Quando os fundos entrarem,
`drawDecks` e `drawLadders` saem do sketch — o piso e a escada passam a ser
pintados — e a colisão, o `point_x`, o `point_y` e o `ladder_x` continuam sendo
a verdade de posicionamento.

## Referências

- [#8 Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8)
- [#10 Pipeline Aseprite → Processing](https://github.com/shelldonryan/gtd_example/issues/10)
- [#28 Escolher e integrar os efeitos sonoros](https://github.com/shelldonryan/gtd_example/issues/28)
- [#29 Camada de assets: sketch pronto para receber a arte](https://github.com/shelldonryan/gtd_example/issues/29)

