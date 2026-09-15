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

## Mecanica principal

A partida representa uma viagem de dez dias por quatro cômodos. A Sala de
comando é o hub central e possui uma porta por convés para Dormitório, Depósito
e Sala de máquinas; as salas periféricas não se conectam entre si.

Incidentes surgem em dias alternados. A resposta escolhe uma contenção, mas cria
um problema local persistente com perda diária, prazo e crise conhecida. Não há
aceite de tarefa no Comando: o jogador consulta as urgências no HUD e no mapa e
escolhe onde intervir.

Uma correção, recuperação ou aceleração principal pode ser concluída por dia.
Preparação e políticas são livres. Para encerrar o turno, o técnico retorna ao
próprio beliche no Dormitório, confere as consequências previstas e dorme.

O jogador deve equilibrar os seguintes recursos:

- **Energia:** mantém o motor e os sistemas da nave funcionando.
- **Oxigênio:** garante a sobrevivência das pessoas a bordo.
- **Água:** Consumida pelos sobreviventes.
- **Comida:** Consumida diariamente pelos sobreviventes.
- **Peças:** Utilizadas para reparar o motor e outros sistemas.
- **Moral:** Representa o estado emocional dos sobreviventes e pode afetar a
  capacidade de lidar com problemas.

## Comodos da nave

### Sala de comando

É o hub físico e o centro de navegação e comunicações. A porta superior leva ao
Dormitório, a média ao Depósito e a inferior à Sala de máquinas. Vera acompanha
a rota; o console permite consultar a viagem e aumentar potência, enquanto a
antena conclui correções de comunicação. Não existe briefing diário obrigatório.

### Sala de máquinas

Concentra motor, energia e suporte de vida. Sílvia oferece diagnóstico e seu
benefício de mecânica; bancada, reator, distribuição e suporte recebem as
intervenções técnicas. O modo economia é uma política persistente local.

### Depósito

Concentra estoques, componentes especiais e racionamento. Recursos comuns do HUD
são pagos diretamente no ponto final; apenas componentes especiais, como um kit
ou fusível específico, precisam ser buscados. Bento oferece leitura logística
sem ser passagem obrigatória de toda correção.

### Dormitório

Concentra descanso, saúde e moral. Dormir encerra o turno; `Cuidar do grupo`
recupera moral; `Socorrer [nome]` estabiliza um sobrevivente em risco. Neusa
oferece a leitura humana do grupo.

## Eventos

O pool mantém sete incidentes: falha no motor, chuva de meteoros, falta de
comida, conflito no dormitório, falha no suporte de vida, falha no sistema de
energia e falha nas comunicações.

Eles surgem em dias alternados e um problema ainda ativo não é sorteado de novo.
Cada cartão oferece duas contenções: gastar mais agora para ganhar segurança ou
economizar e aceitar maior risco. A escolha não encerra a causa; a correção
acontece fisicamente no cômodo responsável.

O dano no casco por meteoros não pertence a uma estação fixa: cada ocorrência
escolhe um local aleatório alcançável pelo jogador em qualquer um dos quatro
cômodos e permanece ali até a correção.

Problemas ignorados aplicam uma perda diária e avançam para uma crise específica.
Uma crise pode destruir um sistema, causar uma grande perda ou colocar um
sobrevivente nomeado em risco. A issue #20 contém uma proposta numérica
executável, ainda PROVISÓRIA até a validação do usuário.

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
