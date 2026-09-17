# Problemas da tripulação e dos suprimentos

Os incidentes de suprimentos e tripulação pertencem a duas variações da mesma
família de ordens: uma necessidade humana ou logística gera duas soluções
físicas e uma delas deve ser executada antes de dormir.

## Falta de comida

O incidente cria uma necessidade no Depósito. As duas soluções são quests
físicas e deixam o custo legível antes da escolha:

| ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FOOD-A | Bento | caixa de provisões | `-1 peça` | console da rota (Comando) | estoque de comida (Depósito) | recompor o estoque | `-3 comida/dia; prazo 3; -8 comida e uma pessoa em risco; prazo 2` |
| FOOD-B | Bento | selante de estoque | `-4 moral` | console da rota (Comando) | estoque de comida (Depósito) | proteger a reserva | `-3 comida/dia; prazo 3; -8 comida e uma pessoa em risco; prazo 2` |

Uma ordem preventiva também pode usar a caixa de provisões para aumentar comida
em um dia sem incidente. Se a solução não for concluída, o problema de comida
permanece ativo, cobra `-3 comida/dia`, reduz o prazo de 3 dias e chega à crise
`-8 comida e uma pessoa em risco` quando o prazo zera. O prazo da crise reinicia
em 2 dias.

## Conflito no dormitório

O incidente cria uma necessidade no Dormitório. As duas soluções usam rotas
curtas e deixam o resultado legível antes da escolha:

| ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- |
| CON-A | Neusa | cartões de mediação | `-5 moral` | console da rota (Comando) | mesa do grupo (Dormitório) | mediar a conversa | `-3 moral/dia; prazo 3; -8 moral e uma pessoa em risco; prazo 2` |
| CON-B | Neusa | refeição quente | `-4 comida` | console da rota (Comando) | mesa do grupo (Dormitório) | reunir o grupo | `-3 moral/dia; prazo 3; -8 moral e uma pessoa em risco; prazo 2` |

Ordens preventivas de convivência podem usar cartões de mediação para aumentar
moral em dias sem incidente. Se a solução não for concluída, o problema de
tripulação permanece ativo, cobra `-3 moral/dia`, reduz o prazo de 3 dias e chega
à crise `-8 moral e uma pessoa em risco`; o prazo da crise reinicia em 2 dias.

## Risco individual

Uma crise de comida ou conflito pode iniciar uma pessoa em risco. Uma crise do
suporte de vida também pode iniciar risco. Há no máximo uma pessoa em risco por
vez. O prazo inicial é de 2 noites. Socorrer é uma quest visível com custo
`-8 água` e `-2 comida`.

Se o prazo chegar a zero, a pessoa morre e `A BORDO` diminui; a morte não altera
custos nem cria bônus ou penalidades ocultos.

## Estado

As soluções físicas e os objetos de comida e convivência estão na matriz de
[[ACTIONS]]; os valores numéricos são o contrato vigente do ciclo. As falhas de
sistema estão em [[SYSTEM_FAULTS]] e os eventos externos, em [[HAZARDS]]. O
socorro exige presença no beliche da pessoa em risco e confirmação do custo, sem
uma cadeia adicional de coleta; usa a mesma conclusão diária das demais quests.

## Referências

- [#25 Redesenhar incidentes e ordens como quests físicas](https://github.com/shelldonryan/gtd_example/issues/25)
- [#26 Simplificar mecânicas legadas e balancear o ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26)
