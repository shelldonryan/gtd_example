# Falhas de sistema

Eventos internos criam problemas persistentes na Sala de máquinas ou no
Comando. O cartão escolhe uma contenção imediata; nenhuma alternativa corrige a
causa. Os valores abaixo são a proposta **PROVISÓRIA** da issue #20.

## Falha no motor

Perda de 4 de energia por dia. `Reduzir rotação` custa 5 de energia e abre prazo
3; `Manter impulso` custa 2 de moral e abre prazo 2. A crise destrói o motor e
causa derrota. Reparar custa 2 peças com Sílvia viva ou 3 sem ela.

## Falha no suporte de vida

Perda de 4 de oxigênio por dia. `Usar redundância` custa 4 de energia e abre
prazo 4; `Recircular o ar` custa 3 de oxigênio e abre prazo 2. A crise perde 12
de oxigênio, põe uma pessoa em risco e reinicia em 3. Reparar custa 1 peça com
Sílvia viva ou 2 sem ela.

## Falha no sistema de energia

Perda de 3 de energia por dia. `Desligar circuitos` custa 4 de energia e abre
prazo 4; `Distribuir a sobrecarga` custa 4 de moral e abre prazo 2. A crise
perde 12 de energia, desliga o modo economia e reinicia em 3. Reparar exige o
fusível de potência e custa 1 peça com Sílvia viva ou 2 sem ela.

## Falha nas comunicações

Perda de 2 de moral por dia e suspensão das transmissões da Terra. `Manter
escuta` custa 3 de energia e abre prazo 4; `Desligar o transmissor` custa 3 de
moral e abre prazo 2. A crise perde 10 de moral e reinicia em 3. Reparar custa
1 peça com Vera viva ou 2 sem ela.

## Estado

Valores provisórios implementados em `prototype/balance-model.mjs`; aguardam
validação antes de migrar para o sketch. Os textos D-047 serão adaptados na
issue #21.
