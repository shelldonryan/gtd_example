# Contrato e registro histórico de verificação do sketch

Os comandos e resultados descritos nesta nota registram o fluxo de verificação
da campanha E6 em 20/09/2026. A revisão estática de 21/09/2026 não compilou nem
executou o sketch, o harness ou o modelo. O mapa do checkout atual não possui a
orientação por rota/escada mencionada em cenários históricos; consulte
[`docs/CURRENT_IMPLEMENTATION.md`](../docs/CURRENT_IMPLEMENTATION.md) para o
estado observado no código.

Esta nota é só do repositório: é material de verificação do agente e **não faz
parte da entrega**. As decisões de arquitetura e de jogo ficam em
[[SKETCH_ARCHITECTURE]] e nas demais notas de design; aqui ficam os comandos, o
contrato do harness, a costura de verificação, a sequência determinística, o
modelo numérico e as fixtures.

## Como rodar

Na instalação usada, `processing-java` não existe e também não existe
`C:\Program Files\Processing\runtime\bin\java.exe`. O launcher suportado é o CLI
embutido no `Processing.exe`. Os comandos abaixo são executados a partir da raiz
do repositório:

```
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --capture
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --hit-test
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --ladder-test
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --asset-pipeline-test
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --metrics
```

Para a validação técnica dos módulos JavaScript, o projeto mantém um script
nativo do Node, sem dependências adicionais:

```
npm run typecheck
```

No Linux, os runners do repositório localizam o CLI embutido em
`/opt/processing/bin/Processing` (ou em `PROCESSING_BIN`), copiam o sketch para
uma pasta temporária chamada `last_horizon` e executam o modo Java com Xvfb
quando não há `DISPLAY`. Se houver um socket PulseAudio local, ele é usado para
que o `javax.sound.sampled` consiga abrir os WAVs durante o harness:

```text
./tools/build.sh
./tools/run-headless.sh --capture
./tools/run-headless.sh --hit-test
./tools/run-headless.sh --ladder-test
./tools/run-headless.sh --asset-pipeline-test
./tools/regression-final.sh
```

O runner temporário mantém o nome da pasta igual ao arquivo `last_horizon.pde`,
evita artefatos de compilação no sketch e copia `last_horizon/output/` de volta
ao workspace ao terminar. A consolidação `tools/regression-final.sh` executa
`tools/cleanup-verification-artifacts.mjs` antes da campanha e ao sair, removendo
o diretório de saída transitório mesmo quando uma etapa falha.

Ele executa `node --check` em `prototype/balance-model.mjs`,
`tools/snapshot-entrega.mjs`, `tools/e6-audit.mjs`,
`tools/compare-metrics.mjs` e `tools/e6-evidence.mjs`.

`--capture`, `--hit-test`, `--ladder-test`, `--asset-pipeline-test` e `--metrics`
são a fronteira pública de verificação. Sem argumento, o sketch abre o jogo
normal. `--metrics` aquece por 120 quadros e grava três amostras de 30 segundos
em `last_horizon/output/performance__metricas.csv`, com mediana, p95, carga de
arte, memória adicional e contadores de cache.

## Contrato do harness

- **`--capture`** salva 34 estados do ciclo em `last_horizon/output/`: menu e
  vinheta, ofertas, seleção, confirmação presencial, rota e mapa da quest,
  coleta, objeto carregado, entrega, recompensa, previsão noturna, incidentes,
  retomada, socorro, pausa, derrota, vitória, resumo noturno denso, ajuda e
  transmissão da Terra; salva também os cartões e HUDs do catálogo,
  `orders_badge_pulse.png` e as capturas do modal de ajuda e da transmissão.
  O modo exerce aceite presencial, coleta, entrega, custo inviável, falha,
  negligência, retomada pela interface, exclusividade diária, crises, socorro,
  morte e filtragem do pool.
- As asserções cobrem os seis portais pela tabela, uma porta fora da borda, uma
  abertura sem deck, limiar acima de um deck, chegada independente em outro
  canto, retorno imediato à posição de entrada, porta coincidente com ponto de
  quest, escada em `x` arbitrário, as falas de NPC por estado, as transmissões
  (motor, casco, primeira perda, uma vez por partida) e as três variações da
  mensagem de Marte.
- O bloco `checkEditorialContract()` valida a cobertura dos 22 IDs, o fallback
  factual de entrada inválida, a pureza das consultas, o reconhecimento no dia
  do resultado e no dia seguinte, a apresentação controlada pela abertura da
  conversa, a separação entre risco e resultado e a prioridade socorro,
  ajuda, falha e omissão.
- O bloco `checkCacheContract()` valida as seis fontes de ícone, a estabilidade
  dos seis caches, o compartilhamento de uma faixa de piso por tile/largura e a
  invalidação seletiva quando uma única fonte muda.
- **`--hit-test`** cobre as quatro fichas de sala e o letterbox, confirmando que
  o clique nunca transporta o técnico. **`--ladder-test`** cobre as rotas
  físicas da escada: saída lateral, travessia, encaixe no convés, rearme após
  soltar, repouso e escada em posição arbitrária; salva
  `ladder__middle_exit__1280x720.png`.
- Asserção falha imprime `FALHOU`, restaura o baseline das tabelas mutáveis e
  encerra o harness imediatamente. Cada bloco de verificação começa e termina
  com o mesmo reset, cobrindo sequência de incidentes, posição, flags, pontos,
  portas, escadas e arte de portas. `QUEST CHECK: PASS` só aparece quando
  nenhuma asserção falhou; havendo falha, sai `QUEST CHECK: FALHOU`.
- **Campanhas internas:** o mesmo modo executa três estratégias vencedoras, uma
  omissão derrotada por motor destruído e as 2.520/2.520 sequências de
  incidentes vencidas pela reserva de peças, no próprio Processing, uma etapa
  por quadro. Enquanto elas rodam, o sketch mostra uma tela estável de
  verificação, sem expor os recursos mutáveis dos cenários internos.
- **Arte na verificação:** os testes de portal assumem a travessia instantânea,
  então `checkConnectedDoors()`, `checkPlayerFacing()` e `checkDoorAnywhere()`
  rodam com a arte da porta limpa (`clearDoorArt()`/`restoreDoorArt()`) e
  devolvem o estado anterior no fim. A travessia em dois quadros tem teste
  próprio (`checkDoorTraversalArt()`), que instala um par de quadros e confere
  abrir, trocar de sala e fechar.
- **Áudio na verificação:** a camada de áudio (`last_horizon/audio.pde`) usa
  `javax.sound.sampled` da JVM e carrega 14 de 14 clipes (`som: 14 de 14 carregados`):
  porta, quatro passos de ataque único e cauda de 12 ms para caminhada, quatro
  passos com impacto para corrida e quatro passos originais da escada. Durante o
  `setup()`, cada clip é iniciado no frame 0 por 50 ms em modo silencioso
  (`MUTE`,
  `MASTER_GAIN` ou `VOLUME` mínimo), depois é parado, reposicionado e aquece o
  mixer antes do primeiro passo real. `checkPlayerFootsteps()` verifica que a
  caminhada dispara no início e em 400 ms do ciclo visual, sem antecipar o
  segundo contato; corrida, decolagem e aterrissagem mantêm seus gatilhos. Se
  `data/audio/` ou algum arquivo estiver ausente, o sketch continua mudo;
  `--capture` e `--ladder-test` passam identicamente.
- **Animação do jogador na verificação:** `checkPlayerAnimationLoop()` confere
  que idle e walk entram em loop, e `checkPlayerRun()` cobre a corrida com
  `Shift`: passo acelerado no convés (1,0 → 2,4 px por quadro, com e sem a faixa
  de `run`), avanço de um quadro a cada 75 ms, ciclo fechado nos 8 quadros,
  comparação pixel a pixel provando que a faixa vem da linha 41 do LPC e não da
  caminhada, regresso à caminhada ao soltar a tecla, ausência de corrida parado,
  prioridade da escada e do pulo sobre a corrida e passo do ar já no quadro da
  decolagem. As duas últimas foram conferidas por mutação: ler a linha 39, mover
  o passo para antes da gravidade e remover o passo acelerado reprovam o harness.
- **Contagem atual:** `--capture` fecha em **169 asserções `OK`** com
  `QUEST CHECK: PASS`, medidas em 2026-09-18 após D-158: 159 antes dos testes de
  orientação do NPC no pulo e dos bancos independentes de passos. Medido no
  repositório com os sons integrados, na cópia sem arte, na cópia com as 57
  fixtures e no híbrido sem os fundos de sala.
- **Feedback visual de NPC (D-155):** os retângulos geométricos foram removidos
  da cena. O contorno/halo cyan é derivado dos frames carregados em runtime e
  só aparece no raio de interação, sem alterar o hit-test nem o sprite original.
- O harness também verifica que o NPC mantém a orientação horizontal para o
  jogador durante o pulo e acompanha a mudança de lado no ar, sem aplicar essa
  orientação quando o jogador está em uma escada ou fora do mesmo convés.
- **Ícones de recursos (D-157):** os seis PNGs estáticos de 32×32 em
  `data/icons/` substituem os vetores dos cartões por uma camada `PGraphics`
  sem interpolação; o alerta crítico permanece geométrico e não carrega
  `aviso.png`. `--asset-pipeline-test` → `arte: 14 de 56 imagens carregadas`,
  `pipeline: OK`; `--hit-test` → 5 `OK`;
  `--capture` → `QUEST CHECK: PASS`. A inspeção visual confirmou energia,
  oxigênio, água, comida, peças e moral nos cartões.

## Fixture do pipeline

- `pipeline_probe.aseprite` e `pipeline_probe_frame_1.png` são o fixture do
  pipeline, não assets finais nem convenção de produção. O probe tem 16×16
  pixels e é exibido duas vezes na grade lógica, no render físico 1280×720.
- O modo de prova prepara uma camada `PGraphics` sem interpolação antes de
  `beginDraw()`. A camada é composta no buffer principal, preservando a
  suavização do texto.
- O comando é
  `"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --asset-pipeline-test`.
  Ele salva `pipeline__probe__1280x720.png` e
  `pipeline_window__probe__1280x720.png` em
  `last_horizon/output/` e encerra com `pipeline: OK` quando o PNG é carregado
  por `loadImage()`, ou `pipeline: FALHOU` quando não é. O modo do pipeline não
  roda as asserções de gameplay.
- Evidências temporárias ficam em `last_horizon/output/`: imagens usam
  `etapa__estado__viewport.ext`, logs usam `etapa__execucao.log` e medições
  usam `etapa__metricas.csv`. O arquivo documental `metrics.csv` é o relatório
  consolidado; não é um nome alternativo para a medição temporária. O utilitário
  de consolidação remove o diretório após a execução; nenhum PNG, log ou medição
  transitória é retido sem política aprovada.

## Costura de verificação

- A aba principal declara pontos de extensão inertes: `harness_setup`,
  `harness_update` e `harness_scene`, além da interface `SceneHook`, em
  `last_horizon/last_horizon.pde`.
- A aba `last_horizon/capture.pde` se instala neles: `installHarness()` liga os
  três ganchos e `harness_scene` devolve `false` fora dos modos de verificação,
  deixando o jogo desenhar normalmente.
- Sem essa aba o sketch compila e roda: os ganchos ficam nos valores padrão,
  que não fazem nada. Por isso a cópia entregue sai com 8 abas — todas menos
  `capture.pde` —, e essa é a única diferença entre o sketch do repositório e o
  da entrega.

## Sequência determinística

`captureStartDay()` em `capture.pde` fixa a sequência de incidentes antes de
cada cenário. O sorteio podia repetir o motor no dia 4 e quebrar a asserção de
prioridade do incidente novo, uma falha intermitente reproduzida no código
original; com a sequência fixada, o cenário é reprodutível. O harness também
captura as tabelas pós-carregamento e as restaura ao entrar, sair ou falhar em
uma fixture, evitando que uma mutação de teste atravesse a próxima fixture.

## Modelo numérico

```
node prototype/balance-model.mjs --simulate
node --check prototype/balance-model.mjs
```

A simulação imprime `BALANCE CHECK: PASS`; `--check` valida a sintaxe do
arquivo. O modelo é a referência numérica independente do sketch.

## Auditoria E6

Na raiz, `npm run e6:audit` executa `tools/e6-audit.mjs`. A auditoria não
substitui a compilação do Processing: ela confere a presença dos contratos T01–T10,
as contagens do domínio, os 22 IDs editoriais, as entradas de projeção, os
caches, o modo de métricas e a exclusão dos dois módulos opcionais no snapshot.
`npm run e6:evidence` valida o playtest, as seis amostras, o ambiente
equivalente, a matriz funcional, os cenários especiais, os caches e o snapshot.
`npm run e6:compare -- baseline.csv final.csv` calcula a variação da mediana e
do p95; aumento acima de 10% no p95 encerra com `INVESTIGATE` para exigir
registro no relatório.

## Projeção noturna

`last_horizon/night_projection.pde` define a fronteira pura
`simulateNightTransition()`. Ela clona recursos, tripulação, riscos, problemas,
quests, objetos, conclusão, sequência e índice de incidentes antes de aplicar,
uma única vez, consequência da quest, consumo, perdas, risco, prazos, crises,
limite e condições de término. O retorno contém `projected_state`, `deltas`,
`effects`, `fatal_conditions` e `game_outcome`.

`projectNight()` é o adaptador de exibição do modal e `processNight()` consome
exatamente uma projeção para aplicar o resultado confirmado. Nenhum deles
seleciona o próximo dia; a preparação do novo dia permanece em `endDay()` e
só ocorre depois de um resultado contínuo. O harness `--capture` também confere
que recálculo do preview preserva RNG, globais, memória editorial, riscos e
prazos, que snapshot e estado real não compartilham arrays, que a aplicação é
numericamente equivalente ao preview e que o dia 10 projeta vitória.

## Caminho de arte com fixtures

1. Copie o sketch para uma pasta temporária.
2. Crie PNGs de teste nos caminhos de [[INVENTORY]] — `data/icons/`,
   `data/stations/`, `data/objects/`, `data/npc/` com o JSON ao lado,
   `data/doors/`, `data/rooms/`, `data/portraits/`, `data/screens/` e
   `data/map/`.
3. Rode o sketch na pasta temporária com `--run` e confirme no console a linha
   `arte: N de M imagens carregadas` e o desenho 1:1.

Nenhuma arte de teste entra no repositório: a verificação usa só a cópia
temporária.

## Snapshot de entrega

A branch `entrega` é um artefato **gerado**, não um lugar de edição: protótipo e
documentação evoluem na branch de trabalho, e o snapshot é remontado quando for
publicar.

```
node tools/snapshot-entrega.mjs
git push origin entrega
```

- O script lê a árvore da branch de trabalho por índice temporário — não toca no
  working tree, então o Obsidian aberto não atrapalha — e cria um commit novo em
  cima do snapshot anterior: o push é sempre normal, sem force.
- Fora do snapshot: `SESSION_START.md`, `code/VERIFICATION.md`, `prototype/`,
  `tools/`, `skills-lock.json`, `.obsidian/`, `last_horizon/capture.pde`,
  `last_horizon/test_mode.pde` e os fixtures `pipeline_probe.*`.
- O runtime mantém hooks inertes quando `capture.pde` e `test_mode.pde` estão
  ausentes; os dois módulos são opcionais no sketch de desenvolvimento.
- Se a árvore não mudou desde o último snapshot, o script não cria commit.
- A pasta `../entrega_last_horizon/` é uma cópia local do mesmo corte, para
  conferência; a fonte continua sendo a branch de trabalho.

## Limitações observadas

- O runtime manual não existe nesta instalação:
  `Test-Path 'C:\Program Files\Processing\runtime\bin\java.exe'` retorna
  `False`. Portanto não há comando manual de compilação usando esse runtime; o
  launcher suportado é o CLI do Processing.
- A captura não usa bibliotecas externas do sketch: usa somente o core
  carregado pelo CLI e a família Segoe UI instalada no Windows. Não há
  biblioteca adicional ausente bloqueando o harness.
- O CLI emite os avisos `display count needs to be implemented for non-AWT` e
  `AWT disabled`, mas compila, executa, salva as imagens e encerra com sucesso.
  A execução headless não foi validada nesta sessão.

## Referências

- [#4 Executar e capturar o sketch fora da IDE](https://github.com/shelldonryan/gtd_example/issues/4)
- [#10 Pipeline Aseprite → Processing](https://github.com/shelldonryan/gtd_example/issues/10)
- [#29 Camada de assets: sketch pronto para receber a arte](https://github.com/shelldonryan/gtd_example/issues/29)
- [#30 Desacoplar o harness do jogo para a entrega](https://github.com/shelldonryan/gtd_example/issues/30)
