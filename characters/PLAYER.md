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
pelos quatro cômodos. A Sala de comando é o hub; suas portas por convés levam
ao Dormitório, ao Depósito e à Sala de máquinas. O mapa mostra a nave em quatro
cartões e marca a sala atual, o objetivo e a contagem de problemas. Os pontos de
interação de cada cômodo estão em [[ROOMS]].

Incidentes criam problemas locais persistentes. Nos dias com incidente, o técnico
escolhe uma entre duas soluções físicas e executa a rota correspondente
([[ACTIONS]]). Nos dias sem incidente, compara duas ordens preventivas e confirma
uma presencialmente com o sobrevivente responsável.

Uma quest usa as etapas `COLETAR` e `ENTREGAR`. O técnico carrega um objeto por
vez. Em geral, ele confirma a coleta na origem e o entrega no destino; nas
ordens V-02 e N-02, a própria confirmação com o responsável entrega o objeto
diretamente ao técnico. As interações com a tripulação e as estações acompanham
a ordem ou o incidente ativo.

## Representação visual

O técnico é carregado a partir de uma spritesheet única em
`last_horizon/data/player/player_sheet.png`, com as faixas definidas por
`last_horizon/data/player/player_sheet.json`. O carregador suporta
transparentemente os padrões **Universal LPC** e **Aseprite** (D-140 a D-142):

- **Universal LPC (ativo):** matriz 13×54 de células 64×64 (`player_sheet.png`, 832×3456).
  Extrai `idle` (2 quadros de 500 ms, linha 25), `walk` (8 quadros de 100 ms,
  linha 11), `climb` (6 quadros de 140 ms, linha 21, na escada), `jump`
  (sequência canônica `0-1-2-3-4-1`, 6 quadros de 75 ms, linha 29, no ar) e
  `run` (8 quadros de 75 ms, linha 41, com `Shift` no convés).
- **Aseprite (backup / compatibilidade):** tira horizontal de 640×64 com 10 quadros
  de 64×64, contendo `idle` (0–1) e `walk` (2–9). Quando o sprite é Aseprite,
  `climb`, `jump` e `run` degradam graciosamente para idle/walk; o passo acelerado
  do `Shift` continua valendo.

A detecção é automática: se o JSON tiver a chave `"frames"`, processa como
Aseprite; caso contrário, processa como Universal LPC. O quadro visual é
desenhado em 32×32 na grade lógica e centralizado sobre a caixa física original
de 16×24. Uma única arte atende as duas direções: `player_facing` espelha o
personagem quando o técnico anda para a esquerda ou para a direita, inclusive ao
entrar por uma porta. Os créditos e licenças abertas (CC-BY / OGA-BY) do LPC
estão documentados em `last_horizon/data/player/LICENSE.txt`.

## Deslocamento

Andar custa 1,0 px lógico por quadro; correr com `Shift` custa 2,4. A caminhada
foi calibrada pelo ciclo de 800 ms da própria animação: 1,0 px/quadro cobre 48 px
lógicos por ciclo, perto de duas alturas do técnico, e foi o valor que reduziu o
deslize dos pés sem tornar a navegação lenta (D-154). A corrida vale só no
convés: escada e ar mantêm o ritmo normal, e o pulo não muda de altura. Com
`Shift` acelera o deslocamento no convés, e a animação acompanha o estado de
corrida do técnico.

## Controles

| Ação | Tecla |
| --- | --- |
| Andar | ← → ou A/D |
| Correr | `Shift` com ← → ou A/D |
| Usar escada | ↑ ↓ ou W/S |
| Pular | espaço |
| Interagir | E |
| Pausa | ESC |

As mesmas teclas e as telas onde valem estão em [[FLOW]].

## Vínculos

- **Sobreviventes:** Vera, Bento, Neusa e Sílvia ficam nos cômodos e respondem às interações do técnico; dependem das decisões dele para permanecer vivos. O grupo está descrito em [[CONTEXT]].
- **Base em Marte:** representa o destino da missão e a possibilidade de um
  novo começo para a humanidade.
- **Terra:** permanece como uma lembrança da civilização que ficou para trás e
  pode enviar mensagens durante a viagem.

## Recursos e limitações

O personagem possui acesso a:

- Sala de comando.
- Sala de máquinas, com motor, energia e suporte de vida.
- Depósito.
- Dormitório.
- Painel de informações da nave.
- Estoque de peças para reparos.

As soluções de incidente podem cobrar energia, peças, comida ou moral, e o
socorro cobra água e comida. O jogador escolhe qual ordem ou problema resolver
dentro do limite de uma quest concluída por dia.

## Relação com a progressão

Ao longo dos dez dias, a campanha avança por recursos, quests, problemas ativos
e estado da tripulação. O histórico e o objetivo narrativos desta ficha
complementam o papel do técnico na viagem.

## Referências

- [#10 Pipeline Aseprite → Processing](https://github.com/shelldonryan/gtd_example/issues/10)
- [#15 Sala jogável: movimento, colisão, escadas e interação](https://github.com/shelldonryan/gtd_example/issues/15)
- [#18 Reestruturar navegação, tarefas e feedback após playtest](https://github.com/shelldonryan/gtd_example/issues/18)
