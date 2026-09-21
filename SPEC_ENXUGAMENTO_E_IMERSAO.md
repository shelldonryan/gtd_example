# Last Horizon — código enxuto, quests com propósito e interface a serviço da diversão

Data: 19/09/2026. Base inspecionada: commit `16d81f1` e arquivos locais da sessão.

**Status: proposta de design; implementação completa não confirmada.** Esta SPEC descreve requisitos e critérios, não um retrato confiável do comportamento atual. A revisão estática de 21/09/2026 encontrou diferenças ainda abertas, especialmente no mapa e na orientação por salas/conveses. O código atual e as diferenças confirmadas estão resumidos em [`docs/CURRENT_IMPLEMENTATION.md`](docs/CURRENT_IMPLEMENTATION.md). Os resultados E6 são evidência registrada para a campanha de 20/09/2026 e não foram revalidados contra este checkout.

Registro de publicação feito em 19/09/2026: a issue pretendida e a sincronização do Wayfinder estavam pendentes por falta de acesso autenticado; inventário, labels e bloqueadores nativos não foram verificados naquela ocasião. Esse estado externo não foi consultado nesta revisão local.

## Problem Statement

O jogador deveria sentir que mantém uma pequena tripulação viva durante uma viagem perigosa. Hoje, parte dessa experiência aparece como um formulário: textos longos em maiúsculas, campos técnicos repetidos, informações sobre todas as etapas a cada interação e diálogos que explicam regras em vez de expressar pessoas.

A decisão interessante existe — priorizar necessidades com recursos limitados — mas disputa atenção com burocracia visual. Depois de escolher uma ordem, o jogador continua relendo responsável, objeto, origem, destino, efeito e falha, mesmo quando só precisa saber para onde ir. Mensagens genéricas de bloqueio também não explicam exatamente o que falta.

No código, repetições em tipografia, assets, portas, botões e seleção de modais tornam cada ajuste mais trabalhoso e propenso a inconsistências. Há trabalho de renderização estática repetido por quadro e uma aba que concentra nave, física, animação e áudio de movimento. Documentação desatualizada aumenta o risco de uma limpeza desfazer decisões recentes.

O objetivo não é reduzir linhas a qualquer custo: é diminuir complexidade acidental, tornar consequências compreensíveis e devolver atenção à exploração, à escolha e ao vínculo com a tripulação.

## Solution

### Experiência desejada

O ciclo percebido passa a ser: **perceber uma necessidade → escolher quem ou o que ajudar → agir na nave → sentir a consequência → preparar a próxima noite**. O ciclo mecânico existente continua responsável por custos, limites e desfechos.

- Durante a exploração, mostrar uma próxima ação concreta e o alerta mais importante.
- Antes de um compromisso, mostrar alternativas, benefício/custo, rota e consequência relevante sem esconder números decisivos.
- Durante coleta e entrega, apresentar um painel curto, contextual e com verbo claro.
- Depois da ação, responder com resultado breve e mudança visível do objetivo, sem outro modal obrigatório.
- Em conversas, deixar cada sobrevivente falar como uma pessoa e reconhecer o que acabou de acontecer.
- Manter detalhes completos consultáveis em Ordens, Mapa e previsão da noite.
- Refatorar primeiro com equivalência observável; aplicar a nova apresentação depois, sem misturar mudanças de balanceamento.

### Critérios de sucesso

1. Os dez achados possuem implementação e verificação rastreáveis, ou justificativa documentada para eventual impedimento.
2. Campanhas, custos, recompensas, prazos, socorro, limites e desfechos mantêm os resultados de referência.
3. Em exploração, o jogador identifica o próximo passo sem abrir detalhes; diante de uma escolha, entende o principal benefício e risco.
4. Coleta e entrega não exigem mais confirmações que hoje. Nenhuma nova conversa, tutorial ou cena bloqueante é adicionada ao caminho obrigatório.
5. Nenhum custo, perda fatal ou morte prevista depende de tooltip, cor isolada ou expansão opcional para ser percebido no momento decisivo.
6. As falas diferenciam os quatro NPCs e nunca contradizem estado, disponibilidade ou resultado da partida.
7. Otimização é demonstrada por trabalho eliminado e medidas comparáveis; não se promete porcentagem de FPS sem evidência.

## User Stories

1. Como jogador iniciante, quero entender que preciso chegar a Marte com a nave funcionando e alguém vivo, para reconhecer o objetivo da viagem.
2. Como jogador, quero comparar duas necessidades reais da tripulação, para sentir que minha escolha importa.
3. Como jogador, quero ver o benefício e a consequência de cada preventiva antes de aceitá-la, para escolher conscientemente.
4. Como jogador, quero saber que selecionar uma preventiva ainda exige falar com o responsável, para não confundir seleção com aceite.
5. Como jogador, quero saber quando uma decisão se torna irreversível, para não assumir um compromisso sem perceber.
6. Como jogador, quero receber o objeto diretamente quando ele já está com o NPC, para evitar uma interação redundante.
7. Como jogador, quero saber qual é meu próximo destino, para explorar sem reler a descrição inteira.
8. Como jogador, quero reconhecer portas, NPCs e estações ativas, para me orientar no cenário.
9. Como jogador, quero coletar com uma explicação curta, para continuar jogando em vez de ler um formulário.
10. Como jogador, quero confirmar o custo real da entrega, para não gastar recursos por engano.
11. Como jogador sem recursos suficientes, quero saber quanto tenho e quanto falta, para entender por que a entrega não pode acontecer.
12. Como jogador, quero perceber quando meu trabalho resolveu algo, para sentir satisfação ao concluir uma ordem.
13. Como jogador, quero que Vera, Bento, Neusa e Sílvia tenham vozes diferentes, para lembrar quem são.
14. Como jogador, quero que as pessoas reconheçam minha ajuda ou um problema ignorado, para sentir continuidade entre os dias.
15. Como jogador, quero conversar opcionalmente sem receber novas obrigações, para conhecer a tripulação no meu ritmo.
16. Como jogador, quero que o NPC me lembre apenas do próximo passo relevante, para não ouvir toda a quest novamente.
17. Como jogador, quero distinguir informação narrativa de informação mecânica, para entender números sem quebrar a conversa.
18. Como jogador, quero perceber a aproximação de Marte nas falas, para sentir uma viagem com progressão.
19. Como jogador, quero retomar uma solução pendente entendendo que o prazo não reiniciou, para avaliar o risco corretamente.
20. Como jogador, quero saber quando o socorro usa minha conclusão diária e mantém negligência preventiva, para fazer uma escolha informada.
21. Como jogador, quero consultar todos os problemas mesmo quando o HUD destaca só um, para não perder informação estratégica.
22. Como jogador, quero prever os efeitos de dormir e reconhecer crises fatais, para assumir consequências conscientemente.
23. Como jogador, quero que o mapa continue apenas consultivo, para preservar a exploração física da nave.
24. Como jogador, quero fechar ou voltar de um painel sem cancelar minha ordem aceita, para usar a interface com confiança.
25. Como jogador, quero distinguir botões indisponíveis de botões ativos e saber o motivo, para não depender de tentativa e erro.
26. Como jogador, quero ler textos e números em 720p sem sobreposição, para jogar confortavelmente.
27. Como jogador, quero ver pixel art nítida e animações consistentes, para manter a qualidade visual durante a simplificação.
28. Como jogador, quero continuar jogando quando faltar um asset ou som, para que a ausência não quebre a partida.
29. Como desenvolvedor, quero um desenho comum de sombras e botões, para mudar um padrão sem corrigir várias cópias.
30. Como desenvolvedor, quero compartilhar a seleção de sprites e halos, para que orientação e fallback não divirjam.
31. Como desenvolvedor, quero uma preparação única de portais, para preservar a chegada com e sem animação.
32. Como desenvolvedor, quero preparar conteúdo visual estático uma vez, para evitar trabalho desnecessário por quadro.
33. Como desenvolvedor, quero uma fonte comum da prioridade dos modais, para alinhar desenho, teclado e clique.
34. Como desenvolvedor, quero responsabilidades separadas em abas procedurais, para navegar pelo código sem uma nova arquitetura de classes.
35. Como desenvolvedor, quero manter o modo de teste disponível no desenvolvimento e opcional na entrega, para depurar sem acoplar o jogo a ele.
36. Como mantenedor, quero documentação vigente separada de histórico, para não restaurar regras ultrapassadas.
37. Como responsável pela entrega, quero evidência de equivalência e playtest, para distinguir uma interface bonita de uma experiência compreensível e divertida.
38. Como jogador, quero abrir o mapa e reconhecer minha sala e meu convés, para relacionar o desenho ao lugar em que estou.
39. Como jogador, quero ver as conexões reais entre as salas, para entender quando preciso passar pelo Comando.
40. Como jogador, quero identificar a próxima porta e a escada que liga os conveses necessários, para chegar ao objetivo sem adivinhar.
41. Como jogador, quero que o mapa acompanhe confirmação, coleta, entrega e retorno ao beliche, para não me orientar por uma etapa já concluída.
42. Como jogador, quero consultar outra sala sem perder a rota da ordem ativa, para explorar com autonomia.
43. Como jogador, quero distinguir um problema de uma ação que posso executar agora, para não seguir marcadores impossíveis.

## Implementation Decisions

### 1. Limites e contratos preservados

- Manter quatro salas, quatro sobreviventes, seis recursos, dez dias, cinco incidentes sem reposição nos dias pares e o pool de sete tipos.
- Manter oito preventivas, quatorze soluções, uma conclusão por dia e um objeto carregado por vez.
- Preservar as rotas e posições atuais nesta entrega. Melhorar o sentido da viagem e a apresentação das quests sem acrescentar percursos ou alterar o balanceamento.
- Manter seleção remota e aceite presencial das preventivas; V-02 e N-02 continuam entregando o objeto no próprio aceite.
- Manter escolha de incidente antes da exploração, custo urgente pago somente na entrega, retomada da mesma solução e prazo persistente.
- Manter socorro, negligência, crise e ordem exata do processamento noturno, inclusive desempates e prioridade de derrota sobre vitória.
- Manter E para abrir interação, ENTER para confirmar, ESC para fechar/voltar/pausar, mouse nos botões e demais controles existentes. Não introduzir coleta automática ou confirmação por proximidade.
- Manter render 1280×720, grade lógica 640×360, Segoe UI suavizada, pixel art sem interpolação e ampliação inteira.
- Manter estilo procedural, globais agrupadas e abas do Processing. Não introduzir engine, dependências, framework de UI, hierarquia de entidades ou linguagem de scripts de quest.

### 2. Os dez achados técnicos

#### T01 — Tipografia e sombra comuns

**Situação:** os helpers de texto centralizado com sombra e de prompt repetem o mesmo desenho; o texto alinhado à esquerda repete os deslocamentos do contorno.

**Decisão:** extrair um desenhador de contorno que receba texto, posição já resolvida, tamanho e cor. Os wrappers continuam expressando alinhamento e política de tamanho. Os dois wrappers centralizados podem delegar ao mesmo núcleo; remover um nome redundante somente após conferir todos os usos, inclusive harness.

**Contrato:** não aplicar piso de 16 px aos prompts de 11 px nem desfazer o ajuste de nomes das portas. Preservar os cinco deslocamentos, cor, centralização e medidas. Mudanças editoriais de tamanho pertencem à etapa de UI, não à refatoração.

**Aceite:** equivalência visual de nomes longos, prompts, sombras, acentos e limites de sala no estágio de refatoração.

#### T02 — Seleção única de arte dos NPCs

**Situação:** sprite, halo ciano e halo laranja repetem busca textual do NPC e fallback por orientação.

**Decisão:** resolver identidade uma vez por NPC desenhado; usar um seletor compartilhado que receba identidade, direção e banco de imagens. Manter bancos separados de arte e cores se isso tornar os dados mais claros, sem criar hierarquia de classes.

**Contrato:** conservar equivalência de nomes aceita hoje, prioridade esquerda/direita/frontal, retorno nulo, Aseprite espelhado e LPC direcional. A ausência de um halo não deve alterar o sprite principal.

**Aceite:** orientação em ambos os lados, pulo, escada, outros conveses, NPC morto, sprite ausente e halos ausentes/parciais mantêm o comportamento esperado.

#### T03 — Preparação única da travessia

**Situação:** os caminhos animado e instantâneo repetem identificação de retorno, chegada e registro da saída.

**Decisão:** calcular e registrar a travessia uma única vez, antes de escolher sua execução animada ou imediata. Os dados preparados são sala destino, posição de chegada, direção e porta de retorno. Não calcular novamente depois de trocar a sala.

**Contrato:** salvar a posição de saída anterior à movimentação; retorno imediato reaproveita x/y, demais caminhos usam a chegada configurada. Preservar som único, fases de abertura/fechamento e fallback sem arte.

**Aceite:** portas arbitrárias em x/y, chegada fora de deck seguida de gravidade, ida/volta e transições com arte completa, parcial e ausente.

#### T04 — Cache dos ícones do HUD

**Situação:** um buffer é limpo e recomposto para cada ícone estático a cada quadro.

**Decisão:** preparar seis representações nítidas quando a arte é carregada. O desenho normal apenas compõe a imagem pronta. Recriar cache somente se a imagem-fonte mudar durante uma fixture ou recarga explícita.

**Contrato:** preservar tamanho, alinhamento, transparência, fallback geométrico e alerta crítico dinâmico. Não cachear número, barra, cor de estado nem piscada junto do ícone.

**Aceite:** render normal não executa preparação de buffer por ícone/quadro; screenshots equivalentes na refatoração. Registrar custo inicial e memória adicional do cache.

#### T05 — Reuso do piso preparado

**Situação:** a escolha de tile ignora o convés e produz três faixas idênticas.

**Decisão:** escolher o tile pela prioridade de fallback vigente, preparar uma faixa e compartilhar a referência entre conveses. Manter capacidade de faixas distintas se os dados futuramente fornecerem tiles diferentes, sem construir isso antecipadamente.

**Contrato:** imagem compartilhada é tratada como imutável; não aplicar edição destrutiva por convés. Preservar recorte final e ausência de arte. Não apagar imagens-fonte por não serem escolhidas hoje.

**Aceite:** uma preparação para tile/largura idênticos, sem diferença visual, com restauração correta após fixtures.

#### T06 — Rodapé comum de ações

**Situação:** diálogos, incidentes, sono e painéis técnicos repetem medidas e alinhamento dos botões.

**Decisão:** compartilhar composição de rodapé com ação secundária à esquerda e principal à direita, espaçamento de 8 unidades lógicas e altura atual de 20. Largura é calculada pelo rótulo e padding, limitada à área do painel. O helper deve desenhar e registrar a mesma geometria para hit-test.

**Contrato:** rótulo, ação e disponibilidade são fornecidos pelo contexto; o helper não decide gameplay. Se o conjunto não couber, ampliar a área útil ou quebrar o layout do painel, não truncar o verbo ou esconder o atalho. Não encolher texto abaixo do limite já permitido para botões.

**Aceite:** pares e botão único, rótulos longos, estado desabilitado, teclado, mouse e ausência de clique atravessando modal.

#### T07 — HUD de recursos orientado por uma sequência explícita

**Situação:** desenho dos seis cartões e avanço horizontal repetidos; códigos de recurso e ícone divergem para moral/peças.

**Decisão:** declarar a ordem visual energia, oxigênio, água, comida, peças e moral, com mapeamento explícito para recurso e ícone. Percorrer essa sequência utilizando leitura numérica já existente. Unificar rótulos pela identidade do recurso, sem usar índice de ícone como índice de recurso.

**Contrato:** peças permanecem inteiras, sem barra e sem alerta de limiar percentual. Dia e tripulação continuam cartões próprios. Não migrar todo o estado de recursos para arrays apenas para encurtar esse loop.

**Aceite:** cada cartão recebe valor, nome, ícone, cor e barra corretos, especialmente moral e peças; extremos e limites continuam iguais.

#### T08 — Resolução comum do modal ativo

**Situação:** desenho, ENTER, ESC e bloqueios mantêm decisões paralelas sobre os mesmos flags.

**Decisão:** criar um resolvedor sem efeitos colaterais com prioridade explícita: pausa, transmissão, incidente, ordens, mapa, diálogo, técnico, sono, ajuda, nenhum. Desenho e roteamento de input consultam esse resultado. Manter inicialmente os flags existentes; não substituir por uma pilha genérica.

**Contrato:** transmissão pode cobrir incidente; fechar a transmissão revela o incidente. ESC no detalhe da solução volta à comparação; ESC na comparação obrigatória pausa, preservando o incidente. Fechar painel não cancela ordem aceita. Ações pendentes são limpas apenas nos caminhos adequados. Cursor e clique devem consultar a mesma camada efetivamente interativa, sem sugerir ação em controles encobertos.

**Aceite:** matriz de estados sobrepostos, pause/resume, teclado, cursor, clique e reinício; nenhuma confirmação alcança um painel oculto. Qualquer divergência observada entre comportamento atual e essa prioridade deve ser classificada como correção de UI, não escondida na refatoração.

#### T09 — Responsabilidades menores em abas

**Situação:** a aba da nave reúne 1.707 linhas de cenário, portais, física, animação e passos.

**Decisão:** separar blocos coesos de nave/cenário, portais, movimento do jogador e animação do jogador. Manter reprodução de áudio na camada de áudio; os gatilhos continuam próximos dos movimentos que os determinam. Não extrair uma aba por função nem fragmentar tabelas e operações inseparáveis.

**Contrato:** primeira mudança é movimentação de código sem alterar expressões, ordem de atualização ou inicialização. Como o Processing combina abas, conferir dependências entre inicializadores globais antes de movê-los. Não depender de uma nova ordem alfabética para inicializar tabelas.

**Aceite:** compilação do sketch completo e corte de entrega; mesmas campanhas, física, animação e áudio. O ganho é navegação/manutenção, não redução prometida de linhas ou FPS.

#### T10 — Modo de teste opcional

**Situação:** o modo manual pede remoção na entrega, mas funções e flags são chamados diretamente pelo runtime e o snapshot não o exclui.

**Decisão:** ampliar minimamente a costura opcional já usada pelo harness para entrada de depuração, overlay e consulta de destaque forçado. Defaults inertes ficam no runtime; o módulo de teste instala suas implementações. Preservar Ctrl+K, teleporte e destaque no desenvolvimento.

**Contrato:** consultar destaque forçado apenas em apresentação/disponibilidade visual, sem autorizar pagamento, entrega, aceite ou conclusão indevida. O corte de entrega exclui harness e módulo manual sem remover código por substituição textual. Nenhum arquivo de teste deve ser requisito para compilar o jogo.

**Aceite:** jogo com ambos, sem ambos e com apenas um módulo opcional; ausência de controles de debug na entrega; atalhos e teleporte continuam úteis no desenvolvimento. Atualizar documentação e script do snapshot sem publicar a branch automaticamente.

### 3. Questline: continuidade sem novas obrigações

#### 3.1 Arco da viagem

O arco editorial usa o calendário existente: dias 1–3 estabelecem pessoas e rotina; dias 4–7 enfatizam desgaste e consequências; dias 8–10 apontam a aproximação de Marte. O calendário altera tom, não incidentes, custos, posições, sorteio ou dificuldade.

Uma fala de fim de viagem nunca presume que um incidente específico aconteceu: cinco de sete são sorteados. Referências a reparo, morte, ajuda e omissão dependem de eventos realmente registrados. Não adicionar cutscenes, diálogos obrigatórios ao acordar nem uma ordem extra para concluir o arco.

#### 3.2 Catálogo editorial completo

Os IDs continuam internos. O jogador vê títulos em caixa de frase, motivação curta e verbos de ação. A tabela define a intenção editorial; objetos, origem/destino e números continuam nos dados mecânicos vigentes.

| ID | Título visível | Motivação/fala-base | Resultado mecânico preservado |
| --- | --- | --- | --- |
| V-01 | Um sinal para casa | Vera: “A antena está perdendo força. Vamos deixar o canal pronto.” | +8 moral |
| V-02 | Rumo a Marte | Vera: “Confira este cartão no console. Não podemos desperdiçar energia na rota.” | +8 energia; objeto no aceite |
| B-01 | Reserva em ordem | Bento: “Tem provisão separada na prateleira. Leve ao estoque antes que vire bagunça.” | +8 comida |
| B-02 | Peças para a próxima falha | Bento: “Traga a chave de torque. Quero essas peças prontas quando precisarmos.” | +2 peças |
| N-01 | Água para o grupo | Neusa: “O filtro está no console. Leve à mesa comum; eu cuido do restante.” | +8 água |
| N-02 | Um pouco de conversa | Neusa: “Leve estes cartões à mesa do grupo. Podemos começar ouvindo uns aos outros.” | +8 moral; objeto no aceite |
| S-01 | Energia sem desperdício | Sílvia: “Pegue o módulo no console e leve à distribuição. Vamos acertar essa carga.” | +8 energia |
| S-02 | Respirar com tranquilidade | Sílvia: “Traga o cartucho ao suporte. Melhor testar agora do que durante uma falha.” | +8 oxigênio |
| ENG-A | Alinhar o motor | Sílvia: “Com a chave de torque e duas peças, alinhamos esse eixo.” | -2 peças; resolve motor |
| ENG-B | Estabilizar a rotação | Sílvia: “O atuador estabiliza a rotação. Vai consumir energia.” | -8 energia; resolve motor |
| HUL-A | Vedar a ruptura | Sílvia: “Leve o kit até a ruptura. Precisamos segurar o oxigênio.” | -1 peça; resolve casco |
| HUL-B | Fixar a blindagem | Sílvia: “A placa fecha a abertura. Prepare energia para fixá-la.” | -6 energia; resolve casco |
| FOOD-A | Recompor o estoque | Bento: “Traga a caixa. Com uma peça, deixamos o estoque funcionando de novo.” | -1 peça; resolve comida |
| FOOD-B | Proteger as provisões | Bento: “O selante protege o que resta. O grupo não vai gostar desse aperto.” | -4 moral; resolve comida |
| CON-A | Abrir espaço para ouvir | Neusa: “Traga os cartões. A conversa vai ser difícil, mas precisamos dela.” | -5 moral; resolve conflito |
| CON-B | Sentar à mesma mesa | Neusa: “Uma refeição juntos pode acalmar os ânimos.” | -4 comida; resolve conflito |
| LIFE-A | Trocar o cartucho | Sílvia: “Traga o cartucho. Uma peça põe o suporte de volta.” | -1 peça; resolve suporte |
| LIFE-B | Recircular o ar | Sílvia: “O filtro de CO2 resolve. A recirculação vai puxar energia.” | -6 energia; resolve suporte |
| PWR-A | Isolar o circuito | Sílvia: “Busque o fusível. Trocamos a peça e isolamos a falha.” | -1 peça; resolve energia |
| PWR-B | Redistribuir a carga | Sílvia: “O módulo redistribui a carga. Vai ficar menos confortável para todos.” | -5 moral; resolve energia |
| COM-A | Restabelecer o contato | Vera: “Traga a bobina à antena. Ainda podemos recuperar o canal.” | -1 peça; resolve comunicações |
| COM-B | Manter a escuta | Vera: “A célula mantém a escuta. Precisamos reservar energia para isso.” | -5 energia; resolve comunicações |

Essas falas contextualizam resultados existentes; não introduzem racionamento, bônus, nova fabricação, personagens ou capacidades. Quando um texto sugere uma causa não representada, a implementação deve tratá-la como ambientação sem alegar um novo efeito sistêmico.

#### 3.3 Fluxo obrigatório enxuto

| Momento | Informação principal | Ação e efeito |
| --- | --- | --- |
| Duas preventivas | Necessidade, responsável, benefício, objeto, rota curta, perda se incompleta | “Escolher”; apenas seleciona |
| Seleção pendente | “Fale com Vera — Comando” | Pode trocar a seleção em Ordens antes do aceite |
| Confirmação presencial | Uma fala, benefício/perda, “Esta será sua ordem de hoje” | “Aceitar (ENTER)”; assume compromisso |
| Coleta | “Pegar bobina de transmissão?” e “Depois: antena — Comando” | “Pegar (ENTER)”; mantém a coleta física |
| Entrega preventiva | “Calibrar a antena” e “Moral +8” | “Concluir (ENTER)” |
| Entrega urgente | Resultado e “Custo: 1 peça; você tem 3” | “Aplicar reparo (ENTER)” ou verbo editorial equivalente |
| Conclusão | “Antena calibrada · Moral +8” | Fecha interação e atualiza objetivo, sem novo modal |
| Retomada | Mesmo problema/solução, prazo atual, negligência ainda aplicável | Confirma sem reiniciar prazo |
| Socorro | Pessoa, 8 água + 2 comida, uso da conclusão diária e negligência se aplicável | Confirma no beliche de socorro |
| Sono | Consequência desta noite e riscos fatais | “Dormir (ENTER)” |

Em incidentes, a comparação das duas soluções inclui custo exato, objeto e rota. A revisão final cabe no mesmo painel, sem empilhar uma nova janela. Custo insuficiente não desabilita a escolha da solução: mostrar “Você ainda não tem o necessário para entregar”. A entrega permanece bloqueada enquanto faltar recurso.

### 4. Voz e memória dos NPCs

#### 4.1 Direção de escrita

| Pessoa | Voz | Evitar | Exemplo após ajuda |
| --- | --- | --- | --- |
| Vera | Pragmática, curta, orientada à viagem | Repetir números do HUD em todas as falas | “Rota conferida. Estamos um pouco mais perto.” |
| Bento | Protetor do estoque, resmunga sem hostilizar | Humilhar o jogador ou virar tutorial ambulante | “Tudo no lugar. Assim eu consigo trabalhar.” |
| Neusa | Cansada, cuidadosa, atenção às pessoas | Sermões e promessas de sobrevivência garantida | “Obrigada. Hoje deu para respirar um pouco.” |
| Sílvia | Direta, concreta, focada no sistema | Jargão desnecessário e listas de regras | “Resolvido. Já era hora de esse motor colaborar.” |

Falas usam português natural, acentos e caixa de frase. Regra editorial: uma ou duas frases, até 160 caracteres por fala-base; conteúdo mecânico estruturado aparece separado. Nenhum texto completo é cortado para obedecer ao limite: reescrever o conteúdo. Títulos de sistema podem usar destaque, mas não parágrafos inteiros em maiúsculas.

#### 4.2 Seleção por contexto

Prioridade: confirmação pendente com o responsável; lembrete da etapa da ordem ativa; risco do próprio NPC; reconhecimento de consequência ainda não apresentado; oferta disponível; comentário sobre o problema mais urgente; ambientação da fase da viagem. As ações de socorro permanecem no ponto apropriado e não são transferidas para o diálogo.

O NPC responsável lembra o próximo passo com uma frase. Outro NPC evita recitar a ordem inteira: “A Sílvia está esperando esse cartucho no suporte.” Não usar “decisão em andamento”, “quest do dia já escolhida” ou “recursos insuficientes ou...” como fala humana.

Registrar apenas memória editorial mínima por NPC: último resultado relevante (ajuda, ordem incompleta, ordem não aceita, socorro), dia do resultado e se o reconhecimento já foi apresentado. Registrar na transição mecânica real, nunca no draw. Resetar ao iniciar nova partida; não persistir entre partidas.

Guardar o último resultado ocorrido no dia ou na noite anterior, sem sobrescrever por mera abertura de painel. Se ocorrerem múltiplos resultados, socorro tem prioridade sobre ajuda, ajuda sobre falha e falha sobre omissão. Depois de apresentado ou envelhecido além do dia seguinte, usar a fala contextual normal. Não acumular uma fila de conversas atrasadas.

Diálogos de ambientação têm duas variantes por NPC para cada fase da viagem; alternância determinística por conversa, sem sorteio por quadro e sem alterar o gerador de incidentes. A primeira repetição do mesmo contexto apresenta lembrete curto em vez de reapresentar exposição. NPC morto nunca fala. Nenhuma fala concede recurso, cancela problema ou cria objetivo adicional.

**Cobertura editorial exigida:** 22 textos-base da tabela, quatro vozes com confirmação/lembrete/conclusão/falha/omissão/socorro/risco, e 24 falas de ambientação (4 pessoas × 3 fases × 2 variantes). Composição por parâmetros é permitida nos lembretes factuais; evitar 22 cópias da mesma descrição longa.

### 5. Informação progressiva e composição da UI

#### 5.1 HUD durante exploração

- Preservar os oito cartões superiores e sua ordem; manter números, ícones, rótulos e barras.
- Substituir as quatro linhas densas inferiores por duas linhas prioritárias dentro da faixa existente: objetivo acionável e alerta/resultado contextual.
- Objetivo por estado: “Escolha uma ordem em Ordens”; “Fale com Neusa — Dormitório”; “Pegue o filtro — console da rota, Comando”; “Leve o filtro à mesa comum — Dormitório”; “Trabalho concluído. Descanse no seu beliche”.
- Com item, o verbo “Leve” e o nome do objeto informam transporte; remover a duplicação permanente de “Na mão”, origem passada e responsável quando não mudam o próximo passo.
- Se houver risco de morte ou crise fatal nesta noite, a segunda linha é reservada a isso. Depois, priorizar pessoa em risco, problema com menor prazo (desempate vigente) e resultado recente. Resultado não apaga alerta fatal: nesse caso aparece no próprio painel antes do fechamento ou junto à linha do objetivo por até 3 segundos.
- Mostrar “+N problemas” com acesso a Ordens/Mapa quando existirem outros. O HUD reduz volume, não o conjunto consultável de problemas.
- Manter os botões Mapa, Ordens e Ajuda. O selo de ofertas mantém sua função, sem novas setas pulsantes, balões permanentes ou indicadores concorrentes.

#### 5.2 Ordens e incidentes

Painel de comparação preserva duas alternativas lado a lado. Cada cartão mostra título, responsável, motivação de uma frase, efeito/custo exato, objeto, rota origem → destino e consequência compacta. O ID técnico não aparece na UI comum.

Preventiva: mostrar recompensa e perda se aceita e incompleta no cartão. Mostrar a negligência das duas ofertas em uma linha comum do painel, com números e recursos corretos. Não afirmar que concluir uma gera penalidade pela outra.

Incidente: perda diária, prazo e crise pertencem a um resumo comum do problema, em vez de repetir o mesmo texto nas duas soluções. Cada solução conserva seu próprio custo, objeto, rota e resultado. A revisão enfatiza o compromisso e o custo na entrega.

“Detalhes” expande uma região no mesmo painel para explicação completa e regras adicionais. Não cria segundo modal. Informação necessária para escolher já aparece sem expansão. Se a altura não comportar, paginar detalhes com controles visíveis; não reduzir fonte nem sobrepor rodapé.

Ordem ativa: mostrar etapa atual, destino, custo/recompensa e acesso a detalhes. Retomadas: substituir o rótulo ambíguo “Ofertas / próxima retomada” por navegação explícita “Ofertas” e “Pendências (N)”; cada pendência mostra problema e prazo. Acesso a retomadas respeita dias e bloqueios atuais.

#### 5.3 Interação contextual

Diálogo mantém retrato e painel inferior. Painel técnico de coleta/entrega passa a usar uma faixa inferior compacta dentro da área disponível, dimensionada pelo conteúdo, com título, até duas linhas factuais e rodapé. Não escurecer toda a cena para uma coleta simples; o bloqueio de movimento permanece enquanto a interação está aberta.

Painéis de escolha e sono continuam usando fundo escurecido. Manter a cena reconhecível e nunca cobrir o texto de custo por retrato. Confirmar uma ação fecha o painel; sucesso não abre outra janela.

Vocabulário de saída: “Voltar (ESC)” na revisão; “Agora não (ESC)” antes de aceitar/coletar/entregar; “Fechar (ESC)” em consulta; “Continuar (ENTER)” somente para informação. Evitar “Cancelar” onde isso possa sugerir cancelamento da ordem aceita.

Erros descrevem causa real: “Falta 1 peça. Você tem 1 de 2”; “Você já concluiu seu trabalho de hoje”; “Confirme primeiro com Vera”; “Aproxime-se da bancada”. UI consulta uma razão estruturada, mas a função de ação revalida o estado ao confirmar. Ocultar/desabilitar botão não substitui validação mecânica.

#### 5.4 Sono e previsão

Título: “Encerrar o dia?”. Resumo: trabalho concluído/pendente, variações de recursos desta noite e riscos. Usar tabela compacta com recurso, variação e valor previsto; peças não são tratadas como porcentagem.

Perdas de ordem/negligência, consumo, problemas, risco e crises devem seguir a mesma ordem do processamento real. A previsão deve ser calculada sem mutar a partida, reproduzir a noite corrente e indicar a causa de derrota quando houver. Não prever incidentes futuros nem consumir sorteio. Usar funções puras comuns de cálculo quando possível, mantendo o modelo independente como referência externa.

Morte prevista, motor destruído e recurso que causa derrota nunca ficam em “Detalhes”. Todos os avisos fatais devem caber no resumo; os demais problemas podem ir à área paginada. Falha de quest urgente significa problema persistente, não uma multa inventada. Socorro/retomada em dia preventivo mantém o aviso de negligência aplicável.

Essa previsão exata é uma melhoria funcional de apresentação, além dos dez achados técnicos. Deve receber testes próprios; não alterar o processador noturno para fazer o resultado coincidir com um preview incorreto.

#### 5.5 Layout, legibilidade e feedback

Preservar a grade e as regiões principais. Corpo de texto usa 16 px reais e entrelinha de 18; prompts contextuais de 11 px são exceções existentes. Maiúsculas ficam restritas a rótulos curtos quando úteis. Cortar redundância antes de diminuir fonte.

Nenhum significado depende apenas da cor: usar rótulos, valores, verbo e estado habilitado. Cor de efeito positivo/negativo acompanha o sinal numérico. Controle encoberto não recebe cursor de ação.

Sem animação de digitação, esperas artificiais ou som adicional obrigatório. Reutilizar halos, animações e áudio existentes. Pulso permanece apenas onde já comunica disponibilidade; não pulsar cada campo da nova UI.

#### 5.6 Mapa útil: planejar o próximo deslocamento

**Solicitação adicional do usuário:** o mapa precisa mostrar melhor para onde ir e ter utilidade real. Esta seção substitui a proposta anterior de apenas preservar o mapa consultivo. A orientação espacial é parte de E5; o mapa continua sem teleporte e sem executar ações de quest.

**Diagnóstico verificado:** o mapa atual apresenta quatro cartões em sequência, localização da sala atual e detalhes da sala clicada. A coleta/entrega só aparece quando a sala correspondente está selecionada. Não há conexões desenhadas, posição do técnico dentro da sala ou orientação por porta/convés. A implementação inclusive pode mostrar o destino de entrega enquanto a coleta ainda está pendente. O redesenho distingue destino futuro de próximo passo executável.

**Objetivo de produto:** responder em uma abertura: “Onde estou?”, “Para onde vou?” e “Qual é a próxima passagem?”. O mapa deve ensinar a disposição da nave e permitir memorizar rotas, sem transformar exploração em seguir uma linha permanente na cena.

##### Composição

- Usar um painel amplo dentro de 640×360 lógicos, com margem externa de 12. Título e objetivo no topo; corpo dividido entre esquema de conexões e detalhe espacial; instrução de próximo passo e botão Fechar no rodapé. Manter corpo em 16 px reais.
- Na visão geral, colocar Comando como hub e ligar somente as salas conectadas pelos portais configurados. As linhas representam conexões, não corredores físicos ou distâncias. Mostrar nome legível em todos os nós; miniaturas são opcionais e não carregam informação exclusiva.
- Localização atual: marcador de pessoa com rótulo “Você”. Objetivo ativo: marcador de alvo e verbo, como “Pegar filtro”. Ambos aparecem quando compartilham a mesma sala, sem um substituir o outro. Forma e texto distinguem os marcadores mesmo sem cor.
- Destacar somente o caminho da sala atual até a sala do objetivo, com sentido de percurso. Exemplo: “Depósito → Comando → Dormitório”. Salas e conexões fora desse percurso continuam visíveis com menor destaque.
- O detalhe espacial abre na sala atual, mostrando seus três conveses, escadas com trechos reais, portas e posição do técnico. Mostrar o ponto de objetivo se estiver nessa sala; caso contrário, destacar a porta de saída da rota. Projetar as coordenadas de mundo na área do esquema, sem depender de imagem de fundo.
- Clicar numa sala altera apenas o detalhe consultado. Manter objetivo e rota geral visíveis. Oferecer “Minha sala” e “Destino” para focar o detalhe; esses controles não movem o jogador nem alteram a ordem.
- Marcadores comuns de estações aparecem discretamente, sem rótulos de todas elas ao mesmo tempo. Nomear apenas ponto de objetivo, porta da rota e ponto selecionado; seleção de outros pontos abre informação curta no próprio detalhe, nunca outro modal.
- Problemas ficam em um resumo secundário “Alertas (N)”, com expansão/paginação no próprio painel. Não preencher todas as salas com “0 problemas”. Risco fatal mantém aviso visível, mas não troca o alvo de navegação silenciosamente.

##### Alvo automático por estado

| Estado | Alvo do mapa | Texto/condição |
| --- | --- | --- |
| Preventiva selecionada e não aceita | Responsável pela confirmação | “Fale com Neusa — Dormitório” |
| Ordem aceita em coleta | Origem do objeto | “Pegue o filtro — console da rota, Comando” |
| Ordem em entrega | Destino do objeto | “Leve o filtro à mesa comum — Dormitório” |
| Conclusão diária realizada | Beliche do técnico | “Volte ao seu beliche — Dormitório” |
| Nenhuma ordem escolhida | Nenhuma rota automática | “Escolha uma ordem em Ordens para ver o caminho”; botão Ordens troca de painel sem empilhar modais |
| Pessoa em risco e nenhuma ordem ativa | Socorro disponível para consulta | “Ver local do socorro” destaca o beliche de socorro como consulta opcional; não aceita nem conclui socorro |
| Retomada ainda não confirmada | Apenas consulta da pendência | Não apresentar coleta como liberada; após confirmação, apontar a origem normalmente |
| Alvo inválido/ausente | Nenhuma rota fictícia | “Local indisponível”; preservar mapa e apontar a pendência de dados na validação |

O alvo da quest tem prioridade sobre consultas opcionais. Consultar socorro ou outro ponto não muda o HUD nem a ordem. A consulta é identificada como “Consulta”, pode ser encerrada com “Minha rota” e é descartada ao fechar o mapa. A próxima abertura sempre usa o estado real atual. Sem ordem, o jogador também pode consultar o beliche para optar por dormir, com aviso de que isso não resolve as pendências.

##### Orientação de salas e conveses

- Calcular caminho entre salas usando a tabela de portais como grafo direcionado; escolher menor número de travessias e desempatar pela ordem estável da tabela. Com quatro salas, uma busca simples basta. Não fixar em código que todo percurso passa pelo Comando, embora a configuração atual tenha essa topologia.
- O próximo passo fornece sala atual, porta de saída, convés/altura e destino. Exemplo: “Vá à porta do Comando no convés médio”. Ao entrar no Comando, recalcular para a próxima porta; ao chegar à sala-alvo, indicar estação/NPC e seu convés.
- Dentro da sala, usar os conveses e os trechos declarados das escadas para indicar a próxima escada que conecta o nível atual ao nível necessário. Para rotas com mais de uma escada, minimizar trocas de convés; desempatar por distância horizontal inicial e, depois, índice estável. Não desenhar passagem por uma escada que não atende aquele trecho.
- Destacar no esquema a escada indicada e nomear sua posição relativa (“escada à esquerda”, “escada à direita” ou referência horizontal quando necessário). Não prometer caminho milimétrico, salto automático ou distância/tempo estimado.
- Para jogador no ar/escada, mostrar posição real; usar o trecho da escada quando identificável. Quando ainda não houver convés de referência seguro, mostrar a porta/objetivo e seu nível sem inventar comando de subida/descida. Para porta livre sem deck, mostrar sua altura real e “abertura fora do convés”, sem atribuir um convés falso.
- Casco usa o ponto sorteado da campanha, nunca posição ilustrativa fixa. Alvo que coincide com outro marcador continua selecionável e identificado por rótulo; priorizar o ponto de quest na representação.
- Fechar o mapa devolve a mesma sala, posição, direção e estado mecânico. O mapa não avança tempo de jogo, sorteio, quest ou recursos. Respeitar bloqueio de abertura durante transições de porta para evitar mudança de sala sob o painel.

##### Ligação com o HUD e limite de informação

HUD e mapa consultam o mesmo alvo atual. Após coleta, a rota antiga desaparece e o destino de entrega assume; após entrega, o beliche assume. V-02 e N-02 pulam diretamente para entrega quando o objeto é recebido no aceite.

O HUD mantém objetivo e sala, sem reproduzir todo o mapa. O próximo deslocamento detalhado aparece no mapa; não adicionar minimapa permanente, trilha luminosa, bússola piscante ou setas sobre todas as portas. Preservar os nomes de destino existentes nas portas para o jogador aplicar no cenário o que aprendeu no mapa.

##### Interfaces e aceitação específicas

Adicionar consultas puras de alvo atual, rota de salas e próxima ligação vertical. Elas retornam identificadores de sala/ponto/porta/escada e motivo de ausência de rota; o render resolve rótulos. Não consumir RNG nem alterar estado do jogador. Recalcular ao abrir e ao mudar a consulta; invalidar a rota se alvo, sala ou tabelas de navegação mudarem em fixtures. Não introduzir um motor de pathfinding contínuo.

O mapa só é aceito se um jogador conseguir apontar a próxima porta e o convés sem receber explicação externa. Verificar os 12 pares ordenados entre salas distintas, alvo na mesma sala em outro convés, V-02/N-02, etapa de coleta/entrega, retorno ao beliche, casco aleatório, socorro opcional, NPC morto, alvo ausente, ausência de caminho, portas arbitrárias e arte ausente.

No playtest, incluir um percurso Depósito → Dormitório via Comando e outro entre conveses na mesma sala. Pelo menos 2 de 3 participantes devem identificar em até 10 segundos a próxima passagem após abrir o mapa e alcançar o objetivo sem instrução do avaliador. Registrar número de reaberturas e voltas erradas; comparar com a versão anterior. Reaberturas frequentes por desorientação pedem ajuste de legibilidade, não adição automática de mais marcadores. Testar teclado/mouse, marcadores sobrepostos e nenhum teleporte ou alteração da decisão ao consultar.

### 6. Organização dos dados e interfaces internas

- Separar catálogo mecânico (IDs, recursos, custos, origem/destino, proprietário) de catálogo editorial (título curto, motivação e falas). Ambos se ligam pelos IDs existentes, não por texto exibido nem posição acidental de uma lista traduzida.
- Acrescentar validação de integridade ao harness: cobertura dos 22 IDs, responsáveis válidos, pontos válidos, ausência de entrada editorial faltante e textos dentro do orçamento. Em runtime, conteúdo editorial faltante cai em texto factual curto existente, sem bloquear gameplay.
- Helpers de consulta produzem objetivo atual, motivo de bloqueio, resumo de problema e conteúdo do painel. Não gastam recursos, não avançam animação, não registram memória e não alteram RNG.
- Apresentação é renderização dessas consultas. Ações continuam em funções de domínio existentes e revalidam proximidade, disponibilidade e custo.
- Evitar construir um sistema genérico de diálogos. Catálogos planos, seletores contextuais e pequeno estado editorial bastam para quatro NPCs e 22 quests.
- Não compartilhar implementação de regras com o modelo Node: sua independência detecta regressões. Compartilhar fixtures/resultados esperados, quando útil, não o algoritmo que se pretende verificar.

### 7. Documentação e fonte de verdade

Antes de implementar, resolver divergências de posições de escadas/portas, animações suportadas, tipografia e composição da entrega comparando decisões registradas e código. Não mover entidades para caber em um documento antigo. Se duas decisões aprovadas conflitam, registrar o conflito e resolver antes de tocar a área.

Atualizar documentação de fluxo, HUD, salas, personagens, arquitetura e verificação com a experiência aprovada. A regra de mostrar tudo antes do compromisso continua válida; a obrigação de repetir todos os campos no HUD e em cada interação é substituída pela informação progressiva desta proposta após sua aprovação.

Manter as ADRs de quests físicas e ciclo simplificado; registrar uma nova decisão de apresentação para informação progressiva e falas contextuais. Não reescrever decisões históricas como se o novo desenho já existisse.

Enxugar o resumo operacional para estado atual, evidências e próxima fronteira, transferindo histórico detalhado para registro preservado e referenciado. Não apagar evidências de decisões passadas. Retirar instruções de cópias concorrentes e alinhar artefatos transitórios ao diretório autorizado, com limpeza ao fim.

### 8. Ordem de implementação e entregas

| Etapa | Entrega | Depende de | Evidência de saída |
| --- | --- | --- | --- |
| E0 | Reconciliar documentação, conferir tracker, atualizar índice e capturar baseline | Acesso necessário e revisão desta proposta | Matriz vigente, fontes e baseline |
| E1 | T01, T02, T06 e T07 | E0 | UI visualmente equivalente; regressões passam |
| E2 | T03, T04 e T05 | E1 | Portais equivalentes, caches medidos, fallback preservado |
| E3 | T08, T09 e T10 | E2 | Input consistente; runtime e corte de entrega compilam |
| E4 | Catálogo editorial, memória e questline | E3 | Todas as quests cobertas; nenhuma mudança numérica |
| E5 | HUD, mapa de orientação, comparação, interação, sono e detalhes | E4 | Navegação compreensível, cenários gráficos aprovados e preview exato |
| E6 | Playtest, ajustes editoriais/layout e documentação final | E5 | Critérios de diversão/clareza e regressão satisfeitos |

Essa tabela representa dependências propostas, não o estado nativo das issues, que não pôde ser consultado. Não criar automaticamente dez issues desconectadas. Publicar uma spec principal; eventual decomposição deve manter os IDs T01–T10 e E0–E6.

Antes de editar qualquer função, classe ou método, executar impacto upstream com índice atualizado, conferir chamadores e fluxos e reportar risco alto/crítico. As áreas mais sensíveis por inspeção são modais, portais, inicialização e noite; isso não substitui o relatório do GitNexus. Não instalar ferramentas sem autorização. Antes de commit, conferir o escopo com detect_changes.

## Testing Decisions

### Costuras e referência

Cobertura confirmada pelo usuário nesta sessão: **harness do próprio sketch, modelo de balanceamento independente e playtest de clareza/diversão**. O harness é a costura principal e já permite simular campanhas e capturar cenas. Não criar uma segunda infraestrutura de testes para exercitar helpers privados.

Um bom teste executa uma interação ou um dia e verifica consequência observável: destino, objeto, recursos, estado, texto relevante, disponibilidade e pixels. Evitar testes que apenas reproduzam condicionais ou obriguem uma organização específica de arquivos.

A análise anterior executou o modelo numérico: BALANCE CHECK: PASS, com 2.520/2.520 sequências vencedoras pela estratégia de reserva de peças. As 169 asserções do harness gráfico são evidência histórica documentada, não execução realizada nesta elaboração. Capturar baseline novo antes da implementação.

### Matriz de aceitação funcional

| Grupo | Cenários obrigatórios | Resultado esperado |
| --- | --- | --- |
| Preventivas | Duas ofertas, troca antes de aceitar, confirmação distante, aceite presencial, V-02/N-02, falha e negligência | Mesmas regras/recursos; seleção nunca apresentada como aceite |
| Incidentes | Sete tipos, ambas as soluções, revisão/volta, custo insuficiente na escolha e na entrega | Escolha permitida sem custo disponível; entrega cobra uma vez; problema correto resolvido |
| Retomada | Dia sem incidente, novo incidente, prazo parcial, seleção preventiva pendente | Prioridade e bloqueios atuais; prazo não reinicia; negligência correta |
| Socorro | Sem risco, risco ativo, recursos insuficientes, limite diário e morte do responsável de oferta | Custo/limite preservados; ofertas filtradas; nenhuma fala de morto |
| Noite | Ordem concluída, incompleta, não aceita, risco anterior, crises simultâneas, fatalidade e dia 10 | Preview coincide com processamento; desempate e derrota/vitória preservados |
| Portas | Arte presente/ausente/parcial, retorno imediato, outro percurso, porta livre e chegada aérea | Mesma chegada, direção, som e fases; gravidade correta |
| Movimento | Andar/correr, teclas opostas, pulo, subida, saída lateral, rearme de escada | Mesma velocidade, colisão, animação e cadência de passos |
| Modais | Pausa sobre transmissão/incidente, ESC revisão/comparação, detalhes abertos, clique encoberto | Só a camada ativa recebe input; fechar não cancela quest |
| Mapa | 12 pares entre salas, mesmo cômodo/outro convés, etapas, beliche, casco sorteado e consulta opcional | Rota e próxima passagem corretas; alvo igual ao HUD; nenhuma mudança mecânica |
| NPCs | Cada contexto editorial, repetição, fases, novo dia, reset, morte | Voz correta, estado verdadeiro, sem repetição contínua ou efeito mecânico |
| Assets | Aseprite/LPC, arte parcial/ausente, halos parciais, áudio ausente | Fallback funcional e pixel art preservada |
| Entrega | Módulos opcionais em todas as combinações; corte gerado sem publicar | Runtime independente; debug ausente do produto de entrega |

### Verificação visual

- Usar os modos existentes de captura, hit-test, escadas e pipeline. Completar com interação real em 720p e janela ampliada/letterbox.
- Em E1–E3, comparar screenshots com o baseline e justificar diferenças intencionais separadamente.
- Em E4–E5, capturar comparação preventiva, incidente, detalhe, aceite com NPC, coleta, entrega insuficiente, conclusão, retomada, socorro, noite densa, fatalidade, pausa, mapa e desfechos.
- Confirmar textos longos/acento, nenhum overflow, rodapés clicáveis, contraste, alinhamento, camada ativa, retrato e destino visível.
- Casos de noite com muitos problemas devem mostrar todos os riscos fatais sem invadir botões; detalhes paginados não truncam conteúdo.
- Não usar apenas leitura do código ou screenshots geradas sem interação para afirmar que teclado, mouse e modais funcionam.

### Desempenho

Medir antes/depois na mesma máquina, assets, sala e tamanho de janela, separando inicialização de quadros estabilizados. Registrar mediana e p95 do tempo por quadro em três amostras de 30 segundos, mais tempo de carregamento e número de preparações de buffer/faixa. Instrumentação temporária não entra na entrega.

Critério técnico: ícones não são recompostos continuamente e pisos idênticos não são construídos três vezes. Nenhuma regressão consistente de p95 acima de 10% sem investigação; se houver ruído, repetir em condições controladas antes de atribuir causa. Não remover suavização, fallback ou qualidade gráfica para atingir número.

### Playtest de diversão e clareza

Realizar com três pessoas que não conheçam o código. Usar um trecho curto com preventiva, incidente, entrega insuficiente e previsão de noite perigosa; permitir exploração livre e conversas opcionais. Na comparação antes/depois, alternar a ordem das versões entre participantes para reduzir efeito de aprendizagem.

Observar sem explicar: tempo para encontrar próximo objetivo, consultas repetidas, erros de seleção/aceite, bloqueios incompreendidos, duração de leitura e interrupções. Não inferir diversão somente por velocidade.

Ao fim, pedir que expliquem o que fizeram, o que custou, o que aconteceria se dormissem e quem são dois NPCs; colher notas de 1 a 5 para clareza, vontade de continuar e prazer no ciclo. Perguntar qual momento foi mais interessante e qual pareceu burocrático.

Metas iniciais de aceitação: pelo menos 2 de 3 encontram o próximo passo em até 10 segundos usando HUD/cena; 3 de 3 reconhecem o aviso fatal antes de confirmar sono; pelo menos 2 de 3 explicam corretamente o custo e distinguem seleção de aceite; pelo menos 2 de 3 reconhecem vozes diferentes e dão nota ≥4 para clareza e vontade de continuar. Nenhuma etapa obrigatória ganha confirmação extra. Esses números são critérios de projeto, não resultados já obtidos nem prova estatística.

Se falhar, ajustar primeiro texto, hierarquia e feedback, depois repetir os cenários afetados. O registro da campanha E6 de 20/09/2026 marcou 2/3 para próxima passagem em até 10 segundos, 3/3 para aviso fatal, 2/3 para seleção versus aceite, 2/3 para vozes e 2/3 para nota mínima 4. A revisão de 21/09/2026 não revalidou esse playtest e não encontrou a orientação por escadas descrita em A2 no código atual. Os quatro ajustes permanecem registrados como resultados históricos da campanha.

## Out of Scope

- Alterar custos, recompensas, dificuldade, duração, sorteio, quantidade de quests ou condições de término.
- Acrescentar missões paralelas, combate, minigames, crafting, inventário livre, romance, reputação ou árvores de diálogo.
- NPCs móveis, salas novas, mudança de topologia ou redesign de rotas/posições nesta versão.
- Novos assets obrigatórios, dublagem, fontes externas, bibliotecas ou migração de engine.
- Remover fallbacks, compatibilidade Aseprite/LPC, harness ou modelo de balanceamento para reduzir contagem de linhas.
- Substituir simulação independente por implementação compartilhada que possa reproduzir o mesmo erro.
- Publicar build, fazer push, fechar issues, alterar balanceamento ou implementar esta spec durante a tarefa de documentação.

## Further Notes

### Riscos e cuidados

- **Informação escondida:** detalhes opcionais não podem esconder custo, irreversibilidade ou risco fatal. Critérios de conteúdo prevalecem sobre minimalismo visual.
- **Narrativa falsa:** comentários sobre ajuda/perda exigem evento real; fase da viagem não prova que determinado incidente ocorreu.
- **Abstração excessiva:** eliminar repetição comprovada; não construir engine genérica de UI/quests para um elenco pequeno.
- **Cache obsoleto:** fixtures que trocam imagens devem invalidar a preparação correspondente. Não confundir imagem carregada com cache válido.
- **Regressão de física/áudio:** movimento e animação têm ordem intencional; separar abas não autoriza rearranjar a atualização.
- **Preview divergente:** conferir a previsão contra uma noite realmente processada a partir de estado equivalente, incluindo crises simultâneas e limites.
- **Documentação conflitante:** posições e políticas recentes precisam de reconciliação explícita; a proposta não escolhe silenciosamente uma fonte antiga.

### Fronteira desta entrega

Este documento é o artefato detalhado solicitado. Os dez achados e o redesenho editorial/visual estão especificados, com contratos preservados, interfaces internas, cenários e ordem de execução. Nenhum código do jogo foi modificado.

A publicação da spec e sincronização do Wayfinder continuam pendentes por indisponibilidade de acesso autenticado. Não há label aplicada, ticket atribuído, bloqueador nativo confirmado ou alegação de implementação concluída. Quando o acesso estiver disponível, conferir se já existe issue equivalente, publicar/atualizar a spec sem duplicar, aplicar ready-for-agent conforme o fluxo invocado e sincronizar o resumo operacional e o corpo do Wayfinder.

Fonte de processo: skill to-spec invocada pelo usuário. Base de produto: análise daquela conversa, contrato mecânico, ADRs de quests físicas/ciclo simplificado, arquitetura, fluxo, HUD, salas, fontes, inventário, personagens e código então disponível. Este fechamento registra o estado da proposta em 19/09/2026. A revisão local de 21/09/2026 compara a implementação com estes requisitos sem alterar a decisão de produto ou declarar os critérios atendidos.
