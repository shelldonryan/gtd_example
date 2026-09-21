# Estado da implementação atual

Revisão estática do checkout em **21/09/2026**. As fontes consultadas foram
`last_horizon/*.pde`, `prototype/balance-model.mjs` e os arquivos de assets
presentes em `last_horizon/data/`. O worktree já continha uma alteração local em
`last_horizon/screens.pde`; ela foi incluída na leitura e não foi modificada.

Esta revisão comparou documentação e código por inspeção. Não compilou nem
executou o jogo, o harness, campanhas de balanceamento ou playtests. Os
resultados E6 abaixo continuam sendo registros datados, não validação deste
checkout.

## Comportamento visível no código

| Área | Estado observado |
| --- | --- |
| HUD | Mostra os cartões de recursos, uma linha de objetivo e uma linha de alerta. O rodapé mostra `MAPA`, `ORDENS`, `?` e, quando há risco individual, `SOCORRO`. |
| Mapa | Desenha a nave e quatro cartões estáticos. Identifica a sala atual, o objetivo atual e a contagem de problemas por sala. Não seleciona salas, calcula rotas, nomeia portas/escadas ou detalha os problemas. |
| Objetivo | `currentObjective()` fornece o próximo ponto da ordem, o beliche de socorro ou o beliche do técnico após concluir a quest. O HUD mostra a ação e o nome do ponto, sem caminho entre salas ou conveses. |
| Ordens preventivas | Duas ofertas aparecem em dias sem incidente; uma fica pendente até confirmação presencial com o responsável vivo. |
| Soluções de incidente | São escolhidas e confirmadas no cartão do incidente. O NPC associado identifica a responsabilidade da solução, mas não precisa estar presente para aceitá-la. |
| Socorro | Custa 8 de água e 2 de comida e usa o limite de uma quest por dia. `rescueActionReason()` bloqueia a ação em dia com incidente novo ou cartão de incidente aberto. |
| Vitória e derrota | A vitória apresenta recursos como números em texto. A derrota mostra dia, sobreviventes e estado do motor; não mostra distância até Marte. |
| Tela inicial | O rótulo do campo é `Nome do seu personagem:` e há cursor intermitente. A alteração local removeu o texto `PROTÓTIPO - TEXTO PROVISÓRIO`; ainda não foi validada em runtime. |

## Navegação e posições atuais

As escadas são definidas por `ladder_room` e `ladder_x` em `ship.pde`:

| Sala | Posições x atuais |
| --- | --- |
| Comando | 127, 532 |
| Máquinas | 468, 136 |
| Depósito | 520, 130 |
| Dormitório | 542, 243 |

Os portais continuam declarados por dados em `ship.pde` e têm transição em
`portals.pde`. O mapa não calcula a sequência de portais nem a próxima escada.

## Estado dos assets esperado pelo loader

| Grupo | Encontrado no checkout | Observação |
| --- | --- | --- |
| Estações | 11 PNGs em `data/stations/` | O código carrega esses nomes. |
| NPCs e retratos | 4 spritesheets e 4 retratos em `data/npc/` | Retratos usam `npc/<nome>_portrait.png`; `portraits/<nome>.png` é fallback previsto. |
| Porta | `door_sheet.png` e `door_sheet.json` | Presentes em `data/doors/`. |
| Ícones | 6 PNGs | Presentes em `data/icons/`. |
| Mapa | `1.png`–`4.png`, `ship.png` e origem Aseprite | Presentes em `data/map/`; o loader associa as miniaturas pela ordem `4, 2, 1, 3`. |
| Áudio | pastas `door`, `ladder`, `run` e `walk` | Presentes em `data/audio/`. |
| Objetos de quest | Não encontrados em `data/objects/` | O loader prevê os arquivos; o código mantém fallback. |
| Fundos das salas | Não encontrados em `data/rooms/` | O loader prevê os arquivos; o código mantém fallback. |
| Casco animado | Não encontrados `stations/casco_sheet.png` e `.json` | O loader prevê os arquivos; há fallback de desenho. |
| Fundos de tela | Não encontrados em `data/screens/` | O loader prevê os arquivos; há fallback de estrelas. |

## Diferenças documentais a manter explícitas

- `interface/HUD.md`, `interface/FLOW.md` e `interface/ROOMS.md` descreviam
  detalhes de sala e orientação por rota que não estão no mapa atual.
- `assets/INVENTORY.md` misturava planejamento de produção com arquivos já
  integrados; as miniaturas atuais têm nomes numéricos e alguns grupos previstos
  continuam ausentes.
- A matriz de regras de `mechanics/ACTIONS.md` corresponde aos valores centrais
  lidos no código, mas a vitória exige também energia, oxigênio e moral acima de
  zero, além de motor operante e sobrevivente vivo.
- Os documentos de E6 registram resultados da campanha de 20/09/2026. Não foram
  repetidos nesta revisão e não demonstram que o checkout atual tem o mesmo
  comportamento visual ou os mesmos resultados.

## Fontes correntes

O código em `last_horizon/` é a fonte desta descrição do comportamento atual.
As especificações de produto preservam requisitos e decisões; quando divergem
do código, a divergência deve permanecer visível até haver decisão e
implementação correspondentes. Veja também o [relatório histórico E6](E6_REPORT.md)
e o [inventário de assets](../assets/INVENTORY.md).
