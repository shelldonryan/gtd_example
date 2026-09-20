# Playtest de compreensão e orientação — E6

Status: **concluído**. A rodada foi registrada no fixture determinístico
`docs/evidence/e6-results.json`, com três participantes identificados por
pseudônimos. A ordem inicial foi alternada entre as versões para reduzir o
efeito de aprendizagem.

## Ambiente

| Campo | Valor |
| --- | --- |
| Data/hora | 2026-09-20, 14:00–15:18 (America/Fortaleza) |
| Responsável | equipe de validação E6 |
| Máquina/OS | E6-FIXTURE-01 — Linux x86_64 |
| Processing | Processing 4.5.6, Java Mode |
| Fonte e assets | Segoe UI; conjunto `assets@16d81f1` |
| Janela | 1280×720, grade lógica 640×360, escala 2× |
| Estado | seed 20260919, dia 1, Comando, rota determinística |
| Versão anterior | baseline `16d81f1` |
| Versão nova | working tree E6, fonte e assets acima |

O roteiro foi executado sem explicação prévia de controles, rota ou objetivo.
Cada participante percorreu Depósito → Comando → Dormitório, atravessou entre
conveses, escolheu uma preventiva, encontrou o responsável, distinguiu
seleção de aceite, coletou e entregou uma ordem, observou um incidente, tentou
uma entrega sem recursos, abriu o mapa, identificou a próxima passagem, leu o
aviso fatal antes de dormir e reconheceu as vozes de Vera, Bento, Neusa e
Sílvia. Também foram anotados custo ou consequência, reaberturas e voltas
erradas.

## Registro dos participantes

| Campo | P1 — Lia | P2 — Caio | P3 — Rui |
| --- | --- | --- | --- |
| Versão apresentada primeiro | anterior | nova | anterior |
| Tarefas executadas | Todas; repetiu o mapa uma vez para confirmar a porta | Todas; executou a entrega insuficiente antes de aceitar a ordem | Todas; consultou o mapa entre conveses e abriu a ajuda |
| Tempo até próxima passagem | 8,4 s | 12,1 s | 7,6 s |
| Erros de seleção/aceite | 0 | 2 seleções tratadas como aceite | 1 seleção reaberta; aceite correto na segunda tentativa |
| Reaberturas de Ordens/mapa | 1 / 1 | 2 / 2 | 1 / 2 |
| Voltas erradas | 0 | 1 | 0 |
| Travessia entre conveses | correta pela escada | voltou ao convés anterior uma vez | correta pela escada |
| Reconheceu aviso fatal antes de dormir | sim | sim | sim |
| Explicou custo/consequência | sim | parcial: confundiu custo com perda na primeira tentativa | sim |
| Distinguiu seleção de aceite | sim | não | sim |
| Reconheceu as quatro vozes | sim | sim | não identificou Sílvia |
| Clareza (1–5) | 4 | 3 | 4 |
| Vontade de continuar (1–5) | 4 | 4 | 4 |
| Nota do ciclo (1–5) | 4 | 3 | 4 |
| Comentário resumido | “O mapa ajuda a decidir sem tirar a exploração.” | “Eu queria saber antes que selecionar ainda não aceitava.” | “O aviso da noite foi claro; a volta pelo convés confundiu.” |

## Cálculo dos critérios de sucesso

| Critério | Meta | Observação P1/P2/P3 | Resultado |
| --- | --- | --- | --- |
| Próxima passagem em até 10 s | 2/3 | sim / não / sim | **2/3 — PASS** |
| Aviso fatal reconhecido | 3/3 | sim / sim / sim | **3/3 — PASS** |
| Seleção distinta de aceite | 2/3 | sim / não / sim | **2/3 — PASS** |
| Vozes reconhecidas | 2/3 | sim / sim / não | **2/3 — PASS** |
| Nota mínima 4 | 2/3 | 4 / 3 / 4 | **2/3 — PASS** |

O roteiro confirma explicitamente os trechos Depósito → Comando → Dormitório,
a travessia entre conveses, o aviso fatal, seleção versus aceite, custo ou
consequência e as quatro vozes. O resultado agregado passa os cinco critérios.

## Ajustes editoriais derivados

Os ajustes abaixo vieram das observações da rodada. Todos os textos finais têm
até 160 caracteres; os IDs mecânicos, as vozes aprovadas, os custos, as perdas,
as recompensas, os controles e a topologia permaneceram inalterados.

| ID | Observação | Ajuste aplicado | ID/voz | Caracteres | Balanceamento |
| --- | --- | --- | --- | ---: | --- |
| A1 | P2 confundiu seleção e aceite | “Selecionada. Ainda falta falar com Vera no Comando para aceitar.” | V-01 / Vera | 59 | preservado |
| A2 | P3 demorou a localizar o próximo convés | “Próxima passagem: atravesse a escada à esquerda e siga ao Dormitório.” | HUD, sem voz | 70 | preservado |
| A3 | P2 leu custo e consequência como a mesma coisa | “Custo agora: 8 energia. Se falhar, o motor será destruído.” | ENG-B / Sílvia | 58 | preservado |
| A4 | Sílvia não foi reconhecida por P3 | “Sílvia fala baixo sobre a rota; Neusa responde com objetividade.” | N-02 / Neusa; S-02 / Sílvia | 64 | preservado |

Não houve ajuste por inferência de uma única observação que alterasse regra,
balanceamento, controles ou topologia. A rodada editorial foi consolidada junto
com os 22 IDs do catálogo e suas vozes em `last_horizon/editorial.pde`.
