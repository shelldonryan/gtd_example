# Last Horizon

Last Horizon é um jogo 2D de sobrevivência e gestão durante uma viagem de dez
dias até Marte. O jogador controla o técnico da nave, mantém seis recursos e
resolve incidentes e ordens em quatro cômodos exploráveis.

## Estado implementado

O jogo executável é o sketch Processing em [`last_horizon/`](last_horizon/).
Ele contém o Comando, a Sala de máquinas, o Depósito e o Dormitório, ligados por
portas; o técnico anda, corre, pula, usa escadas e interage com estações e com
Vera, Bento, Neusa e Sílvia.

Cada dia permite concluir uma quest. Nos dias sem incidente há duas ofertas
preventivas; nos dias 2, 4, 6, 8 e 10 há um incidente com duas soluções. Uma
ordem preventiva é confirmada com a pessoa responsável. As soluções de
incidentes são escolhidas no cartão do incidente. As etapas físicas usam coleta
e entrega; uma solução urgente não concluída mantém o problema ativo. A noite
processa consumo, perdas, prazos, crises, riscos e condições de término.

O botão `MAPA` abre uma sobreposição com a nave e quatro cartões de cômodo. Ela
marca a sala atual, o objetivo e a quantidade de problemas por sala. A janela usa um buffer de render
1280×720 e amplia a imagem em fatores inteiros; o texto usa Segoe UI e a arte
pixel usa amostragem sem interpolação.

## Executar

Abra [`last_horizon/last_horizon.pde`](last_horizon/last_horizon.pde) no
Processing 4.5.6 e execute. Para os comandos de validação no Windows, veja
[`code/VERIFICATION.md`](code/VERIFICATION.md).

## Documentação

- [Estado atual da implementação](docs/CURRENT_IMPLEMENTATION.md): comportamento
  confirmado no sketch, assets disponíveis e resultados de validação.
- [Mecânicas e valores](mechanics/ACTIONS.md): recursos, calendário, quests,
  problemas, riscos e processamento noturno.
- [Fluxo da interface](interface/FLOW.md), [HUD](interface/HUD.md) e
  [cômodos](interface/ROOMS.md): apresentação e interação no jogo.
- [Eventos](events/): incidentes técnicos, ameaças e riscos de tripulação.
- [Personagens](characters/) e [contexto narrativo](history/CONTEXT.md): elenco
  e premissa.
- [Inventário de assets](assets/INVENTORY.md): arquivos de arte e áudio
  presentes e sua integração.
- [Arquitetura do sketch](code/SKETCH_ARCHITECTURE.md) e
  [verificação](code/VERIFICATION.md): organização do código e comandos.
- [Proposta de enxugamento e imersão](docs/SPEC_ENXUGAMENTO_E_IMERSAO.md):
  requisitos de produto; use `docs/CURRENT_IMPLEMENTATION.md` para distinguir
  requisitos daquilo que está implementado.
- [Decisões de arquitetura](docs/adr/): decisões registradas para o ciclo de
  quests e o ciclo diário.

## Validação registrada

Em 21/09/2026, no Windows, `npm.cmd run typecheck`,
`npm.cmd run regression:windows` (4/4 cenários) e
`node prototype/balance-model.mjs --simulate` passaram. A simulação avaliou
2.520 sequências. O modo de pipeline carrega um PNG sintético com `loadImage()`.
