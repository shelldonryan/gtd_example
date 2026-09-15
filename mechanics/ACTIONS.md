# Ações e custos

Este arquivo registra o contrato mecânico vigente. Os estoques e custos ainda
presentes são a linha de base do protótipo; perdas, prazos, crises e bônus serão
recalculados no próximo ticket de balanceamento antes de voltar ao código.

## Regras base

| Regra | Valor |
| --- | --- |
| Recursos em barra | energia, oxigênio, água, comida, moral — de 0 a 100 |
| Peças | contagem inteira |
| Sobreviventes | 4 a bordo; o técnico não entra na conta |
| Duração | 10 dias |
| Estoques iniciais | 100 em energia, oxigênio, água e moral; 70 de comida; 6 peças |
| Intervenções principais por dia | 1 correção, recuperação ou aceleração |
| Incidentes | em dias alternados; problema ativo não é sorteado novamente |

Decisões fixadas neste arquivo:

- **Energia é um estoque único**, consumido para manter o motor e o suporte de
  vida. Não existe combustível separado: a barra de energia é esse estoque.
- **Modo economia e racionamento são políticas persistentes locais.** Podem ser
  ligados ou desligados em Máquinas e no Depósito sem gastar a intervenção
  principal. Reduzem consumo e cobram moral ao ativar e em cada dia mantidos.
- **Encerrar o dia** continua exigindo dormir no beliche do técnico no
  Dormitório, conferir o resumo do consumo e confirmar. Não existe botão
  `Passar dia`.

## Consumo ao encerrar o dia

| Recurso | Consumo | Observação |
| --- | --- | --- |
| Energia | 6 | motor e suporte de vida; 3 com modo economia |
| Oxigênio | 5 | 10 se a energia estiver abaixo de 30 |
| Água | 8 | 4 com racionamento |
| Comida | 7 | 3 com racionamento |
| Moral | 2 | mais 1 por recurso em vermelho (de 1 a 29) |

O primeiro dia começa no Comando e os seguintes, no Dormitório. Incidentes
surgem em dias alternados. A resposta escolhe quanto risco aceitar naquele
momento, mas não resolve a causa: o problema nasce ativo no cômodo afetado.

O técnico pode explorar, diagnosticar, coletar componentes especiais — itens
únicos exigidos por correções específicas — e ajustar políticas sem gastar a
intervenção principal. Uma correção, recuperação ou aceleração pode ser
concluída por dia. Dormir processa consumo, perdas diárias,
prazos, crises, vitória ou derrota. Dormir sem intervir é permitido, mas todos
os problemas ativos continuam cobrando perdas e avançando para suas crises.

## Intervenções e problemas ativos

Não existe aceite diário de tarefa nem briefing obrigatório. O evento já cria
um problema ativo; HUD e mapa indicam onde agir, e os pontos relacionados passam
a responder imediatamente.

Cada problema mostra três informações antes do encerramento do dia:

1. perda aplicada por dia;
2. prazo restante;
3. consequência específica quando o prazo chega a zero.

O cartão do incidente segue o padrão **risco agora, correção depois**: suas duas
contenções trocam custo imediato por segurança, mas nenhuma encerra o problema.
A causa só desaparece com uma intervenção física no cômodo correspondente.

| Tipo de intervenção principal | Função |
| --- | --- |
| Correção | remove um problema persistente e seu prazo |
| Recuperação | restaura uma margem crítica ou estabiliza um sobrevivente |
| Aceleração | reduz a exposição aos próximos dias da viagem |

`Aumentar potência` elimina um dia futuro completo: consumo e eventual incidente
daquele dia deixam de ocorrer. No Dormitório, dormir apenas encerra o turno;
`Cuidar do grupo` recupera moral e `Socorrer [nome]` estabiliza uma pessoa em
risco. As duas últimas são intervenções principais distintas.

As sequências variam conforme o problema. Um passo só existe para descobrir
informação, obter algo realmente necessário ou aplicar a correção. NPC e troca
de cômodo não são requisitos universais. Recursos já contabilizados no HUD são
pagos diretamente no ponto final; somente componentes especiais precisam ser
buscados e carregados fisicamente.

Problemas e responsabilidades permanecem distribuídos assim:

| Origem | Local de correção |
| --- | --- |
| Motor, energia e suporte de vida | Sala de máquinas |
| Comunicações e rota | Sala de comando |
| Falta de comida, estoque e componentes | Depósito |
| Conflito, saúde e moral | Dormitório |
| Dano no casco por meteoros | local aleatório alcançável em qualquer um dos quatro cômodos |

Os valores de perda, prazos, crises, custos das intervenções e benefícios dos
sobreviventes serão definidos e simulados no ticket de balanceamento.

### Políticas de contenção

| Sala | Política | Efeito atual a revalidar |
| --- | --- | --- |
| Máquinas | Modo economia | reduz consumo de energia; cobra moral ao ativar e por dia |
| Depósito | Racionamento | reduz consumo de comida e água; cobra moral ao ativar e por dia |

## Agravamento

Todo problema cobra sua perda ao encerrar o dia e reduz o prazo visível. Quando
o prazo chega a zero, aplica uma crise coerente com seu domínio, não uma derrota
universal. O motor pode ser destruído; crises de estoque, conflito, casco ou
comunicações produzem perdas próprias e podem continuar ativas.

Uma crise pode colocar um sobrevivente nomeado em risco. Essa pessoa recebe um
prazo visível; `Socorrer [nome]` a estabiliza, enquanto deixar o prazo chegar a
zero causa sua morte. A perda reduz `A BORDO` e remove o benefício da
especialidade daquela pessoa, mas nunca bloqueia uma intervenção necessária:
a mesma ação continua possível com custo ou risco maior.

## Sobreviventes e fim de jogo

| Situação | Efeito |
| --- | --- |
| Sobrevivente em risco chega ao prazo zero | a pessoa morre e `A BORDO` diminui |
| Sem sobreviventes vivos | derrota imediata — quinta causa, com mensagem própria |
| Oxigênio em zero | derrota imediata |
| Energia em zero | derrota imediata |
| Moral em zero | derrota imediata |
| Motor destruído | derrota imediata |
| Dia final com motor operante e 1 ou mais sobreviventes vivos | vitória |

## Pendências de balanceamento

- Fixar calendário exato dos dias de incidente.
- Definir perdas diárias, prazos e crises dos sete problemas.
- Definir custos e efeitos das contenções e intervenções.
- Definir o benefício de Vera, Bento, Neusa e Sílvia e a penalidade de perdê-los.
- Simular os caminhos de correção, recuperação, aceleração e omissão.
