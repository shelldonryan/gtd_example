# Ameaças do percurso

Eventos externos criam problemas persistentes na nave. O incidente apresenta
duas soluções físicas em formato de quest; o jogador escolhe uma, coleta o objeto
indicado e o entrega no destino.

## Chuva de meteoros

A nave atravessa uma região carregada e sofre dano no casco. O problema cobra
`-4 oxigênio por dia` e tem prazo inicial de 3 dias. Quando o prazo chega a zero,
a crise aplica `-12 oxigênio` e reinicia o prazo em 2 dias.

As duas soluções são quests físicas, ambas com o ponto de entrega sorteado uma
única vez:

| ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HUL-A | Sílvia | kit de vedação | `-1 peça` | console da rota (Comando) | ponto de casco sorteado | fechar a ruptura | `-4 oxigênio/dia; prazo 3; crise -12 oxigênio; prazo 2` |
| HUL-B | Sílvia | placa de blindagem | `-6 energia` | console da rota (Comando) | ponto de casco sorteado | sustentar a placa | `-4 oxigênio/dia; prazo 3; crise -12 oxigênio; prazo 2` |

O cartão informa responsável, objeto, custo, origem, destino, resultado e
`SE FALHAR: PROBLEMA ATIVO; -4 OXIGÊNIO/DIA; PRAZO 3; CRISE -12 OXIGÊNIO`.
O ponto de entrega é sorteado entre locais livres e alcançáveis dos quatro
cômodos e permanece associado ao local até que a solução seja concluída.

Como as duas origens ficam no Comando, o percurso até o dano usa no máximo dois
cômodos distintos. O kit de vedação aparece apenas na solução `HUL-A`; ele
nunca fica disponível para coleta livre.

## Estado

O dano no casco e as duas rotas de solução estão definidos na matriz de quests
da issue #25. Os valores numéricos acima são o contrato recalibrado da issue
#26. O sketch `last_horizon/` executa a coleta no console e a entrega no ponto
do casco sorteado, que permanece fixo durante as retomadas.
