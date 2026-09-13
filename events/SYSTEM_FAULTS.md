# Falhas de sistema

Eventos internos da nave: equipamentos que quebram pelo uso e pela falta de
manutenção. O recurso em jogo aqui é a peça — sem peças, a falha escala.

Todo evento desta pasta precisa de pelo menos duas alternativas, cada uma
sacrificando um recurso diferente. Os valores ficam em `mechanics/ACTIONS.md`.

## Falha no motor

O motor perde rendimento no meio do percurso e a viagem fica em risco.

| Alternativa | O que se perde | O que se mantém |
| --- | --- | --- |
| Reparar com peças | 2 peças | motor operante, viagem no prazo |
| Seguir com o motor danificado | 1 dia de viagem e o risco de destruição em 3 dias | as peças, para o próximo problema |

A segunda alternativa é uma aposta: as peças podem ser necessárias em outro
cômodo, mas o motor danificado tem prazo. O jogador decide se paga agora ou se
guarda o recurso e convive com o atraso.
## Falha no suporte de vida

O suporte de vida perde estabilidade e passa a consumir mais oxigênio para
manter a nave habitável.

| Alternativa | O que se perde | O que se mantém |
| --- | --- | --- |
| Reparar com peças | 2 peças | suporte estável e consumo normal de oxigênio |
| Operar em emergência | 10 de energia na hora e 3 de oxigênio por dia até o reparo | as peças, para uma tarefa posterior |

O modo de emergência permanece ativo até a nova tarefa ser concluída. A tarefa
pode ser concluída no mesmo dia da resposta do evento; a resposta não consome a
ação.

**No cartão (D-047):** `FALHA NO SUPORTE DE VIDA` — `REPARAR (2 PEÇAS)` ou
`EMERGÊNCIA (ENERGIA -10)`; no painel `SISTEMA`, `REPARAR SUPORTE`.

## Falha no sistema de energia

A rede elétrica perde estabilidade e passa a operar em carga forçada.

| Alternativa | O que se perde | O que se mantém |
| --- | --- | --- |
| Forçar a rede | 10 de energia na hora | a moral do grupo |
| Desligar setores | moral | a energia para o suporte de vida |

As duas alternativas deixam a falha ativa: a energia continua sendo drenada
(+3 por dia) até Sílvia entregar uma das três variantes de reparo. Cada variante
só pode ser usada uma vez por partida.

**No cartão (D-047):** `FALHA NO SISTEMA DE ENERGIA` — `FORÇAR A REDE (ENERGIA
-10)` ou `DESLIGAR SETORES (MORAL -10)`; no painel `SISTEMA`, `REPARAR ENERGIA`.

## Falha nas comunicações

O transmissor perde o contato com a Terra e a nave viaja sem instruções externas.

| Alternativa | O que se perde | O que se mantém |
| --- | --- | --- |
| Reparar com peças | 1 peça | o contato com a Terra e as transmissões |
| Seguir sem comunicação | 1 de moral por dia e as transmissões da Terra suspensas | a peça, para outro sistema |

O silêncio permanece até a tarefa `Reparar comunicações` ser concluída, com
1 peça, na antena da Sala de comando.

**No cartão (D-047):** `FALHA NAS COMUNICAÇÕES` — `REPARAR (1 PEÇA)` ou
`SILÊNCIO (MORAL -1/DIA)`; no painel `SISTEMA`, `REPARAR COMUNICAÇÕES`.

## Pendências

- Nenhuma falha de sistema pendente nesta versão.
- Os cartões das falhas anteriores à D-047 (motor, meteoros, comida e conflito)
  seguem na versão provisória até a etapa de implementação dos textos do #11.
