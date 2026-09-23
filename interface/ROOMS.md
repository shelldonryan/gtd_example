# Cômodos jogáveis

Os quatro cômodos formam uma topologia com a Sala de comando como hub. Três
portas ligam o Comando ao Dormitório, ao Depósito e à Sala de máquinas. O mapa
é uma sobreposição consultiva com quatro cartões de cômodo.

Os conveses usam `y = 128`, `202` e `278` na grade lógica. As duas escadas de
cada sala e os pontos de interação estão configurados em `last_horizon/ship.pde`.
O pulo tem 48 px e a troca de convés é feita pelas escadas.

## Pontos de interação

| Tipo | O que faz |
| --- | --- |
| Leitura técnica | abre painel inferior com informações da estação |
| Oferta de ordem | mostra as opções preventivas do dia |
| Confirmação de ordem | confirma a ordem escolhida com o responsável |
| Coleta | entrega ao técnico o objeto associado à ordem |
| Entrega | aplica a recompensa ou resolve a solução escolhida |
| Conversa | abre retrato e painel do sobrevivente |
| Porta | leva à sala conectada |

Regras que valem em todos os cômodos:

- Alcances dependem do ponto. Portas exigem até 18 px na horizontal e na vertical;
  NPCs aceitam até 22 px na horizontal e 3 px na vertical; cada estação usa o
  alcance definido por seu ponto.
  NPCs vivos mantêm o nome; ao entrar no alcance, o sprite recebe halo cyan e
  aparece a indicação `E`.
- O técnico carrega **um objeto de quest por vez**. O item aparece como parte da
  ordem aceita e é entregue no destino.
- Coleta e entrega são as duas etapas leves de uma ordem. A entrega aplica custo,
  recompensa, correção ou risco correspondente.
- Uma quest pode ser concluída por dia. Ordens preventivas aceitas não podem ser
  canceladas.
- Nos dias sem incidente, duas ordens são comparadas remotamente e uma é
  confirmada presencialmente com o sobrevivente responsável.
- Nos dias com incidente, o cartão apresenta duas soluções físicas e a escolhida
  deve ser executada no espaço jogável.
- Estações fora da etapa atual ficam apagadas, sem marcador de ação, destaque ou
  resposta a `E`. NPCs vivos respondem a `E` a qualquer momento, com texto e tipo
  de painel conforme o estado: oferta própria do dia, confirmação presencial,
  ordem ativa sob sua responsabilidade, ordem ativa de outra pessoa, quest do dia
  concluída, problema ativo sem escolha ou nada pendente. Portas e beliche do
  técnico permanecem acessíveis; socorro habilita com pessoa em risco e quest
  diária livre.
- O mapa marca a sala atual, o ponto objetivo e a contagem de problemas por sala.
- Indicações usam ações concretas, nunca termos internos.
- Cada ordem define os pontos de coleta e entrega; os detalhes aparecem na oferta
  e no painel `ORDENS`.
- A matriz completa das oito ordens preventivas e das quatorze soluções de
  incidente está em [[ACTIONS]]; estes pontos preservam as rotas físicas e a
  leitura local.


## Sala de comando

O cômodo é o hub físico e concentra navegação, comunicações e comparação inicial
das ordens. As ofertas podem ser lidas remotamente e são confirmadas junto ao
sobrevivente responsável.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| superior | porta do Dormitório | porta |
| superior | Vera — ordens de navegação e comunicações | conversa, confirmação e coleta/entrega condicionadas à ordem |
| médio | porta do Depósito | porta |
| médio | console da rota — origem de objetos, jornada e previsão | leitura, coleta e entrega |
| inferior | porta da Sala de máquinas | porta |
| inferior | antena — destino de ordens de comunicação | entrega |

No primeiro dia, o técnico começa no Comando. Os dias seguintes começam no
Dormitório.
O console da rota informa jornada, dias restantes e previsão de consumo antes
das decisões de quest.

## Sala de máquinas
O cômodo concentra motor, energia e suporte de vida.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | bancada do motor — destino de ordens do motor | entrega |
| médio | Sílvia — ordens e confirmação técnica | conversa, confirmação e coleta/entrega condicionadas à ordem |
| médio | painel de distribuição — destino de ordens de energia | entrega |
| superior | painel de suporte de vida — destino de ordens de oxigênio | entrega |
| acesso | porta única para o convés inferior do Comando | porta |
## Depósito

O cômodo concentra logística e estoques. Objetos de quest ficam na origem
indicada pela ordem; alguns partem do console da rota no Comando para manter a
rota curta.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | estoque de comida — destino de ordens de suprimentos | entrega |
| inferior | componentes e objetos especiais da ordem ativa | coleta condicionada à ordem |
| médio | Bento — ordens logísticas e confirmação | conversa, confirmação e coleta/entrega condicionadas à ordem |
| superior | prateleira de reserva — objetos da ordem ativa | leitura e coleta condicionadas à ordem |
| acesso | porta única para o convés médio do Comando | porta |

## Dormitório

O cômodo concentra descanso, saúde, moral e encerramento do turno.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | ponto fixo de socorro | entrega de socorro para a pessoa em risco |
| médio | Neusa — ordens da tripulação e confirmação | conversa, confirmação e coleta/entrega condicionadas à ordem |
| médio | mesa do grupo — destino de ordens de convivência | entrega |
| superior | mesa comum — destino de ordens de moral | entrega |
| superior | beliche do técnico — resumo e dormir | leitura técnica e encerramento |
| acesso | porta única para o convés superior do Comando | porta |

## Portas e escadas

Portas usam uma tabela de portais, sem depender das bordas. Cada registro
declara `door_room`, `door_target`, `door_x` e `door_y`; `door_x` é o centro
horizontal e `door_y` é o limiar vertical dos pés do técnico. O campo
`door_deck` é apenas uma referência opcional do layout: `0`, `1` e `2`
identificam um convés e `-1` permite uma abertura sem deck, inclusive acima do
piso.

O portal responde a `E` quando o técnico fica até 18 px do centro e até 18 px
verticalmente do limiar. Assim como ocorre com os NPCs da tripulação, o nome da sala
de destino permanece fixo e rente logo acima da porta com contorno/glow de sombra preta
(`textCenteredShadow`) em branco (`COL_TEXT`); ao entrar no raio de alcance e colisão, o nome
muda para ciano (`COL_CYAN`) e a instrução `"Pressione E"` (`textPromptShadow`, tam. 11) surge
empilhada sobre o cabeçote da porta. Na primeira travessia, `door_arrival_x` (centro),
`door_arrival_y` (pés) e `door_arrival_facing` definem a chegada padrão na sala
de destino, inclusive em outro canto ou convés válido. Ao retornar imediatamente
pela porta que leva à sala anterior, o jogo reaproveita o `x/y` exato em que o
técnico saiu, em vez de usar a posição antiga da porta inversa. Em qualquer
outro percurso, aplica a chegada padrão configurada. A posição deve corresponder
a uma superfície alcançável; fora de uma superfície, a gravidade continua
normalmente.

Escadas continuam usando `ladder_room` e `ladder_x`; cada registro pode ocupar
qualquer posição horizontal do cômodo sem alterar a lógica de travessia. As
posições atuais em `ship.pde` são **127 e 532** no Comando, **468 e 136** na Sala
de máquinas, **520 e 130** no Depósito e **542 e 243** no Dormitório. Nenhuma estação fica a
menos de 40 px do eixo de uma escada. Com os fundos em imagem, o piso e a
escada passam a ser pintados e a colisão continua a mesma.

## Ordens

Os incidentes e os dias tranquilos usam a mesma estrutura de ordem: responsável,
objeto, origem, destino e consequência. Nos dias sem incidente, duas ordens
preventivas chegam remotamente e uma é confirmada ao encontrar o sobrevivente
responsável. Os pares válidos protegem recursos diferentes e ficam no catálogo
de [[ACTIONS]].

Nos dias com incidente, o cartão apresenta duas soluções físicas. A escolhida
substitui a contenção separada e precisa ser executada na estação correspondente.
O cartão informa também o custo e o resultado; os valores numéricos estão em
[[ACTIONS]].

| Ordem | Tipo | Origem | Onde conclui |
| --- | --- | --- | --- |
| Manutenção preventiva | preparação | ponto indicado pela oferta | estação indicada pela oferta |
| Solução técnica | correção | console da rota (Comando) | estação do motor, energia, suporte, comunicações ou casco |
| Solução de suprimentos | recuperação | console da rota (Comando) | estoque de comida |
| Solução da tripulação | convivência | Neusa ou console da rota | mesa do grupo |
| Socorro | recuperação humana | recursos do estoque, pagos na confirmação | ponto fixo de socorro no Dormitório |

Ordens preventivas e soluções possuem duas etapas leves: `COLETAR` e `ENTREGAR`. A rota usa
no máximo dois cômodos distintos, o sobrevivente responsável pode ser origem ou
destino, e o objeto é carregado por vez. A solução do casco parte do console da
rota no Comando para alcançar o ponto sorteado em qualquer cômodo.

Após a confirmação da ordem, a coleta mostra o objeto e sua finalidade. A ordem
preventiva exige confirmação presencial com o responsável; a solução de incidente
é confirmada no cartão. A entrega mostra o resultado antes de aplicar. Se uma
ordem preventiva aceita falhar ao dormir, o objeto retorna à origem; se uma
solução urgente falhar, o problema permanece ativo com suas perdas, prazo e
crise, e a mesma solução reaparece como retomada.
Em dia com incidente novo, o cartão do incidente tem prioridade; a retomada do
problema anterior fica disponível no próximo dia sem incidente.

O socorro é confirmado presencialmente no ponto fixo de socorro do Dormitório:
paga `-8 água` e `-2 comida` e conclui a quest do dia.


## Leitura do jogador

O HUD mostra o objetivo e o alerta atuais. O botão `ORDENS` apresenta os dados
detalhados da oferta ou quest ativa: responsável, objeto, origem, destino,
benefício, custo e consequência.

O mapa mostra quatro cartões de sala e marca a sala atual, o objetivo da etapa
e a contagem de problemas. As informações da ordem ficam no painel `ORDENS`.

Quando o dano no casco estiver ativo, ele pertence ao cômodo sorteado para aquela
ocorrência e a quest aponta para o local alcançável correspondente. A origem das
duas soluções é o console da rota no Comando.

O catálogo de quests e os valores estão em [[ACTIONS]] e nas notas de `events/`.
O botão `ORDENS` reabre as ofertas ou os detalhes da quest; `OFERTAS / PRÓXIMA
RETOMADA` permite consultar soluções pendentes em dias sem incidente. Estações
usam os assets catalogados e os objetos da quest têm representação no sketch. O
HUD está em [[HUD]] e a ordem das telas em [[FLOW]].

## Referências

- [#8 Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8)
- [#15 Sala jogável: movimento, colisão, escadas e interação](https://github.com/shelldonryan/gtd_example/issues/15)
- [#25 Redesenhar incidentes e ordens como quests físicas](https://github.com/shelldonryan/gtd_example/issues/25)
- [#27 Corrigir desfechos, transmissões e parametrizar portas, escadas, NPCs e HUD](https://github.com/shelldonryan/gtd_example/issues/27)
