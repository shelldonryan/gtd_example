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
Processing 4.5.6. Esse arquivo é a entrada do sketch `last_horizon/`; as demais
abas `.pde` da pasta fazem parte do mesmo sketch e são compiladas juntas pelo
Processing.

## Documentação

- [Mecânicas e valores](mechanics/ACTIONS.md): recursos, calendário, quests,
  problemas, riscos e processamento noturno.
- [Fluxo da interface](interface/FLOW.md), [HUD](interface/HUD.md) e
  [cômodos](interface/ROOMS.md): apresentação e interação no jogo.
- [Eventos](events/): incidentes técnicos, ameaças e riscos de tripulação.
- [Personagens](characters/) e [contexto narrativo](history/CONTEXT.md): elenco
  e premissa.
- [Inventário de assets](assets/INVENTORY.md): arquivos de arte e áudio
  presentes e sua integração.
- [Arquitetura do sketch](code/SKETCH_ARCHITECTURE.md): organização das abas
  Processing e do estado da partida.
