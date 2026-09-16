# Ameaças do percurso

Eventos externos criam problemas persistentes na nave. O incidente apresenta
duas soluções físicas em formato de quest; o jogador escolhe uma, coleta o objeto
indicado e o entrega no destino.

## Chuva de meteoros

A nave atravessa uma região carregada e sofre dano no casco. A escolha usa duas
quests físicas, ambas com o ponto de entrega sorteado uma única vez:

| ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HUL-A | Sílvia | kit de vedação | peças | console da rota (Comando) | ponto de casco sorteado | fechar a ruptura | problema ativo; perda, prazo e crise do casco |
| HUL-B | Sílvia | placa de blindagem | energia | console da rota (Comando) | ponto de casco sorteado | sustentar a placa | problema ativo; perda, prazo e crise do casco |

O cartão informa responsável, objeto, custo, origem, destino, resultado e
`SE FALHAR: PROBLEMA ATIVO; PERDA, PRAZO E CRISE DO CASCO`. O ponto de entrega é
sorteado entre locais livres e alcançáveis dos quatro cômodos e permanece
associado ao local até que a solução seja concluída.

Como as duas origens ficam no Comando, o percurso até o dano usa no máximo dois
cômodos distintos. O kit de vedação aparece apenas na solução `HUL-A`; ele
nunca fica disponível para coleta livre. Os valores numéricos pertencem ao #26.

## Estado

O dano no casco e as duas rotas de solução estão definidos na matriz de quests
da issue #25. O ticket #26 ainda define os valores numéricos de custo, perda,
prazo e crise.
