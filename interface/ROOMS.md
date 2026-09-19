# Cômodos jogáveis

Os quatro cômodos formam uma topologia em estrela inspirada na composição
lateral de `COMMAND_ROOM_CONCEPT_ART.png`. A Sala de comando é o hub central:
uma porta por convés leva ao Dormitório, ao Depósito e à Sala de máquinas. As
três salas periféricas não possuem portas entre si. O mapa é apenas consultável.

```
  convés superior  y≈164   [ estação ]        [ estação ]
  convés médio     y≈232   [ estação ]   esc  [ estação ]
  convés inferior  y≈300   [ estação ]   esc  [ estação ]
                            x≈150                x≈330
```

As posições acima são indicativas; o ajuste fino é da implementação, desde que
cada estação fique alcançável andando ou subindo escada. O pulo de 48 px
**não** alcança o convés de cima: trocar de nível é papel da escada.
As posições definitivas de escadas e estações, congeladas para a pintura dos
fundos, estão em [[INVENTORY]].

## Pontos de interação

| Tipo | Interrompe movimento | O que faz |
| --- | --- | --- |
| Leitura técnica | sim | abre painel inferior sem retrato |
| Oferta de ordem | sim | mostra uma ordem do sobrevivente e permite compará-la com outra |
| Confirmação de ordem | sim | confirma a ordem escolhida antes da coleta |
| Coleta | sim | entrega ou libera o objeto da ordem |
| Entrega | sim | aplica a recompensa ou resolve a solução escolhida |
| Conversa | sim | abre retrato e caixa inferior do sobrevivente |
| Porta | não | troca entre o Comando e uma sala periférica |

Regras que valem em todos os cômodos:

- Alcance de interação de 12 px para estações e portas, e 22 px lateral para NPCs
  (D-144), na mesma altura. NPCs vivos mantêm o nome; ao entrar no alcance, o
  sprite recebe contorno/halo cyan e o `E` aparece na diagonal superior direita,
  próximo da cabeça, sem moldura geométrica.
- O técnico carrega **um objeto de quest por vez**. O item aparece como parte da
  ordem aceita e é entregue no destino; não há coleta livre de componentes.
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
- O mapa mostra a origem e o destino, mas não transporta o técnico.
- Indicações usam ações concretas, nunca termos internos.
- A ordem ativa usa somente pontos que aparecem na oferta. O objeto não fica
  disponível no mapa antes da confirmação da ordem.
- A matriz completa das oito ordens preventivas e das quatorze soluções de
  incidente está em [[ACTIONS]]; estes pontos preservam as rotas físicas e a
  leitura local.


## Sala de comando

O cômodo é o hub físico e concentra navegação, comunicações e comparação inicial
das ordens. As ofertas podem ser lidas remotamente; não existe visita obrigatória
ao Comando para aceitar uma ordem.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| superior | porta do Dormitório | porta |
| superior | Vera — ordens de navegação e comunicações | conversa, confirmação e coleta/entrega condicionadas à ordem |
| médio | porta do Depósito | porta |
| médio | console da rota — origem de objetos, jornada e previsão | leitura, coleta e entrega |
| inferior | porta da Sala de máquinas | porta |
| inferior | antena — destino de ordens de comunicação | entrega |

No primeiro dia, o técnico começa no Comando. Nos demais, chega ao hub pela
porta superior vinda do Dormitório.
O console da rota informa jornada, dias restantes e previsão de consumo antes
das decisões de quest. Não existe aceleração que elimine dias.

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

O cômodo concentra descanso, saúde, moral e encerramento do turno.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | beliche temporário `SOCORRER [NOME]` de sobrevivente em risco | entrega de socorro |
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
verticalmente do limiar. Ao entrar no raio de alcance, a porta exibe seu prompt
em duas linhas empilhadas verticalmente acima da folha: na linha superior, o nome
da sala de destino com contorno/glow de sombra preta (`textCenteredShadow`) em ciano;
na linha inferior, a instrução `"Pressione E"` (`textPromptShadow`) em ciano (tam. 11).
Na primeira travessia, `door_arrival_x` (centro),
`door_arrival_y` (pés) e `door_arrival_facing` definem a chegada padrão na sala
de destino, inclusive em outro canto ou convés válido. Ao retornar imediatamente
pela porta que leva à sala anterior, o jogo reaproveita o `x/y` exato em que o
técnico saiu, em vez de usar a posição antiga da porta inversa. Em qualquer
outro percurso, aplica a chegada padrão configurada. A posição deve corresponder
a uma superfície alcançável; fora de uma superfície, a gravidade continua
normalmente.

Escadas continuam usando `ladder_room` e `ladder_x`; cada registro pode ocupar
qualquer posição horizontal do cômodo sem alterar a lógica de travessia. As
posições finais vieram da composição dos concept arts e estão fechadas para a
pintura dos fundos: **127 e 532** no Comando, **114 e 526** na Sala de máquinas,
**120 e 489** no Depósito e **127 e 482** no Dormitório. Nenhuma estação fica a
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
| Socorro | recuperação humana | recursos do estoque, pagos na confirmação | beliche da pessoa em risco |

Ordens preventivas e soluções possuem duas etapas leves: `COLETAR` e `ENTREGAR`. A rota usa
no máximo dois cômodos distintos, o sobrevivente responsável pode ser origem ou
destino, e o objeto é carregado por vez. A solução do casco parte do console da
rota no Comando para alcançar o ponto sorteado em qualquer cômodo.

Após a confirmação da ordem, a coleta mostra o objeto e sua finalidade. A ordem
preventiva exige confirmação presencial com o responsável; a solução de incidente
é confirmada no cartão. A entrega mostra o resultado antes de aplicar. Se uma
ordem preventiva aceita falhar ao dormir, o objeto retorna à origem; se uma
solução urgente falhar, o problema permanece ativo sem multa adicional e a mesma
solução reaparece como retomada.
Em dia com incidente novo, o cartão do incidente tem prioridade; a retomada do
problema anterior fica disponível no próximo dia sem incidente.

O socorro simplificado é confirmado presencialmente no beliche da pessoa em
risco: paga `-8 água` e `-2 comida` e conclui a quest do dia, conforme o modelo
numérico. Não há objeto adicional nem cadeia de visitas para socorrer.


## Leitura do jogador

O HUD mostra a ordem ativa com estágio, responsável, objeto, origem, destino,
recompensa ou resultado e consequência da falha. Também destaca o problema
ativo com menor prazo e quantos outros existem.

O mapa agrupa problemas e ordens por sala. Cada problema mostra perda diária,
prazo e consequência da crise; cada ordem mostra o ponto de coleta, o destino e
o estágio atual. O mapa nunca transporta o técnico.

Quando o dano no casco estiver ativo, ele pertence ao cômodo sorteado para aquela
ocorrência e a quest aponta para o local alcançável correspondente. A origem das
duas soluções é o console da rota no Comando.

O catálogo de quests e o balanceamento numérico estão em [[ACTIONS]] e nas notas
de `events/`. O sketch `last_horizon/` executa esse contrato. O botão `ORDENS`
reabre as ofertas ou os detalhes da quest; `OFERTAS / PRÓXIMA RETOMADA` permite
consultar as soluções pendentes em dias sem incidente. A arte das estações e
dos objetos ainda usa a representação geométrica do protótipo. O que o jogador
vê na tela está em [[HUD]], e a ordem das telas está em [[FLOW]].

## Referências

- [#8 Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8)
- [#15 Sala jogável: movimento, colisão, escadas e interação](https://github.com/shelldonryan/gtd_example/issues/15)
- [#25 Redesenhar incidentes e ordens como quests físicas](https://github.com/shelldonryan/gtd_example/issues/25)
- [#27 Corrigir desfechos, transmissões e parametrizar portas, escadas, NPCs e HUD](https://github.com/shelldonryan/gtd_example/issues/27)
