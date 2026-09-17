# Last Horizon

## Visao geral

Last Horizon é um jogo 2D de gerenciamento de recursos e exploração em plataformas.

O jogador assume o papel de um técnico responsével por uma espaconave que transporta os últimos sobreviventes da Terra para uma base em Marte.

A Terra está passando por uma crise ambiental e populacional, com os recursos
do planeta se esgotando, a viagem até Marte é necessária para a sobrevivência da humanidade. 

Durante o percurso, o jogador precisa manter a nave funcionando, administrar os estoques e tomar decisões diante de problemas.

## Genero e perspectiva

- Gerenciamento de recursos
- Sobrevivência
- Exploração 2D em plataforma
- Visão macro da espaçonave como mapa
- Cômodos laterais exploráveis
- Interface com indicadores de recursos

## Resolução e tipografia

O render do projeto é **1280×720 (720p)**, com janela redimensionável e
ampliação inteira. A grade lógica 640×360 serve apenas para posicionamento; não é
uma resolução alternativa do jogo.

O texto visível usa **Segoe UI** instalada no Windows, com suavização. Assets
pixel art devem ser desenhados sem interpolação. Essa separação não altera a
resolução do render nem cria uma fonte alternativa.

## Personagem e assets

O técnico usa uma spritesheet única em `last_horizon/data/player/player_sheet.png`
com o metadado correspondente em `player_sheet.json`. A exportação tem dez
quadros de 64×64: `idle` usa os quadros 0–1 e `walk` usa os quadros 2–9.

O sketch preserva as durações do JSON, repete as duas animações em loop e
espelha o quadro conforme a direção do movimento. A aparência é desenhada em
32×32 na grade lógica, enquanto a caixa de colisão continua em 16×24.

O padrão de animação vale para todo asset animado do projeto: uma spritesheet
única em PNG com JSON de metadados. Não há exportação de PNG separado por
quadro; o `.aseprite` de origem acompanha a spritesheet quando disponível.
A lista final de imagens a produzir — canvas, tela onde aparece, estática ou
animada e ordem de produção — está em `assets/INVENTORY.md`.

## Executar o jogo

As quests das issues #25, #26 e #27 estão implementadas em `last_horizon/*.pde`;
`prototype/balance-model.mjs` é a referência numérica separada, não o jogo.
Abra `last_horizon/last_horizon.pde` no Processing 4.5.6 e execute.
O botão `ORDENS` compara as ofertas e reabre os detalhes da quest. Em dias
tranquilos ele não abre sozinho: o selo `!` pulsa quando há oferta ou retomada.
O botão `?` do rodapé abre a ajuda com teclas e botões.
Estações fora da etapa atual ficam apagadas e não respondem a `E`; os
sobreviventes respondem sempre, com fala e painel conforme o estado do dia.
Confirme a preventiva com seu responsável, colete e entregue usando `E` e
`ENTER`, e durma no seu beliche. A migração não depende da conclusão do
inventário #8. Comandos CLI e captura: `code/SKETCH_ARCHITECTURE.md`.

## Mecanica principal

A partida representa uma viagem de dez dias por quatro cômodos. A Sala de
comando é o hub central e a topologia padrão possui uma porta por convés para
Dormitório, Depósito e Sala de máquinas; as salas periféricas não se conectam
entre si.

As portas são portais configuráveis por dados. `door_x` e `door_y` posicionam
cada abertura em qualquer ponto horizontal ou vertical da sala; `door_deck = -1`
representa uma abertura sem deck ou acima do piso. O acionamento usa proximidade
horizontal e vertical ao limiar. A transição declara `door_arrival_x`,
`door_arrival_y` e `door_arrival_facing` para a chegada padrão em qualquer canto
ou convés válido da tela de destino. No retorno imediato para a sala anterior,
o jogo reaproveita a posição `x/y` em que o jogador saiu; outros percursos usam
a chegada padrão configurada.

Incidentes surgem nos dias 2, 4, 6, 8 e 10. Existem sete tipos, cinco escolhidos
por partida sem reposição, organizados em falhas técnicas, suprimentos e
tripulação. Cada incidente oferece duas soluções em formato de quest: o jogador
escolhe uma, coleta o objeto necessário e o entrega no destino físico.

Nos dias sem incidente, duas ordens preventivas são oferecidas pelos
sobreviventes. O jogador escolhe uma e deve concluí-la para evitar a perda maior
por negligência. A ordem concluída aumenta um recurso específico; aceitar e não
concluir perde uma pequena quantidade desse mesmo recurso. Não aceitar nenhuma
ordem perde pequenas quantidades dos dois recursos oferecidos.

Uma ordem de incidente não concluída deixa o problema ativo, com perda diária,
prazo e crise. A coleta e a entrega formam as duas etapas leves da quest, e uma
única quest pode ser concluída por dia. Componentes especiais existem como
objetos de quest e o técnico carrega um por vez.

O objetivo é chegar a Marte com o motor operante e pelo menos um sobrevivente
vivo. O jogador administra:

- **Energia:** mantém o motor e os sistemas da nave funcionando.
- **Oxigênio:** garante a sobrevivência das pessoas a bordo.
- **Água:** consumida pelos sobreviventes.
- **Comida:** consumida diariamente pelos sobreviventes.
- **Peças:** utilizadas em reparos e ordens técnicas.
- **Moral:** representa o estado emocional dos sobreviventes.

## Comodos da nave

É o hub físico e o centro de navegação e comunicações. A porta superior leva ao
Dormitório, a média ao Depósito e a inferior à Sala de máquinas. Vera oferece
ordens ligadas à rota e às comunicações; o console pode ser origem ou destino de
objetos, e a antena recebe entregas. Não existe uma lista extensa de tarefas.

### Sala de máquinas

Concentra motor, energia e suporte de vida. Sílvia oferece e confirma ordens
técnicas; bancada, distribuição, reator e suporte recebem entregas ou fornecem
leituras curtas. Não há modo economia nem bônus de especialista.

### Depósito

Concentra estoques e objetos de quest. Bento oferece e confirma ordens
logísticas; o técnico coleta cada objeto na origem indicada pela ordem e o leva
ao destino. Não há racionamento nem coleta livre fora de uma ordem.

### Dormitório

Concentra descanso, saúde e moral. Neusa oferece e confirma ordens da tripulação.
Uma pessoa em risco pode gerar uma quest simples de socorro. Dormir encerra o
turno e processa as consequências.

## Eventos

O pool mantém sete incidentes: falha no motor, chuva de meteoros, falta de
comida, conflito no dormitório, falha no suporte de vida, falha no sistema de
energia e falha nas comunicações. Eles pertencem às famílias de falhas técnicas,
suprimentos e tripulação.

Cinco incidentes aparecem, sem reposição, nos dias 2, 4, 6, 8 e 10. Cada cartão
oferece duas soluções físicas em formato de quest. O jogador escolhe uma,
coleta o objeto indicado e o entrega no destino.

Nos dias sem incidente, duas ordens preventivas são oferecidas pelos
sobreviventes. Uma deve ser aceita e concluída para evitar o prejuízo maior por
negligência. A ordem concluída aumenta um recurso específico; a ordem aceita e
não concluída perde uma pequena quantidade desse mesmo recurso.

O dano no casco por meteoros continua sendo associado a um local aleatório,
alcançável pelo jogador em qualquer um dos quatro cômodos. Problemas não
resolvidos permanecem ativos, aplicam perdas diárias, reduzem prazos e podem
chegar a crises.

## Condições de término

### Vitória

O jogador vence ao chegar ao décimo dia com o motor funcionando e pelo menos
um sobrevivente vivo.

### Derrota

O jogador perde caso o oxigênio chegue a zero, o motor seja destruído, a moral
chegue a zero, a nave fique sem energia para continuar a viagem ou não reste
nenhum sobrevivente vivo a bordo.

## Escopo da primeira versão

O protótipo sera desenvolvido com quatro cômodos, quatro sobreviventes a bordo
(além do técnico controlado pelo jogador), seis recursos e uma viagem de dez dias.

O objetivo é garantir uma versão em duas semanas, com foco na navegação entre o
mapa macro e os cômodos, no controle direto do técnico, no controle dos
recursos e nas consequências das decisões.

## Referências

- Fallout Shelter
- Jogos 2D de gerenciamento e sobrevivencia
