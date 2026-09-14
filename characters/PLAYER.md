# Personagem principal

| Campo | Descrição |
| --- | --- |
| Nome | Definido pelo jogador no início da partida |
| Função | Técnico responsável pela manutenção e pelo gerenciamento da espaçonave |
| Histórico | Foi selecionado para acompanhar a nave por conhecer os sistemas de energia, o motor e os protocolos de emergência. |
| Objetivo | Manter a nave funcionando e conduzir os sobreviventes até a base em Marte. |
| A bordo | Viaja com os quatro sobreviventes, mas não entra na contagem deles |

## Papel no jogo

O protagonista é o jogador dentro da nave. Ele controla diretamente o técnico
durante a exploração dos cômodos. No mapa geral, seleciona um cômodo; dentro
dele, move-se pela cena 2D lateral, alcança os três conveses, as escadas, as
estações e os sobreviventes, e interage com o ponto que fecha a tarefa do dia.

Cada tarefa é uma cadeia de poucos passos e atravessa mais de um cômodo: o
técnico fala com um sobrevivente, pega o item no lugar certo e instala. A
movimentação e os passos intermediários são livres e não substituem a decisão de
gestão: só a interação que conclui a tarefa usa a ação do dia.

O técnico carrega um item por vez. O item não se perde quando o dia vira:
continua com ele até ser entregue ou trocado por outro.

## Representação visual

O técnico é carregado a partir de uma spritesheet única em
`last_horizon/data/player/player_sheet.png`, com as faixas definidas por
`last_horizon/data/player/player_sheet.json`. O PNG tem 640×64 e dez quadros de
64×64:

- `idle`: quadros 0–1, 500 ms por quadro;
- `walk`: quadros 2–9, 100 ms por quadro.

As durações do JSON controlam o loop no runtime. O quadro visual é desenhado em
32×32 na grade lógica e centralizado sobre a caixa física original de 16×24.
Uma única arte atende as duas direções: `player_facing` espelha o personagem
quando o técnico anda para a esquerda ou para a direita, inclusive ao entrar
por uma porta. Os assets pixel art são amostrados sem interpolação.


## Controles

| Ação | Tecla |
| --- | --- |
| Andar | ← → ou A/D |
| Usar escada | ↑ ↓ ou W/S |
| Pular | espaço |
| Interagir | E |
| Pausa | ESC |

## Vínculos

- **Sobreviventes:** Vera, Bento, Neusa e Sílvia ficam nos cômodos e respondem às interações do técnico; dependem das decisões dele para permanecer vivos.
- **Base em Marte:** representa o destino da missão e a possibilidade de um
  novo começo para a humanidade.
- **Terra:** permanece como uma lembrança da civilização que ficou para trás e
  pode enviar mensagens durante a viagem.

## Recursos e limitações

O personagem possui acesso a:

- Sala de comando.
- Sala de energia e motor.
- Depósito.
- Dormitório.
- Painel de informações da nave.
- Estoque de peças para reparos.

O personagem não possui recursos ilimitados. Cada reparo, mudança de rota ou
ação de emergência pode consumir energia, peças, comida, água ou moral. Por
isso, sua principal habilidade é decidir qual problema deve ser resolvido
primeiro.

## Relação com a progressão

O personagem não recebe novos poderes durante a primeira versão do jogo. A
progressão acontece por meio do conhecimento do jogador sobre os sistemas da
nave e pelas consequências acumuladas de suas decisões ao longo dos dez dias
de viagem.
