# Last Horizon — Session Start

> Resumo operacional obrigatório. Leia antes de analisar, editar ou implementar
> e sincronize-o com o Wayfinder antes de encerrar a sessão.

Atualizado após a conclusão da
[issue #34](https://github.com/shelldonryan/gtd_example/issues/34), que recalibrou
a velocidade da caminhada (1,5 → 1,0 px/quadro) para casar com o ciclo da
animação de `walk`, com a corrida da [issue #33](https://github.com/shelldonryan/gtd_example/issues/33)
intacta (D-153, D-154).
Destino Wayfinder: [issue #1](issue://1)

## Regras inegociáveis

1. Antes de qualquer avanço, leia este arquivo, `issue://1`, o inventário de
   issues e as fontes específicas do ticket.
2. Recalcule a disponibilidade pelo estado e pelos bloqueadores **nativos** das
   issues. Snapshots neste arquivo ou no corpo da #1 podem estar velhos.
3. Antes de editar, reporte entendimento, conflitos, lacunas e ticket escolhido.
4. Não invente decisões de gameplay, arquitetura, controles, objetivos,
   personagens ou apresentação. Decisão material exige consulta ao usuário.
5. Ao confirmar uma decisão, atualize imediatamente a fonte de domínio, este
   resumo e a issue correspondente.
6. Uma sessão **não está encerrada** enquanto documentos locais e Wayfinder
   divergirem sobre decisões, estados, bloqueios, evidências, fronteira ou
   próximo ticket.

## Sincronização obrigatória no encerramento

Execute sempre, nesta ordem:

1. Releia `issue://?state=all`, `issue://1`, a issue trabalhada, seus comentários
   e bloqueadores nativos.
2. Na issue trabalhada, registre decisões, arquivos alterados e evidência de
   verificação. Atualize estado e dependências; só feche quando a aceitação
   estiver comprovada.
3. Atualize o **corpo da issue #1** com a fronteira atual: disponíveis,
   bloqueadas, concluídas e próximo caminho crítico. Comentário histórico não
   substitui um corpo desatualizado.
4. Atualize as fontes locais afetadas e este arquivo com o mesmo estado.
5. Releia o corpo da #1 e este arquivo lado a lado. Corrija qualquer diferença
   antes da resposta final.

O grafo nativo define disponibilidade. O corpo da #1 e este arquivo devem
reproduzi-lo; nenhum dos dois pode manter um snapshot sabidamente obsoleto.

## Autoridade e estados

Ordem em caso de conflito:

1. última decisão explicitamente confirmada pelo usuário;
2. decisão confirmada na issue responsável e na fonte específica do domínio;
3. resumo operacional deste arquivo;
4. código atual, que prova implementação, não necessariamente intenção.

Fontes de mesma autoridade divergentes constituem erro de sincronização: pare,
reporte e não escolha silenciosamente.

- **CONFIRMADA** — decisão aprovada pelo usuário.
- **IMPLEMENTADA** — comportamento comprovado no código e na verificação.
- **ABERTA** — ainda exige decisão ou trabalho.
- **PROVISÓRIA** — hipótese temporária, nunca requisito.
- **SUPERSEDED** — regra histórica substituída; não reutilizar.

## Estado operacional atual

- #19, #20, #21, #22, #23 e #24 estão CLOSED; D-073 a D-110 continuam
  confirmadas e implementadas no protótipo anterior.
- #25 foi concluída: catálogo das oito preventivas e quatorze soluções,
  agora com confirmação, coleta e entrega físicas em `last_horizon/`.
- #26 foi concluída: números, pool, falhas, negligência, crises, risco e socorro
  estão implementados tanto no modelo Node quanto no sketch Processing.
- #27 foi concluída após validação manual do retorno pelas portas. Nesta sessão,
  os portais ganharam limiar `x/y` independente de deck e chegada configurável
  (`x/y/direção`) em qualquer ponto válido da sala; a porta das Máquinas no
  Comando está no centro do deck inferior (`x = 320`) e foi validada manualmente.
  O harness mantém a tela estável durante as campanhas internas e prioriza
  pontos de quest quando coincidem com um portal.

- A migração foi solicitada explicitamente antes do inventário #8. O jogo já
  executa o novo ciclo; a arte entra por arquivo, com fallback geométrico.
- #8 foi concluída: a lista de imagens, os canvas e a ordem de produção estão em
  `assets/INVENTORY.md`, e o layout de escadas e estações ficou congelado para a
  pintura dos fundos.
- #29 foi concluída nesta sessão: o sketch tem a camada de arte (`assets.pde`)
  com fallback geométrico, desenho 1:1 e travessia de porta em dois quadros.
- #30 foi concluída nesta sessão: a aba principal não cita mais o harness, então
  a cópia entregue sai sem `capture.pde` e compila fora do repositório.
- #28 está OPEN por decisão do usuário:
  [Escolher e integrar os efeitos sonoros](https://github.com/shelldonryan/gtd_example/issues/28);
  porta e escada estão escolhidas, integradas, verificadas e aprovadas na escuta
  (D-136 a D-139), em `data/audio/<evento>/`. O ticket fica aberto para uma
  possível ampliação de sons — hipótese registrada, nunca requisito (D-139).
- As posições de escada e estação estão **fechadas** para a pintura dos fundos:
  escadas em 127/532 (Comando), 114/526 (Máquinas), 120/489 (Depósito) e 127/482
  (Dormitório), com as estações realocadas e folga mínima de 40 px do eixo de
  uma escada. As portas continuam sendo sprites e mudam sem repintura.
- A entrega vai pelo GitHub: o repositório é privado e o professor tem acesso;
  a branch `entrega` é **gerada** — `node tools/snapshot-entrega.mjs` remonta o
  snapshot a partir da branch de trabalho (D-134) —, e o push é ação do usuário.
  Uma cópia equivalente está em `../entrega_last_horizon/`. A apresentação roda
  na máquina dele abrindo `last_horizon/last_horizon.pde` no Processing.
- #7 foi concluída:
  [Documento de entrega e como o jogo roda na apresentação](https://github.com/shelldonryan/gtd_example/issues/7);
  o plano B é uma gravação curta de partida, a ser feita pelo usuário até 23/09.
- #31 foi concluída: suporte híbrido aos formatos Aseprite e Universal LPC, novo
  player LPC integrado com animações extras de climb na escada e jump no ar, e
  NPCs com olhar dinâmico por convés e alcance de interação ajustado para 22 px
  (D-140 a D-144).
- #32 foi concluída: entrega direta na confirmação presencial de preventivas com o
  responsável (V-02 e N-02, D-145), diálogo de orientação pós-entrega (D-146),
  HUD com `NA MÃO:` (D-147), mapa sem coleta concluída (D-148), cadência dos
  passos na escada a 27 px lógicos (~450 ms) com primeiro passo instantâneo em
  1 px e atenuação do som de saída (D-149, D-150).
- Os 4 retratos de NPCs foram integrados em `data/portraits/` com fundo sólido do
  card em `ui.pde` (D-151), a animação de pulo LPC foi corrigida para a linha 29
  com sequência canônica `0-1-2-3-4-1` em 450 ms (D-152) e o mixer de áudio
  recebeu pré-aquecimento no `setup()` com `primeSound()`.
- #33 foi concluída: corrida com `Shift` no convés a 2,4 px/quadro, com a faixa
  `run` do LPC (linha 41, 8 quadros de 75 ms) e fallback para a caminhada quando a
  spritesheet não traz a faixa (D-153).
- #34 foi concluída: o andar caiu de 1,5 para **1,0 px/quadro** para casar com o
  ciclo de 800 ms da animação de caminhada, com a corrida intacta (D-154).
- O próximo caminho crítico na arte é a seleção dos assets CC0/CC-BY pelo usuário
  na ordem de `assets/INVENTORY.md`, iniciando pelo Bloco 1 (Ícones do HUD em
  `data/icons/`).

### Fronteira Wayfinder

Sincronizada com o grafo nativo depois da sessão do #34:

| Issue | Estado | Bloqueadores abertos | Relação |
|---|---|---|---|
| #34 Calibrar a velocidade da caminhada | CLOSED | — | andar a 1,0 px/quadro casado com o ciclo de 800 ms; corrida intacta |
| #33 Adicionar corrida com Shift | CLOSED | — | corrida a 2,4 px/quadro com a faixa `run` do LPC e fallback; verificada no harness |
| #32 Refinamento do fluxo de quests | CLOSED | — | entrega direta na confirmação (V-02, N-02), fala de orientação de NPCs, HUD e mapa refinados |
| #31 Suportar spritesheets Aseprite e LPC | CLOSED | — | suporte híbrido transparente, climb e jump para LPC e novo player integrado |
| #7 Documento de entrega | CLOSED | — | entrega pelo GitHub (repo privado, acesso do professor) e plano B por gravação curta |
| #29 Camada de assets | CLOSED | — | camada de arte com fallback, travessia de porta e drop-in documentado |
| #30 Desacoplar o harness | CLOSED | — | cópia entregue sem `capture.pde`, testada fora do repositório |
| #8 Inventário de assets | CLOSED | — | lista, canvas e ordem de produção em `assets/INVENTORY.md`; escadas e estações congeladas |
| #28 Escolher e integrar os efeitos sonoros | OPEN | — | porta e escada entregues, integradas e validadas (D-136 a D-138); aberto por decisão do usuário para ampliação não decidida (D-139) |
| #27 Portais, desfechos, transmissões, NPCs e HUD | CLOSED | — | escopo ampliado; concluído e validado |
| #25 Redesenhar incidentes e ordens como quests físicas | CLOSED | — | catálogo e fluxo físico implementados no sketch |
| #26 Simplificar mecânicas legadas e balancear o ciclo de quests | CLOSED | — | números, pool e consequências implementados no sketch |
| #19 Redesenhar o ciclo | CLOSED | — | contrato anterior superseded |
| #20 Balancear o novo ciclo | CLOSED | — | números anteriores superseded |
| #21 Implementar novo ciclo e hub | CLOSED | — | implementação anterior superseded em parte |
| #22 Calendário em dias pares | CLOSED | — | calendário preservado |
| #23 Confirmação nas intervenções | CLOSED | — | confirmação preservada para ações importantes |
| #24 Painel na coleta de componentes | CLOSED | — | componentes reaproveitados como quests |


## Contrato vigente do produto

O contrato abaixo está implementado no sketch `last_horizon/` e no modelo
numérico `prototype/balance-model.mjs`. A migração não aguardou o inventário #8,
por solicitação explícita do usuário; arte final continua fora desta mudança.

- Jogo de gerenciamento de recursos e exploração 2D em plataforma, em uma nave
  **sem nome**.
- Viagem de dez dias; primeiro dia no Comando, seguintes no Dormitório.
- Incidentes nos dias 2, 4, 6, 8 e 10; cinco dos sete tipos, embaralhados sem
  reposição. Os tipos pertencem às famílias de falhas técnicas, suprimentos e
  tripulação.
- Nos dias sem incidente, os sobreviventes oferecem duas ordens preventivas. O
  jogador escolhe e confirma uma presencialmente; deve concluí-la para evitar o
  prejuízo maior de negligência.
- Ajuste de playtest: dias tranquilos começam sem modal; `ORDENS` mostra `!`
  pulsante enquanto houver escolha disponível, até selecionar uma ordem.
- O selo de `ORDENS` usa círculo e exclamação geométrica centralizados, com
  pulso conjunto de tamanho e cor em ciclo de 1,4 s.
- Só o ponto da etapa atual permite interação. Demais estações e NPCs ficam
  sem marcador de ação e sem resposta a `E`; NPCs vivos permanecem visíveis.
  Portas, beliche do técnico e socorro com risco/quest livre são preservados.
- Nos dias com incidente, o cartão apresenta duas soluções físicas. O jogador
  escolhe uma, coleta o objeto e entrega no destino.
- Toda ordem informa objeto, origem, destino, recompensa e consequência de falha.
  Uma ordem aceita não pode ser cancelada.
- Uma única quest pode ser concluída por dia. Coleta e entrega são as duas etapas
  leves; o técnico carrega um objeto por vez.
- Ordem preventiva concluída aumenta um recurso específico. Ordem aceita e não
  concluída perde uma pequena quantidade desse mesmo recurso. Nenhuma ordem
  preventiva aceita perde os dois recursos oferecidos.
- Se nenhuma ordem preventiva for aceita, os dois recursos das ofertas sofrem
  pequenas perdas. Os valores exatos pertencem ao balanceamento.
- Solução de incidente não concluída deixa o problema ativo, com perda diária,
  prazo e crise normais, sem multa extra; a mesma solução pode ser retomada nos
  dias seguintes. Em dia com incidente novo, o cartão novo tem prioridade; a
  retomada volta a aparecer no próximo dia sem incidente.
- O sobrevivente responsável pode ser origem ou destino. A rota é curta e não
  exige três cômodos distintos.
- Componentes especiais, como fusível e kit de vedação, existem como objetos de
  quest; não há coleta livre fora de uma ordem.
- Economia, racionamento e bônus numéricos dos sobreviventes não fazem parte do
  novo ciclo.
- Há no máximo uma pessoa em risco por vez. Socorro é uma quest simples; a morte
  reduz `A BORDO` sem recalcular custos.
- O Comando é o único hub. O mapa mostra origem, destino e problemas, mas nunca
  transporta o técnico.
- Dormir no beliche do técnico processa consumo, perdas, riscos, prazos, crises
  e término.
- Vitória: chegar após o décimo dia com motor operante e ao menos um
  sobrevivente. Derrota: energia, oxigênio ou moral em zero, motor destruído ou
  nenhum sobrevivente vivo.
- Todo NPC vivo responde a `E` a qualquer momento, com texto e tipo de painel
  conforme o estado do dia; estações fora da etapa atual continuam apagadas.
- Portais são dados: cada porta declara sala, destino, `x/y` do limiar, referência
  opcional de convés (`door_deck`) e `x/y/direção` de chegada. `door_deck = -1`
  permite abertura sem deck ou acima do piso; a proximidade usa os dois eixos.
- Transmissões da Terra (primeira falha do motor, primeira chuva de meteoros e
  primeira perda) abrem uma vez por partida, antes do cartão do incidente, e não
  consomem dia, tarefa, recurso ou ação.
- A vitória traz a mensagem de Marte em três variações e lista os sobreviventes
  por nome quando houver perdas. "Reparo no limite" é a solução do motor entregue
  com o prazo do problema em 1 e só prevalece quando houver perdas.
- A derrota mostra apenas a contagem de sobreviventes e encerra a partida: não
  existe continuar jogando depois da chegada.
- O nome do técnico é obrigatório: `INICIAR (ENTER)` e a tecla `ENTER` ficam
  bloqueados enquanto o campo estiver vazio.
- Alertas não têm linha de texto: cor, ícone de aviso e borda piscando no cartão
  do recurso, e o problema ativo na faixa de urgência.
- Os cartões de recurso mostram rótulo de texto (`ENERGIA`, `OXIGÊNIO`, `ÁGUA`,
  `COMIDA`, `PEÇAS`, `MORAL`); o inventário #8 troca apenas os ícones por assets.
- O rodapé tem `MAPA`, `ORDENS` e `?`; a dica de teclas virou o modal
  `AJUDA — CONTROLES`. Textos e estética de modais e cartões ficam deferidos.
- A arte final está especificada em `assets/INVENTORY.md`: fundo em imagem por
  sala, com o piso e as escadas **pintados** no fundo e a colisão mantida no
  código; estações, objetos, NPCs, portas, ícones, retratos, telas e miniaturas
  do mapa são sprites carregados por arquivo, com a geometria do protótipo como
  fallback enquanto o asset não existe; painéis, cartões, barras, faixas,
  botões, o selo `!` e todo o texto continuam em código.

O catálogo concreto, seus IDs, objetos, origens, destinos, resultados e textos
estão em `mechanics/ACTIONS.md` e `events/`. Os valores numéricos e a seleção
final do pool foram definidos e simulados no ticket #26, e são executados pelo
sketch `last_horizon/`.

Números, custos, recompensas, perdas, prazos e ordem final do processamento:
`mechanics/ACTIONS.md`, `prototype/balance-model.mjs` e `last_horizon/game.pde`.
Topologia e ordens: `interface/ROOMS.md`.

## Contrato técnico

- Processing 4.5.6, modo Java, sketch plano em inglês, funções curtas e
  `update` separado de `draw`.
- Render 1280×720; grade lógica 640×360 apenas para posicionamento; janela 16:9
  escalável com ampliação inteira.
- Segoe UI suavizada: título 32 px, leitura 16 px, entrelinha 18 px; botão pode
  reduzir até 10 px somente para caber.
- Pixel art sem interpolação. Asset animado: uma spritesheet PNG + JSON; nomes
  ASCII; `.aseprite` acompanha a exportação quando disponível.
- Asset estático: canvas = tamanho na tela, porque 1 pixel de arte = 1 pixel do
  render 1280×720. Base 64×64; porta 64×128; ícones 32×32; retratos 224×276;
  fundos de sala 1280×456; telas 1280×720; miniaturas do mapa 240×144. Lista
  completa por arquivo em `assets/INVENTORY.md`.
- Sala: três conveses, duas escadas por sala, sem câmera. Escadas finais:
  127/532, 114/526, 120/489 e 127/482; nenhuma estação a menos de 40 px de um
  eixo de escada.
- Portais e escadas vivem em tabelas. Portas usam `door_room`, `door_target`,
  `door_x`, `door_y`, `door_deck`, `door_arrival_x`, `door_arrival_y` e
  `door_arrival_facing`; escadas usam `ladder_room` e `ladder_x`. O limiar da
  porta não precisa coincidir com um deck e a chegada configurada vale na
  primeira travessia; no retorno imediato, o jogador reaparece no `x/y` de saída.
- Jogador: colisão 16×24; andar 1,0 px/quadro; correr 2,4 px/quadro com `Shift`
  no convés; pulo 48 px; gravidade 0,5; escada 1,0; interação 12 px; plataformas
  atravessáveis por baixo.
- Controles: setas/WASD, `Shift` para correr, espaço, E, ENTER em diálogos/modais,
  ESC para pausa e mouse nos botões `MAPA` e `ORDENS`.
- HUD: seis ícones 16×16; cartões de recurso com ícone, número, rótulo e barra.
- Áudio offline: `javax.sound.sampled`, WAV PCM 16 bits em `data/audio/<evento>/` (porta e escada integradas; alerta e clique sem som).
- A arte entra por arquivo em `data/` (`icons/`, `stations/`, `objects/`,
  `npc/`, `doors/`, `rooms/`, `portraits/`, `screens/`, `map/`), com fallback
  geométrico quando o arquivo não existe, desenho 1:1 no render 1280×720 e
  travessia de porta em dois quadros.
- A cópia entregue é o sketch sem a aba do harness (`capture.pde`): a aba
  principal declara pontos de extensão inertes e o harness se instala neles.

Concept arts definem linguagem visual e composição, nunca nomes, números,
dimensões ou layout final:

- `assets/concept_arts/HUD_CONCEPT_ART.png`;
- `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png`;
- `assets/concept_arts/COMMAND_ROOM_EDITED.png`, `MACHINE_ROOM.png`,
  `WAREHOUSE.png` e `BEDROOM.png`, agora incluídos no escopo do inventário
  ampliado da issue [Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8).

## Índice de decisões

Não replique aqui o histórico completo:

- D-001 a D-047: protótipo anterior; fontes em #14, #11, #12 e #17.
- D-048 a D-072: navegação, interação, viewport, tipografia e animação já
  implementadas; fonte principal em #18.
- D-073 a D-096: contrato histórico do ciclo anterior, com briefing, tarefa,
  contenção e correção separadas; **SUPERSEDED** pelo novo contrato de ordens e
  soluções físicas registrado na ADR-0001.
- D-097: dano no casco aleatório e alcançável; permanece confirmado e deverá ser
  usado como destino de uma solução física.
- D-098: números do ciclo anterior; a forma de problemas, políticas e benefícios
  foi **SUPERSEDED** pela ADR-0002. A recalibração do novo ciclo está
  implementada no ticket #26; o calendário e os sete tipos continuam como base.
- D-099 a D-103: decisões de implementação do ciclo anterior, incluindo
  distribuição, beliche temporário, empate de urgência e crise imediata;
  **SUPERSEDED** onde conflitarem com ordens e riscos simplificados.
- D-104 a D-107: leituras do ciclo anterior; superseded onde conflitam com as
  quests das issues #25 e #26, agora implementadas no sketch.
- D-108: os incidentes ocorrem nos dias 2, 4, 6, 8 e 10 e o dia 1 fica sem
  incidente; decisão preservada no novo contrato.
- D-109: confirmação de ações importantes; o princípio permanece e os painéis
  e ações concretas foram adaptados e implementados no fluxo de quests do sketch.
- D-110: coleta com confirmação; o princípio de objeto explicado permanece, mas
  coleta livre e uso exclusivo de fusível ou kit ficam **SUPERSEDED** pelo
  modelo de objetos de quest.
- **Novo ciclo de quests (ADR-0001):** dias sem incidente oferecem duas ordens
  preventivas e permitem concluir uma; dias com incidente oferecem duas
  soluções físicas. Objetos têm origem, destino e consequência legíveis.
- **Simplificação do ciclo (ADR-0002):** seis recursos e consumo permanecem;
  políticas, bônus numéricos, coleta livre e contador separado de intervenção
  saem. Problemas persistentes permanecem; há no máximo uma pessoa em risco.
- **Tickets concluídos:** a #25 define matriz, textos e rotas; a #26 define
  números, seleção do pool e simulação. Ambos foram migrados para o sketch.
  O inventário de assets (#8) continua disponível como próximo caminho.
- **D-111 a D-117 (sessão #27):** fala de NPC por estado (D-111); portas e
  escadas em tabela (D-112); HUD com rótulos nos cartões, faixa inferior em
  campos fixos e modal de ajuda `?` (D-113); nome vazio mantém `INICIAR`
  bloqueado (D-114); derrota sem nomes e inexistência de pós-vitória (D-115);
  transmissões da Terra antes do incidente e mensagens de Marte, com "reparo no
  limite" definido como entrega com prazo 1 (D-116); alertas do #11
  **superseded**, sem linha de texto (D-117).
- **Ampliação técnica da #27 nesta sessão:** o limiar do portal usa `x/y`
  independente de deck e a chegada usa `x/y/direção` configurável; no retorno
  imediato, o jogador reaparece na posição de saída da sala anterior. Isso
  permite aberturas sem deck e surgimento inicial em qualquer ponto válido.
- **D-118 a D-125 (sessão #8, inventário de assets):** o fundo de cada sala é
  uma imagem e o piso e a escada passam a ser **pintados** nela, com a colisão
  mantida no código (D-118); escadas definitivas por sala — 127/532, 114/526,
  120/489 e 127/482 — medidas na composição dos concept arts, com as estações
  realocadas e folga mínima de 40 px (D-119); 14 estações com desenho próprio em
  canvas 64×64, com o casco sorteado em qualquer ponto (D-120); NPCs, porta e
  casco animados em dois quadros e o restante estático (D-121); canvas = tamanho
  na tela, com base 64×64 e exceções por peça (D-122); menu e vinheta com a nave
  de fora e a Terra ao fundo, vitória com a base em Marte e derrota com o espaço
  vazio (D-123); o som fica pendente e o jogo segue mudo (D-124); a lista e a
  ordem de produção vivem em `assets/INVENTORY.md`, começando pelos ícones do
  HUD (D-125).
- **D-126 a D-131 (sessão #7, entrega e camada de arte):** a entrega é a
  documentação de design do vault mais o jogo em Processing, rodando na máquina
  do professor a partir da pasta do sketch (D-126); o material de verificação sai
  dos documentos entregues e passa a viver em `code/VERIFICATION.md`, só do
  repositório, com a cópia entregue sem a aba do harness (D-127); o `README.md`
  é o hub do grafo, as notas se linkam por wikilink e as issues ficam só em
  `Referências` no fim, com `assets/INVENTORY.md` e as concept arts na entrega
  (D-128); a camada de arte carrega por arquivo com fallback geométrico e 1:1 e
  a porta ganha travessia em dois quadros, com **arte de IA proibida** e
  CC0/CC-BY permitida, selecionada pelo usuário (D-129); prazo de entrega em
  23/09 (D-130); o harness fixa a sequência de incidentes para não repetir o
  motor no dia 4, corrigindo falha intermitente (D-131). A opção de "esperar a
  arte final toda" fica **superseded** por D-126/D-129.
- **D-132 e D-133 (fechamento da sessão #7):** a entrega vai pelo GitHub — o
  repositório é privado e o professor tem acesso —, com uma branch `entrega`
  curada como snapshot (D-132); o plano B da apresentação é uma gravação curta
  de partida feita pelo usuário (D-133).
- **D-134 (workflow da entrega):** a branch `entrega` é artefato **gerado** a
  partir da branch de trabalho (`node tools/snapshot-entrega.mjs`); código e
  documentação evoluem só na branch de trabalho e o snapshot é remontado antes
  de publicar — não existe atualização em dois lugares.
- **D-135 (sessão #28, som):** o conjunto de sons foi definido evento por evento
  e ficou em **travessia de porta e escada**; clique de UI, alerta de recurso
  crítico e os demais eventos não têm som — o alerta continua apenas visual. A
  cadência "uma vez na transição para o vermelho" chegou a ser confirmada e foi
  revertida na mesma sessão, ficando **SUPERSEDED**; o par "clique + alerta" era
  recorte de escopo da #3, nunca confirmado pelo usuário.
- **D-136 (sessão #28, som):** o som da escada é a mistura de `footsteps/metal/4`
  (congusbongus, CC-BY 3.0, crédito obrigatório de Eelke) com `impactMetal_004`
  (Kenney, CC0), 60 ms entre as peças; vive em
  `last_horizon/data/audio/ladder.wav`, com receita e créditos em
  `LICENSE-ladder.txt`, e toca **apenas na saída** da escada — o engate não tem
  som, porque a subida é coberta pelos passos (D-137). A porta segue pendente,
  com a direção "pneumático metálico".
- **D-137 (sessão #28, som):** a escada ganha **passos** enquanto o técnico sobe
  ou desce — `step_01..04.wav` em rotação, um a cada 18 px lógicos
  (`LADDER_STEP_SPACING` em `ship.pde`). O gatilho do `ladder.wav` é único, na
  saída (`leaveLadderAtDeck`), o que também elimina o disparo duplo que existia
  nas pontas da escada, quando engate e saída caíam no mesmo quadro. Os sons
  foram suavizados a pedido do usuário: `ladder.wav` a −10 dBFS e os passos a
  −20 dBFS com passa-baixas em 5 kHz.
- **D-138 (sessão #28, som):** a porta usa `door.wav` — chiado de ar contínuo
  (rubberduck, CC0) com batente metálico (Kenney, CC0) 480 ms depois, escolhido
  pelo usuário entre seis candidatos; toca uma vez no início da travessia
  (`enterRoomThroughDoor`), nos dois caminhos, com ou sem a arte da porta. Os
  sons ficaram separados em `data/audio/<evento>/`, cada pasta com o seu
  `LICENSE.txt`. A porta foi suavizada por medição: pico em -10 dBFS e RMS em
  -25,8 dBFS, igualando a saída da escada que o usuário aprovou.
- **D-139 (sessão #28, som):** o escopo do #28 — porta e escada — está entregue,
  integrado e aprovado na escuta. O ticket permanece **aberto por decisão do
  usuário**, que cogitou acrescentar outros sons se sobrar tempo; essa ampliação
  é **PROVISÓRIA** — hipótese registrada, nunca requisito, e nada além de porta e
  escada deve ser tratado como escopo.
- **D-140 (sessão #31, spritesheet do jogador):** o sketch suporta
  transparentemente os formatos Aseprite e Universal LPC; no LPC, o player ativa
  `climb` (6 quadros, linha 21) na escada e `jump` (13 quadros, linha 49) no ar,
  com fallback gracioso para idle/walk quando o sprite for Aseprite.
- **D-141 (sessão #31, spritesheet de NPCs):** na camada de arte (`assets.pde`),
  os NPCs suportam transparentemente o formato Universal LPC com orientação
  frontal (Sul / linha 24, 2 quadros de respiração), além do formato Aseprite com
  array `"frames"`.
- **D-142 (sessão #31, organização de assets do jogador):** substituição direta
  com backup — `player_sheet.png` e `player_sheet.json` passam a ser o novo sprite
  LPC (832×3456), com o original mantido como `player_sheet_aseprite.*`, backup
  explícito em `player_sheet_lpc.*` e créditos/licença em `LICENSE.txt`.
- **D-143 (sessão #31, integração de NPCs e olhar por deck):** os 4 NPCs
  (`vera.png`, `bento.png`, `neusa.png` e `silvia.png`) foram integrados em `data/npc/`
  no padrão Universal LPC com `LICENSE.txt`. Em `ship.pde`, `drawNpc` verifica se o
  jogador está no mesmo convés (`same_deck`): se estiver no mesmo deck, o sobrevivente
  vira dinamicamente para o técnico (linha 23 para a esquerda, linha 25 para a direita);
  se estiver em deck diferente ou em escada, mantém a pose neutra/frontal (linha 24),
  preservando o fallback geométrico caso o asset não exista.
- **D-144 (sessão #31, raio de interação dos NPCs):** o alcance lateral de
  interação com NPCs foi ajustado para 22 px (`NPC_INTERACTION_RANGE = 22`), após
  redução de ~30% em relação aos 32 px iniciais, proporcionando um encaixe justo
  e natural ao lado do sobrevivente. Estações e portas mantêm o raio padrão de 12 px.
- **D-145 (sessão #32, entrega direta em preventivas):** quando a origem de uma
  ordem preventiva coincide com o próprio responsável (`V-02` com Vera e `N-02` com
  Neusa), a confirmação presencial entrega o objeto diretamente na mão do técnico
  (`held_item = active_quest + 1`) e avança a etapa imediatamente para `QUEST_DELIVER`,
  eliminando a segunda interação redundante no mesmo ponto físico.
- **D-146 (sessão #32, fala de orientação pós-entrega):** ao interagir novamente
  com o responsável da quest com o objeto já em mãos, o diálogo orienta a rota de
  entrega no destino ("SIGA A ORDEM: JÁ ENTREGUEI [OBJETO]. LEVE ATÉ [DESTINO]."),
  reforçando a clareza da etapa atual.
- **D-147 (sessão #32, linha de rota no HUD com item na mão):** em `hud.pde`,
  quando o técnico carrega um item (`held_item != ITEM_NONE`), a segunda linha da
  faixa de ordem exibe `NA MÃO: [OBJETO] | ENTREGA: [DESTINO]`, alinhada à terminologia
  canônica de `INVENTORY.md`.
- **D-148 (sessão #32, mapa consultável na etapa de entrega):** em `ship.pde`,
  a ficha da sala no mapa oculta a linha de `COLETA` quando a etapa já avançou para
  `QUEST_DELIVER`, exibindo apenas `ENTREGA` na sala de destino.
- **D-149 (sessão #32, sincronização de som e animação da escada):** o ritmo dos
  passos na escada foi recalibrado para uma cadência mais cadenciada e natural:
  animação com quadros de 140 ms (420 ms por passada no LPC de 6 quadros) e
  `LADDER_STEP_SPACING = 25` px lógicos (~417 ms a 60 FPS), eliminando a sensação
  acelerada do valor anterior. O primeiro passo dispara em `LADDER_FIRST_STEP = 1` px lógico
  (~16 ms / 1 quadro), o temporizador `player_animation_started_at` passa a ser
  reiniciado ao iniciar o movimento na escada, e o subsistema de áudio passa por
  pré-aquecimento no `setup()` com `primeSound()`.
- **D-150 (sessão #32, atenuação do som de saída da escada):** atendendo ao pedido
  de menos destaque ao final do curso da escada, `ladder.wav` foi atenuado em −8,5 dB
  (pico de −10,0 dBFS para −18,6 dBFS; RMS de −25,6 dBFS para −34,1 dBFS) e filtrado com
  passa-baixas em 5 kHz, eliminando o estalo metálico agudo e nivelando a presença sonora
  diretamente à faixa dos passos da subida.
- **D-151 (sessão complementar, retratos dos NPCs no diálogo):** os 4 retratos em pixel art
  foram integrados em `data/portraits/` (`vera.png`, `bento.png`, `neusa.png`, `silvia.png`),
  com fallback automático para `data/npc/*_portrait.png` em `assets.pde`. Em `ui.pde`,
  `drawPortrait` agora desenha o fundo sólido do card (`COL_PANEL` e `COL_BORDER`) antes da arte com transparência, eliminando vazamento visual do cenário atrás do busto.
- **D-152 (sessão complementar, sequência canônica de pulo LPC 0-1-2-3-4-1 na linha 29):** a animação de pulo
  do técnico no padrão Universal LPC foi corrigida para a linha correta de pulo (linha 29, Leste / perfil direito,
  pertencente ao bloco de 4 direções das linhas 26–29 com 5 quadros cada), usando a sequência canônica
  `0-1-2-3-4-1` (6 quadros a 75 ms), totalizando 450 ms, sincronizada perfeitamente
  com o tempo de voo físico de 462 ms (28 frames a 60 FPS). Em quedas prolongadas, o frame é
  fixado na pose final de aterrissagem via `min(raw_elapsed, total_duration - 1)`, sem repetir o agachamento no ar.
- **D-153 (sessão #33, corrida com Shift):** `Shift` com uma direção horizontal
  acelera o técnico de 1,5 para 2,4 px/quadro no convés e ativa a faixa `run` da
  spritesheet (linha 41 do LPC, 8 quadros de 75 ms, espelhada para Oeste), com
  regresso imediato a caminhada ou repouso ao soltar a tecla. Correr é decisão de
  convés: escada e ar mantêm velocidade e animação próprias, `Shift` parado não
  anima nada, e um sprite sem a faixa de `run` acelera o passo mantendo a
  caminhada. Velocidade e animação saem do mesmo predicado, então nunca
  discordam. O modal `AJUDA — CONTROLES` ganhou a linha `CORRER: SHIFT` e passou
  a dimensionar a altura pelo número de linhas.
- **D-154 (sessão #34, caminhada):** o playtest reprovou o andar a 1,5 px/quadro
  por deslizar em relação à animação de 8 quadros a 100 ms. `PLAYER_SPEED` caiu
  para **1,0 px/quadro**: 48 px lógicos por ciclo, perto de duas alturas do
  técnico, mantendo a navegação da nave em ~10 s de ponta a ponta. A corrida
  (2,4 px/quadro) foi aprovada no playtest e ficou intacta.

## Fontes por tarefa

Sempre:

- `issue://1`, `issue://?state=all`, issue escolhida, comentários e bloqueadores;
- `README.md`, `history/CONTEXT.md` e este arquivo.

Gameplay e balanceamento:

- `mechanics/ACTIONS.md`;
- `interface/ROOMS.md`, `interface/FLOW.md`, `interface/HUD.md`;
- `events/CREW_ISSUES.md`, `events/HAZARDS.md`,
  `events/SYSTEM_FAULTS.md`;
- `characters/PLAYER.md`, `characters/npcs/*.md`;
- #19, #20 e `prototype/balance-model.mjs`.

Interface e desfechos:

- `interface/MENU_INIT.md`, `interface/MENU_GAME_OVER.md`,
  `interface/MENU_VICTORY.md`;
- #11 e assets visuais relevantes.

Arte e layout:

- `assets/INVENTORY.md`;
- `assets/concept_arts/*.png` (linguagem visual e composição, nunca nomes,
  números ou dimensões).

Código:

- `code/SKETCH_ARCHITECTURE.md`;
- todos os `.pde` de `last_horizon/`;
- `code/VERIFICATION.md` (só do repositório) para comandos, harness, costura e
  fixtures;
- comandos e evidências de captura da issue afetada.

`interface/MENU_CONFIGURATION.md` foi removido; o menu de configuração segue fora
do escopo. Arquivos `research/*.md` podem existir apenas nas branches
`research/*`.

## Lacunas que exigem consulta ou ticket

- a seleção da arte, na ordem de `assets/INVENTORY.md` — ícones, porta, casco,
  objetos, NPCs, estações, retratos, fundos, telas e miniaturas do mapa; quem
  seleciona é o usuário, e arte gerada por IA é proibida pelo professor;
- a gravação curta do plano B, a ser feita pelo usuário até 23/09;
- a definição visual das **portas**, que são sprite e mudam sem repintura; as
  escadas, que são pintadas, estão fechadas;
- o texto e a estética dos modais e cartões, deferidos por decisão da #27;
- qualquer nome, retrato ou história além de Vera, Bento, Neusa e Sílvia.


## Checklist de abertura

- [x] Ler este arquivo antes de qualquer avanço.
- [x] Recalcular issues, bloqueadores e fronteira.
- [x] Identificar ticket e skill correspondente à label.
- [x] Ler fontes específicas, comentários e assets relevantes.
- [x] Comparar intenção, documentação e código.
- [x] Reportar entendimento, conflitos, lacunas e recorte antes de editar.

## Checklist de encerramento

- [x] Registrar decisões e evidências na issue trabalhada.
- [x] Atualizar estado e dependências nativas da issue.
- [x] Atualizar o corpo da #1 com a fronteira e o próximo ticket.
- [x] Atualizar fontes locais afetadas e este arquivo.
- [x] Confirmar que #1, issues específicas e documentos locais concordam.
- [x] Registrar arquivos alterados e verificação executada.
- [x] Declarar se o resultado é documentação, protótipo executável ou
      funcionalidade pronta.

### Sessão atual — #34 calibração da caminhada
Sessão da [issue #34](https://github.com/shelldonryan/gtd_example/issues/34) —
reajuste do andar para casar com a animação de caminhada.

- **Relato do playtest:** o técnico deslizava andando; a corrida com `Shift` está
  aprovada e **não foi tocada**.
- **Decisão (D-154):** `PLAYER_SPEED` foi de 1,5 para **1,0 px/quadro**. A
  animação de caminhada tem 8 quadros de 100 ms (ciclo de 800 ms) e um passo
  curto: a 1,5 px/quadro o técnico cobria 72 px lógicos por ciclo (três alturas)
  e os pés patinavam. Com 1,0 px/quadro o ciclo cobre 48 px lógicos (duas
  alturas) e o deslize por quadro de animação cai cerca de um terço (medido nas
  solas: de 15–24 para 9–18 px de arte por quadro). O passo lateral ao sair da
  escada (`leaveLadderAtDeck`) usa a mesma constante e encolhe junto.
- **Código alterado:** `last_horizon/last_horizon.pde` (`PLAYER_SPEED` com o
  comentário de calibração).
- **Evidência:** `--capture` → **159 asserções `OK`**, zero `FALHOU`,
  `QUEST CHECK: PASS`; `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`;
  `--asset-pipeline-test` → `OK`. A aferição do deslize é medida, mas o veredito
  continua sendo o playtest.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `730d57b`
  (sketch) e `8ac6494` (documentos), mais este registro.
- **Resultado:** funcionalidade ajustada no jogo Processing — andar casado com a
  animação; nenhuma outra tecla, faixa ou velocidade mudou.

### Sessão anterior — #33 corrida com Shift
Sessão da [issue #33](https://github.com/shelldonryan/gtd_example/issues/33) —
corrida acionada por `Shift`, com a faixa `run` da spritesheet.

- **Decisão confirmada (D-153):** `Shift` com uma direção horizontal corre no
  convés a 2,4 px/quadro (caminhada, 1,5 na época; recalculada na #34) e anima a
  linha 41 do LPC (8 quadros de 75 ms, espelhada para Oeste); soltar a tecla volta
  imediatamente a caminhada ou repouso. Correr é decisão de convés: escada e ar
  mantêm velocidade e animação próprias, `Shift` parado não anima nada e um sprite
  sem a faixa de `run` acelera o passo mantendo a caminhada. Velocidade e animação
  compartilham o mesmo predicado (`playerIsRunning()`), então sprite e passo nunca
  discordam.
- **Código alterado:** `last_horizon/last_horizon.pde` (`PLAYER_RUN_SPEED`,
  `run_held`, faixa de `run`, `SHIFT` no mapa de teclas), `last_horizon/ship.pde`
  (carga da linha 41, tag `run` do Aseprite, estados `PLAYER_ANIM_*`,
  `playerIsRunning()` e passo do convés), `last_horizon/ui.pde` (linha
  `CORRER: SHIFT COM ← → OU A/D` e painel de ajuda que dimensiona pelo número de
  linhas) e `last_horizon/capture.pde` (`checkPlayerRun()`).
- **Evidência:** `--capture` → **159 asserções `OK`**, zero `FALHOU`,
  `QUEST CHECK: PASS`, `som: 6 de 6 carregados`, `arte: 8 de 57 imagens carregadas`;
  `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`; `--asset-pipeline-test` → `OK`.
  A linha de base medida no commit `fd62b7a` fecha em 148 asserções, então o
  delta é de +11, sem remoções. Revisão de código independente antes do commit:
  oito achados, todos tratados (guardas do teste sem faixa de `run`, asserções
  por mutação — linha 39 no lugar da 41, passo antes da gravidade e perda do
  passo acelerado reprovam —, tecla vazada no harness, termo inerte em
  `player_animation_moving`, ordem do passo no quadro da decolagem e
  enumerações da arquitetura). Inspeção visual do modal de ajuda confirma a nova
  linha e o botão com folga.
- **Wayfinder:** #33 fechada com o relatório da sessão; a fronteira fica #28
  (áudio, aberta por decisão do usuário) e a arte na ordem de
  `assets/INVENTORY.md`.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `3962d52`
  (sketch) e `2b91c24` (documentos), mais este registro.
- **Resultado:** funcionalidade pronta no jogo Processing — corrida no convés com
  animação própria e fallback.

### Sessão anterior — áudio da escada, retratos de NPC e animação do pulo
Sessão de correção do áudio da escada, integração dos 4 retratos de diálogo e alinhamento da animação de pulo LPC.

- **Áudio da escada (D-149, D-150):** `primeSound()` agora aquece os clips em frame 0
  por 50 ms em silêncio durante `setup()`, eliminando a latência do mixer; cadência
  dos passos calibrada em 27 px lógicos (~450 ms) com o primeiro passo instantâneo em 1 px.
- **Retratos dos NPCs (D-151):** 4 portraits integrados em `data/portraits/` (`vera.png`,
  `bento.png`, `neusa.png`, `silvia.png`) com fallback para `data/npc/*_portrait.png`;
- **Animação do pulo (D-152):** o pulo LPC foi corrigido para a linha real de pulo
  (linha 29, Leste / perfil direito do bloco 26–29 de 5 quadros), usando a sequência canônica
  do Universal LPC Generator `0-1-2-3-4-1` (6 quadros a 75 ms), totalizando 450 ms,
  casando perfeitamente com os 462 ms de tempo no ar da física do pulo (28 frames a 60 FPS).
  Em quedas longas, o frame congela no quadro final de descida/aterrissagem sem repetir agachamento no ar.
- **Evidência:** `--ladder-test` → 6 `OK`, `som: 6 de 6 carregados`, `arte: 8 de 57 imagens carregadas`;
  `--hit-test` → 5 `OK`; `--capture` → `QUEST CHECK: PASS`, 148 asserções `OK`
  (recontadas no commit `fd62b7a`; o número 146 registrado na sessão estava defasado).
- **Commit na branch `prototype/sketch-architecture` (sem push):**
  `7cde3f9` — `feat(sketch): integrar retratos dos NPCs, corrigir pulo LPC e ajustar audio`
- **Wayfinder:** #28 reivindicada e mantida OPEN para validação acústica no ambiente de apresentação;
  #32 atualizada com o relatório da sessão e mantida OPEN.
### Sessão anterior — #32
Sessão da [issue #32](https://github.com/shelldonryan/gtd_example/issues/32) —
refinamento do fluxo de quests, eliminação de redundâncias e polimento do HUD/mapa.

- **Decisões confirmadas (D-145 a D-150):** entrega direta na confirmação de preventivas
  (V-02 e N-02) avançando direto para `QUEST_DELIVER`; diálogo de orientação atualizado;
  linha de rota no HUD exibindo `NA MÃO:` quando item carregado; mapa consultável exibindo
  apenas entrega na etapa de entrega; sincronização da cadência sonora da escada
  com a animação de climb (passos a 25 px / 420 ms, partida instantânea em 1 px); e atenuação do
  som de saída da escada (`ladder.wav` a −18,6 dBFS com passa-baixas em 5 kHz).
- **Código alterado:** `tasks.pde` (`acceptPreventive`, `interactNpc`), `hud.pde` (`orderRouteLine`),
  `ship.pde` (`drawRoomCard`), `capture.pde` (`captureCompleteQuest`, asserção de entrega direta)
  e `prototype/balance-model.mjs` (`acceptPreventive`).
- **Evidência:** `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` → **146 asserções `OK`**,
  zero `FALHOU`, `QUEST CHECK: PASS`, `som: 6 de 6 carregados`, `arte: 4 de 57 imagens carregadas`.
  `node prototype/balance-model.mjs --simulate` → `BALANCE CHECK: PASS` (2520/2520 sequências).
- **Wayfinder:** #32 aberta e mantida OPEN por decisão expressa do usuário, ligada como sub-issue da #1.
- **Fontes sincronizadas:** `mechanics/ACTIONS.md`, `interface/FLOW.md`, `interface/HUD.md`,
  `code/SKETCH_ARCHITECTURE.md`, `code/VERIFICATION.md` e este arquivo.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `a8aeed6` (sketch), `0e632ba` (áudio) e este registro de documentação.
- Resultado: funcionalidade refinada e verificada no Processing — fluxo de preventivas sem cliques redundantes.

### Sessão anterior — #31

Sessão da [issue #31](https://github.com/shelldonryan/gtd_example/issues/31) —
suporte híbrido aos padrões Aseprite e Universal LPC, novas animações do player e integração.

- **Decisões do usuário (D-140 a D-142):** suporte híbrido transparente a Aseprite e LPC;
  ativação de `climb` (6 quadros, linha 21) na escada e `jump` (13 quadros, linha 49) no ar
  para sprites LPC, com fallback gracioso para Aseprite; orientação frontal (Sul / linha 24)
  para NPCs no formato LPC; substituição direta com backup (`player_sheet_aseprite.*` e `LICENSE.txt`).
- **Código:** `assets.pde` detecta automaticamente JSON Aseprite (`"frames"`) vs LPC;
  carrega perfis esquerdo (linha 23) e direito (linha 25) para os NPCs virarem
  dinamicamente na direção do técnico (D-143); `ship.pde` gerencia máquina de
  estados com idle, walk, climb e jump.
- **Assets integrados:** os 4 NPCs foram colocados em `data/npc/` (`vera.png`,
  `bento.png`, `neusa.png`, `silvia.png`) com `LICENSE.txt`.
- **Evidência:** `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` → **145 asserções `OK`**,
  zero `FALHOU`, `QUEST CHECK: PASS`, `arte: 4 de 57 imagens carregadas`.
  Inspeção visual confirma Vera, Bento, Neusa e Sílvia desenhados no convés e olhando
  para o jogador.
- **Wayfinder:** #31 criada, rotulada `wayfinder:task`, vinculada como sub-issue da #1 e concluída com evidência.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `ec99d12` (sketch),
  `84cfe48` (assets), `5c46a74` (documentos), `a509fe0` (vault) e este registro.
- Resultado: funcionalidade pronta no jogo Processing — player e 4 NPCs integrados em LPC, com animações e olhar dinâmico.
### Sessão anterior — #28


Sessão da [issue #28](https://github.com/shelldonryan/gtd_example/issues/28) —
som da escada e da porta escolhidos com o usuário, integrados e verificados.

- Fronteira recalculada no grafo nativo antes desta sessão: apenas #1 e #28
  abertas; #28 sem bloqueadores.
- **Correção de escopo:** o ticket afirmava "dois efeitos (clique e alerta)",
  herdados do recorte da #3, sem confirmação do usuário. A definição passou a ser
  **evento por evento**, a partir dos eventos reais do código — 18 candidatos
  levantados com âncora em `ship.pde`, `game.pde`, `hud.pde` e `tasks.pde` —, e a
  procedência ficou registrada no ticket.
- **Decisões do usuário:** clique de UI e alerta de recurso crítico **sem som**
  (a cadência "uma vez na transição para o vermelho" foi confirmada e revertida
  na mesma sessão — **SUPERSEDED**); a escada toca na **saída** e ganha **passos**
  na subida e na descida; a porta toca **uma vez na travessia** (D-135 a D-138).
- **Escolha por escuta, em quatro rodadas:** a Kenney foi reprovada pelo usuário;
  entraram qubodup (portas reais), yd (porta deslizante), BMacZero (mecânica),
  rubberduck (ar) e congusbongus (escada de alumínio). A porta final — "tsssss
  contínuo + metal" — trocou a camada de ar, que era gravação de porta de
  madeira, por chiado real: ZCR 4.070 → ~13.400.
- **Defeito corrigido:** engate e saída da escada no mesmo quadro disparavam o
  som em rajada — 5 disparos no mesmo quadro no teste do harness, 1 depois. Com
  o gatilho único na saída, o caso deixou de existir por construção.
- **Níveis medidos, não estimados:** escada a −10 dBFS de pico e passos a
  −20 dBFS com passa-baixas em 5 kHz; porta a −10 dBFS de pico e −25,8 dBFS de
  RMS, alinhada à escada aprovada (estava 6,8 dB acima dela).
- **Estrutura:** os sons ficaram em `data/audio/<evento>/`, cada pasta com o seu
  `LICENSE.txt`.
- **Evidência:** `--ladder-test` → 6 `OK`; `--capture` → **145 asserções `OK`**,
  zero `FALHOU`, `QUEST CHECK: PASS`, `som: 6 de 6 carregados`; com a pasta de som
  ausente, `5 de 6 carregados`, jogo mudo e sem exceção.
- **Wayfinder:** #28 permanece OPEN por decisão do usuário (D-139), com o corpo
  reescrito no estado entregue; a #1 registra a entrega e a hipótese.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `f11ca5b`
  (sketch), `274aa4a` (sons), `ce7098a` (documentos), `34dda16` (vault) e o
  próprio registro de commits. A
  árvore fica limpa, exceto `last_horizon/data/player/player_sheet_new.*`, que
  não é desta sessão. A branch `entrega` precisa ser remontada
  (`node tools/snapshot-entrega.mjs`) antes de publicar.
- Resultado: funcionalidade pronta no jogo Processing — som de porta e de escada,
  com licenças e níveis documentados.

### Sessão anterior — #7

Sessão da [issue #7](https://github.com/shelldonryan/gtd_example/issues/7) —
entrega montada, documentação separada da verificação e sketch pronto para
receber arte.

- Fronteira recalculada no grafo nativo antes desta sessão: apenas #1, #7 e #28
  estavam OPEN; #8 CLOSED com todos os bloqueadores fechados.
- Grilling do #7 com decisões confirmadas uma a uma: entrega = documentação do
  vault (menos os operacionais) + o jogo; `assets/INVENTORY.md` e as concept
  arts entram; material de verificação sai dos docs entregues e vira
  `code/VERIFICATION.md`, só do repositório; `README.md` é o hub do grafo, com
  wikilinks entre as notas e issues apenas em `Referências`; o pacote roda na
  máquina do professor abrindo o `.pde` no Processing; prazo 23/09; arte de IA
  proibida, CC0/CC-BY permitidas e selecionadas pelo usuário.
- Tickets abertos e concluídos na sessão: #29 (camada de arte) e #30 (desacoplar
  o harness), ambos ligados como sub-issues da #1 e fechados com evidência.
- Código: `last_horizon/assets.pde` carrega a arte por arquivo com fallback
  geométrico e desenho 1:1; `ship.pde` ganhou a travessia de porta em dois
  quadros; `last_horizon.pde` declara os pontos de extensão do harness
  (`harness_setup`, `harness_update`, `harness_scene`); `capture.pde` se instala
  neles e passou a fixar a sequência de incidentes.
- Evidência: `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` →
  **145 asserções `OK`** e `QUEST CHECK: PASS` em três execuções seguidas; cópia
  com as 57 fixtures de arte em pasta temporária → 57/57 carregadas, 145 `OK`,
  `PASS`; híbrido sem os fundos de sala → 53/57, 145 `OK`, `PASS`; inspeção
  visual confirmou ícones nos cartões, estações com a base no convés, porta no
  limiar e retratos/telas desenhados.
- Defeito de verificação corrigido: o sorteio da sequência de incidentes podia
  repetir o motor no dia 4 e quebrar a asserção de prioridade — reproduzido no
  código original (três execuções: `PASS`, `FALHOU`, `PASS`) e corrigido com
  sequência determinística; três execuções seguintes passaram.
- Pacote montado fora do repositório: `../entrega_last_horizon/` com 23 notas,
  8 concept arts, o sketch de 8 abas e `data/player/`; zero wikilink quebrado e
  zero token de verificação nos documentos entregues; a pasta compila e roda
  fora do repositório.
- Fontes sincronizadas: `README.md`, `interface/`, `mechanics/ACTIONS.md`,
  `events/`, `characters/`, `docs/adr/`, `history/CONTEXT.md`,
  `assets/INVENTORY.md`, `code/SKETCH_ARCHITECTURE.md`, `code/VERIFICATION.md`
  (novo) e este arquivo.
- Wayfinder: #29 e #30 CLOSED com evidência; #7 desbloqueada no grafo (as duas
  dependências concluídas) e fechada no fim da sessão com entrega pelo GitHub e
  plano B por gravação curta.
- Commits da sessão na branch de trabalho, sem push: `acca499` (sketch),
  `9124fbf` (documentos), `6d52247` (resumo), `8ff4f26` (Obsidian) e `00bc5fa`
  (script do snapshot e regra D-134).
- A branch `entrega` foi gerada por `tools/snapshot-entrega.mjs` — 42 arquivos,
  sem material de verificação — e o script não cria commit quando a árvore não
  mudou.
- Pendências: som (#28) e a seleção da arte seguem abertos, e a gravação do
  plano B é ação do usuário até 23/09.
- Resultado: protótipo executável pronto para receber arte e pacote de entrega
  montado e verificado.

### Sessão anterior — #8

Sessão da [issue #8](https://github.com/shelldonryan/gtd_example/issues/8) —
inventário de assets e congelamento do layout para a pintura.

- Fronteira recalculada no grafo nativo antes desta sessão: apenas #1, #7 e #8
  estão OPEN, e os bloqueadores nativos da #8 estão todos CLOSED.

- Decisões confirmadas pelo usuário, uma a uma: fundo em imagem por sala, com
  piso e escadas **pintados** no fundo e colisão mantida no código; escadas
  definitivas por sala, medidas na composição dos concept arts; 14 estações com
  desenho próprio; NPCs com idle, porta com abertura e casco com brilho
  animados; menu e vinheta com a nave de fora e a Terra ao fundo; vitória com a
  base em Marte; derrota com o espaço vazio; som deixado para depois.

- Layout aplicado em `last_horizon/ship.pde`: `ladder_x` por sala (127/532,
  114/526, 120/489, 127/482) e dez estações realocadas — mais Vera (540→575) e
  Sílvia (540→570), que ficariam sobre a escada. Folga mínima de 40 px do eixo
  de escada e 60 px entre estações; nenhuma coordenada estava cravada no harness.

- Documento novo: `assets/INVENTORY.md` — 57 PNGs e 6 JSONs, com canvas por
  peça, tela onde aparece, estática ou animada, o que continua em código e a
  ordem de produção (ícones → porta e casco → objetos → NPCs → estações →
  retratos → fundos → telas e mapa).

- Evidência: `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` → 142
  asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS`; inspeção visual das
  capturas novas confirmou as escadas em 0,20/0,83 (Comando), 0,18/0,82
  (Máquinas) e 0,20/0,75 (Dormitório), sem estação sob escada.

- Fontes sincronizadas: `assets/INVENTORY.md`, `interface/ROOMS.md`,
  `interface/HUD.md`, `code/SKETCH_ARCHITECTURE.md`, `README.md` e este arquivo.
- Commits na branch `prototype/sketch-architecture`, sem push: `d7010c5`
  (sketch), `006334c` (inventário), `edfae19` (fontes) e este registro.
- Wayfinder: #8 CLOSED com decisões, arquivos e evidência no ticket; #28 criada,
  rotulada `wayfinder:task` e ligada como sub-issue da #1; corpo e comentário da
  #1 atualizados com a fronteira.

- Pendência: o som foi para a #28; nenhuma decisão de áudio foi tomada nesta
  sessão.
- Grafo: a #27 foi ligada como sub-issue da #1, fechando a única lacuna — todas
  as issues marcadas "Part of #1" estão agora no grafo nativo. Continuam abertas
  #7 e #28; as demais estão CLOSED.
- Resultado: documentação de arte fechada e layout congelado no protótipo
  executável — não é a arte final, que segue a ordem de produção.

### Sessão anterior — #27

Sessão da [issue #27](https://github.com/shelldonryan/gtd_example/issues/27),
concluída após o trabalho ser desviado do inventário #8 e o retorno pelas portas
ser validado manualmente.

- Fronteira recalculada no grafo nativo antes desta sessão: #7 e #8 estão OPEN;
  #27 está CLOSED; #8 segue como próximo caminho crítico.

- Decisões confirmadas pelo usuário, uma a uma: NPCs voltam a ser interativos com
  texto por estado; portas viram portais com limiar e chegada configurável,
  retornando imediatamente à posição `x/y` de saída na sala anterior; escadas
  viram dados aceitando posições arbitrárias; HUD com rótulos de texto nos
  cartões, faixa inferior em campos fixos e rodapé com `?`; nome vazio mantém
  `INICIAR` bloqueado; derrota só com contagem; pós-vitória inexistente; alertas
  sem linha de texto; "reparo no limite" é a solução do motor entregue com prazo 1.

- Vinheta trocada pelo roteiro confirmado no #11; transmissões da Terra e a
  mensagem de Marte implementadas com o nome do técnico.
- Defeito corrigido: `enterRoom()` usava o destino da porta em vez da sala da
  própria porta — entrar no Depósito levava ao Comando.
- Harness endurecido: asserção falha reprova o resultado e `QUEST CHECK: PASS`
  não é mais impresso depois de uma falha.
- Evidência: `--capture` → 140 asserções `OK` e `QUEST CHECK: PASS`, incluindo
  abertura sem deck, limiar acima de deck, chegada independente em outro canto,
  retorno da porta à posição de entrada, prioridade de quest sobre portal
  coincidente e 2.520/2.520 campanhas sem travar a janela; `--hit-test` → 5
  `OK`; `--ladder-test` → 6 `OK` (inclui escada em x arbitrário); `node
  prototype/balance-model.mjs --simulate` → `BALANCE CHECK: PASS`.
- Capturas novas em `last_horizon/output/`: `32_help_panel.png`,
  `34_earth_transmission.png`, `29_victory.png` (mensagem de Marte),
  `28_defeat.png` (contagem, sem nomes) e `catalogue_*_hud.png` (cartões
  rotulados e faixa em campos fixos); a inspeção visual confirmou os textos.
- Fontes sincronizadas: `interface/` (MENU_INIT, MENU_VICTORY, MENU_GAME_OVER,
  HUD, FLOW, ROOMS), `code/SKETCH_ARCHITECTURE.md`, `README.md` e este arquivo.
- Wayfinder: #27 CLOSED após validação manual, com o corpo atualizado para os
  portais ampliados; corpo e comentário da #1 atualizados; comentário na #8
  registrando que os cartões passam a ter rótulo e que portas/escadas deixaram de
  ser posições fixas.
- GitNexus continua sem indexar as funções `.pde`; a verificação funcional é a do
  Processing.
- O delta desta sessão foi commitado depois do encerramento: `e1563e0` (sketch),
  `89328d9` (docs), `f992cfb` (concept arts) e `d870f67` (vault); nenhum push foi
  feito.
- Alinhamento posterior: `SESSION_START.md` (contrato técnico) e
  `interface/TEXT_FONTS.md` ainda diziam "cartões de recurso sem rótulo"; as duas
  linhas passaram a registrar ícone + número + rótulo + barra, conforme a decisão
  confirmada na #27 e o comentário da #8. Nenhuma decisão nova foi tomada.
- Wayfinder desta sincronização: corpo e comentário da #1 atualizados com a
  fronteira recalculada no grafo nativo, os commits acima e o alinhamento dos
  rótulos. A fronteira não mudou: #8 é o próximo caminho crítico e #7 segue em
  paralelo.
- Resultado: funcionalidade pronta no jogo Processing — vinheta, transmissões,
  desfechos, NPCs, HUD e portais com limiar e chegada configuráveis —, não apenas
  documentação.
