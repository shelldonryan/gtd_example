# Sugestoes de enriquecimento da SPEC

Projeto: last-horizon-enxugamento-imersao
SPEC: SPEC20260919_145427.md
Fonte de comparacao: PRD20260919_145427.md e stories-requisitos20260919_145427.md

## Objetivo da viagem e entrada inicial

- **E1** [APLICADO] [OBJETIVO DA VIAGEM] A SPEC define os fatos obrigatorios da vinheta, mas nao fixa a copia aprovada, a quantidade de paginas, as quebras de linha nem como a regra de caixa de frase se aplica ao texto inicial atualmente exibido em maiusculas.
  Opcoes: a) manter tres paginas e reescrever a copia em caixa de frase; b) condensar os quatro fatos em uma unica pagina; c) manter a vinheta atual em maiusculas como excecao explicita.
  Sugestao: opcao a - preserva o fluxo e os controles existentes, resolvendo a tensao com a regra de legibilidade.

- **E2** [APLICADO] [ENTRADA INICIAL] O campo de nome do tecnico existe no baseline e tem limite de 12 caracteres, mas a SPEC nao define tamanho maximo, caracteres aceitos, tratamento de espacos, entrada vazia nem a mensagem de bloqueio do botao iniciar.
  Opcoes: a) aceitar ate 12 caracteres Unicode, remover espacos nas pontas e exigir pelo menos um caractere; b) aceitar somente letras, espaco e acentos; c) remover o campo de nome da entrega.
  Sugestao: opcao a - mantem o comportamento atual e cobre nomes em portugues sem criar persistencia.

## Catalogo de quests, textos e compromisso

- **E3** [APLICADO] [CATALOGO EDITORIAL] A SPEC exige `short_motivation`, `base_line` e `factual_fallback` para cada um dos 22 IDs, mas nao define se a motivacao existente pode cumprir o papel de fala-base, quando o fallback e usado nem os limites de titulo e motivacao exibidos nos cartoes.
  Opcoes: a) reutilizar a motivacao como fala-base e manter fallback factual separado apenas para ausencia; b) manter tres textos distintos por ID; c) usar uma unica frase editorial e gerar os demais campos dela.
  Sugestao: opcao a - evita duplicacao de texto e reduz risco de divergencia entre cartao, fala e fallback.

- **E4** [APLICADO] [CATALOGO MECANICO] Os campos `result`, `incomplete_loss`, `neglect_loss` e `consequence` sao citados como tipos logicos, mas a SPEC nao define sua forma nem se a implementacao deve duplicar esses dados no catalogo ou continuar derivando-os dos arrays e funcoes mecanicas existentes.
  Opcoes: a) manter consequencias como consulta por ID aos dados mecanicos vigentes; b) criar campos estruturados paralelos para cada delta, limpeza, crise e estado; c) copiar as consequencias para o catalogo editorial.
  Sugestao: opcao a - conserva uma unica fonte numerica e evita alterar balanceamento por duplicacao.

- **E5** [REJEITADO] [NPC RESPONSAVEL MORTO] A SPEC cobre NPC morto como interlocutor invalido, mas nao define o que ocorre se o responsavel morrer depois da selecao e antes do aceite, ou depois de uma quest ja aceita.
  Opcoes: a) limpar selecao nao aceita e recalcular ofertas vivas; manter quest aceita se sua rota fisica continuar valida; b) falhar automaticamente a quest na proxima transicao; c) bloquear a quest e exibir indisponibilidade ate o fim do dia.
  Sugestao: opcao a - preserva a irreversibilidade somente depois do aceite e evita inventar uma penalidade nova.

- **E6** [APLICADO] [BLOQUEIOS DE ACAO] `pendingQuestReason` e descrita como razao estruturada, mas nao ha enum de motivos, campos obrigatorios nem copy definida para recurso insuficiente, ponto ou distancia incorretos, estado obsoleto, limite diario, confirmacao pendente e ausencia de risco.
  Opcoes: a) enum de motivo com valores atual, necessario, alvo, NPC e etapa, traduzido pela UI; b) string pronta retornada pelo dominio; c) booleano e uma mensagem generica.
  Sugestao: opcao a - permite revalidacao atomica, mensagens consistentes e cobertura dos casos de `ENTER` ou clique depois de uma mudanca de estado.

## Socorro e retomada

- **E7** [APLICADO] [PAINEL DE SOCORRO BLOQUEADO] A SPEC diz que o painel deve continuar consultavel quando o socorro estiver bloqueado, mas nao define como o jogador abre esse painel quando o ponto esta indisponivel por conclusao diaria, incidente ou selecao pendente.
  Opcoes: a) abrir sempre que houver risco e desabilitar somente a acao; b) manter o ponto fechado e informar apenas pelo HUD; c) permitir abertura apenas pelo Mapa.
  Sugestao: opcao a - corresponde ao criterio do PRD e preserva pessoa, prazo, custo e motivo do bloqueio.

- **E8** [APLICADO] [RETOMADA] A SPEC nao define o tratamento de uma retomada aberta quando o problema for resolvido, o dia mudar ou um incidente novo passar a ter prioridade antes da confirmacao.
  Opcoes: a) revalidar no confirmar, nao mutar e exibir a razao atual; b) fechar o painel e limpar a selecao visual; c) confirmar usando o snapshot antigo do painel.
  Sugestao: opcao a - impede custo, objeto ou prazo aplicados a uma quest que deixou de estar disponivel.

## Previsao noturna e desfechos

- **E9** [APLICADO] [SNAPSHOT NOTURNO] A SPEC descreve o snapshot por dominios, mas nao enumera todos os campos que precisam ser copiados nem define como o resultado puro entrega os efeitos editoriais, transmissao, crises e desfecho sem mutar a partida.
  Opcoes: a) listar campos completos de entrada e retornar estado projetado, efeitos editoriais e desfecho; b) clonar todas as globais do sketch; c) retornar apenas os seis recursos e recalcular os demais na confirmacao.
  Sugestao: opcao a - torna comparavel a previsao e a noite real sem depender de efeitos colaterais ocultos.

- **E10** [APLICADO] [AVANCO DE DIA] A SPEC nao esclarece se `projectNight` deve projetar tambem o incremento de `day`, a abertura do proximo incidente, as ofertas preventivas, transmissao e flags de inicio do novo dia, nem como `game_outcome` representa a vitoria apos a noite do dia 10.
  Opcoes: a) a funcao pura retorna o estado completo do proximo ponto de ciclo e `processNight` apenas o confirma; b) a projecao termina no fim dos efeitos noturnos e o preparo do dia seguinte ocorre fora dela; c) a previsao mostra somente recursos e alertas, sem proximo estado.
  Sugestao: opcao a - alinha a equivalencia de preview e noite real e explicita a fronteira de mutacao.

- **E11** [APLICADO] [PAINEL DE SONO] A SPEC nao define como exibir todos os problemas, riscos e alertas quando o conteudo exceder a area do painel em 720p, especialmente com ate sete problemas ativos.
  Opcoes: a) mostrar resumo fatal e lista paginada ou expansivel; b) usar rolagem dentro do painel; c) reduzir fonte e altura ate caber tudo.
  Sugestao: opcao a - preserva corpo de 16 px e mantem a informacao decisiva visivel.

- **E12** [APLICADO] [FATALIDADE] Quando mais de uma condicao fatal ocorrer na mesma noite, a SPEC nao define se o resumo mostra todas as condicoes ou apenas a primeira da prioridade de `checkEndConditions`.
  Opcoes: a) listar todas as condicoes previstas e usar a prioridade apenas no titulo; b) mostrar somente a primeira condicao; c) mostrar apenas o aviso fatal mais urgente.
  Sugestao: opcao a - evita esconder informacao que explica o resultado e preserva a prioridade existente para o desfecho.

## Vozes e memoria editorial

- **E13** [APLICADO] [MEMORIA DE RISCO] A memoria inclui `risk`, mas a prioridade documentada cobre apenas socorro, ajuda, falha e omissao; tambem nao esta definido se o risco e registrado ao ser criado, ao atingir prazo zero ou nos dois momentos.
  Opcoes: a) manter risco ativo separado, registrar reconhecimento na ativacao e registrar morte como resultado distinto; b) registrar risco somente quando a pessoa morrer; c) deixar risco sobrescrever qualquer resultado do mesmo dia.
  Sugestao: opcao a - separa estado de perigo de desfecho e evita apagar uma ajuda ou socorro valido.

- **E14** [APLICADO] [PUREZA DAS CONSULTAS EDITORIAIS] A SPEC diz que `editorialContextLine` e `editorialPhaseLine` sao puras e que somente `beginNpcConversation` incrementa contagem e marca apresentacao, enquanto o baseline ainda faz essas mutacoes dentro das consultas.
  Opcoes: a) mover toda mutacao para `beginNpcConversation`; b) permitir mutacao no seletor, desde que a abertura seja idempotente; c) separar consulta em pre-visualizacao e confirmacao com token.
  Sugestao: opcao a - torna o contrato puro verificavel e impede redesenho ou reabertura de alterar memoria.

## HUD, copy e legibilidade

- **E15** [APLICADO] [PRIORIDADE DO ALERTA] A ordem geral esta listada, mas nao define como a mensagem de sistema recente compete com fatalidade, risco, problema de menor prazo e reconhecimento de resultado, nem por quanto tempo um feedback de sucesso permanece na segunda linha.
  Opcoes: a) fatalidade > risco > problema de menor prazo > feedback recente > demais alertas, com duracao fixa; b) feedback recente sempre ocupa a linha; c) separar feedback em um terceiro elemento temporario.
  Sugestao: opcao a - preserva a prioridade de seguranca e torna a exibicao deterministica.

- **E16** [APLICADO] [FAIXA DE DUAS LINHAS] A SPEC exige duas linhas, mas nao define se cada linha deve ser de uma linha fisica, se pode quebrar, qual e o limite de caracteres e como a informacao do HUD antigo de quatro linhas migra para Ordens ou Mapa.
  Opcoes: a) duas linhas fisicas com truncamento controlado e detalhes completos nos paineis; b) permitir quebra limitada dentro da faixa; c) manter quatro linhas no HUD.
  Sugestao: opcao a - protege a area de jogo e evita que texto longo mova o rodape.

- **E17** [APLICADO] [TOKENS VISUAIS] A SPEC manda reutilizar `COL_*`, mas nao mapeia explicitamente selecionado, positivo, negativo, bloqueado, fatal, informativo e texto secundario aos tokens existentes.
  Opcoes: a) registrar um mapa semantico usando os tokens atuais; b) manter a escolha em cada chamada de desenho; c) criar novos tokens de estado.
  Sugestao: opcao a - centraliza contraste e evita significados divergentes entre cards, HUD e modais.

- **E18** [APLICADO] [TIPOGRAFIA DE BOTOES] A SPEC preserva corpo de 16 px e nao reduzir texto para caber, enquanto a documentacao vigente permite que botoes reduzam ate 10 px; falta declarar a excecao ou elimina-la.
  Opcoes: a) permitir reducao ate 10 px somente em botoes, com largura minima e sem truncar atalho; b) manter minimo de 16 px e paginar ou reflowar o rótulo; c) aumentar botoes e alterar o layout.
  Sugestao: opcao a - preserva a regra existente sem reduzir texto narrativo.

## Mapa, viewport e navegacao consultiva

- **E19** [APLICADO] [MAPA SEM PASSAGEM] A SPEC cita alvo ausente, rota ausente e `porta livre`, mas nao define o significado de `porta livre`, nem a mensagem para alvo na mesma sala sem escada alcancavel, ponto com altura arbitraria ou porta sem convés.
  Opcoes: a) mostrar motivo explicito, `Local indisponivel`, abertura fora do convés ou altura real; b) aproximar o alvo do convés mais proximo; c) ocultar o alvo ate existir rota completa.
  Sugestao: opcao a - respeita a geometria real e evita inventar uma passagem.

- **E20** [APLICADO] [CONSULTAS OPCIONAIS DO MAPA] Quando nao existe rota automatica, a SPEC diz que o Mapa permite consultar beliche ou socorro, mas nao define controles, labels, estado selecionado nem como deixar claro que a consulta nao virou alvo de navegacao.
  Opcoes: a) oferecer botoes de consulta com rotulo `Consulta` e manter alvo automatico vazio; b) mostrar apenas marcadores clicaveis; c) nao oferecer pontos opcionais no Mapa.
  Sugestao: opcao a - torna a consulta descoberta sem alterar a rota ativa.

- **E21** [APLICADO] [VIEWPORT DESKTOP] A SPEC define render canonico e janela ampliada, mas nao define comportamento abaixo de 1280x720, em proporcao diferente de 16:9, em redimensionamento durante modal ou em fullscreen.
  Opcoes: a) declarar 1280x720 como minimo e preservar escala inteira com corte ou letterbox; b) permitir escala fracionaria para manter toda a cena; c) impedir redimensionamento da janela.
  Sugestao: opcao a - preserva pixel art, tipografia e contratos visuais do baseline.

## Cache, entrega e evidencias

- **E22** [APLICADO] [INVALIDACAO DE CACHE] A SPEC exige recarga explicita e invalidacao seletiva quando o conteudo muda com o mesmo caminho, mas nao define a operacao publica, a identidade da fonte nem os contadores esperados para icon cache e faixas de piso.
  Opcoes: a) usar geracao ou identidade da imagem por fonte e invalidar somente a chave afetada; b) limpar todos os caches em qualquer recarga; c) comparar somente o caminho do arquivo.
  Sugestao: opcao a - atende a invalidacao seletiva e evita trabalho desnecessario.

- **E23** [APLICADO] [CORTE DE ENTREGA] A SPEC e o PRD exigem retirar `capture.pde` e `test_mode.pde` do snapshot, mas o script atual lista apenas `capture.pde` entre os modulos opcionais excluidos.
  Opcoes: a) excluir os dois arquivos no fluxo do snapshot e validar compilacao; b) manter `test_mode.pde` com todas as funcoes inertes; c) separar o modo de teste em uma copia externa ao sketch.
  Sugestao: opcao a - alinha o artefato gerado ao requisito declarado e elimina debug do runtime final.

- **E24** [APLICADO] [ARTEFATOS DE EVIDENCIA] E0 a E6 exigem baseline, capturas, medicoes, playtest e documentacao sincronizada, mas nao definem diretorios, nomes de arquivos, formato ou politica de versionamento desses artefatos.
  Opcoes: a) guardar tudo em uma arvore versionada de documentacao e evidencias com nomes por etapa; b) guardar apenas no diretorio de execucao da sessao; c) registrar somente um relatorio final consolidado.
  Sugestao: opcao a - permite auditar cada etapa e comparar baseline com a entrega.

- **E25** [APLICADO] [COMPARACAO VISUAL] A SPEC exige comparacao de pixels e registro de mudancas intencionais, mas nao define limiar de aprovacao, regioes permitidas nem como tratar antialiasing e fontes entre maquinas.
  Opcoes: a) comparar exatamente fora de regioes explicitamente permitidas; b) usar diferenca perceptual com limiar documentado; c) aprovar por inspeccao manual sem limiar.
  Sugestao: opcao a - separa mudancas planejadas da regressao visual e mantem o criterio reproduzivel.

## Correcoes transversais

- **T1** [APLICADO] [SEPARACAO DE EVIDENCIA E DECISAO] Separar fatos observados no baseline, funcionalidades propostas e decisoes aprovadas na leitura da SPEC.
- **T2** [APLICADO] [PROPORCIONALIDADE DE VALIDACAO] Manter criterios e testes proporcionais, usando harness para contratos determinísticos, modelo numerico independente para regras, comparacao visual conforme o ambiente e playtest para compreensao.
