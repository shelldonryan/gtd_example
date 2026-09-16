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

## Pontos de interação

| Tipo | Interrompe movimento | O que faz |
| --- | --- | --- |
| Leitura técnica | sim | abre painel inferior sem retrato |
| Oferta de ordem | sim | mostra uma ordem do sobrevivente e permite compará-la com outra |
| Confirmação de ordem | sim | confirma a ordem escolhida antes da coleta |
| Coleta | sim | entrega ou libera o objeto da ordem |
| Entrega | sim | aplica a recompensa ou resolve a solução escolhida |
| Conversa | sim | abre retrato e caixa inferior do sobrevivente |
| Interruptor | sim | explica a consequência e pede confirmação |
| Porta | não | troca entre o Comando e uma sala periférica |

Regras que valem em todos os cômodos:

- Alcance de interação de 12 px, na mesma altura, e o ponto se destaca quando o
  técnico entra no alcance.
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
- Diagnóstico e conversa fora da ordem não gastam a conclusão diária.
- O mapa mostra a origem e o destino, mas não transporta o técnico.
- Indicações usam ações concretas, nunca termos internos.

## Sala de comando

O cômodo é o hub físico e concentra navegação, comunicações e comparação inicial
das ordens. As ofertas podem ser lidas remotamente; não existe visita obrigatória
ao Comando para aceitar uma ordem.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| superior | porta do Dormitório | porta |
| superior | Vera — ordens de navegação e comunicações | conversa e confirmação |
| superior | antena — destino de ordens de comunicação | entrega |
| médio | porta do Depósito | porta |
| médio | console da rota — jornada, previsão e ordens de potência | leitura e entrega |
| inferior | porta da Sala de máquinas | porta |
| inferior | painel de situação — visão geral dos problemas e ordens | leitura técnica |

No primeiro dia, o técnico começa no Comando. Nos demais, chega ao hub pela
porta superior vinda do Dormitório. Ordens de potência podem eliminar um dia
futuro completo, conforme os valores definidos no balanceamento.

## Sala de máquinas
O cômodo concentra motor, energia e suporte de vida.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | bancada do motor — destino de ordens do motor | entrega |
| médio | Sílvia — ordens e confirmação técnica | conversa e confirmação |
| médio | painel de distribuição — destino de ordens de energia | entrega |
| superior | reator — leitura da potência do sistema | leitura técnica |
| superior | painel de suporte de vida — destino de ordens de oxigênio | entrega |
| acesso | porta única para o convés inferior do Comando | porta |
## Depósito

O cômodo concentra logística, estoques e objetos de quest.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | componentes e objetos especiais | coleta |
| médio | Bento — ordens logísticas e confirmação | conversa e confirmação |
| médio | estoque de comida — destino de ordens de suprimentos | entrega |
| superior | prateleira de reserva — objetos disponíveis | leitura e coleta |
| acesso | porta única para o convés médio do Comando | porta |

O cômodo concentra descanso, saúde, moral e encerramento do turno.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | beliche temporário `SOCORRER [NOME]` de sobrevivente em risco | entrega de socorro |
| médio | Neusa — ordens da tripulação e confirmação | conversa e confirmação |
| médio | mesa do grupo — destino de ordens de convivência | entrega |
| superior | mesa comum — destino de ordens de moral | entrega |
| superior | beliche do técnico — resumo e dormir | leitura técnica e encerramento |
| acesso | porta única para o convés superior do Comando | porta |

## Ordens

Os incidentes e os dias tranquilos usam a mesma estrutura de ordem: objeto,
origem, destino e consequência. Nos dias sem incidente, duas ordens preventivas
chegam remotamente e uma é confirmada ao encontrar o sobrevivente responsável.

Nos dias com incidente, o cartão apresenta duas soluções físicas. A solução
escolhida substitui a contenção separada e precisa ser executada na estação
correspondente.

| Ordem | Tipo | Onde conclui |
| --- | --- | --- |
| Manutenção preventiva | preparação | estação indicada pela oferta |
| Solução técnica | correção | estação do motor, energia, suporte, comunicações ou casco |
| Solução de suprimentos | recuperação | estoque ou estação logística |
| Solução da tripulação | convivência | mesa do grupo ou mesa comum |
| Socorro | recuperação humana | beliche da pessoa em risco |

Uma quest possui somente duas etapas leves: coletar e entregar. A rota usa no
máximo dois cômodos distintos, e o sobrevivente que oferece a ordem pode ser a
origem ou o destino. O objeto é carregado por vez e pode ser reutilizado em
ordens diferentes.


## Leitura do jogador

O HUD mostra a ordem ativa com objeto, origem, destino, recompensa e consequência
da falha. Também destaca o problema ativo com menor prazo e quantos outros
existem.

O mapa agrupa problemas e ordens por sala. Cada problema mostra perda diária,
prazo e consequência da crise; cada ordem mostra o ponto de coleta e o destino.
O mapa nunca transporta o técnico.

Quando o dano no casco estiver ativo, ele pertence ao cômodo sorteado para aquela
ocorrência e a quest aponta para o local alcançável correspondente.

O sketch atual ainda implementa o ciclo anterior. A migração para ordens,
soluções físicas, componentes de quest, riscos simplificados e uma conclusão
diária pertence aos tickets [Redesenhar incidentes e ordens como quests físicas](https://github.com/shelldonryan/gtd_example/issues/25)
e [Simplificar mecânicas legadas e balancear o ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26).
