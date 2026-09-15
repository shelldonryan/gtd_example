# HUD

## Objetivo

O HUD apresenta recursos e a urgência que o jogador precisa acompanhar enquanto
atravessa a nave. Não há lista lateral de tarefas: a faixa compacta destaca o
problema com menor prazo, e o mapa reúne todos os problemas ativos por sala.

## Informações exibidas

| Elemento | Como aparece | Função |
| --- | --- | --- |
| Dia da viagem | cartão de texto | mostra o dia atual e o total de dias da viagem |
| A bordo | cartão de texto | quantos sobreviventes vivos; o técnico não entra na conta |
| Energia | ícone, número e barra | estoque que mantém o motor e o suporte de vida |
| Oxigênio | ícone, número e barra | tempo de sobrevivência possível no espaço |
| Água | ícone, número e barra | quantidade de água |
| Comida | ícone, número e barra | quantidade de comida armazenada |
| Peças | ícone e número | quantas peças podem ser usadas em reparos |
| Moral | ícone, número e barra | estado emocional dos sobreviventes |
| Problema urgente | faixa textual compacta | menor prazo, sala responsável e quantidade de outros problemas |

## Barras de recursos

Cada recurso de barra tem valor entre 0 e 100.

- **Verde:** recurso seguro, entre 60 e 100.
- **Amarelo:** recurso em atenção, entre 30 e 59.
- **Vermelho:** recurso crítico, entre 1 e 29.
- **Vazio:** recurso em zero e com risco de derrota.

As peças são uma contagem numérica, sem barra.

## Ícones

Os seis recursos usam **ícones de 16×16** na paleta do HUD — energia, oxigênio,
água, comida, peças e moral. O cartão do recurso passa a ser ícone + número
(+ barra), **sem rótulo de texto**: só DIA e A BORDO têm rótulo. Os ícones entram
no inventário de assets.

## Onde cada elemento fica

| Zona | Conteúdo |
| --- | --- |
| Topo | dia, quantos estão a bordo e os seis indicadores de recurso |
| Centro | sala 2D jogável usando toda a largura |
| Faixa de urgência | problema com menor prazo e quantidade dos demais |
| Rodapé | botão `MAPA` e orientação de controles |
| Sobreposição | mapa, diálogos, painéis técnicos, incidentes e resumo ao dormir |

O mapa abre pelo botão `MAPA`, mostra `VOCÊ ESTÁ AQUI` e marca todas as salas
afetadas. Fechá-lo retorna à mesma sala e posição.

## Controles de alto nível

### Mapa

O botão `MAPA` abre uma sobreposição consultável. Clicar num cômodo mostra
ocupante, sistemas e todos os problemas locais. Cada problema informa perda
diária, prazo restante e consequência da crise. O clique nunca transporta o
técnico.

### Diálogos e pontos

- Diálogos de NPC avançam com `ENTER` ou clique em `CONTINUAR (ENTER)`.
- Problemas já nascem ativos; não existe briefing nem confirmação de tarefa.
- Recursos comuns são pagos no ponto da intervenção. Coleta física fica
  reservada a componentes especiais.

Os botões de modais repetem o atalho no rótulo: `FECHAR (ESC)`, `VOLTAR (ESC)`,
`CONFIRMAR (ENTER)` e o botão de dormir. O botão de pausa é
`CONTINUAR (ESC)`.

### Encerrar o dia

Não existe botão persistente `Passar dia`. O técnico precisa chegar ao próprio
beliche no Dormitório e interagir. Antes de dormir, o resumo modal mostra:

1. consumo previsto dos recursos;
2. perdas e políticas persistentes;
3. problemas ativos, prazos e crises iminentes;
4. intervenção principal concluída ou ausente;
5. confirmação para dormir e opção de voltar.

Dormir processa recursos, moral, perdas, prazos, crises, vitória ou derrota e
abre o novo dia no Dormitório.

## Estados da interface

- **Salas de interior:** o Comando é o hub; Dormitório, Depósito e Máquinas
  ligam-se somente a ele.
- **Diálogo de NPC:** retrato sobre a cena e caixa inferior; bloqueia movimento e
  interação até avançar ou fechar.
- **Painel técnico:** usa a caixa inferior sem retrato para sistemas e resumo do
  fim do dia.
- **Coleta e conclusão:** exibem aviso breve sem interromper a exploração.
- **Mapa:** preserva sala e posição e reúne os problemas por cômodo.
- **Incidente:** modal técnico com duas contenções; bloqueia a exploração até a
  escolha, mas deixa o problema ativo para correção física.
- **Transmissão e desfecho:** permanecem modais.

## Avisos

Um recurso em vermelho (de 1 a 29) avisa por três canais ao mesmo tempo: a cor,
um **ícone de aviso** ao lado do número e a **borda do cartão piscando** (meio
segundo aceso, meio apagado). A cor sozinha deixa quem não a distingue sem
nenhuma pista.

Alertas críticos usam os cartões de recurso: cor, ícone de aviso e borda
piscando. A faixa de urgência mostra:

1. problema ativo com menor prazo;
2. prazo restante;
3. sala onde a intervenção deve ocorrer;
4. quantidade de outros problemas ativos.

Exemplo: `MOTOR DANIFICADO — 2 DIAS — MÁQUINAS | +2 PROBLEMAS`.

O mapa contém a comparação completa. A ficha da sala mostra, para cada problema,
a perda diária, o prazo e a consequência quando ele chegar a zero. Para dano no
casco, a ficha pertence ao cômodo que contém o local alcançável sorteado naquela
ocorrência. Valores e textos finais serão fixados no ticket de balanceamento.
