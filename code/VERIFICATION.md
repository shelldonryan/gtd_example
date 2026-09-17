# Verificação do sketch

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
```

`--capture`, `--hit-test`, `--ladder-test` e `--asset-pipeline-test` são a
fronteira pública de verificação. Sem argumento, o sketch abre o jogo normal.

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
- **`--hit-test`** cobre as quatro fichas de sala e o letterbox, confirmando que
  o clique nunca transporta o técnico. **`--ladder-test`** cobre as rotas
  físicas da escada: saída lateral, travessia, encaixe no convés, rearme após
  soltar, repouso e escada em posição arbitrária; salva
  `ladder_middle_exit.png`.
- Asserção falha imprime `FALHOU`, marca o resultado como reprovado e encerra o
  harness imediatamente. `QUEST CHECK: PASS` só aparece quando nenhuma asserção
  falhou; havendo falha, sai `QUEST CHECK: FALHOU`.
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
  `javax.sound.sampled` da JVM e carrega 6 de 6 clipes (`som: 6 de 6 carregados`).
  Durante o `setup()`, cada clip é iniciado no frame 0 por 50 ms em modo silencioso
  (`MUTE`, `MASTER_GAIN` ou `VOLUME` mínimo), depois é parado, reposicionado e
  aquece o mixer antes do primeiro passo real. Se a pasta `data/audio/` ou
  qualquer arquivo estiver ausente, o carregador emite aviso no console e o
  sketch continua executando mudo, sem exceção; os testes de `--capture` e
  `--ladder-test` passam identicamente.
- **Animação do jogador na verificação:** `checkPlayerAnimationLoop()` confere
  que idle e walk entram em loop, e `checkPlayerRun()` cobre a corrida com
  `Shift`: passo acelerado no convés (1,0 → 2,4 px por quadro, com e sem a faixa
  de `run`), avanço de um quadro a cada 75 ms, ciclo fechado nos 8 quadros,
  comparação pixel a pixel provando que a faixa vem da linha 41 do LPC e não da
  caminhada, regresso à caminhada ao soltar a tecla, ausência de corrida parado,
  prioridade da escada e do pulo sobre a corrida e passo do ar já no quadro da
  decolagem. As duas últimas foram conferidas por mutação: ler a linha 39, mover
  o passo para antes da gravidade e remover o passo acelerado reprovam o harness.
- **Contagem atual:** `--capture` fecha em **159 asserções `OK`** com
  `QUEST CHECK: PASS`, medidas em 2026-09-17 com a corrida integrada (148 antes
  dela; a recontagem no commit `fd62b7a` mostra que a referência de 146 estava
  defasada). Medido no repositório com os sons integrados, na cópia sem arte, na
  cópia com as 57 fixtures e no híbrido sem os fundos de sala.
- **Feedback visual de NPC (D-155):** os retângulos geométricos foram removidos
  da cena. O contorno/halo cyan é derivado dos frames carregados em runtime e
  só aparece no raio de interação, sem alterar o hit-test nem o sprite original.
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
  Ele salva `pipeline_probe.png` e `pipeline_probe_window.png` em
  `last_horizon/output/` e encerra com `pipeline: OK` quando o PNG é carregado
  por `loadImage()`, ou `pipeline: FALHOU` quando não é. O modo do pipeline não
  roda as asserções de gameplay.

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
original; com a sequência fixada, o cenário é reprodutível.

## Modelo numérico

```
node prototype/balance-model.mjs --simulate
node --check prototype/balance-model.mjs
```

A simulação imprime `BALANCE CHECK: PASS`; `--check` valida a sintaxe do
arquivo. O modelo é a referência numérica independente do sketch.

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
  `tools/`, `skills-lock.json`, `.obsidian/`, `last_horizon/capture.pde` e os
  fixtures `pipeline_probe.*`.
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
