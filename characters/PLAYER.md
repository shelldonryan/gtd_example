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
ao Dormitório, ao Depósito e à Sala de máquinas. O mapa apenas consulta posição
e problemas. Os pontos de interação de cada cômodo estão em [[ROOMS]].

Incidentes criam problemas locais persistentes. Nos dias com incidente, o técnico
escolhe uma entre duas soluções físicas e executa a rota correspondente
([[ACTIONS]]). Nos dias sem incidente, compara duas ordens preventivas e confirma
uma presencialmente com o sobrevivente responsável.

Uma quest tem as etapas `COLETAR` e `ENTREGAR`. O técnico carrega somente o
objeto da ordem aceita, que aparece no ponto de origem e é entregue no destino.
Diagnósticos e conversas fora da ordem são opcionais; não existem políticas,
coleta livre de componentes ou cadeia universal de visitas.

## Representação visual

O técnico é carregado a partir de uma spritesheet única em
`last_horizon/data/player/player_sheet.png`, com as faixas definidas por
`last_horizon/data/player/player_sheet.json`. O carregador suporta
transparentemente os padrões **Universal LPC** e **Aseprite** (D-140 a D-142):

- **Universal LPC (ativo):** matriz 13×54 de células 64×64 (`player_sheet.png`, 832×3456).
  Extrai `idle` (2 quadros de 500 ms, linha 25), `walk` (8 quadros de 100 ms,
  linha 11), `climb` (6 quadros de 120 ms, linha 21, na escada) e `jump`
  (13 quadros de 70 ms, linha 49, no ar).
- **Aseprite (backup / compatibilidade):** tira horizontal de 640×64 com 10 quadros
  de 64×64 (`player_sheet_aseprite.*`), contendo `idle` (0–1) e `walk` (2–9).
  Quando o sprite é Aseprite, `climb` e `jump` degradam graciosamente para
  idle/walk.

A detecção é automática: se o JSON tiver a chave `"frames"`, processa como
Aseprite; caso contrário, processa como Universal LPC. O quadro visual é
desenhado em 32×32 na grade lógica e centralizado sobre a caixa física original
de 16×24. Uma única arte atende as duas direções: `player_facing` espelha o
personagem quando o técnico anda para a esquerda ou para a direita, inclusive ao
entrar por uma porta. Os créditos e licenças abertas (CC-BY / OGA-BY) do LPC
estão documentados em `last_horizon/data/player/LICENSE.txt`.
## Controles

| Ação | Tecla |
| --- | --- |
| Andar | ← → ou A/D |
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

O personagem não possui recursos ilimitados. Cada reparo, mudança de rota ou
ação de emergência pode consumir energia, peças, comida, água ou moral. Por
isso, sua principal habilidade é decidir qual problema deve ser resolvido
primeiro.

## Relação com a progressão

O personagem não recebe novos poderes durante a primeira versão do jogo. A
progressão acontece por meio do conhecimento do jogador sobre os sistemas da
nave e pelas consequências acumuladas de suas decisões ao longo dos dez dias
de viagem.

## Referências

- [#10 Pipeline Aseprite → Processing](https://github.com/shelldonryan/gtd_example/issues/10)
- [#15 Sala jogável: movimento, colisão, escadas e interação](https://github.com/shelldonryan/gtd_example/issues/15)
- [#18 Reestruturar navegação, tarefas e feedback após playtest](https://github.com/shelldonryan/gtd_example/issues/18)
