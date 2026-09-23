# MENU GAME OVER

## Objetivo

Encerrar a partida informando **qual** falha acabou com a viagem.

## Condições

Oxigênio em zero, energia em zero, moral em zero, motor destruído ou nenhum
sobrevivente vivo; a lista de derrotas está em [[ACTIONS]].

## Elementos

| Elemento | Função |
| --- | --- |
| Motivo | o nome da falha que encerrou a viagem |
| Mensagem | uma linha fechando aquela falha |
| Resumo | dia alcançado, sobreviventes vivos e estado do motor |
| Botão "Nova partida" | volta ao [[MENU_INIT]] |

## Regras

- A tela de derrota é modal e informa a causa da viagem.
- A mensagem muda conforme a causa:

| Causa | Título | Mensagem |
| --- | --- | --- |
| Oxigênio em zero | OXIGÊNIO ZERO | `O OXIGÊNIO ACABOU ANTES DA CHEGADA.` |
| Energia em zero | ENERGIA ZERO | `SEM ENERGIA, A NAVE NÃO PÔDE SEGUIR.` |
| Moral em zero | MORAL ZERO | `A MORAL CAIU A ZERO. O GRUPO NÃO RESISTIU À VIAGEM.` |
| Motor destruído | MOTOR DESTRUÍDO | `O MOTOR FOI DESTRUÍDO ANTES DE MARTE.` |
| Nenhum sobrevivente vivo | SOBREVIVENTES PERDIDOS | `NENHUM SOBREVIVENTE RESTOU A BORDO.` |

## Referências

- [#11 Roteiro da vinheta, mensagens e textos do jogo](https://github.com/shelldonryan/gtd_example/issues/11)
- [#14 Decisões pendentes: roster, derrota, objetivos das salas e vocabulário](https://github.com/shelldonryan/gtd_example/issues/14)
- [#27 Corrigir desfechos, transmissões e parametrizar portas, escadas, NPCs e HUD](https://github.com/shelldonryan/gtd_example/issues/27)
