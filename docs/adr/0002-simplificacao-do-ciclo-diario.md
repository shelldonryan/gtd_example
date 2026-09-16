# Simplificação do ciclo diário

**Status:** accepted

O ciclo anterior acumulava seis recursos, políticas persistentes, bônus numéricos de sobreviventes, componentes livres, um contador de intervenção e riscos individuais concorrentes. A decisão é manter os seis recursos e o consumo diário, mas usar uma única conclusão de quest por dia; remover economia e racionamento; remover bônus numéricos de Vera, Bento, Neusa e Sílvia; usar componentes somente como objetos de quest; manter problemas persistentes com perda, prazo e crise; e permitir no máximo uma pessoa em risco por vez, com uma quest simples de socorro. A morte reduz a tripulação sem recalcular custos. O objetivo é preservar pressão, objetos, navegação e consequências humanas, eliminando modificadores ocultos e limites duplicados.

## Considered Options

- **Manter todas as políticas e bônus:** rejeitada; criava decisões paralelas e regras invisíveis à triagem.
- **Remover também problemas, prazos e crises:** rejeitada; retirava a consequência que dá peso à escolha de solução.
- **Manter um contador separado de intervenção:** rejeitada; duplicava a regra de uma conclusão por dia.

## Consequences

A ordem preventiva, a solução urgente e o socorro compartilham a mesma unidade
diária. Os valores de recompensas, perdas, custos, prazos e crises estão
consolidados em `mechanics/ACTIONS.md`, simulados em
`prototype/balance-model.mjs` e executados no sketch `last_horizon/`.
Esta ADR registra a forma do sistema e as remoções que a simplificação exigiu.