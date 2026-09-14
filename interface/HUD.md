# HUD

## Objetivo

O HUD apresenta apenas o que o jogador precisa acompanhar enquanto atravessa a
nave. O painel lateral `SISTEMA / TAREFA` foi removido: mapa e salas usam a
largura liberada. A tarefa ativa fica numa faixa textual compacta, e alertas
aparecem nos cartões de recurso ou como avisos temporários.

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
| Próxima ação | faixa textual compacta | tarefa ativa, ação concreta e cômodo de destino |

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
| Faixa de orientação | tarefa ativa e uma única próxima ação concreta |
| Rodapé | botão `MAPA` e orientação de controles |
| Sobreposição | mapa, diálogos, painéis técnicos, eventos e resumo do fim do dia |

O mapa abre pelo botão `MAPA`, mostra `VOCÊ ESTÁ AQUI` e permite consultar a
ficha de cada cômodo. Fechá-lo retorna à mesma sala e posição.

## Controles de alto nível

### Mapa

O botão `MAPA` abre uma sobreposição consultável. Clicar num cômodo mostra
ocupante, sistemas, alertas e, quando houver tarefa ativa, seu destino final. A
ficha não detalha as salas intermediárias da rota. O clique nunca transporta o
técnico.
### Diálogos e briefing

- Diálogos de NPC avançam com `ENTER` ou clique em `CONTINUAR (ENTER)`.
- O console de briefing confirma a tarefa selecionada com `ENTER`; `E` continua
  reservado à interação na sala.

Os botões de modais repetem o atalho no rótulo: `FECHAR (ESC)`, `VOLTAR (ESC)`,
`CONFIRMAR (ENTER)` e `ENCERRAR DIA (ENTER)`. O botão de pausa é
`CONTINUAR (ESC)`.

### Encerrar o dia

Não existe botão persistente `Passar dia`. O técnico precisa chegar ao próprio
beliche no Dormitório e interagir. Antes da confirmação, um resumo modal mostra:

1. consumo previsto dos recursos;
2. falhas e estados ativos;
3. tarefa concluída ou pendente;
4. `ENCERRAR DIA (ENTER)` e `VOLTAR (ESC)`.

Confirmar processa recursos, moral, vitória ou derrota e abre o novo dia no
Dormitório.

## Estados da interface

- **Salas de interior:** formam uma sequência conectada por portas e usam toda a
  largura disponível.
- **Diálogo de NPC:** retrato sobre a cena e caixa inferior; bloqueia movimento e
  interação até avançar ou fechar.
- **Painel técnico:** usa a caixa inferior sem retrato para briefing, sistemas e
  resumo do fim do dia.
- **Coleta e conclusão:** exibem aviso breve sem interromper a exploração.
- **Mapa:** sobreposição consultável que preserva sala e posição.
- **Evento:** modal técnico sem retrato sobre a sala, com título, situação e duas
  alternativas acompanhadas das consequências; bloqueia a exploração até a escolha.
- **Transmissão e desfecho:** permanecem modais.

## Avisos

Um recurso em vermelho (de 1 a 29) avisa por três canais ao mesmo tempo: a cor,
um **ícone de aviso** ao lado do número e a **borda do cartão piscando** (meio
segundo aceso, meio apagado). A cor sozinha deixa quem não a distingue sem
nenhuma pista.

Alertas críticos usam os cartões de recurso: cor, ícone de aviso e borda
piscando. Falhas e mudanças de estado aparecem como avisos temporários com uma
ação concreta, por exemplo `REPARAR MOTOR` ou `VÁ À SALA DE ENERGIA`.

A faixa de orientação não acumula histórico nem usa termos internos como
`passos livres` ou `ponto final`. Ela mostra somente:

1. nome da tarefa ativa;
2. próxima ação concreta;
3. cômodo onde a ação acontece;
4. custo e efeito, quando relevantes para a decisão.

Exemplo: `AUMENTAR POTÊNCIA — VÁ AO REATOR, SALA DE ENERGIA`.
