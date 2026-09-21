# MENU INIT

## Objetivo

Abrir a partida: apresentar o jogo e registrar quem é o técnico. É a primeira
tela do fluxo descrito em [[FLOW]].

## Elementos

| Elemento | Função |
| --- | --- |
| Título | "Last Horizon", sobre estrelas desenhadas pelo sketch |
| Subtítulo | uma linha da premissa: a Terra ficou para trás, Marte é o destino |
| Campo de nome | rótulo `Nome do seu personagem:`; o jogador digita o nome do técnico e vê um cursor intermitente |
| Botão "Iniciar (Enter)" | começa a vinheta; fica inativo enquanto o nome estiver vazio |
| Botão "Sair" | fecha o jogo |

## Regras

- Nome vazio: `Iniciar (Enter)` e a tecla `ENTER` permanecem bloqueados; a partida exige um nome.
- Limite de 12 caracteres, para caber na largura da tela.
- O fundo atual usa estrelas desenhadas pelo sketch.

## Regra de mensagens

O nome digitado para o técnico aparece nas transmissões da Terra e de Marte
([[MENU_VICTORY]], [[MENU_GAME_OVER]]).

## Referências

- [#11 Roteiro da vinheta, mensagens e textos do jogo](https://github.com/shelldonryan/gtd_example/issues/11)
- [#27 Corrigir desfechos, transmissões e parametrizar portas, escadas, NPCs e HUD](https://github.com/shelldonryan/gtd_example/issues/27)
