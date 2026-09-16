# Problemas da tripulação e dos suprimentos

Os incidentes de suprimentos e tripulação pertencem a duas variações da mesma
família de ordens: uma necessidade humana ou logística gera duas soluções físicas
e uma delas deve ser executada antes de dormir.

## Falta de comida

O incidente cria uma necessidade no Depósito. As duas soluções são quests
físicas e deixam o custo legível antes da escolha:

| ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FOOD-A | Bento | caixa de provisões | peças | console da rota (Comando) | estoque de comida (Depósito) | recompor o estoque | problema ativo; perda, prazo e crise da comida |
| FOOD-B | Bento | selante de estoque | moral | console da rota (Comando) | estoque de comida (Depósito) | proteger a reserva | problema ativo; perda, prazo e crise da comida |

Uma ordem preventiva também pode usar a caixa de provisões para aumentar comida
em um dia sem incidente. Se a solução não for concluída, o problema de comida
permanece ativo, cobra sua perda diária, reduz o prazo e pode chegar à crise.
Valores numéricos pertencem ao ticket #26.

## Conflito no dormitório

O incidente cria uma necessidade no Dormitório. As duas soluções usam rotas
curtas e deixam o resultado legível antes da escolha:

| ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- |
| CON-A | Neusa | cartões de mediação | moral | console da rota (Comando) | mesa do grupo (Dormitório) | mediar a conversa | problema ativo; perda, prazo e crise do conflito |
| CON-B | Neusa | refeição quente | comida | console da rota (Comando) | mesa do grupo (Dormitório) | reunir o grupo | problema ativo; perda, prazo e crise do conflito |

Ordens preventivas de convivência podem usar cartões de mediação para aumentar
moral em dias sem incidente. Se a solução não for concluída, o problema de
tripulação permanece ativo, cobra sua perda diária, reduz o prazo e pode chegar
à crise.


## Risco individual

Há no máximo uma pessoa em risco por vez. Socorrer é uma ordem visível e simples.
Se o prazo chegar a zero, a pessoa morre e `A BORDO` diminui; a morte não altera
custos nem cria bônus ou penalidades ocultos.

## Estado

As soluções físicas e os objetos de comida e convivência estão definidos na
matriz de quests da issue #25. O ticket #26 ainda define os valores numéricos
de custo, recompensa, perda, prazo e crise.
