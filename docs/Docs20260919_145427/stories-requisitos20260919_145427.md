# User stories e requisitos da feature

## 1. Contexto e objetivo

Esta documentação transforma `discovery20260919_145427.md` e
`SPEC_ENXUGAMENTO_E_IMERSAO.md` em stories e requisitos implementáveis para o
projeto existente Last Horizon.

A feature deve implementar o enxugamento técnico, a questline editorial, as
falas contextuais, a informação progressiva da interface e o mapa orientado ao
próximo deslocamento. O ciclo mecânico continua sendo o mesmo: viagem de dez
dias, quatro salas, quatro sobreviventes, seis recursos, cinco incidentes
sorteados entre sete tipos, oito preventivas, quatorze soluções, uma conclusão
por dia, coleta e entrega físicas, retomada de soluções, socorro e desfechos
existentes.

O resultado deve tornar o próximo passo compreensível durante a exploração,
permitir comparar benefício, custo e consequência antes de um compromisso,
reduzir repetições visuais e editoriais e manter a exploração física da nave.

### 1.1 Limites da feature

Fazem parte desta entrega:

- T01 a T10 da SPEC, com equivalência observável antes das mudanças de
  apresentação.
- E0 a E6 da ordem de implementação proposta.
- Catálogo editorial ligado aos IDs mecânicos atuais.
- Memória contextual mínima para as falas dos quatro sobreviventes.
- HUD de duas linhas prioritárias, painéis progressivos, previsão noturna
  verificável e mapa de orientação.
- Validação visual, medição de desempenho, regressão do ciclo e playtest de
  clareza e diversão.

Não fazem parte desta entrega:

- Alterar custos, recompensas, dificuldade, duração, sorteio, quantidade de
  quests, rotas físicas ou condições de término.
- Adicionar salas, combate, crafting, inventário livre, romance, reputação,
  árvores de diálogo, minijogos, dublagem ou cutscenes obrigatórias.
- Adicionar engine, framework, biblioteca de UI, classes de entidades,
  backend, banco de dados, autenticação ou dependências de aplicação.
- Remover o fallback geométrico, a compatibilidade Aseprite e LPC, o harness
  de verificação ou o modelo numérico independente.
- Publicar build, fazer push ou alterar o balanceamento.

### 1.2 Baseline técnico observado

| Área | Evidência no código | Implicação para a feature |
| --- | --- | --- |
| Estado e ciclo | `last_horizon/last_horizon.pde` mantém estado global, constantes, input, viewport e ciclo `draw`/`update`; `game.pde` processa noite e desfechos | A implementação deve manter globais agrupadas, atualização separada do desenho e a ordem do processamento noturno |
| Catálogo mecânico | `last_horizon/tasks.pde` mantém IDs, títulos mecânicos, objetos, responsáveis, pontos, recursos, custos, estado da quest e ações de interação | O catálogo editorial deve se ligar aos mesmos 22 IDs sem substituir os dados mecânicos |
| Interface comum | `last_horizon/ui.pde` já possui `drawShadowText`, `drawModalFooter`, `drawButton`, `findButton` e `uiLayer` | T01, T06 e T08 devem consolidar e completar essas costuras, com uma única geometria para desenho, hit-test e camada ativa |
| HUD | `last_horizon/hud.pde` já declara `HUD_RESOURCE_ORDER`, cache de ícones, faixa de objetivo, alerta e rodapé | T04 e T07 devem garantir cache preparado na carga, mapeamento explícito e prioridade correta sem mover regras de recurso para o índice do ícone |
| Mapa | `last_horizon/navigation.pde` já possui `calculateMapRoute`, busca por salas, `mapTargetPoint` e `findNextMapLadder`; `ship.pde` desenha o overlay e o detalhe dos conveses | E5 deve completar a orientação por porta, convés, escada, alvo e estado real sem criar teleporte ou pathfinding contínuo |
| Salas e portais | `last_horizon/ship.pde` possui tabelas de portas e escadas, `startDoorTransition`, `enterRoomThroughDoor`, fallback geométrico e animação de porta | T03 deve preparar a travessia uma vez e preservar chegada, retorno, som, animação e gravidade |
| NPCs e assets | `last_horizon/assets.pde` carrega Aseprite/LPC, espelha frames, prepara halos e oferece fallback; `ship.pde` usa `drawNpc` | T02 deve resolver identidade, direção, sprite e halo em uma seleção compartilhada |
| Editorial | `last_horizon/editorial.pde` já separa títulos, motivações, vozes, variantes de ambientação e memória mínima | E4 deve completar a cobertura de contextos e impedir que desenho ou abertura de painel registre memória |
| Modo de teste | `last_horizon/test_mode.pde` intercepta Ctrl + K, teleporta, força visual e desenha overlay; `capture.pde` instala hooks no sketch | T10 deve manter a costura opcional e produzir runtime compilável sem o modo manual e sem o harness |
| Referência numérica | `prototype/balance-model.mjs` é um modelo JavaScript ESM independente, sem `package.json` ou dependências de aplicação | A implementação deve continuar sendo comparada com o modelo, sem compartilhar o algoritmo do sketch |

### 1.3 Contratos preservados

Os requisitos abaixo assumem os contratos documentados em
`mechanics/ACTIONS.md`, `interface/FLOW.md`, `interface/HUD.md`,
`interface/ROOMS.md`, `docs/adr/0001-ordens-e-incidentes-como-quests.md`,
`docs/adr/0002-simplificacao-do-ciclo-diario.md` e
`code/SKETCH_ARCHITECTURE.md`.

- A viagem dura dez dias e os incidentes ocorrem nos dias 2, 4, 6, 8 e 10.
- Os sete tipos de incidente continuam sendo embaralhados sem reposição, com
  cinco tipos escolhidos por partida.
- Os recursos iniciais, consumo, custos, recompensas, perdas, prazos, crises,
  limite diário, risco individual e condições de término não mudam.
- O Comando continua sendo o hub e o mapa continua consultivo.
- `E` abre a interação, `ENTER` confirma e `ESC` fecha, volta ou pausa conforme
  a camada ativa.
- Um objeto de quest continua sendo carregado por vez e nunca há coleta livre.
- A ausência de asset ou som continua usando fallback funcional ou silêncio.
- O modelo numérico continua independente do algoritmo Processing.

## 2. User stories

As stories estão agrupadas por domínio. Cada critério de aceite descreve um
resultado observável no sketch, nos artefatos de verificação ou no playtest.

### 2.1 Objetivo, escolhas e ciclo da quest

#### US-01: reconhecer o objetivo da viagem

Como jogador iniciante, quero entender que preciso chegar a Marte com o motor
operante e pelo menos um sobrevivente vivo, para reconhecer o objetivo da
viagem antes de começar a explorar.

Critérios de aceite:

1. A vinheta inicial informa dez dias de viagem, Marte como destino, motor
   operante e a condição mínima de sobreviventes.
2. A informação aparece antes da primeira exploração e não exige abrir Ordens,
   Mapa ou Ajuda.
3. A tela não apresenta uma regra mecânica nova nem altera o estado da partida.
4. Os controles existentes para avançar a vinheta continuam sendo clique e
   `ENTER`.

Referências: `last_horizon/screens.pde`, `last_horizon/game.pde`,
`interface/MENU_INIT.md` e `interface/FLOW.md`.

#### US-02: comparar preventivas

Como jogador, quero comparar duas necessidades reais da tripulação, para sentir
que minha escolha importa antes de aceitar uma ordem.

Critérios de aceite:

1. Em dia sem incidente, o painel exibe as duas ofertas disponíveis em cartões
   lado a lado.
2. Cada cartão apresenta título em caixa de frase, responsável, motivação curta,
   benefício exato, objeto, origem, destino e perda se aceita e incompleta.
3. A negligência das duas ofertas aparece em uma informação comum, com os
   recursos e números corretos.
4. O ID técnico, como `V-01`, não aparece na interface comum.
5. Trocar a seleção antes da confirmação não altera recursos, objeto,
   responsável, prazo ou estado da partida.

Referências: `last_horizon/tasks.pde`, `last_horizon/editorial.pde`,
`last_horizon/screens.pde` e `mechanics/ACTIONS.md`.

#### US-03: distinguir seleção de aceite presencial

Como jogador, quero saber que selecionar uma preventiva ainda exige falar com o
responsável, para não confundir seleção com aceite.

Critérios de aceite:

1. Escolher um cartão apenas grava uma seleção pendente e informa o NPC e a sala
   onde a confirmação deve ocorrer.
2. O jogador consegue abrir Ordens novamente e trocar a seleção enquanto ela não
   foi confirmada.
3. A aproximação de um NPC que não é o responsável não aceita a ordem e informa
   quem deve ser procurado.
4. A confirmação distante é recusada por `acceptPreventive()` e não altera
   `active_quest`, `held_item` ou recursos.
5. O aceite presencial informa que a ordem não pode ser cancelada.

Referências: `last_horizon/tasks.pde`, funções `choosePreventive`,
`acceptPreventive`, `interactNpc` e `pointIsAvailable`.

#### US-04: receber o objeto e cumprir a rota física

Como jogador, quero coletar e entregar o objeto com instruções curtas, para agir
na nave sem reler um formulário a cada etapa.

Critérios de aceite:

1. Depois do aceite, o HUD e o Mapa mostram somente o próximo verbo e o local
   necessário para a etapa atual.
2. Nas ordens cuja origem coincide com o responsável, como `V-02` e `N-02`, o
   aceite coloca o objeto em `held_item` e abre diretamente a etapa de entrega.
3. Nas demais ordens, a coleta só é possível no ponto de origem e a entrega só é
   possível no ponto de destino.
4. A coleta mantém o objeto visível ou consultável e atualiza o próximo objetivo
   para a entrega.
5. A entrega concluída fecha a interação e atualiza o objetivo para o beliche,
   sem abrir um modal de sucesso obrigatório.
6. Nenhuma confirmação adicional é introduzida entre a coleta e a entrega.

Referências: `last_horizon/tasks.pde`, funções `collectQuestObject`,
`deliverQuest`, `openQuestStepPanel` e `applyQuestAction`, além de
`last_horizon/hud.pde` e `last_horizon/navigation.pde`.

#### US-05: entender custo e falta de recurso

Como jogador, quero confirmar o custo real antes de entregar uma solução, para
não gastar recursos por engano nem ficar sem entender um bloqueio.

Critérios de aceite:

1. A comparação de soluções urgentes mostra custo, objeto, origem, destino e
   resultado de cada alternativa.
2. Escolher uma solução continua possível mesmo quando o recurso necessário
   ainda não está disponível.
3. Na entrega, o painel mostra o custo e o valor disponível, por exemplo
   `Falta 1 peça. Você tem 1 de 2`.
4. Sem recurso suficiente, o botão de entrega fica indisponível ou a ação é
   recusada, o objeto permanece carregado e o recurso não é debitado.
5. Com recurso suficiente, o custo é pago uma única vez e o problema correto é
   resolvido.

Referências: `last_horizon/tasks.pde`, funções `pendingQuestEnabled`,
`pendingQuestReason` e `deliverQuest`, e `last_horizon/ui.pde`.

#### US-06: manter uma conclusão diária e retomar pendências

Como jogador, quero entender o que pode ser feito hoje e o que ficou pendente,
para avaliar o risco sem reiniciar prazos por engano.

Critérios de aceite:

1. O jogo permite no máximo uma quest concluída por dia, incluindo socorro e
   retomada.
2. Uma solução urgente incompleta mantém o problema, a perda diária, o prazo e
   a crise normais, sem multa adicional.
3. A mesma solução escolhida aparece em `Pendências (N)` em dias sem incidente,
   com o prazo atual visível.
4. Retomar uma solução exige confirmação, preserva o prazo já decorrido e não
   troca o custo ou a consequência exibidos.
5. Em um dia com incidente novo, o cartão novo tem prioridade; a retomada volta
   a aparecer no próximo dia sem incidente.
6. Fechar um painel de retomada não cancela a ordem nem limpa a pendência.

Referências: `last_horizon/tasks.pde`, variáveis `problem_deadline`,
`problem_solution`, `active_quest`, `quest_completed`, `orders_page` e
`last_horizon/game.pde`.

#### US-07: decidir sobre socorro

Como jogador, quero saber o custo e o impacto diário do socorro, para escolher
entre estabilizar uma pessoa e manter outra conclusão do dia.

Critérios de aceite:

1. Quando houver uma pessoa em risco, o painel do beliche de socorro informa
   pessoa, prazo, custo de 8 água e 2 comida e uso da conclusão diária.
2. Sem risco, o ponto de socorro permanece fechado e não abre o painel nem uma
   ação de resgate.
3. Se houver risco e a conclusão diária já tiver sido escolhida, o painel
   permanece consultável e exibe pessoa, prazo, custo, limite de conclusão
   diária e motivo do bloqueio; o botão de socorro fica desabilitado.
4. Em dia preventivo, socorrer a pessoa não remove a perda de negligência das
   ofertas não aceitas.
5. Com recursos suficientes, o socorro debita os dois custos, remove o risco,
   registra o resultado editorial e marca a conclusão diária.
6. Sem recursos suficientes, nenhum recurso ou prazo é alterado.

Referências: `last_horizon/tasks.pde`, funções `openRescuePanel` e
`rescueUrgentSurvivor`, `last_horizon/game.pde` e `events/CREW_ISSUES.md`.

#### US-08: prever a noite antes de dormir

Como jogador, quero prever os efeitos de dormir, para assumir conscientemente
perdas, crises e possíveis fatalidades.

Critérios de aceite:

1. O painel de sono apresenta o título `Encerrar o dia?` e uma tabela compacta
   com recurso, variação e valor previsto.
2. A previsão considera, na mesma ordem do processamento real, falha ou
   negligência da preventiva, consumo, perdas dos problemas, risco, prazos,
   crises, limite dos recursos e término.
3. Peças aparecem como contagem inteira e não como porcentagem ou barra.
4. Morte prevista, motor destruído e energia, oxigênio ou moral em zero aparecem
   no resumo principal do painel, sem ficarem escondidos em detalhes.
5. Abrir, fechar ou recalcular a previsão não altera estado, recursos, RNG,
   prazo, sorteio ou memória editorial.
6. A previsão de um estado reproduz o resultado observável de uma noite real
   iniciada no mesmo estado.

Referências: `last_horizon/ui.pde`, função `drawEndDayPanel`,
`last_horizon/game.pde`, funções `processNight`,
`processProblemDeadlines`, `checkEndConditions` e `nightFatalWarning`.

### 2.2 Voz, memória e continuidade dos NPCs

#### US-09: reconhecer quatro vozes distintas

Como jogador, quero que Vera, Bento, Neusa e Sílvia falem de formas diferentes,
para lembrar quem são enquanto cuido da nave.

Critérios de aceite:

1. Vera usa frases pragmáticas e orientadas à viagem.
2. Bento fala como responsável pelo estoque, com tom protetor e resmungão sem
   hostilidade.
3. Neusa fala de modo cansado, cuidadoso e atento às pessoas.
4. Sílvia usa frases diretas e concretas, focadas no sistema.
5. Cada texto-base tem uma ou duas frases, até 160 caracteres, com acentos e
   caixa de frase.
6. O resultado mecânico aparece separado da fala narrativa e nenhum diálogo
   concede recurso, cancela problema ou cria objetivo adicional.

Referências: `last_horizon/editorial.pde`, `characters/npcs/NPC_1.md` a
`NPC_4.md`, `history/CONTEXT.md` e `SPEC_ENXUGAMENTO_E_IMERSAO.md`.

#### US-10: reconhecer ajuda, falha, omissão e risco

Como jogador, quero que cada NPC reconheça o que realmente aconteceu, para
sentir continuidade entre os dias sem ouvir uma narração falsa.

Critérios de aceite:

1. O sistema registra apenas o último resultado editorial de ajuda, falha,
   omissão, socorro ou risco depois da transição mecânica real.
2. Quando houver mais de um resultado no mesmo período, a prioridade é socorro,
   ajuda, falha e omissão, nessa ordem.
3. A fala de reconhecimento aparece no máximo uma vez para o NPC no contexto
   correspondente e não é registrada pelo `draw`.
4. Uma fala nunca afirma que um incidente ocorreu se ele não estiver registrado
   no estado da partida.
5. NPC morto não abre diálogo nem aparece como interlocutor válido.
6. Ao iniciar nova partida, a memória editorial é zerada.

Referências: `last_horizon/editorial.pde`, funções `recordEditorialResult`,
`recordEditorialRisk`, `editorialRecognition`, `resetEditorialMemory`,
`last_horizon/tasks.pde` e `last_horizon/game.pde`.

#### US-11: conversar opcionalmente sem criar obrigação

Como jogador, quero conversar com os sobreviventes no meu ritmo, para conhecer a
tripulação sem receber novas tarefas obrigatórias.

Critérios de aceite:

1. NPCs vivos podem responder a `E` conforme o estado do dia, mesmo quando não
   são o responsável pela ordem atual.
2. O responsável prioriza confirmação pendente, etapa da ordem, risco próprio,
   reconhecimento recente, oferta, problema urgente e ambientação da viagem.
3. Um NPC que não é o responsável lembra o próximo passo em uma frase curta e
   não repete a quest inteira.
4. Cada NPC possui duas variantes determinísticas de ambientação para cada fase
   dos dias 1 a 3, 4 a 7 e 8 a 10.
5. Conversar não altera recurso, prazo, RNG, ordem, risco, objetivo ou limite
   diário.

Referências: `last_horizon/editorial.pde`, função `editorialContextLine`,
`last_horizon/tasks.pde`, função `interactNpc`, e `characters/npcs/`.

### 2.3 HUD, painéis e legibilidade

#### US-12: identificar o próximo passo durante a exploração

Como jogador, quero ver uma ação concreta e o alerta mais importante, para
explorar sem abrir detalhes repetidamente.

Critérios de aceite:

1. A faixa inferior mostra duas linhas prioritárias na área existente: objetivo
   acionável e alerta ou resultado contextual.
2. O objetivo usa os estados reais: escolher ordem, falar com responsável,
   pegar objeto, levar objeto ou voltar ao beliche.
3. Com um objeto em mãos, a linha usa o verbo `Leve` e o destino atual, sem
   repetir permanentemente origem, responsável ou o rótulo `Na mão` quando não
   forem necessários para a próxima ação.
4. Se houver risco fatal nesta noite, ele ocupa a segunda linha antes de alertas
   não fatais.
5. Os demais problemas continuam consultáveis por Ordens ou Mapa, mesmo quando o
   HUD mostra apenas o mais urgente e a indicação `+N problemas`.

Referências: `last_horizon/hud.pde`, funções `currentObjectiveLine`,
`currentAlertLine`, `alertLineColour`, `last_horizon/tasks.pde` e
`last_horizon/navigation.pde`.

#### US-13: consultar detalhes progressivamente

Como jogador, quero receber primeiro a informação necessária para decidir e
consultar o restante no mesmo painel, para entender a situação sem excesso de
texto.

Critérios de aceite:

1. O cartão de comparação mostra título, motivação curta, benefício ou custo,
   objeto, rota e consequência principal sem exigir expansão.
2. A área de detalhes usa expansão ou paginação no mesmo painel e mantém
   controles visíveis.
3. Os dados mecânicos necessários para decidir nunca ficam escondidos em tooltip,
   cor ou expansão opcional.
4. Em incidentes, perda diária, prazo e crise aparecem como resumo comum; cada
   solução mostra apenas seu custo, objeto, rota e resultado.
5. A apresentação não reduz o texto abaixo do limite de leitura para fazer o
   conteúdo caber e não sobrepõe o rodapé.

Referências: `last_horizon/tasks.pde`, funções `drawQuestCard`,
`drawOrdersPanel`, `questDetails` e `questFailure`, e
`mechanics/ACTIONS.md`.

#### US-14: usar interações contextuais curtas

Como jogador, quero que coleta, entrega e bloqueios mostrem somente o contexto
relevante, para continuar jogando com confiança.

Critérios de aceite:

1. O painel de coleta informa objeto, verbo `Pegar`, destino seguinte e o fato de
   que o objeto fica com o técnico até a entrega.
2. O painel de entrega informa resultado e custo exato antes da confirmação.
3. O painel técnico usa uma faixa inferior compacta na área disponível e não
   escurece a cena inteira para uma coleta simples.
4. `Agora não (ESC)` aparece antes de aceitar, coletar ou entregar; `Voltar
   (ESC)` aparece na revisão; `Fechar (ESC)` aparece em consulta.
5. Um sucesso fecha a interação e atualiza objetivo e feedback, sem abrir outro
   modal obrigatório.
6. Mensagens de erro explicam a causa real e a ação revalida proximidade,
   disponibilidade e custo no momento da confirmação.

Referências: `last_horizon/tasks.pde`, funções `openQuestStepPanel`,
`applyQuestAction`, `pendingQuestReason`, `last_horizon/ui.pde` e
`last_horizon/screens.pde`.

#### US-15: manter modais e controles consistentes

Como jogador, quero fechar ou voltar de um painel sem cancelar minha ordem, para
usar teclado e mouse sem medo de perder estado.

Critérios de aceite:

1. A camada efetivamente ativa tem prioridade explícita: pausa, transmissão,
   incidente, ordens, mapa, diálogo, técnico, sono, ajuda e cena.
2. Uma transmissão pode cobrir o incidente; ao fechá-la, o incidente reaparece.
3. `ESC` na comparação de solução obrigatória pausa; `ESC` na revisão volta à
   comparação.
4. Fechar Mapa, Ordens, diálogo, técnico, sono ou Ajuda não cancela uma ordem
   aceita e só limpa ações pendentes nos caminhos correspondentes.
5. `ENTER`, clique, cursor e hit-test consultam a mesma camada e nenhum clique
   alcança um painel encoberto.
6. Pausar e retomar preserva sala, posição, objetivo, objeto e estado mecânico.

Referências: `last_horizon/screens.pde`, funções `modalOpen`, `uiLayer`,
`drawModalLayer`, `closeTopModal`, `doAction`,
`last_horizon/ui.pde` e `last_horizon/last_horizon.pde`.

#### US-16: ler a interface em 720p

Como jogador, quero ler textos e números em 720p sem sobreposição, para jogar
confortavelmente durante a viagem.

Critérios de aceite:

1. O render continua em 1280 por 720, com grade lógica 640 por 360, ampliação
   inteira e letterbox.
2. O corpo de texto usa 16 px reais e entrelinha de 18 px; prompts contextuais
   de 11 px permanecem exceções controladas.
3. Maiúsculas ficam restritas a rótulos curtos e não são usadas em parágrafos
   narrativos.
4. Nenhum significado depende apenas de cor; valores, rótulos, verbos e estado
   habilitado também estão presentes.
5. Textos longos, acentos, retratos, custo, botões e destino permanecem dentro
   da área útil em 720p e em janela ampliada.

Referências: `last_horizon/last_horizon.pde`, `last_horizon/ui.pde`,
`interface/TEXT_FONTS.md` e `code/SKETCH_ARCHITECTURE.md`.

### 2.4 Mapa e orientação espacial

#### US-17: planejar o próximo deslocamento pelo mapa

Como jogador, quero abrir o mapa e saber onde estou, para onde vou e qual é a
próxima passagem, para memorizar rotas sem teleporte.

Critérios de aceite:

1. O mapa mostra Comando como hub e desenha somente as conexões derivadas das
   tabelas de portais configuradas.
2. O esquema identifica `Você`, o objetivo atual, o verbo da ação e a sala
   atual, mesmo quando os marcadores compartilham uma sala.
3. O caminho destacado usa a rota de menor número de travessias e desempate
   estável pela ordem da tabela.
4. O detalhe da sala mostra três conveses, posição do técnico, portas, escadas
   com trechos reais e o ponto de objetivo quando ele está na sala.
5. Quando o objetivo está em outra sala, o mapa indica a próxima porta e o
   convés ou a altura real. Quando está na mesma sala em outro convés, indica a
   escada correta e seu lado relativo.
6. Portas sem convés exibem abertura fora do convés e não recebem um convés
   inventado.
7. O mapa mantém alvo e rota gerais quando o jogador consulta outra sala.
8. Fechar o mapa restaura exatamente sala, posição, direção e estado mecânico;
   abrir ou consultar o mapa não avança tempo, quest, recursos, RNG ou sorteio.
9. Em um percurso Depósito para Dormitório via Comando e em um percurso entre
   conveses, pelo menos 2 de 3 participantes identificam a próxima passagem em
   até 10 segundos sem explicação externa.

Referências: `last_horizon/navigation.pde`, `last_horizon/ship.pde`, funções
`drawMapOverlay`, `drawMapRoomDetails`, `drawMapDeckPlan`,
`calculateMapRoute` e `findNextMapLadder`, além de `interface/ROOMS.md`.

#### US-18: consultar problemas sem perder a rota

Como jogador, quero consultar alertas, socorro e outras salas sem perder minha
rota ativa, para explorar com autonomia.

Critérios de aceite:

1. Problemas aparecem em resumo secundário `Alertas (N)` com expansão ou
   paginação no próprio painel.
2. O risco fatal permanece visível, mas não troca o alvo de navegação
   silenciosamente.
3. `Minha sala` e `Destino` mudam somente o detalhe consultado, não movem o
   técnico nem alteram a ordem.
4. Sem ordem ativa, o mapa informa que não existe rota automática e permite
   consultar o beliche ou o socorro como consulta opcional.
5. Uma retomada ainda não confirmada não apresenta coleta como liberada.
6. Alvo inválido ou ausente mostra `Local indisponível` e não cria rota fictícia.

Referências: `last_horizon/navigation.pde`, `last_horizon/ship.pde`,
`last_horizon/hud.pde` e `last_horizon/tasks.pde`.

### 2.5 Qualidade técnica e manutenção

#### US-19: reutilizar tipografia e rodapé de modais

Como desenvolvedor, quero uma fonte comum para sombras, alinhamentos e botões,
para corrigir um padrão sem corrigir várias cópias.

Critérios de aceite:

1. Os wrappers de texto centralizado, prompt e alinhamento à esquerda delegam ao
   núcleo comum de contorno sem alterar os cinco deslocamentos atuais.
2. Nomes longos, acentos, prompts de 11 px, limites de sala e fallback mantêm a
   aparência equivalente na etapa de refatoração.
3. O rodapé comum aceita botão único ou par de botões, com secundário à esquerda,
   principal à direita, oito unidades lógicas de espaçamento e altura atual de
   20.
4. A largura é calculada pelo rótulo e padding, limitada à área do painel, sem
   truncar verbo ou atalho.
5. A mesma geometria registrada pelo helper é usada pelo hit-test.

Referências: `last_horizon/ui.pde`, funções `drawShadowText`,
`textCenteredShadow`, `textPromptShadow`, `modalButtonWidth`,
`drawModalFooter`, `drawButton` e `findButton`.

#### US-20: manter seleção única de arte de NPC

Como desenvolvedor, quero resolver identidade, direção, sprite e halo de cada
NPC por uma seleção compartilhada, para que orientação e fallback não divirjam.

Critérios de aceite:

1. O desenho de um NPC resolve sua identidade uma vez e reutiliza o resultado
   para sprite, halo cyan e halo laranja.
2. A prioridade de orientação esquerda, direita e frontal permanece igual à
   atual, inclusive para Aseprite espelhado e LPC direcional.
3. A ausência de halo não remove nem altera o sprite principal.
4. O comportamento permanece correto no mesmo convés, no ar, na escada, em
   outros conveses, com NPC morto, sprite ausente ou halo parcial.

Referências: `last_horizon/assets.pde`, funções `loadNpcArtFrames`,
`crewArtFramesFacing`, `crewArtGlowFramesFacing`,
`crewArtOrangeGlowFramesFacing`, e `last_horizon/ship.pde`, função `drawNpc`.

#### US-21: preparar uma vez a travessia de portal

Como desenvolvedor, quero preparar dados de saída, chegada e retorno uma única
vez, para preservar transições com e sem animação.

Critérios de aceite:

1. A travessia calcula sala destino, posição de chegada, direção e porta de
   retorno antes de escolher execução animada ou instantânea.
2. A posição de saída é salva antes da troca de sala.
3. O retorno imediato reaproveita `x` e `y` salvos; outros caminhos usam a
   chegada configurada na tabela da porta.
4. Arte completa, parcial ou ausente preserva destino, gravidade, som único e
   fases de abertura e fechamento.
5. Uma porta em `x` e `y` arbitrários, uma abertura sem deck e uma porta fora de
   um piso continuam sendo testáveis.

Referências: `last_horizon/ship.pde`, tabelas `door_*`, funções
`startDoorTransition`, `updateDoorTransition`, `enterRoomThroughDoor`,
`enterRoomAtPosition` e `doorInRange`.

#### US-22: eliminar preparação visual por quadro

Como desenvolvedor, quero preparar ícones e faixas estáticas uma vez, para
reduzir trabalho repetido sem mudar o visual.

Critérios de aceite:

1. Os seis ícones de recursos são preparados na carga ou em recarga explícita.
2. O desenho normal compõe a imagem pronta e não recria um buffer por ícone e
   por quadro.
3. O cache mantém tamanho, alinhamento, transparência, fallback geométrico e
   alerta crítico dinâmico.
4. O número, a barra, a cor de estado e a piscada não entram no cache do ícone.
5. Pisos que usam o mesmo tile compartilham uma faixa imutável e não são
   construídos três vezes.
6. Fixtures que trocam a imagem-fonte invalidam somente o cache afetado.

Referências: `last_horizon/hud.pde`, funções `ensureResourceIconCache` e
`prepareResourceIconCache`, `last_horizon/assets.pde`, funções
`prepareDeckStrips` e `floorArtForDeck`, e `last_horizon/ship.pde`, função
`drawDecks`.

#### US-23: manter o HUD guiado por mapeamento explícito

Como desenvolvedor, quero uma sequência explícita de recursos, para evitar que
ícone, valor, rótulo e cor se desalinhem.

Critérios de aceite:

1. A ordem visual é energia, oxigênio, água, comida, peças e moral.
2. Cada entrada associa explicitamente recurso, ícone, rótulo, valor, cor e
   preenchimento.
3. Peças permanecem inteiras, sem barra e sem alerta percentual.
4. Moral e peças são verificadas em cenários de valor baixo, alto e limite.
5. O estado global de recursos não é convertido em arrays somente para encurtar
   o loop.

Referências: `last_horizon/hud.pde`, `HUD_RESOURCE_ORDER`,
`hudResourceValue`, `hudResourceAccent`, `hudResourceFill`,
`last_horizon/last_horizon.pde` e `mechanics/ACTIONS.md`.

#### US-24: resolver modal ativo em uma fonte comum

Como desenvolvedor, quero uma fonte única para prioridade de modal, desenho e
input, para impedir que confirmação ou clique atravesse uma camada escondida.

Critérios de aceite:

1. Um resolvedor sem efeitos colaterais retorna a camada ativa pela prioridade
   definida na SPEC.
2. `drawModalLayer`, `handleEnter`, `handleEscape`, `findButton`, cursor e
   clique consultam o mesmo resultado.
3. O resolvedor não substitui inicialmente os flags existentes por uma pilha
   genérica.
4. A matriz transmissão, incidente, revisão, comparação, diálogo, técnico,
   sono, mapa, ajuda e pausa é verificada com teclado e mouse.
5. Divergência de comportamento atual é registrada como correção de UI e não
   escondida em uma refatoração estrutural.

Referências: `last_horizon/screens.pde`, `last_horizon/last_horizon.pde`,
`last_horizon/ui.pde` e `last_horizon/capture.pde`.

#### US-25: separar responsabilidades em abas procedurais

Como desenvolvedor, quero encontrar nave, portais, movimento e animação em
blocos coesos, para manter o sketch sem introduzir classes ou framework.

Critérios de aceite:

1. O conteúdo atualmente concentrado em `ship.pde` é separado por
   responsabilidade coesa entre cenário, portais, movimento e animação.
2. Gatilhos de áudio continuam próximos do movimento que os determina e a
   reprodução permanece em `audio.pde`.
3. A primeira etapa move código sem alterar expressões, ordem de atualização ou
   inicialização.
4. O sketch completo compila, executa e conserva física, animação, áudio,
   campanhas e comportamento de portas.
5. Não é criada uma aba por função pequena nem uma nova hierarquia de entidades.

Referências: `last_horizon/ship.pde`, `last_horizon/audio.pde`,
`last_horizon/last_horizon.pde` e `code/SKETCH_ARCHITECTURE.md`.

#### US-26: manter modo de teste opcional

Como desenvolvedor, quero manter o modo de teste no desenvolvimento e removê-lo
do corte de entrega, para depurar sem acoplar o jogo ao produto final.

Critérios de aceite:

1. Ctrl + K, teleporte para as quatro salas e destaque visual continuam úteis no
   sketch de desenvolvimento.
2. O destaque forçado altera somente apresentação e disponibilidade visual; não
   autoriza pagamento, aceite, entrega ou conclusão indevida.
3. O runtime compila e roda com ambos os módulos opcionais, sem o modo manual e
   com apenas um deles.
4. O snapshot gerado exclui harness, `capture.pde` e módulo manual sem depender
   de substituição textual frágil.
5. A entrega não mostra controles de debug e não publica automaticamente a
   branch.

Referências: `last_horizon/test_mode.pde`, `last_horizon/capture.pde`,
`last_horizon/last_horizon.pde`, `tools/snapshot-entrega.mjs` e
`code/VERIFICATION.md`.

#### US-27: manter documentação e evidência sincronizadas

Como mantenedor, quero separar regra vigente de histórico e ter evidência de
equivalência, para não reintroduzir decisões ultrapassadas.

Critérios de aceite:

1. As divergências de portas, escadas, animações, tipografia e entrega são
   conferidas antes de editar a área afetada.
2. `interface/FLOW.md`, `interface/HUD.md`, `interface/ROOMS.md`, personagens,
   arquitetura e verificação refletem o comportamento aprovado.
3. A nova decisão de informação progressiva e falas contextuais é registrada
   sem reescrever ADRs históricas.
4. A matriz de verificação contém equivalência, visual, desempenho e playtest.
5. O documento operacional mantém estado atual, evidências e fronteira sem
   apagar histórico de decisões.

Referências: `SESSION_START.md`, `SPEC_ENXUGAMENTO_E_IMERSAO.md`,
`docs/adr/`, `code/VERIFICATION.md` e as documentações de `interface/`.

## 3. Requisitos funcionais

### 3.1 Ciclo, quests e regras preservadas

#### RF-01: preservar invariantes do ciclo

Relacionadas: US-01, US-02, US-04, US-06, US-07, US-08.

O sketch deve manter quatro salas, quatro sobreviventes, seis recursos, dez
dias, cinco incidentes em dias pares definidos, sete tipos de incidente,
quatorze soluções, oito preventivas, uma conclusão diária e um objeto carregado
por vez. A implementação deve usar os estados e tabelas existentes em
`last_horizon/last_horizon.pde`, `tasks.pde` e `game.pde`.

#### RF-02: exibir objetivo da viagem

Relacionada: US-01.

As telas iniciais devem informar Marte, dez dias, motor operante e ao menos um
sobrevivente vivo como condição de chegada, sem alterar o estado mecânico.

#### RF-03: comparar duas preventivas

Relacionadas: US-02, US-03.

Em dias sem incidente, `drawOrdersPanel` deve apresentar as duas ofertas
disponíveis com dados editoriais curtos e dados mecânicos completos: responsável,
benefício, objeto, origem, destino, perda se incompleta e negligência das
ofertas. O vínculo deve usar os IDs de `tasks.pde`.

#### RF-04: manter seleção pendente antes do aceite

Relacionada: US-03.

`choosePreventive` deve alterar somente a seleção ainda não confirmada. A
confirmação deve continuar exigindo proximidade do responsável, presença na sala
correta e validação de disponibilidade por `acceptPreventive`.

#### RF-05: aceitar a ordem no NPC correto

Relacionadas: US-03, US-04.

`interactNpc` deve priorizar o responsável da seleção e abrir uma fala curta com
benefício e irreversibilidade. `acceptPreventive` deve revalidar o NPC vivo, o
ponto físico e o limite diário antes de ativar a quest.

#### RF-06: conservar entrega direta de V-02 e N-02

Relacionada: US-04.

Quando origem e responsável coincidirem, o aceite deve colocar o objeto em
`held_item` e mudar `quest_stage` diretamente para `QUEST_DELIVER`. A regra deve
continuar ligada aos dados de origem e ponto do catálogo, sem hardcode visual.

#### RF-07: executar coleta e entrega físicas

Relacionadas: US-04, US-05.

`collectQuestObject` deve exigir o ponto de origem, estado de coleta e ausência
de objeto carregado. `deliverQuest` deve exigir destino, objeto correto, estado
de entrega e recurso suficiente. As ações devem revalidar o estado mesmo que o
botão tenha sido desenhado como ativo.

#### RF-08: preservar custos, recompensas e falhas

Relacionadas: US-02, US-05, US-06.

Os valores de `mechanics/ACTIONS.md` e os arrays correspondentes de `tasks.pde`
devem permanecer iguais. O custo urgente é pago somente na entrega. A entrega
sem recurso não pode debitar, resolver o problema ou remover o objeto da mão.

#### RF-09: manter prioridade e retomada de incidentes

Relacionada: US-06.

Problemas ativos devem continuar visíveis com perda diária, prazo e crise. A
retomada deve usar `problem_solution` e o `problem_deadline` existente, sem
reiniciar prazo. Incidente novo deve ser priorizado nos dias 2, 4, 6, 8 e 10.

#### RF-10: manter socorro como conclusão diária

Relacionada: US-07.

O ponto de risco e `rescueUrgentSurvivor` devem aceitar socorro somente quando
há risco, nenhum incidente bloqueante, nenhum compromisso diário e água e comida
suficientes. O ponto deve continuar consultável enquanto houver risco mesmo
quando uma dessas condições bloquear a ação, exibindo estado, custo, limite e
razão do bloqueio com o botão desabilitado. Sem risco, o ponto permanece fechado.
O custo continua sendo 8 água e 2 comida.

#### RF-11: gerar consulta pura da próxima ação

Relacionadas: US-04, US-06, US-12, US-17.

Deve existir uma consulta única para retornar o objetivo atual, o verbo, o ponto,
a sala, a porta ou a escada relevante e o motivo de ausência. A consulta pode
ser usada pelo HUD e pelo mapa, mas não pode consumir recurso, avançar animação,
registrar memória editorial ou consumir RNG.

#### RF-12: prever o processamento noturno

Relacionada: US-08.

O painel de sono deve calcular uma previsão sem mutar a partida por meio de uma
transição noturna pura compartilhada no runtime Processing. Essa transição deve
receber um snapshot da partida e entradas determinísticas, aplicar na mesma
ordem as etapas de `applyQuestConsequences`, `processNight`,
`processSurvivorRisks`, `processProblemDeadlines`, `clampResources` e
`checkEndConditions`, e retornar o estado projetado sem consumir recursos,
avançar o jogo, sortear ou registrar memória editorial. `processNight()` deve
usar essa mesma transição para aplicar o resultado ao estado real, enquanto o
painel usa o resultado retornado para renderizar a previsão.

A validação deve executar a previsão e a noite real a partir do mesmo snapshot e
comparar recursos, riscos, prazos, crises, estado do motor, sobreviventes e
desfecho. O modelo independente em JavaScript permanece separado, sem
compartilhar o algoritmo, e serve como verificador externo da mesma evidência.

#### RF-13: manter desfechos e prioridade de derrota

Relacionadas: US-01, US-08.

O desfecho deve continuar sendo vitória somente após o décimo dia, com motor
operante e pelo menos um sobrevivente. Energia, oxigênio, moral, motor destruído
ou ausência total de sobreviventes devem continuar levando à derrota conforme a
ordem vigente em `checkEndConditions`.

### 3.2 Catálogo editorial e memória

#### RF-14: separar catálogo mecânico e editorial

Relacionadas: US-09, US-11.

O catálogo editorial deve manter títulos, motivações e falas em estrutura
separada de custos, recursos, pontos, rotas e responsáveis. A associação deve
usar os 22 IDs de `tasks.pde`, nunca o texto exibido ou a posição acidental de
uma lista traduzida.

#### RF-15: cobrir as 22 quests

Relacionadas: US-02, US-05, US-09.

Os 22 IDs, oito preventivas e quatorze soluções, devem ter título visível,
motivação ou fala-base, resultado mecânico preservado e fallback factual curto
quando faltar conteúdo editorial. A validação deve falhar por entrada ausente
no harness, mas o runtime não pode bloquear o jogo por texto ausente.

#### RF-16: selecionar fala por contexto real

Relacionadas: US-10, US-11.

O seletor editorial deve priorizar confirmação pendente, lembrete da etapa ativa,
risco do NPC, reconhecimento recente, oferta, problema urgente e fase da
viagem. O seletor deve evitar frases técnicas como `decisão em andamento` e não
transferir o socorro para uma fala de NPC.

#### RF-17: registrar memória apenas em transição mecânica

Relacionada: US-10.

`recordEditorialResult` e `recordEditorialRisk` devem ser chamados em conclusão,
falha, omissão, socorro ou risco real. Abrir painel, desenhar quadro ou fechar
diálogo não pode sobrescrever o último resultado.

#### RF-18: aplicar prioridade e expiração da memória

Relacionadas: US-10, US-11.

A memória deve guardar resultado, dia e apresentação para cada NPC. O período de
retenção é o dia do resultado e o dia seguinte. Socorro tem prioridade sobre
ajuda, ajuda sobre falha e falha sobre omissão. Depois de exibida ou envelhecida,
a fala volta ao contexto normal. Nova partida deve zerar os arrays editoriais.

#### RF-19: fornecer ambientação determinística

Relacionada: US-11.

Cada NPC deve possuir duas variantes de ambientação para cada uma das três fases
da viagem. A alternância deve depender da contagem de conversa e nunca de sorteio
por quadro ou do gerador de incidentes.

### 3.3 HUD e painéis

#### RF-20: consolidar objetivo e alerta no HUD

Relacionada: US-12.

`drawObjectiveStrip` deve desenhar objetivo e alerta ou resultado em duas linhas,
com prioridade para fatalidade, pessoa em risco, problema de menor prazo,
resultado recente e demais alertas. O HUD não deve repetir todas as etapas da
quest, mas deve manter acesso a todos os problemas por Ordens ou Mapa.

#### RF-21: exibir comparação progressiva

Relacionada: US-13.

`drawQuestCard` e `drawOrdersPanel` devem separar informação necessária para
decisão de detalhes consultáveis. A expansão ou paginação deve ficar no mesmo
painel, preservar números e custo e manter rodapé e botões dentro da área útil.

#### RF-22: compor coleta, entrega e socorro por contexto

Relacionadas: US-04, US-05, US-07, US-14.

`openQuestStepPanel` e `openRescuePanel` devem produzir título, até duas linhas
factuais, custo ou consequência e rodapé contextual. O painel deve usar
`drawModalFooter`, bloquear movimento enquanto aberto e fechar após sucesso sem
criar uma janela secundária.

#### RF-23: apresentar razão estruturada de bloqueio

Relacionadas: US-05, US-07, US-14.

Cada ação bloqueada deve fornecer razão baseada no estado real, como recurso
faltante, confirmação pendente, conclusão diária já usada, distância ou ponto
incorreto. O texto exibido deve ser derivado da razão, e a ação deve revalidar o
estado no momento do `ENTER` ou clique.

`pendingQuestReason()` deve existir sem argumentos, consultar o mesmo estado
usado por `pendingQuestEnabled()` e retornar a razão estruturada do bloqueio
atual para a ação em `pending_quest_action`. O contrato deve cobrir, no mínimo,
recurso insuficiente com recurso atual e necessário, conclusão diária já usada,
confirmação pendente, distância ou ponto incorreto e ausência de risco urgente.
Quando não houver bloqueio, a função deve retornar uma razão vazia ou não ser
exibida. A camada de UI deve derivar o texto dessa razão sem duplicar as regras
de disponibilidade.

#### RF-24: reutilizar rodapé e hit-test

Relacionada: US-19.

`drawModalFooter` deve calcular largura por rótulo e padding, colocar ação
secundária à esquerda e principal à direita, usar oito unidades lógicas de
espaçamento e registrar a mesma geometria para `findButton`. O helper deve
receber rótulo, ação e disponibilidade, sem decidir regras de gameplay.

#### RF-25: resolver prioridade de camada

Relacionadas: US-15, US-24.

`screens.pde` deve expor uma consulta sem efeitos colaterais para a camada ativa,
com prioridade pausa, transmissão, incidente, ordens, mapa, diálogo, técnico,
sono, ajuda e cena. Desenho, teclado, mouse e cursor devem usar a mesma consulta.

#### RF-26: conservar vocabulário de saída

Relacionadas: US-03, US-14, US-15.

Os painéis devem usar `Agora não (ESC)` antes de compromisso ou ação física,
`Voltar (ESC)` na revisão, `Fechar (ESC)` em consulta e `Continuar (ENTER)) para
informação. O termo `Cancelar` não deve aparecer onde possa sugerir que uma
ordem aceita pode ser desfeita.

### 3.4 Mapa e navegação

#### RF-27: derivar conexões do catálogo de portais

Relacionadas: US-17, US-18.

`drawMapOverlay` deve derivar linhas e sentido a partir de `door_room` e
`door_target`, em vez de fixar conexões por índices de salas. A visão deve
mostrar o hub e somente as conexões existentes.

#### RF-28: calcular rota de menor número de travessias

Relacionada: US-17.

`calculateMapRoute` deve continuar usando busca simples no grafo de salas, com
desempate pela ordem estável das tabelas. Deve retornar salas, portas, alvo e
motivo de ausência sem alterar estado mecânico.

#### RF-29: resolver alvo automático por etapa

Relacionadas: US-04, US-06, US-17, US-18.

O alvo deve ser responsável antes do aceite, origem durante coleta, destino
durante entrega e beliche após conclusão. Sem ordem, não deve haver rota
automática. Socorro e pontos selecionados são consultas opcionais e não podem
substituir a rota da quest.

#### RF-30: orientar porta, convés e escada

Relacionada: US-17.

Quando o alvo estiver em outra sala, o mapa deve indicar a próxima porta, sala de
destino e convés ou altura. Quando o alvo estiver em outro convés da sala atual,
`findNextMapLadder` deve selecionar escada que alcance o trecho necessário,
minimizando troca de convés, distância horizontal e índice estável.

#### RF-31: representar localização real e casos inválidos

Relacionada: US-18.

O detalhe espacial deve usar a posição atual do técnico, o trecho real da
escada, o `door_deck` configurado e o ponto de casco sorteado. Alvo inválido,
ausente, sem rota ou com porta livre deve apresentar motivo explícito e nenhuma
posição inventada.

#### RF-32: manter mapa consultivo

Relacionadas: US-17, US-18.

Clique em sala, `Minha sala`, `Destino`, `Alertas` e fechamento do mapa devem
alterar somente a consulta visual. Nenhuma dessas ações pode mover o técnico,
abrir uma porta, aceitar, coletar, entregar, dormir, consumir recurso ou alterar
RNG.

### 3.5 Refatoração técnica T01 a T10

#### RF-33: implementar T01, tipografia comum

Relacionada: US-19.

`drawShadowText` deve ser o núcleo dos wrappers de texto com sombra. A extração
deve preservar tamanho, cinco deslocamentos, cor, centralização, acentos,
prompts de 11 px e comportamento de fallback.

#### RF-34: implementar T02, seleção de arte de NPC

Relacionada: US-20.

Deve existir uma resolução compartilhada por identidade e direção para sprite e
halos. A resolução deve conservar fallback frontal, espelhamento Aseprite,
direções LPC e ausência parcial de halo.

#### RF-35: implementar T03, preparação de portal

Relacionada: US-21.

Os caminhos de transição animada e instantânea devem consumir os mesmos dados
preparados de saída, destino, chegada e retorno. A troca de sala deve ocorrer
sem recalcular depois da mudança de `screen`.

#### RF-36: implementar T04, cache de ícones

Relacionada: US-22.

`prepareResourceIconCache` deve preparar os seis ícones na carga ou após uma
recarga explícita. `drawResourceIcon` deve somente compor o cache quando a fonte
estiver disponível, mantendo fallback geométrico e alerta dinâmico fora do cache.

#### RF-37: implementar T05, reuso do piso

Relacionada: US-22.

`prepareDeckStrips` deve preparar uma faixa por combinação de tile e largura. Se
os três conveses selecionarem o mesmo tile, `art_deck_strip` deve compartilhar a
mesma referência imutável. A prioridade de fallback de `floorArtForDeck` deve
ser preservada.

#### RF-38: implementar T06, rodapé comum

Relacionada: US-19.

Todos os painéis de diálogo, incidente, sono, técnico e ajuda que possuam ações
devem usar o compositor comum de rodapé ou uma composição equivalente que
registre a mesma geometria de hit-test.

#### RF-39: implementar T07, sequência explícita do HUD

Relacionada: US-23.

O mapeamento de `HUD_RESOURCE_ORDER` deve declarar a relação entre recurso,
ícone, valor, cor, rótulo e barra. A sequência deve continuar em energia,
oxigênio, água, comida, peças e moral, sem converter o estado global em arrays
por conveniência.

#### RF-40: implementar T08, resolvedor modal

Relacionada: US-24.

A camada ativa deve ser consultada por desenho, ENTER, ESC, clique e cursor. O
resolvedor deve ser puro e manter os flags existentes durante a primeira
implementação.

#### RF-41: implementar T09, separação de abas

Relacionada: US-25.

Os blocos de cenário, portais, movimento e animação devem ser separados apenas
quando coesos, sem mudar ordem de inicialização, expressões, física, animação,
áudio ou compilação do sketch completo.

#### RF-42: implementar T10, módulos opcionais

Relacionada: US-26.

Hooks inertes no runtime devem permitir a instalação do harness no repositório.
O módulo manual deve continuar fornecendo Ctrl + K, teleporte e destaque no
desenvolvimento. A cópia de entrega deve compilar sem `capture.pde` e sem o
módulo manual, sem remoção por substituição textual frágil.

### 3.6 Organização, validação e documentação

#### RF-43: validar integridade editorial

Relacionada: US-27.

O harness deve validar cobertura dos 22 IDs, responsáveis válidos, pontos
existentes, textos editoriais presentes e limite de 160 caracteres para falas
base. A validação deve ser independente da implementação do modelo Node.

#### RF-44: fornecer consultas puras para apresentação

Relacionadas: US-08, US-12, US-17, US-18.

Consultas de objetivo, bloqueio, problema, painel e rota devem retornar dados
para renderização sem pagar recursos, avançar animação, registrar memória ou
alterar RNG. Funções de domínio existentes continuam sendo responsáveis por
alterar estado.

#### RF-45: sincronizar documentação vigente

Relacionada: US-27.

Após a implementação, atualizar fluxo, HUD, salas, personagens, arquitetura e
verificação com o comportamento aprovado. Manter ADRs históricas e registrar
separadamente a decisão de informação progressiva e falas contextuais.

## 4. Requisitos não funcionais

### 4.1 Performance e uso de memória

#### RNF-01: eliminar recomposição contínua de ícones

Após a carga ou recarga explícita, o desenho estabilizado do HUD não deve criar
um `PGraphics` por ícone e por quadro. A verificação deve registrar o número de
preparações e confirmar seis caches no caso de seis fontes disponíveis.

#### RNF-02: compartilhar faixas idênticas

Quando os três conveses usam o mesmo tile e a mesma largura, deve haver uma
preparação de faixa e referências compartilhadas. A imagem compartilhada deve
ser tratada como imutável e não pode ser editada destrutivamente por convés.

#### RNF-03: medir antes e depois em condições iguais

A medição deve usar a mesma máquina, assets, sala e tamanho de janela, separar
carga de quadros estabilizados e registrar mediana e p95 do tempo por quadro em
três amostras de 30 segundos, além do tempo de carga, memória adicional e
preparações de buffer ou faixa.

#### RNF-04: controlar regressão de p95

Não deve haver regressão consistente superior a 10% no p95 sem investigação e
registro da causa. Não é permitido atingir a meta removendo suavização, fallback
ou qualidade gráfica.

### 4.2 Segurança e superfície de execução

#### RNF-05: manter o produto local

Como o projeto não possui backend, autenticação, autorização ou banco de dados,
a feature não deve introduzir endpoint, credencial, comunicação externa,
persistência de nome ou dependência de aplicação. A validação deve ser feita por
inspeção de dependências, busca de integrações e compilação do sketch.

#### RNF-06: isolar debug do produto de entrega

Controles de Ctrl + K, teleporte, destaque forçado e captura não podem aparecer
na entrega final. Mesmo presentes no sketch de desenvolvimento, não podem
autorizar mudança mecânica fora das funções de domínio.

### 4.3 Usabilidade, legibilidade e acessibilidade visual

#### RNF-07: preservar resolução e escala

O produto deve manter render de 1280 por 720, grade lógica de 640 por 360,
ampliação inteira, letterbox centralizado, Segoe UI para texto e pixel art sem
interpolação.

#### RNF-08: manter orçamento de texto

Falas-base devem ter até 160 caracteres e uma ou duas frases. O corpo da
interface deve usar 16 px reais com entrelinha de 18 px. Prompts de 11 px só
podem aparecer nos contextos já previstos.

#### RNF-09: não depender de cor isolada

Estados positivos, negativos, bloqueados, fatais e selecionados devem combinar
cor com texto, valor, ícone, verbo ou estado habilitado. O jogador deve
reconhecer custo, risco fatal e ação disponível sem depender de percepção de cor.

#### RNF-10: validar clareza com participantes

O playtest deve usar três pessoas que não conheçam o código, alternar a ordem das
versões e observar sem explicar. As metas iniciais são: 2 de 3 encontram o
próximo passo em até 10 segundos; 3 de 3 reconhecem o aviso fatal antes de
confirmar sono; 2 de 3 distinguem seleção de aceite e explicam custo; 2 de 3
reconhecem vozes diferentes; 2 de 3 dão nota mínima 4 para clareza e vontade de
continuar.

#### RNF-11: não adicionar bloqueios obrigatórios

Nenhuma etapa obrigatória deve ganhar confirmação extra, animação de digitação,
espera artificial, tutorial novo, cena nova ou som obrigatório. A simplificação
deve reduzir repetição mantendo informação decisiva.

### 4.4 Confiabilidade e compatibilidade

#### RNF-12: manter fallback funcional

Asset ausente, sprite incompleto, halo ausente, áudio ausente ou imagem parcial
deve preservar execução, interação, colisão, navegação e regras. O fallback não
deve alterar custo, prazo, recurso ou desfecho.

#### RNF-13: invalidar caches quando a fonte mudar

Fixtures que trocam imagens devem invalidar somente o cache correspondente. Um
cache não pode ser considerado válido apenas porque o caminho do arquivo é o
mesmo.

#### RNF-14: preservar equivalência mecânica

O harness deve verificar campanhas, custos, recompensas, prazos, socorro,
retomada, prioridade, portas, escadas, movimento, áudio, modais, assets e
desfechos. O modelo numérico independente deve continuar passando a verificação
de sintaxe e simulação, incluindo as 2.520 sequências da estratégia de reserva
de peças.

#### RNF-15: manter compilação com módulos opcionais

O sketch deve compilar e executar na configuração de desenvolvimento e na cópia
de entrega sem harness. A remoção da captura e do modo manual deve ser realizada
pelo fluxo do snapshot, não por edição manual frágil.

#### RNF-16: manter determinismo das fixtures

Fixtures de captura que fixam a sequência de incidentes devem restaurar arte,
posição, tabelas e flags mutados ao terminar. Consultas de UI e mapa não podem
consumir RNG ou alterar a campanha.

## 5. Ordem de implementação e evidências

| Etapa | Escopo | Dependência | Evidência obrigatória |
| --- | --- | --- | --- |
| E0 | Reconciliar documentação, conferir fontes vigentes, atualizar índice e capturar baseline | Acesso aos arquivos e revisão desta documentação | Matriz de fontes, conflitos resolvidos, baseline visual, funcional e de desempenho |
| E1 | T01, T02, T06 e T07 | E0 | Comparação visual equivalente, catálogo de texto e regressões de HUD, NPC e rodapé |
| E2 | T03, T04 e T05 | E1 | Portais equivalentes, fallback preservado, contagem de caches e faixas preparada |
| E3 | T08, T09 e T10 | E2 | Input consistente, sketch completo compilado, runtime e corte sem módulos opcionais |
| E4 | Catálogo editorial, memória e questline | E3 | 22 IDs cobertos, falas por contexto, memória resetada e nenhuma alteração numérica |
| E5 | HUD, mapa, comparação, interação, sono e detalhes | E4 | Capturas interativas, previsão coincidente com a noite, 12 pares ordenados de salas, alvos de coleta, entrega, beliche e socorro |
| E6 | Playtest, ajustes editoriais e documentação final | E5 | Resultados do playtest, medições antes e depois, regressão aprovada e documentação sincronizada |

### 5.1 Verificação mínima por domínio

1. Rodar a captura existente e preservar o baseline antes da mudança. O
   harness atual registra 34 estados, campanhas, catálogo, modais, mapa,
   socorro, morte, portas, escadas, assets e áudio.
2. Expandir a captura para cobertura editorial dos 22 IDs, ausência de texto,
   falas repetidas, morte de NPC, reconhecimento por resultado e fases da
   viagem.
3. Verificar os 12 pares ordenados entre salas distintas, objetivo na mesma
   sala em outro convés, V-02, N-02, retomada, casco aleatório, socorro,
   NPC morto, alvo ausente, ausência de rota, porta arbitrária e asset ausente.
4. Exercitar transmissão sobre incidente, pausa, comparação, revisão, diálogo,
   técnico, sono, mapa, ajuda, teclado, mouse, cursor e clique fora da janela.
5. Comparar pixels de nomes, prompts, portas, NPCs, ícones, pisos, retratos,
   cards e fallback entre baseline e refatoração. Diferenças intencionais da
   nova apresentação devem ser registradas separadamente da equivalência técnica.
6. Rodar a verificação do modelo numérico independente por sintaxe e simulação.
7. Medir desempenho conforme RNF-03 e registrar o resultado na documentação de
   verificação.
8. Executar o playtest da SPEC e registrar participantes, ordem das versões,
   tarefas, tempo, erros, reaberturas, voltas erradas, notas e comentários.

### 5.2 Matriz resumida de rastreabilidade

| Domínio | Stories | Requisitos principais | Módulos de integração |
| --- | --- | --- | --- |
| Objetivo e ciclo | US-01 a US-08 | RF-01 a RF-13 | `screens.pde`, `game.pde`, `tasks.pde`, `mechanics/ACTIONS.md` |
| NPCs e narrativa | US-09 a US-11 | RF-14 a RF-19 | `editorial.pde`, `tasks.pde`, `ship.pde`, `assets.pde`, `characters/`, `history/` |
| HUD e interação | US-12 a US-16 | RF-20 a RF-26 | `hud.pde`, `ui.pde`, `screens.pde`, `last_horizon.pde` |
| Mapa | US-17 e US-18 | RF-27 a RF-32 | `navigation.pde`, `ship.pde`, `tasks.pde`, `interface/ROOMS.md` |
| Refatoração | US-19 a US-26 | RF-33 a RF-42 | `ui.pde`, `hud.pde`, `assets.pde`, `ship.pde`, `test_mode.pde`, `capture.pde` |
| Documentação e validação | US-27 | RF-43 a RF-45, RNF-14 a RNF-16 | `code/VERIFICATION.md`, `code/SKETCH_ARCHITECTURE.md`, `SESSION_START.md`, `tools/snapshot-entrega.mjs` |

## 6. Riscos de implementação

- `screens.pde`, `ship.pde`, inicialização global e processamento noturno são
  áreas sensíveis. Qualquer mudança deve conferir chamadores, ordem de
  atualização e efeitos sobre as flags existentes.
- O código já contém implementações parciais de cache, rodapé, navegação,
  memória editorial e hooks de harness. A implementação deve completar os
  contratos e medir os efeitos, sem duplicar helpers.
- O mapa atual já calcula rota por busca, mas o desenho de conexões, o detalhe de
  portas sem convés e a atualização de alvo precisam ser comparados com as
  tabelas reais de portas e escadas.
- `prepareDeckStrips` já cria faixas por convés. O requisito de reuso exige
  verificar identidade de referência e invalidação sem apagar imagens-fonte.
- O modo de teste e o harness compartilham pontos de extensão com o runtime. A
  compilação do sketch sem essas abas é critério de entrega.
- O preview de sono é funcionalmente sensível. A implementação não deve alterar
  o processador noturno para fazer o resultado coincidir com uma previsão
  incorreta.
- A SPEC é proposta para a mudança e a documentação vigente descreve o produto
  atual. Durante E0, conflitos entre fonte aprovada e código devem ser
  registrados e resolvidos explicitamente antes da edição.
