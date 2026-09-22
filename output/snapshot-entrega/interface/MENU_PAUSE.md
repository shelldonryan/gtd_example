# MENU PAUSE

## Objetivo

Segurar a partida a qualquer momento sem perder o estado.

## Como se chega

ESC na tela da nave ou dentro de uma sala, conforme as camadas de input de
[[FLOW]]. O fundo escurece e a tela de trás continua visível.

## Elementos

| Elemento | Função |
| --- | --- |
| "Continuar" | volta para a tela onde estava (ESC também) |
| "Reiniciar partida" | recomeça do dia 1, com os estoques iniciais |
| "Sair para o menu inicial" | volta ao MENU INIT |

## Regras

- A pausa não consome tempo nem recursos.
- Se um evento estiver aberto, o cartão fecha e volta ao continuar.
- "Sair para o menu inicial" volta ao [[MENU_INIT]].

## Referências

- [#5 Fluxo de telas e navegação](https://github.com/shelldonryan/gtd_example/issues/5)
- [#18 Reestruturar navegação, tarefas e feedback após playtest](https://github.com/shelldonryan/gtd_example/issues/18)
