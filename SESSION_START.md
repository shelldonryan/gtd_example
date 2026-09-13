# Last Horizon — Session Start

> Documento obrigatório de abertura e encerramento de toda sessão. Leia antes de
> analisar, editar ou implementar qualquer coisa.

Atualizado em: 2026-09-12 (após a sessão de grilling do [#14](issue://14))
Destino Wayfinder: [issue #1](issue://1)

## Como usar este arquivo

1. Leia este documento antes de qualquer avanço.
2. Recalcule a fronteira Wayfinder nas issues; o snapshot abaixo pode ficar velho.
3. Leia as fontes específicas da tarefa e compare intenção, documentação e código.
4. Antes de editar, reporte: entendimento, conflitos, lacunas e ticket escolhido.
5. Não invente uma decisão que altere o gameplay, a arquitetura, os controles, os
   objetivos ou os personagens. Pergunte ao usuário quando a decisão for material.
6. Atualize este arquivo imediatamente quando o usuário confirmar uma decisão e
   novamente antes de encerrar a sessão.

Este arquivo é um resumo operacional. Os detalhes continuam nas fontes específicas;
não copie documentos inteiros para cá.

## Legenda de estado

- **CONFIRMADA** — decisão explicitamente confirmada pelo usuário.
- **IMPLEMENTADA** — comportamento comprovado no código e na verificação.
- **ABERTA** — ainda exige decisão ou trabalho.
- **PROVISÓRIA** — usada para avançar, mas pode mudar.
- **SUPERSEDED** — decisão antiga substituída; não usar como regra atual.
- **INFERÊNCIA** — hipótese; nunca tratar como requisito.

## Hierarquia de autoridade

Em caso de conflito, siga esta ordem:

1. Última decisão confirmada pelo usuário.
2. Decisões CONFIRMADAS neste arquivo.
3. Documento específico do domínio correspondente.
4. Issue do Wayfinder e histórico de decisões.
5. Código atual, que descreve a implementação existente, não necessariamente a
   intenção final.

Se duas fontes de autoridade equivalente divergirem, pare e reporte o conflito.
Não escolha silenciosamente. Depois da decisão do usuário, atualize este arquivo
e as fontes afetadas.

## Contradições conhecidas

- `issue://1` foi sincronizado em 12/09: o loop descrito no mapa já é o das
  decisões D-008/D-009 (sala 2D jogável, tarefa em cadeia de passos, briefing no
  comando), a lista de decisões aponta o #14, `interface/ROOMS.md` entrou nas
  fontes de verdade e o mapa ganhou a seção **Fronteira**. #14, #15 e #16 estão
  ligados como sub-issues (contador 7/15).
- `issue://13` registra o que deveria ser ignorado no antigo exemplo de
  plataforma. Física, pulo e teclado deixam de ser itens a ignorar no
  Last Horizon; combate e IA de inimigos continuam fora do escopo.
- `issue://9` e o sketch atual descrevem uma prova de menus e botões. Eles são
  evidência da implementação existente, não da jogabilidade final.
- O **código** ainda tem três pontos que os documentos já corrigiram: imprime
  "ARES-7" no mapa macro (a nave não tem nome), rotula o cartão como
  `TRIPULAÇÃO` (agora é **A BORDO**, só sobreviventes) e conta o técnico entre
  os quatro. Tudo isso está no escopo do [#16](issue://16).
- Os documentos do vault foram sincronizados em 12/09: `events/CREW_ISSUES.md` e
  `events/SYSTEM_FAULTS.md` não dizem mais que a resposta do evento gasta a ação
  do dia.

## Direção atual do produto

Last Horizon é um protótipo de gerenciamento de recursos com exploração 2D em
plataforma dentro de uma nave espacial. A nave **não tem nome**.

- `assets/HUD_CONCEPT_ART.png` é referência de linguagem visual do mapa macro e
  do HUD; os números do mock (520/600, Dia 084, 42 tripulantes) são ilustrativos —
  a fonte é `mechanics/ACTIONS.md`.
- `assets/COMMAND_ROOM_CONCEPT_ART.png` é a linguagem visual das salas: cena
  lateral 2D em três conveses ligados por escadas, com terminais.
- Clicar em um cômodo no mapa macro abre a sala correspondente; o técnico é
  controlado diretamente dentro dela (setas/WASD, espaço, E, ESC).
- Cada tarefa do dia é uma **cadeia de poucos passos** (falar, coletar, instalar)
  e passa por mais de um cômodo. Movimento e passos intermediários são livres;
  só a interação que **conclui** a tarefa gasta a ação do dia.
- Todas as estações ficam ativas; o briefing do comando sugere uma tarefa sem
  travar nada. O jogador escolhe qual perda aceitar.
- Quatro sobreviventes a bordo, além do técnico: **Vera** (piloto, comando),
  **Bento** (intendente, depósito), **Neusa** (enfermeira, dormitório) e
  **Sílvia** (mecânica, energia). Ficam parados em ponto fixo e são interativos;
  não há rotinas autônomas.
- Botões existem só para menus, pausa e rodapé ("Passar dia" e "Voltar").

### Loop de jogo confirmado

1. A partida dura dez dias.
2. O dia abre com um evento a partir do dia 2; o dia 1 não tem evento e o
   briefing da Vera faz o papel de tutorial.
3. O jogador responde ao evento; a resposta não consome a tarefa do dia.
4. O jogador abre um cômodo pelo mapa macro.
5. Controla o técnico pela cadeia da tarefa e conclui uma tarefa por interação.
6. Pressiona `Passar dia` (rodapé, mouse).
7. Recursos, moral, vitória/derrota e avanço do dia são processados.
8. O próximo evento é sorteado.

Os números e as consequências continuam em `mechanics/ACTIONS.md` até uma nova
decisão explícita. Os pontos de interação e as cinco tarefas estão em
`interface/ROOMS.md`.

## Restrições técnicas confirmadas

- Processing 4.5.6, modo Java, sketch `.pde`.
- Resolução-base 640×360, proporção 16:9, janela escalável com ampliação inteira;
  2× (1280×720) é o padrão.
- `noSmooth()` e `pixelDensity(1)` para preservar pixel art.
- Código em inglês, sketch plano, sem hierarquia de classes desnecessária,
  funções curtas e separação `update`/`draw`.
- Tarefas são **dado**: tabela em `tasks.pde` (arrays paralelos), pontos de
  interação em lista e um despachante de efeitos. Tarefa nova = 1 linha + 1
  estação.
- Sala jogável: 470×280 px, três conveses e duas escadas, **sem câmera**.
- Movimento: personagem 16×24, andar 1,5 px/quadro, pulo de 48 px, gravidade 0,5,
  escada 1,0, alcance de interação 12 px, plataformas atravessáveis por baixo.
- Controles: setas e WASD (andar e escada), espaço (pular), E (interagir), ESC
  (pausa). "Passar dia" e "Voltar" só pelo mouse.
- Tipografia: título 32 px, leitura 16 px, entrelinha 18 px, botão reduz até
  10 px só quando a frase não cabe. HUD com ícones de 16×16 e sem rótulo nos
  cartões de recurso.
- Um PNG por quadro, no padrão `entidade_frame_N.png`, com o `.aseprite` junto
  do sketch para manter a entrega portátil.
- Áudio offline sem biblioteca externa: `javax.sound.sampled`, WAV PCM 16 bits em
  `data/`.

## Estado real da implementação

**O código ainda não acompanha a direção atual.** O sketch em `last_horizon/`
implementa menus, mapa, salas estáticas, botões, ciclo de recursos/eventos e
captura automática. Ainda não implementa:

- controle do técnico;
- gravidade, pulo, escadas e colisão de plataformas;
- pontos de interação, cadeia de passos e a tabela de tarefas;
- NPCs dentro das salas;
- o HUD novo (ícones, A BORDO, alerta piscando) e a remoção do "ARES-7".

`code/SKETCH_ARCHITECTURE.md` registra essa diferença. As capturas existentes em
`last_horizon/output/` comprovam a camada de menus/mapa, não a exploração.
O ticket [#15](issue://15) cobre a sala jogável e o [#16](issue://16) o HUD.

Os arquivos `characters/npcs/NPC_1.md` a `NPC_4.md` estão preenchidos com Vera,
Bento, Neusa e Sílvia. Não inventar nomes, personalidades ou histórias novas
sem decisão do usuário.

## Fontes obrigatórias

### Mapa e coordenação Wayfinder

- `issue://1` — destino, fronteira e decisões gerais do projeto.
- `issue://?state=all` — inventário atual de issues.
- `issue://14` — decisões D-006 a D-023, já fechado (registro histórico).
- Issues específicas do ticket escolhido, incluindo seus bloqueadores nativos.

### Domínio e produto

- `README.md` — escopo resumido.
- `history/CONTEXT.md` — narrativa e vocabulário do domínio.
- `mechanics/ACTIONS.md` — números, custos, ciclo diário e condições de término.
- `interface/ROOMS.md` — pontos de interação, tarefas e geometria dos cômodos.
- `interface/FLOW.md` — mapa macro, salas, eventos, controles e navegação.
- `interface/HUD.md` — informações persistentes e controles de alto nível.
- `interface/MENU_INIT.md`
- `interface/MENU_GAME_OVER.md`
- `interface/MENU_VICTORY.md`
- `events/CREW_ISSUES.md`
- `events/HAZARDS.md`
- `events/SYSTEM_FAULTS.md`
- `characters/PLAYER.md`
- `characters/npcs/*.md`

### Visual e implementação

- `assets/HUD_CONCEPT_ART.png` — mapa macro e HUD.
- `assets/COMMAND_ROOM_CONCEPT_ART.png` — sala lateral jogável.
- `code/SKETCH_ARCHITECTURE.md` — arquitetura registrada e lacunas conhecidas.
- Todos os `.pde` de `last_horizon/` quando a tarefa tocar o código.

`interface/MENU_CONFIGURATION.md` está fora do escopo. Os arquivos de pesquisa
(`research/*.md`) vivem nas branches `research/*`, não na árvore de trabalho da
`prototype/sketch-architecture`; não presumir arquivo ausente.

## Integração com o Wayfinder

### Papéis das labels

- `wayfinder:map` — destino, contexto e fronteira do projeto.
- `wayfinder:grilling` — decisão de design que exige conversa.
- `wayfinder:prototype` — provar uma ideia, estado ou balanceamento.
- `wayfinder:task` — executar uma alteração técnica concreta.
- `wayfinder:research` — investigar um fato externo ou uma convenção.

Para as sessões indicadas no mapa #1:

- decisão de design: combine `/grilling` e `/domain-modeling`;
- aparência ou estado: use `/prototype`;
- fato externo: use `/research`;
- execução técnica: use a issue `wayfinder:task` correspondente.

Use a skill correspondente à label do ticket. Uma issue pode exigir leitura de
mais de uma fonte, mas não se deve pular a etapa de entendimento do mapa.

### Regra de disponibilidade

Uma issue está disponível quando está **OPEN** e não possui nenhum bloqueador
nativo **OPEN**. Bloqueadores CLOSED não impedem o trabalho. Recalcule esta
regra nas issues no início de cada sessão; não confie apenas na tabela abaixo.

### Snapshot atual da fronteira

Sincronizado com o grafo nativo de dependências em 2026-09-12, depois de fechar
o #14 e abrir o #15 e o #16:

| Issue | Estado | Bloqueadores abertos | Relação relevante |
|---|---|---|---|
| #4 — Executar e capturar o sketch | disponível | — | bloqueia #12 |
| #7 — Documento de entrega | disponível | — | independente |
| #8 — Inventário de assets | disponível | — | depende apenas de #5/#6 CLOSED |
| #10 — Pipeline Aseprite → Processing | disponível | — | depende apenas de #6 CLOSED |
| #11 — Roteiro e textos | disponível | — | bloqueia #12 |
| #15 — Sala jogável | disponível | — | independente do #16 |
| #16 — HUD: ícones, alerta e rótulos | disponível | — | independente do #15 |
| #12 — Balanceamento | bloqueada | #4 e #11 | só iniciar quando ambos fecharem |

Issues de base já CLOSED: #2, #3, #5, #6, #9, #13 e #14. A issue #1 permanece
OPEN como mapa do projeto.

O grafo Wayfinder é a fonte da disponibilidade; a ordem recomendada pode mudar
conforme o prazo e os riscos. Não declarar uma issue concluída apenas porque um
arquivo foi alterado: a aceitação e a evidência devem estar no próprio ticket.

### Cadeias de trabalho relevantes

- `#4` + `#11` → `#12`: captura/verificação e textos antes do balanceamento.
- `#15` → sala jogável; `#16` → HUD. Independentes entre si e ambos no caminho
  crítico do protótipo jogável (prazo 23/09).
- `#10` → definição segura do pipeline de arte → produção dos assets listados em `#8`.
- `#7` é independente e pode ser fechado sem bloquear o protótipo.

## Decisões confirmadas

As decisões D-001 a D-005 são da primeira sessão de 12/09; D-006 a D-023 saíram
da sessão de grilling registrada em [issue://14](issue://14), com o detalhe
completo de cada uma.

| ID | Decisão | Estado |
|---|---|---|
| D-001 | O mapa macro abre salas 2D jogáveis | CONFIRMADA |
| D-002 | O técnico é controlável dentro das salas | CONFIRMADA |
| D-003 | A sala usa plataforma básica: andar, pular, escadas, colisão e interação | CONFIRMADA |
| D-004 | Uma tarefa por dia; movimento é livre e a interação concluída consome a ação | CONFIRMADA |
| D-005 | Sobreviventes ficam parados e interativos, sem rotinas autônomas | CONFIRMADA |
| D-006 | O técnico não entra na conta dos quatro sobreviventes | CONFIRMADA |
| D-007 | Sem sobreviventes vivos é derrota imediata (quinta causa) | CONFIRMADA |
| D-008 | Uma tarefa por dia, em cadeia de passos; só a conclusão gasta o dia | CONFIRMADA |
| D-009 | Todas as estações ativas; briefing no comando sugere sem travar | CONFIRMADA |
| D-010 | Cinco tarefas, todas com NPC e troca de cômodo | CONFIRMADA |
| D-011 | Tarefas como dado: tabela em `tasks.pde` + despachante de efeitos | CONFIRMADA |
| D-012 | Três conveses e duas escadas em todos os cômodos | CONFIRMADA |
| D-013 | Números de movimento (16×24, 1,5 / 48 / 0,5 / 1,0 / 12, sem câmera) | CONFIRMADA |
| D-014 | Vera, Bento, Neusa e Sílvia, um por cômodo | CONFIRMADA |
| D-015 | A nave não tem nome | CONFIRMADA |
| D-016 | Vocabulário: sobreviventes, Sala de comando/energia, Depósito, Dormitório, A BORDO | CONFIRMADA |
| D-017 | Seis ícones de 16×16 no HUD | CONFIRMADA |
| D-018 | Tipografia 16 px / entrelinha 18 / título 32 / botão até 10 | CONFIRMADA |
| D-019 | Alerta com borda piscando e ícone de aviso | CONFIRMADA |
| D-020 | Controles: setas + WASD, espaço, E, ESC; rodapé com o mouse | CONFIRMADA |
| D-021 | O dia 1 ensina pelo briefing, sem tela de tutorial | CONFIRMADA |
| D-022 | Playtest com checklist de seis perguntas | CONFIRMADA |
| D-023 | Tarefa não concluída não custa nada; o item fica com o técnico | CONFIRMADA |

## Decisões que exigem consulta

Não decidir silenciosamente:

- curva de dificuldade e probabilidade/repetição de eventos (é o #12);
- efeito definitivo de "socorrer sobrevivente" (+10 de moral é PROVISÓRIO);
- custo de outras falhas de sistema além do motor;
- textos definitivos da vinheta, mensagens e telas (é o #11);
- se a tela de vitória permite continuar jogando depois da chegada;
- qualquer nome, retrato ou história de personagem além do registrado em
  `characters/npcs/`.

## Checklist de início de sessão

- [ ] Ler `SESSION_START.md`.
- [ ] Ler `issue://1` e atualizar o grafo de dependências.
- [ ] Identificar o ticket disponível e a skill indicada pela label.
- [ ] Ler as fontes específicas e os assets visuais relevantes.
- [ ] Distinguir claramente intenção confirmada de implementação existente.
- [ ] Relatar conflitos e decisões abertas antes de editar.
- [ ] Definir o menor recorte que atende ao ticket; não remover gameplay para
      simplificar sem autorização.

## Checklist de encerramento

Antes de encerrar uma sessão, atualizar:

- decisões confirmadas e suas fontes;
- decisões abertas e perguntas feitas ao usuário;
- estado real do código e dos assets;
- issues iniciadas, concluídas ou ainda bloqueadas;
- arquivos alterados;
- comando, cenário ou teste de verificação executado;
- nova fronteira Wayfinder e próximo trabalho recomendado.

A última linha da sessão deve deixar claro se o repositório está apenas com uma
decisão documentada, com um protótipo executável ou com a funcionalidade pronta.

## Estado desta sessão

- **Grilling concluído:** 18 decisões (D-006 a D-023) confirmadas uma a uma e
  registradas em `issue://14`, que foi fechado.
- **Documentos aplicados:** `README.md`, `mechanics/ACTIONS.md`,
  `interface/FLOW.md`, `interface/HUD.md`, `interface/TEXT_FONTS.md`,
  `interface/MENU_GAME_OVER.md`, `interface/MENU_VICTORY.md`,
  `interface/ROOMS.md` (novo), `characters/PLAYER.md`, `characters/npcs/NPC_1` a
  `NPC_4`, `history/CONTEXT.md`, `events/CREW_ISSUES.md`,
  `events/SYSTEM_FAULTS.md` e `code/SKETCH_ARCHITECTURE.md`.
- **Código:** ainda não alterado nesta sessão. As mudanças estão nos tickets
  [#15](issue://15) (sala jogável) e [#16](issue://16) (HUD).
- **Verificação:** nenhum sketch foi executado nesta sessão; a prova é a
  conferência dos documentos contra as decisões e o `git status`.
- **Mapa #1 sincronizado:** loop atualizado para a cadeia de passos, seção
  Fronteira acrescentada, `interface/ROOMS.md` nas fontes de verdade, "Not yet
  specified" reduzido ao que segue aberto e #14/#15/#16 ligados como sub-issues
  (contador de sub-issues: 7 de 15).
- **Nada foi commitado:** as decisões estão na working tree da branch
  `prototype/sketch-architecture`, junto de mudanças não commitadas de sessões
  anteriores. Antes de começar o #15, vale commitar os documentos deste grilling.
- **Próximo trabalho recomendado:** [#15](issue://15) é o maior risco do prazo
  (23/09) e não depende de ninguém; o [#16](issue://16) é o mais barato e pode
  andar em paralelo. O [#4](issue://4) ainda bloqueia o balanceamento.

O repositório está com **documentação decidida e código pendente**: a direção de
gameplay está fechada em papel, mas a sala jogável ainda não existe no sketch.
