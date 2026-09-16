# Falhas de sistema

Falhas internas criam problemas persistentes na família de falhas técnicas. O
incidente apresenta duas soluções físicas em formato de quest; o jogador escolhe
uma, coleta o objeto indicado e o entrega no sistema correspondente.

## Tipos

| Incidente | Destino típico |
| --- | --- |
| Falha no motor | bancada do motor |
| Dano no casco | local alcançável sorteado |
| Falha no suporte de vida | painel de suporte |
| Falha no sistema de energia | painel de distribuição |
| Falha nas comunicações | antena |

Cada solução informa antes da escolha o objeto, o recurso cobrado, a origem, o
destino e o resultado. Os valores numéricos ficam no ticket de balanceamento:

| Incidente | ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Falha no motor | ENG-A | Sílvia | chave de torque | peças | console da rota (Comando) | bancada do motor (Máquinas) | alinhar o eixo do motor | problema ativo; perda, prazo e crise do motor |
| Falha no motor | ENG-B | Sílvia | atuador do motor | energia | console da rota (Comando) | bancada do motor (Máquinas) | estabilizar a rotação | problema ativo; perda, prazo e crise do motor |
| Falha no suporte de vida | LIFE-A | Sílvia | cartucho de oxigênio | peças | console da rota (Comando) | painel de suporte de vida (Máquinas) | repor o cartucho | problema ativo; perda, prazo e crise do suporte |
| Falha no suporte de vida | LIFE-B | Sílvia | filtro de CO2 | energia | console da rota (Comando) | painel de suporte de vida (Máquinas) | recircular o ar | problema ativo; perda, prazo e crise do suporte |
| Falha no sistema de energia | PWR-A | Sílvia | fusível de potência | peças | console da rota (Comando) | painel de distribuição (Máquinas) | isolar o circuito | problema ativo; perda, prazo e crise da energia |
| Falha no sistema de energia | PWR-B | Sílvia | módulo de relé | moral | console da rota (Comando) | painel de distribuição (Máquinas) | redistribuir a carga | problema ativo; perda, prazo e crise da energia |
| Falha nas comunicações | COM-A | Vera | bobina de transmissão | peças | console da rota (Comando) | antena (Comando) | restabelecer o contato | problema ativo; perda, prazo e crise das comunicações |
| Falha nas comunicações | COM-B | Vera | célula de sinal | energia | console da rota (Comando) | antena (Comando) | manter a escuta | problema ativo; perda, prazo e crise das comunicações |

O dano no casco usa `HUL-A` (kit de vedação, custo em peças) ou `HUL-B`
(placa de blindagem, custo em energia). Em ambos, a origem é o console da rota
no Comando e o destino é o ponto de casco sorteado quando o problema nasce.
Assim, a rota usa no máximo o Comando e o cômodo afetado.

Se a solução não for concluída antes de dormir, o problema permanece ativo,
cobra sua perda diária, reduz o prazo e pode chegar à crise. A crise pode
colocar uma pessoa em risco; apenas uma pessoa pode permanecer em risco por vez.


## Estado

A família, os destinos e as duas soluções físicas estão definidos na matriz de
quests da issue #25. O ticket de balanceamento #26 ainda define os valores
numéricos de custo, perda, prazo e crise antes da migração do sketch.
