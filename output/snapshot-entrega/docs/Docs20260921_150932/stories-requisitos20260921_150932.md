# Preparação integrada para entrega

## Contexto e objetivo

Este documento transforma o discovery da feature em stories e requisitos para o projeto existente Last Horizon. A feature consiste em uma revisão técnica integrada do código para reduzir custo e ruído de manutenção e tornar o fluxo de preparação da entrega mais previsível, preservando a experiência e o comportamento funcional observável do jogo.

Os cinco objetivos obrigatórios permanecem uma única entrega integrada: revisar performance, remover código comprovadamente não utilizado, consolidar duplicações, remover comentários dos arquivos executáveis e reorganizar a estrutura do sketch.

O runtime é um sketch Processing 4.5.6 em `last_horizon/`. As abas `.pde` são compiladas como uma unidade e compartilham estado global. Node.js em módulos ES e scripts Bash apoiam checagem, regressão, métricas, execução headless e montagem do snapshot de entrega. Não há banco de dados, backend, autenticação, framework web ou outra camada de persistência.

## Base da arquitetura existente

| Domínio | Arquivos e módulos observados | Contrato relevante para a feature |
| --- | --- | --- |
| Loop e entrada | `last_horizon/last_horizon.pde` | `setup()`, `draw()`, viewport lógico, teclado, mouse e pontos de extensão do harness e do modo de teste. |
| Telas e modais | `last_horizon/screens.pde`, `last_horizon/ui.pde` | `uiLayer()` define a camada ativa; desenho, `findButton()`, cursor, teclado e clique dependem da mesma camada. |
| Quests e ciclo diário | `last_horizon/tasks.pde`, `last_horizon/game.pde` | Estado global de ofertas, seleção, aceite, coleta, entrega, limite diário, incidentes, riscos e encerramento do dia. |
| Projeção noturna | `last_horizon/night_projection.pde` | `simulateNightTransition()` calcula uma projeção sobre snapshot; `projectNight()` exibe a previsão; `processNight()` aplica uma única transição real. |
| HUD e desenho estático | `last_horizon/hud.pde`, `last_horizon/assets.pde` | Seis recursos, ordem visual explícita, alertas dinâmicos, cache de ícones e preparação de faixas de piso. |
| Nave e movimento | `last_horizon/ship.pde`, `last_horizon/portals.pde`, `last_horizon/movement.pde`, `last_horizon/animation.pde`, `last_horizon/audio.pde` | Quatro cômodos, portas, escadas, NPCs, fallback de assets, transições animadas ou imediatas e sons associados ao movimento. |
| Verificação | `last_horizon/capture.pde`, `last_horizon/test_mode.pde` | Harness de captura, cenários de hit-test, escadas, pipeline de assets, métricas e controles opcionais de desenvolvimento. |
| Scripts | `package.json`, `tools/` | Checagem Node.js, regressão Processing, simulação de balanceamento, comparação de métricas, auditoria e snapshot de entrega. |

### Escopo confirmado

- Revisar performance, código não usado, código duplicado, comentários em arquivos executáveis e organização estrutural.
- Preservar quests, ciclo de dias, recursos, incidentes, riscos, modais, HUD, mapa, movimento, assets, áudio e desfechos.
- Manter quatro cômodos, quatro sobreviventes além do técnico, seis recursos, dez dias e uma conclusão de quest por dia.
- Usar a regressão existente, o modelo de balanceamento e a comparação de métricas como evidência de preservação e custo.
- Permitir novas abas `.pde` e movimentação de blocos quando a reorganização for mínima, coesa e rastreável.
- Remover comentários de `.pde`, `.mjs` e `.sh`, preservando shebangs e diretivas obrigatórias de execução. Comentários da documentação do repositório ficam fora da remoção.

### Fora do escopo

- Mecânicas, conteúdo, balanceamento, quests, personagens, rotas ou fluxo de jogador novos.
- Engine, dependência, framework de UI, banco de dados, backend, autenticação ou linguagem externa para quests.
- Alteração do contrato de previsão noturna, da ordem de aplicação dos efeitos ou dos controles existentes.
- Remoção do harness ou do modelo de balanceamento para reduzir contagem de linhas.
- Publicação automática de branch ou entrega automática.

## User stories

### Performance e custo de renderização

#### US-01

Como responsável pela manutenção do sketch, quero eliminar trabalho repetido de renderização estática, para reduzir o custo mensurável da execução durante a apresentação.

**Módulos relacionados:** `last_horizon/hud.pde`, `last_horizon/assets.pde`, `last_horizon/ship.pde`, `last_horizon/capture.pde`.

**Critérios de aceite:**

1. Os seis ícones de recurso do HUD são preparados quando os assets são carregados ou quando a fonte muda, e o desenho normal reutiliza a representação preparada.
2. O piso preparado é reutilizado entre os conveses quando fonte, largura e geração são iguais, sem editar destrutivamente a imagem compartilhada.
3. A ausência de arte mantém o fallback geométrico existente para ícones e piso.
4. O valor, a barra, a cor, o alerta crítico e a ordem dos seis recursos continuam sendo calculados a partir do recurso correto.
5. A instrumentação registra construções, invalidações e memória adicional para que a redução de custo possa ser comparada.

#### US-02

Como responsável pela preparação da entrega, quero comparar baseline e versão revisada em condições equivalentes, para saber se a otimização foi demonstrada por evidência reproduzível.

**Módulos relacionados:** `last_horizon/capture.pde`, `tools/compare-metrics.mjs`, `code/VERIFICATION.md`.

**Critérios de aceite:**

1. A coleta usa `--metrics` como o cenário de comparação de performance, mantendo os mesmos assets, sala, estado, janela nominal, máquina e versão do Processing para baseline e versão final. Os cenários `--capture`, `--hit-test`, `--ladder-test` e `--asset-pipeline-test` são avaliados pela regressão funcional existente.
   Cada captura também produz um manifesto sidecar com `environment`, `machine`, `assets`, `room`, `state`, `nominal_window_s` e `processing`.
2. Cada referência contém três amostras com janela nominal de trinta segundos registrada no manifesto sidecar. O CSV registra separadamente a duração real decorrida e as métricas numéricas da amostra.
3. A comparação registra valores antes, depois e variação observada para mediana e p95 de tempo de quadro. Carregamento, memória adicional, construções de cache e invalidações permanecem disponíveis por amostra ou em resumo simples no registro final, sem exigir novos percentis.
4. Alguma redução mensurável e reproduzível de custo é necessária para declarar a otimização concluída; não há percentual mínimo arbitrário de ganho.
5. Se o ambiente impedir uma medição confiável ou não houver redução mensurável, o resultado fica registrado como inconclusivo para otimização.
6. Para cada métrica agregável com p95 e cada cenário sujeito à medição, o comparador calcula a mediana dos três p95 das amostras baseline e final. Variação superior a 10% mantém o comportamento de falha já tratado por `compare-metrics.mjs` e é registrada como regressão consistente.

### Remoção segura e consolidação de duplicação

#### US-03

Como desenvolvedor do sketch, quero remover somente código comprovadamente não utilizado, para diminuir a superfície de manutenção sem retirar caminhos necessários ao runtime ou à verificação.

**Módulos relacionados:** todas as abas `.pde`, `last_horizon/capture.pde`, `last_horizon/test_mode.pde`, `package.json`, `tools/` e entradas de execução documentadas.

**Critérios de aceite:**

1. Cada trecho removido passa por busca de referências estáticas no repositório.
2. A análise também verifica entrypoints do Processing, nomes globais compartilhados entre abas, entradas de teclado e mouse, modos do harness e scripts chamados por `package.json`.
3. Um trecho não é classificado como morto se for alcançado por um cenário do harness, pelo modo de teste, pela compilação implícita do Processing ou por uma entrada documentada.
4. A validação correspondente é executada depois de cada remoção ou consolidação relevante.
5. Nenhum cenário de equivalência é removido, enfraquecido ou alterado para ocultar uma regressão.

#### US-04

Como desenvolvedor do sketch, quero consolidar lógica duplicada em helpers com responsabilidades explícitas, para corrigir um padrão em um único ponto e manter saídas equivalentes.

**Módulos relacionados:** `last_horizon/ui.pde`, `last_horizon/ship.pde`, `last_horizon/portals.pde`, `last_horizon/hud.pde`, `last_horizon/assets.pde`.

**Critérios de aceite:**

1. Rotinas comuns de texto com sombra, rodapé de ações, seleção de arte de NPC, preparação de portal, mapeamento de recursos e preparação de imagens não mantêm cópias divergentes para o mesmo contrato.
2. A consolidação preserva textos, posições, cores, tamanhos, prioridade de fallback, orientação dos sprites, halos, som, chegada, retorno e comportamento sem asset.
3. O helper de geometria de botão continua registrando a mesma área usada para desenho, cursor, teclado e hit-test.
4. O helper não decide regras de gameplay quando a decisão pertence ao contexto da quest, do incidente ou do modal.
5. Nomes, localizações ou assinaturas alterados têm todas as referências dependentes atualizadas antes da regressão.

#### US-05

Como responsável pela manutenção do repositório, quero remover comentários dos arquivos executáveis, para reduzir ruído textual sem quebrar a execução dos scripts.

**Módulos relacionados:** arquivos `.pde` em `last_horizon/`, módulos `.mjs` e scripts `.sh` executáveis no repositório.

**Critérios de aceite:**

1. Comentários de código e blocos de comentário dos arquivos executáveis cobertos pela feature são removidos.
2. Shebangs e diretivas obrigatórias para execução permanecem no lugar correto.
3. Comentários e conteúdo da documentação em `docs/`, `code/`, `mechanics/`, `events/`, `interface/` e demais áreas documentais não são alterados por essa limpeza.
4. Os arquivos `.mjs` continuam passando por `node --check` e os scripts Bash continuam iniciando com suas diretivas de execução válidas.
5. A remoção de comentários não altera strings exibidas no jogo, dados editoriais, expressões Processing ou comandos operacionais.
6. Uma auditoria obrigatória enumera todos os arquivos `.pde`, `.mjs` e `.sh` cobertos por extensão e caminho, confirma a remoção dos comentários de código e registra as exceções preservadas para shebangs e diretivas necessárias ao funcionamento.

### Reorganização estrutural do sketch

#### US-06

Como desenvolvedor que prepara a entrega, quero separar blocos coesos em abas procedurais menores, para localizar responsabilidades sem introduzir uma arquitetura incompatível com Processing.

**Módulos relacionados:** `last_horizon/ship.pde`, `last_horizon/portals.pde`, `last_horizon/movement.pde`, `last_horizon/animation.pde`, `last_horizon/audio.pde`, `last_horizon/last_horizon.pde`.

**Critérios de aceite:**

1. A separação mantém as responsabilidades de cenário e nave, portais, movimento, animação e áudio identificáveis pelas abas.
2. A reorganização move código de forma mínima e rastreável, sem alterar expressões, ordem de atualização, inicialização ou chamadas de áudio.
3. O sketch continua compilando como uma unidade Processing com e sem os módulos opcionais previstos.
4. Variáveis globais, funções chamadas entre abas e dependências de inicialização continuam disponíveis no momento de uso.
5. A validação final confirma as mesmas campanhas, física, animação, áudio, escadas e travessias de porta.

#### US-07

Como responsável pelo runtime, quero que a transição entre salas seja preparada uma única vez, para manter o mesmo resultado nos caminhos animado, imediato e sem arte.

**Módulos relacionados:** `last_horizon/portals.pde`, `last_horizon/movement.pde`, `last_horizon/ship.pde`.

**Critérios de aceite:**

1. A sala de destino, posição de saída, posição de chegada, direção e porta de retorno são resolvidas antes de escolher a execução da transição.
2. A posição de saída é capturada antes da movimentação e o retorno reaproveita essa posição quando essa é a regra atual.
3. Portas com coordenadas arbitrárias, ida, volta, gravidade após chegada e travessia entre conveses mantêm o resultado atual.
4. A transição com arte completa mantém fases e som; a transição com arte ausente continua funcionando sem bloquear a partida.
5. O estado preparado é limpo depois da entrada ou do encerramento da transição, sem reaproveitar dados de uma porta anterior.

### Preservação do comportamento observável

#### US-08

Como mantenedor do jogo, quero revisar o código mantendo o contrato de quests e do ciclo diário, para preparar a entrega sem alterar decisões, custos ou desfechos percebidos pelo jogador.

**Módulos relacionados:** `last_horizon/tasks.pde`, `last_horizon/game.pde`, `docs/CURRENT_IMPLEMENTATION.md`, `mechanics/ACTIONS.md`, `events/`, `interface/ROOMS.md`.

**Critérios de aceite:**

1. As ofertas preventivas, incidentes, soluções, seleção, confirmação presencial, coleta, entrega, retomada e socorro continuam usando os mesmos estados e pontos físicos.
2. O técnico continua carregando no máximo um objeto por vez e uma conclusão continua consumindo o limite diário.
3. Custos, recompensas, perdas, prazos, negligência, riscos, crises, mortes, vitória e derrota permanecem iguais aos valores de referência.
4. Os quatro cômodos, quatro sobreviventes além do técnico, seis recursos e dez dias continuam presentes.
5. A validação cobre os caminhos de quest e não aceita a reorganização se uma alteração de código mudar apenas o resultado observável, mesmo que a tela continue compilando.
6. Em caso de conflito entre referências, a precedência do comportamento é código executável, `docs/CURRENT_IMPLEMENTATION.md` e, depois, documentação mecânica, de eventos e de interface. Divergências encontradas são registradas.

#### US-09

Como mantenedor do ciclo noturno, quero que previsão e aplicação usem a mesma transição, para evitar divergência entre o que o jogador confirma e o que o jogo aplica.

**Módulos relacionados:** `last_horizon/night_projection.pde`, `last_horizon/game.pde`, `last_horizon/tasks.pde`, `last_horizon/capture.pde`.

**Critérios de aceite:**

1. `projectNight()` usa `simulateNightTransition()` sem efeitos colaterais em estado global, aleatoriedade, modais ou memória editorial.
2. `processNight()` parte do mesmo contrato, aplica uma única projeção e não executa novamente as perdas ou consequências.
3. A previsão contém consumo, perdas de problemas, falhas de quest, riscos, prazos, crises, condições fatais e desfecho quando aplicável.
4. Uma comparação entre previsão e noite processada sobre estados equivalentes confirma os mesmos valores e resultado.
5. Snapshots, fixtures e restaurações não deixam estado residual que altere uma execução posterior.

#### US-10

Como responsável pela interface e pela validação, quero uma única decisão sobre o modal ativo, para que desenho, teclado, cursor e clique respeitem a mesma prioridade.

**Módulos relacionados:** `last_horizon/screens.pde`, `last_horizon/ui.pde`, `last_horizon/last_horizon.pde`, `last_horizon/tasks.pde`.

**Critérios de aceite:**

1. A prioridade vigente entre pausa, transmissão, incidente, ordens, mapa, diálogo, painel técnico, sono, ajuda e cena é preservada.
2. Fechar a transmissão revela o incidente; `ESC` no detalhe da solução retorna à comparação; `ESC` na comparação obrigatória preserva o incidente e pausa.
3. Fechar um painel não cancela uma ordem aceita, e os estados pendentes são limpos somente nos caminhos correspondentes.
4. Nenhum clique ou confirmação alcança um controle de camada encoberta.
5. O hit-test, o cursor, o mouse, `ENTER` e `ESC` seguem a mesma camada que foi desenhada.

### Harness e preparação da entrega

#### US-11

Como responsável pela verificação, quero manter o harness e o modo de teste desacoplados do runtime do jogo, para validar o desenvolvimento sem misturar hooks de teste ao fluxo normal.

**Módulos relacionados:** `last_horizon/capture.pde`, `last_horizon/test_mode.pde`, `last_horizon/last_horizon.pde`, `tools/regression-windows.mjs`.

**Critérios de aceite:**

1. O runtime continua compilando e executando com os hooks opcionais inertes quando `capture.pde` e `test_mode.pde` não estão presentes.
2. O harness continua disponível para `--capture`, `--hit-test`, `--ladder-test`, `--asset-pipeline-test` e `--metrics`.
3. O modo manual continua oferecendo Ctrl+K, teleporte e destaque visual quando incluído no ambiente de desenvolvimento.
4. O destaque visual forçado não autoriza pagamento, aceite, entrega ou conclusão indevida.
5. A matriz de combinações com módulos opcionais confirma compilação em todos os casos previstos.

**Contrato existente preservado:** quando o snapshot de entrega for gerado pelo script vigente, sua lista de exclusões continua removendo o harness, o modo manual, as ferramentas de verificação, o protótipo de balanceamento e artefatos transitórios. A cópia sem esses módulos não expõe Ctrl+K, teleporte, destaque forçado ou overlay de modo de teste, e o corte não remove funções legítimas necessárias à compilação do runtime. Esse contrato não é um novo critério de aceite desta feature.

#### US-12

Como responsável pela preparação da entrega, quero receber um registro único de equivalência, custo e limitações, para avaliar a prontidão do código com evidência verificável.

**Módulos relacionados:** `code/VERIFICATION.md`, `docs/CURRENT_IMPLEMENTATION.md`, `tools/compare-metrics.mjs`.

**Critérios de aceite:**

1. O registro identifica baseline, versão revisada, comandos executados, cenários, métricas, variação observada e estado de cada verificação.
2. Diferenças encontradas, limites da comparação e métricas ou cenários indisponíveis no ambiente ficam explícitos.
3. Uma limitação de ambiente não é apresentada como ganho de performance nem como prova de equivalência.
4. O registro confirma a combinação entre métricas e regressão funcional existente.
5. A entrega somente é considerada pronta quando as verificações disponíveis passam, as limitações restantes estão documentadas e existe redução mensurável e reproduzível de custo. Sem medição confiável ou sem redução, o requisito de otimização permanece inconcluso e a entrega não pode ser marcada como concluída.

## Requisitos funcionais

### Performance e métricas

#### RF-01

O processo deve coletar baseline e versão revisada com `--metrics`, mantendo os mesmos cenários e produzindo um manifesto sidecar por captura com `environment`, `machine`, `assets`, `room`, `state`, `nominal_window_s` e `processing`. O CSV permanece dedicado às métricas numéricas: duração real decorrido, quantidade de quadros, mediana, p95, tempo de carregamento, memória adicional, construções de ícones, construções de faixas e invalidações. Relaciona-se a US-01 e US-02.

#### RF-02

O cache dos seis ícones de recursos deve ser preparado no carregamento ou após mudança explícita da imagem-fonte e reutilizado pelo desenho normal. Relaciona-se a US-01. A preparação não deve ocorrer por ícone a cada quadro.

#### RF-03

As faixas de piso devem compartilhar a mesma imagem preparada quando tile, largura e geração da fonte forem iguais. Relaciona-se a US-01. A imagem compartilhada deve ser tratada como imutável e o fallback geométrico deve permanecer disponível.

#### RF-04

O sistema deve invalidar seletivamente caches cuja fonte, escala, largura ou geração tenha mudado e conservar caches ainda válidos. Relaciona-se a US-01 e US-02. O contador de invalidações deve permitir verificar esse comportamento em fixture.

#### RF-05

`tools/compare-metrics.mjs` deve comparar três amostras por referência, validar os manifestos sidecar e informar mediana, p95 e variação percentual para tempo de quadro. Carregamento, memória adicional, construções de cache e invalidações devem permanecer disponíveis por amostra ou em resumo simples no registro final. Campos obrigatórios ausentes ou divergentes no manifesto devem impedir a comparação. Relaciona-se a US-02 e US-12.

#### RF-06

O resultado de otimização deve ser marcado como concluído somente quando houver redução de custo mensurável e reproduzível. Relaciona-se a US-02. Ausência de redução ou medição não confiável deve resultar em status inconclusivo, com a causa registrada.

#### RF-07

Para cada métrica agregável com p95 e cada cenário sujeito à medição, a mediana dos três p95 da versão revisada não pode variar mais de 10% em relação à baseline. Variação superior a 10% deve continuar sendo reportada como falha pelo comparador existente. Relaciona-se a US-02 e US-12.

### Uso, duplicação e comentários

#### RF-08

Antes de remover código, a análise deve verificar referências estáticas, entrypoints do Processing, símbolos globais entre abas, modos do harness, modo manual, comandos de `package.json` e entradas documentadas. Relaciona-se a US-03.

#### RF-09

Código só pode ser removido quando não possuir referência estática, não for alcançado por entrypoints ou modos de verificação e continuar dispensável após a validação posterior. Relaciona-se a US-03.

#### RF-10

Duplicações de desenho, seleção de arte, preparação de transição, composição de rodapé, mapeamento de recursos e preparação de assets devem ser consolidadas apenas quando o helper preserva o contrato da chamada original. Relaciona-se a US-04.

#### RF-11

Os arquivos executáveis cobertos pela feature devem ficar sem comentários de código, mantendo shebangs e diretivas obrigatórias de execução. Uma auditoria obrigatória por extensão e caminho deve registrar a cobertura e as exceções preservadas. Relaciona-se a US-05. A limpeza abrange `.pde`, `.mjs` e `.sh` e não abrange comentários de documentação.

#### RF-12

Toda função, variável, nome de aba ou caminho alterado pela consolidação deve ter suas referências dependentes atualizadas no runtime, no harness, nos scripts e na documentação operacional aplicável. Relaciona-se a US-03, US-04 e US-06.

### Organização e contratos do sketch

#### RF-13

A reorganização deve manter o sketch Processing como uma unidade compilável, preservando variáveis globais, funções entre abas e a ordem necessária de inicialização. Relaciona-se a US-06.

#### RF-14

`preparePortalTransition()` deve resolver uma única vez sala destino, retorno, saída, chegada e direção antes da execução animada ou imediata. Relaciona-se a US-07.

#### RF-15

As transições de porta devem preservar som, fases de abertura e fechamento, retorno pela posição anterior, gravidade após chegada e funcionamento sem arte. Relaciona-se a US-07.

#### RF-16

Os resolvedores de arte de NPC devem preservar prioridade de orientação, fallback de sprite, suporte aos formatos de spritesheet existentes e independência entre sprite principal e halos. Relaciona-se a US-04 e US-07.

#### RF-17

O HUD deve manter mapeamento explícito entre energia, oxigênio, água, comida, peças e moral, sem deslocar índices de ícone, valor, rótulo, cor ou barra. Relaciona-se a US-01 e US-04.

### Preservação de gameplay e interface

#### RF-18

O catálogo e o estado de quests devem preservar seleção, aceite, coleta, entrega, retomada, socorro, custos, recompensas, perdas e limite de uma conclusão por dia. Relaciona-se a US-08.

#### RF-19

O ciclo diário deve preservar quatro cômodos, quatro sobreviventes além do técnico, seis recursos, dez dias, incidentes e consequências noturnas conforme o código executável, `docs/CURRENT_IMPLEMENTATION.md` e, quando compatível, as tabelas e documentos vigentes. Relaciona-se a US-08.

#### RF-20

`simulateNightTransition()` deve operar sobre `NightSnapshot` sem aleatoriedade, abertura de modal ou alteração da memória editorial. Relaciona-se a US-09.

#### RF-21

`projectNight()` deve exibir a saída de `simulateNightTransition()` e `processNight()` deve aplicar uma única `NightProjection`, sem repetir efeitos. Relaciona-se a US-09.

#### RF-22

A resolução da camada ativa deve continuar sendo compartilhada entre desenho de modal, roteamento de teclado, cursor e hit-test. Relaciona-se a US-10.

#### RF-23

As regras de fechamento de transmissão, incidente, comparação de solução, ordens, mapa, diálogo, painel técnico, sono, ajuda e pausa devem manter a prioridade e a limpeza de estado existentes. Relaciona-se a US-10.

#### RF-24

Assets ausentes ou parciais devem manter fallback funcional para sprites, portas, estações, piso e imagens carregadas pelo pipeline. Relaciona-se a US-04, US-07 e US-08.

### Harness, validação e entrega

#### RF-25

Os cenários `--capture`, `--hit-test`, `--ladder-test` e `--asset-pipeline-test` devem permanecer disponíveis e cobrir ciclo, quests, noite, riscos, menus, hit-test, escadas e carregamento de PNG. Relaciona-se a US-03, US-08 e US-12.

#### RF-26

O modo `--metrics` deve continuar gravando as medições necessárias para a comparação e não deve ser tratado como evidência funcional quando executado sem condições comparáveis. Relaciona-se a US-02 e US-12.

#### RF-27

O harness deve conservar fixtures de portas, escadas, assets, quests, noite, modais e restauração de tabelas, sem remover cenários para fazer a regressão passar. Relaciona-se a US-03, US-09 e US-11.

#### RF-28

O runtime deve compilar sem `last_horizon/capture.pde` e sem `last_horizon/test_mode.pde`, e os hooks inertes devem manter o jogo executável quando os módulos opcionais não forem instalados. Relaciona-se a US-11.

#### RF-29

O registro final deve combinar resultado do typecheck Node.js, regressão Processing, simulação independente de balanceamento, comparação de métricas e limitações do ambiente. Relaciona-se a US-12.

## Requisitos não funcionais

### Performance

#### RNF-01

A feature deve reduzir de forma mensurável e reproduzível pelo menos um custo alvo entre preparação inicial, render por quadro, carregamento de assets ou construção de cache para ser considerada otimização concluída. Organização e legibilidade isoladas não satisfazem esse critério.

#### RNF-02

As medições comparáveis devem usar três amostras por referência, cada uma com janela nominal de trinta segundos no manifesto sidecar e duração real decorrida no CSV. Tempo de quadro possui mediana e p95; carregamento, memória adicional, construções e invalidações permanecem por amostra ou em resumo simples. Os resultados devem manter o mesmo ambiente nos campos validados por `compare-metrics.mjs`.

#### RNF-03

O custo de memória adicional introduzido por caches deve ser registrado por amostra. O cache não deve incluir números, barras, cores de estado ou piscadas dinâmicas do HUD.

#### RNF-04

O cenário `--metrics` não pode apresentar, para uma métrica agregável com p95, variação superior a 10% na mediana dos três p95 da versão revisada em relação à baseline, conforme o comparador existente. Os cenários `--capture`, `--hit-test`, `--ladder-test` e `--asset-pipeline-test` devem passar pela regressão funcional existente. Falhas ou medições indisponíveis devem ser reportadas sem conversão automática em aprovação.

### Usabilidade e comportamento observável

#### RNF-05

Os controles existentes de teclado, mouse, `E`, `ENTER`, `ESC`, pausa, mapa e camadas modais devem manter o comportamento validado no sketch atual. Nenhum clique deve atravessar um modal ativo.

#### RNF-06

O render deve preservar o buffer lógico 640x360, saída 1280x720, ampliação inteira, letterbox proporcional, fonte Segoe UI e pixel art sem interpolação, salvo diferença registrada como limitação ou regressão.

#### RNF-07

Textos, números, cores, tamanhos, posições, sprites, halos, transições, sons, fallback visual e alertas críticos preservados pela revisão devem permanecer verificáveis por captura ou fixture correspondente.

### Confiabilidade e manutenção

#### RNF-08

As validações existentes devem continuar reproduzíveis: `npm.cmd run typecheck`, `npm.cmd run regression:windows` no ambiente Windows disponível, `tools/regression-final.sh` no ambiente Linux compatível e `node prototype/balance-model.mjs --simulate` quando o ambiente permitir.

#### RNF-09

O sketch deve continuar compilando como unidade Processing depois de cada consolidação estrutural relevante, sem depender de ordem alfabética nova entre abas ou de arquivos de teste para inicializar o jogo.

#### RNF-10

O harness deve preservar todos os cenários que sustentam a prova de equivalência, inclusive campanhas, quests, noites, riscos, menus, hit-test, escadas, portas, assets, modais e restauração de fixtures.

#### RNF-11

Toda limitação de ambiente, diferença entre baseline e versão revisada, cenário não executado e métrica sem amostra deve ser registrada com o motivo e o impacto na conclusão. Uma validação não executada não conta como evidência.

#### RNF-12

A organização resultante deve continuar seguindo os padrões atuais de funções, constantes, tabelas globais, classes de dados pontuais e abas procedurais, sem introduzir hierarquia de entidades ou framework adicional.

## Matriz de rastreabilidade

| User stories | Requisitos funcionais principais | RNFs principais |
| --- | --- | --- |
| US-01, US-02 | RF-01 a RF-07, RF-17, RF-26 | RNF-01 a RNF-04 |
| US-03, US-04, US-05 | RF-08 a RF-12, RF-16, RF-24, RF-27 | RNF-07, RNF-09, RNF-10 |
| US-06, US-07 | RF-13 a RF-16 | RNF-06, RNF-09, RNF-12 |
| US-08, US-09 | RF-18 a RF-21, RF-24, RF-27 | RNF-05, RNF-07, RNF-10 |
| US-10 | RF-22 e RF-23 | RNF-05 a RNF-07 |
| US-11 | RF-25, RF-27 e RF-28 | RNF-09, RNF-10 |
| US-12 | RF-05 a RF-07, RF-25, RF-26, RF-29 | RNF-02, RNF-04, RNF-08, RNF-11 |

## Evidências esperadas para a conclusão

1. Typecheck dos módulos Node.js sem erro.
2. Regressão Processing aprovada nos quatro cenários existentes, quando o Processing 4.5.6 estiver disponível no ambiente.
3. Simulação independente do modelo de balanceamento aprovada, quando o ambiente permitir.
4. Comparação de baseline e versão revisada com ambiente equivalente, variação documentada e status explícito para otimização.
5. Verificação de que previsão e aplicação noturnas permanecem equivalentes e sem estado residual.
6. Verificação de compilação do runtime nas combinações previstas com e sem os módulos opcionais.
7. Registro de limitações, cenários não executados e qualquer diferença observada.
8. Auditoria por extensão e caminho confirmando a remoção de comentários em `.pde`, `.mjs` e `.sh`, com shebangs e diretivas obrigatórias preservados.
