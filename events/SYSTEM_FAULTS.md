# Falhas de sistema

Falhas internas criam problemas persistentes na família de falhas técnicas. O
incidente apresenta duas soluções físicas em formato de quest; o jogador escolhe
uma, coleta o objeto indicado e o entrega no sistema correspondente.

## Tipos

| Incidente | Perda por dia | Prazo | Crise |
| --- | --- | ---: | --- |
| Falha no motor | `-4 energia` | 3 | motor destruído |
| Dano no casco | `-4 oxigênio` | 3 | `-12 oxigênio`; prazo 2 |
| Falha no suporte de vida | `-3 oxigênio` | 3 | `-10 oxigênio` e uma pessoa em risco; prazo 2 |
| Falha no sistema de energia | `-3 energia` | 3 | `-10 energia`; prazo 2 |
| Falha nas comunicações | `-2 moral` | 4 | `-8 moral`; prazo 2 |

Cada solução informa antes da escolha o objeto, o recurso cobrado, a origem, o
destino e o resultado. Se a solução não for concluída, a perda diária começa na
noite daquela escolha; não existe multa adicional.

| Incidente | ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Falha no motor | ENG-A | Sílvia | chave de torque | `-2 peças` | console da rota (Comando) | bancada do motor (Máquinas) | alinhar o eixo do motor | `-4 energia/dia; prazo 3; motor destruído` |
| Falha no motor | ENG-B | Sílvia | atuador do motor | `-8 energia` | console da rota (Comando) | bancada do motor (Máquinas) | estabilizar a rotação | `-4 energia/dia; prazo 3; motor destruído` |
| Dano no casco | HUL-A | Sílvia | kit de vedação | `-1 peça` | console da rota (Comando) | ponto de casco sorteado | fechar a ruptura | `-4 oxigênio/dia; prazo 3; -12 oxigênio; prazo 2` |
| Dano no casco | HUL-B | Sílvia | placa de blindagem | `-6 energia` | console da rota (Comando) | ponto de casco sorteado | sustentar a placa | `-4 oxigênio/dia; prazo 3; -12 oxigênio; prazo 2` |
| Falha no suporte de vida | LIFE-A | Sílvia | cartucho de oxigênio | `-1 peça` | console da rota (Comando) | painel de suporte de vida (Máquinas) | repor o cartucho | `-3 oxigênio/dia; prazo 3; -10 oxigênio e risco; prazo 2` |
| Falha no suporte de vida | LIFE-B | Sílvia | filtro de CO2 | `-6 energia` | console da rota (Comando) | painel de suporte de vida (Máquinas) | recircular o ar | `-3 oxigênio/dia; prazo 3; -10 oxigênio e risco; prazo 2` |
| Falha no sistema de energia | PWR-A | Sílvia | fusível de potência | `-1 peça` | console da rota (Comando) | painel de distribuição (Máquinas) | isolar o circuito | `-3 energia/dia; prazo 3; -10 energia; prazo 2` |
| Falha no sistema de energia | PWR-B | Sílvia | módulo de relé | `-5 moral` | console da rota (Comando) | painel de distribuição (Máquinas) | redistribuir a carga | `-3 energia/dia; prazo 3; -10 energia; prazo 2` |
| Falha nas comunicações | COM-A | Vera | bobina de transmissão | `-1 peça` | console da rota (Comando) | antena (Comando) | restabelecer o contato | `-2 moral/dia; prazo 4; -8 moral; prazo 2` |
| Falha nas comunicações | COM-B | Vera | célula de sinal | `-5 energia` | console da rota (Comando) | antena (Comando) | manter a escuta | `-2 moral/dia; prazo 4; -8 moral; prazo 2` |

O dano no casco usa `HUL-A` (kit de vedação, custo em peças) ou `HUL-B`
(placa de blindagem, custo em energia). Em ambos, a origem é o console da rota
no Comando e o destino é o ponto de casco sorteado quando o problema nasce.
Assim, a rota usa no máximo o Comando e o cômodo afetado.

## Estado

A família, os destinos e as duas soluções físicas estão definidos na matriz de
quests da issue #25. Os valores numéricos acima são o contrato recalibrado da
issue #26. O sketch ainda precisa migrar esse contrato para o fluxo visual.
