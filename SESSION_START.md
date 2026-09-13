# Last Horizon — Session Start

> Documento obrigatório de abertura e encerramento de toda sessão. Leia antes de
> analisar, editar ou implementar qualquer coisa.

Atualizado em: 2026-09-13 (após as resoluções dos tickets #11, #12 e #17)
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
- Os conflitos do código foram resolvidos no sketch: as salas agora são jogáveis,
  o HUD usa ícones e **A BORDO**, e o mapa macro não imprime nome de nave.
- O vocabulário visível do código usa **sobreviventes**; `CREW` permanece apenas
  como identificador interno de regra.
- As referências visuais usam o caminho real `assets/concept_arts/`; as artes
  continuam sendo referência de linguagem visual, não fonte de nomes.
- Os documentos do vault foram sincronizados em 12/09: `events/CREW_ISSUES.md` e
  `events/SYSTEM_FAULTS.md` não dizem mais que a resposta do evento gasta a ação
  do dia.
- `issue://11` foi resolvida nesta sessão: a voz, a vinheta, as transmissões, os modais, os alertas e as cinco mensagens de derrota agora têm contrato registrado no ticket e nas fontes de interface.
- `issue://12` foi resolvida nesta sessão: comida inicial 70; pool uniforme de sete eventos, sem repetição imediata e sem resortear falha ativa; falhas de suporte, energia e comunicações com custos, tarefas e variantes não repetíveis. O sketch implementa esse contrato desde o `issue://17`.

## Direção atual do produto

Last Horizon é um protótipo de gerenciamento de recursos com exploração 2D em
plataforma dentro de uma nave espacial. A nave **não tem nome**.

- `assets/concept_arts/HUD_CONCEPT_ART.png` é referência de linguagem visual do
  mapa macro e do HUD; os números do mock (520/600, Dia 084, 42 tripulantes)
  são ilustrativos — a fonte é `mechanics/ACTIONS.md`.
- `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png` é a linguagem visual das
  salas: cena lateral 2D em três conveses ligados por escadas, com terminais.
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
- A voz textual confirmada no #11 é híbrida por canal: sistema seco; Terra e Marte brevemente humanos, sem monólogos.
- Transmissões externas reagem à primeira ocorrência de incidentes graves; usam o nome do técnico, são modais e não consomem tempo, ação, recursos ou tarefa.
- Eventos, transmissões externas e desfechos são modais; alertas, resultados de tarefas e estados operacionais permanecem no painel `SISTEMA`.
- O balanceamento confirmou comida inicial em 70; energia, oxigênio, água e moral começam em 100, e as peças em 6.
- A falha de suporte de vida pode entrar em modo de emergência: custa 10 de energia e acrescenta 3 de consumo de oxigênio por dia até a nova tarefa de reparo.
- O pool tem sete eventos: falha no motor, chuva de meteoros, falta de comida, conflito no dormitório, falha no suporte de vida, falha no sistema de energia e falha nas comunicações. Falha ativa sai do sorteio até ser reparada; as três variantes de energia não se repetem.

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
decisão explícita. Os pontos de interação e as oito tarefas estão em
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

O sketch em `last_horizon/` implementa menus, mapa, salas jogáveis, movimento,
gravidade, pulo, escadas, colisão de plataformas, pontos de interação, tarefas
em cadeia, NPCs fixos, HUD com ícones e captura automática.
O contrato textual do #11 está resolvido; o sketch ainda contém textos provisórios e precisa de uma etapa posterior de implementação.

`code/SKETCH_ARCHITECTURE.md` registra a implementação atual. As capturas em
`last_horizon/output/` incluem estados de exploração e a verificação de que só
a conclusão da tarefa consome a ação do dia.
Os tickets [#15](issue://15) e [#16](issue://16) estão CLOSED após a validação
da evidência na aceitação nativa de cada issue.

Os arquivos `characters/npcs/NPC_1.md` a `NPC_4.md` estão preenchidos com Vera,
Bento, Neusa e Sílvia. Não inventar nomes, personalidades ou histórias novas
sem decisão do usuário.


## Fontes obrigatórias

### Mapa e coordenação Wayfinder

- `issue://1` — destino, fronteira e decisões gerais do projeto.
- `issue://?state=all` — inventário atual de issues.
- `issue://14` — decisões D-006 a D-023 (histórico).
- `issue://11` — decisões D-024 a D-029 (roteiro e textos).
- `issue://12` — decisões D-030 a D-046 (balanceamento e falhas novas).
- `issue://17` — implementação das falhas novas no sketch (tarefa aberta).
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

- `assets/concept_arts/HUD_CONCEPT_ART.png` — mapa macro e HUD.
- `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png` — sala lateral jogável.
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

Sincronizado com o grafo nativo de dependências em 2026-09-13, após fechar #4,
#11, #12, #14, #15, #16 e #17:

| Issue | Estado | Bloqueadores abertos | Relação relevante |
|---|---|---|---|
| #4 — Executar e capturar o sketch | CLOSED | — | execução e captura aceitas |
| #7 — Documento de entrega | disponível | — | independente |
| #8 — Inventário de assets | disponível | — | depende apenas de #5/#6 CLOSED |
| #10 — Pipeline Aseprite → Processing | disponível | — | depende apenas de #6 CLOSED |
| #11 — Roteiro e textos | CLOSED | — | resolução registrada em 13/09 |
| #12 — Balanceamento | CLOSED | — | resolução registrada nesta sessão |
| #15 — Sala jogável | CLOSED | — | sala jogável validada |
| #16 — HUD: ícones, alerta e rótulos | CLOSED | — | HUD validado |
| #17 — Implementar as falhas novas no sketch | CLOSED | — | implementado, verificado e aceito; textos confirmados (D-047) |

Issues de base já CLOSED: #2, #3, #4, #5, #6, #9, #11, #13, #14, #15, #16 e
#17.
A issue #1 permanece OPEN como mapa de coordenação.

O grafo Wayfinder é a fonte da disponibilidade; a ordem recomendada pode mudar
conforme o prazo e os riscos. Não declarar uma issue concluída apenas porque um
arquivo foi alterado: a aceitação e a evidência devem estar no próprio ticket.


### Cadeias de trabalho relevantes

- `#12` (fechado) → `#17` (fechado): o balanceamento liberou a implementação das
  falhas novas no sketch, verificada pela captura e aceita.
- `#15` e `#16` estão fechados; sala jogável e HUD já estão no protótipo.
- `#10` → definição segura do pipeline de arte → produção dos assets listados em
  `#8`.
- `#7` é independente e pode ser fechado sem bloquear o protótipo.

## Decisões confirmadas

As decisões D-001 a D-005 são da primeira sessão de 12/09; D-006 a D-023 saíram
da sessão de grilling registrada em [issue://14](issue://14); D-024 a D-029 saíram
da sessão de grilling registrada em [issue://11](issue://11); D-030 e D-031 saíram
da validação de balanceamento registrada em [issue://12](issue://12); D-032 a D-035
também foram confirmadas no #12; D-047 foi confirmada na sessão do
[issue://17](issue://17).

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
| D-024 | Voz híbrida por canal: sistema seco; Terra e Marte brevemente humanos | CONFIRMADA |
| D-025 | Vinheta em três telas, com objetivo explícito e sem tutorial de controles | CONFIRMADA |
| D-026 | Terra reage uma vez a cada primeiro incidente grave; Marte fala só na vitória | CONFIRMADA |
| D-027 | Eventos, transmissões e desfechos são modais; consequência externa vem antes do evento seguinte | CONFIRMADA |
| D-028 | Nove estados visíveis têm linhas curtas de ação ou estado no painel | CONFIRMADA |
| D-029 | Cinco derrotas usam causa e consequência em texto seco | CONFIRMADA |
| D-030 | Comida inicial em 70; as demais barras começam em 100 e as peças em 6 | CONFIRMADA |
| D-031 | Eventos uniformes, sem repetição imediata, durante a viagem | CONFIRMADA |
| D-032 | `Socorrer sobrevivente` recupera 10 de moral por 5 de água | CONFIRMADA |
| D-033 | Falha de suporte: 2 peças ou emergência com 10 de energia e +3 O₂/dia | CONFIRMADA |
| D-034 | Nova tarefa declarativa de reparo, concluível no mesmo dia do evento | CONFIRMADA |
| D-035 | Falha de suporte entra no pool uniforme de cinco eventos, sem repetição imediata | CONFIRMADA |
| D-036 | Interpretação anterior: falha de energia libera três tarefas alternativas | SUPERSEDED |
| D-037 | Uma tarefa de energia; Sílvia entrega automaticamente uma de três soluções com itens distintos e sem repetição | CONFIRMADA |
| D-038 | Sílvia sorteia a solução entre as três variantes ainda não usadas, sem reposição | CONFIRMADA |
| D-039 | Variantes: fusível (Depósito, 1 peça, painel de distribuição), cabo (Sala de comando, 10 energia, reator) e cartucho (Dormitório, 5 água, bancada do motor) | CONFIRMADA |
| D-040 | Sorteio apenas entre variantes pagáveis; depois das três usadas, a falha sai do pool | CONFIRMADA |
| D-041 | Evento de energia: energia −10 ou moral −10; falha ativa com +3 de energia por dia até o reparo | CONFIRMADA |
| D-042 | Reparo pendente persiste com item e variante; a falha ativa não é resortada e cobra +3 de energia por dia até a instalação | CONFIRMADA |
| D-043 | `Falha no sistema de energia` entra no pool uniforme, que passa a seis eventos; no máximo três ocorrências por partida | CONFIRMADA |
| D-044 | Comunicações: reparar com 1 peça; o silêncio custa moral −1/dia e suspende as transmissões da Terra até `Reparar comunicações` | CONFIRMADA |
| D-045 | Os itens novos vêm do NPC da sala: Bento entrega o fusível e as peças; Vera, o cabo; Neusa, o cartucho | CONFIRMADA |
| D-046 | Falha ativa não é resortada: motor danificado, suporte em emergência, energia ativa e comunicações em silêncio | CONFIRMADA |
| D-047 | Textos das falhas de suporte, energia e comunicações (cartões, alternativas e linhas do painel) aprovados no formato do #11 | CONFIRMADA |


## Decisões que exigem consulta

- se a tela de vitória permite continuar jogando depois da chegada;
- o silêncio das comunicações suspende transmissões que o sketch ainda não tem:
  o modal de transmissão da Terra (D-026) continua fora do código;
- a aplicação dos textos do #11 segue sem ticket: as linhas do painel `SISTEMA`
  já estão no código (`interface/HUD.md`), e faltam vinheta, transmissões,
  modais e as telas de vitória/derrota;
- **uma tarefa por dia não está imposta no código:** `action_used` só é escrito,
  nunca lido como bloqueio, então uma segunda cadeia pode ser iniciada e
  concluída no mesmo dia. Verificado em 13/09; falta decidir onde bloquear (na
  estação que inicia a cadeia ou na conclusão) e abrir o ticket;
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

- **Grilling concluído:** D-006 a D-023 em `issue://14`, D-024 a D-029 em
  `issue://11` e D-030 a D-046 em `issue://12`; os três tickets estão CLOSED.
- **Issues trabalhadas nesta sessão:** [#11](issue://11) e [#12](issue://12)
  resolvidas; [#17](issue://17) implementada no sketch (`wayfinder:task`) com
  evidência na captura, textos confirmados (D-047) e ticket CLOSED.
- **Documentos atualizados nesta sessão:** `SESSION_START.md`,
  `mechanics/ACTIONS.md`, `interface/ROOMS.md`, `interface/FLOW.md`,
  `interface/HUD.md`, `interface/MENU_INIT.md`, `interface/MENU_GAME_OVER.md`,
  `interface/MENU_VICTORY.md`, `events/SYSTEM_FAULTS.md`,
  `code/SKETCH_ARCHITECTURE.md` e `AGENTS.md`.
- **Código:** o sketch tem as três falhas novas, as três tarefas novas, as
  variantes de energia com sorteio sem reposição, o pool de sete eventos e os
  três estados novos do painel `SISTEMA`. `FOOD_START = 70` aparece no HUD do
  dia 1.
- **Verificação:** `Processing.exe cli --sketch=.\last_horizon --run --capture`
  percorre 42 estados e imprime 28 checagens `OK` (falhas novas, custos, item da
  variante, sorteio, painel de distribuição e antena no alcance);
  `--hit-test` e `--ladder-test` continuam `OK`.
- **Mapa #1 sincronizado:** #12 e #17 fechados; disponíveis #7, #8 e #10.
- **Próximo trabalho recomendado:** a cadeia de arte (#10 → #8), com #7 em
  paralelo; a implementação dos textos do #11 no sketch continua sem ticket.

### Textos das falhas novas (D-047)

Escritos nesta sessão no formato do #11 e já no código. Os cartões ficam em
`game.pde` e as linhas do painel em `hud.pde`; a fonte de domínio é
`events/SYSTEM_FAULTS.md` e a de interface, `interface/HUD.md`.

| Falha | Cartão | Alternativa A | Alternativa B | Painel |
|---|---|---|---|---|
| Suporte de vida | `FALHA NO SUPORTE DE VIDA` | `REPARAR (2 PEÇAS)` | `EMERGÊNCIA (ENERGIA -10)` | `REPARAR SUPORTE` |
| Sistema de energia | `FALHA NO SISTEMA DE ENERGIA` | `FORÇAR A REDE (ENERGIA -10)` | `DESLIGAR SETORES (MORAL -10)` | `REPARAR ENERGIA` |
| Comunicações | `FALHA NAS COMUNICAÇÕES` | `REPARAR (1 PEÇA)` | `SILÊNCIO (MORAL -1/DIA)` | `REPARAR COMUNICAÇÕES` |

Corpos dos cartões: `O SUPORTE PERDEU ESTABILIDADE. A NAVE CONSOME MAIS OXIGÊNIO.`, `A REDE PERDEU ESTABILIDADE E OPERA EM CARGA FORÇADA.` e `O TRANSMISSOR PERDEU O CONTATO COM A TERRA.`

O repositório está com **protótipo jogável executável**: as oito tarefas, os sete
eventos e os três estados novos do painel estão no sketch e verificados; o que
resta é a cadeia de arte (#10 → #8) e a implementação dos textos do #11.
