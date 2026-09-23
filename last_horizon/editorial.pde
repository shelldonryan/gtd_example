final int EDITORIAL_RESULT_NONE = 0;
final int EDITORIAL_RESULT_OMISSION = 1;
final int EDITORIAL_RESULT_FAILURE = 2;
final int EDITORIAL_RESULT_HELP = 3;
final int EDITORIAL_RESULT_RESCUE = 4;

final int EDITORIAL_QUEST_ID = 0;
final int EDITORIAL_VISIBLE_TITLE = 1;
final int EDITORIAL_SHORT_MOTIVATION = 2;
final int EDITORIAL_BASE_LINE = 3;
final int EDITORIAL_FACTUAL_FALLBACK = 4;
final int EDITORIAL_FIELD_COUNT = 5;

String[] crew_display_name = {"Vera", "Bento", "Neusa", "Sílvia"};
String[] crew_voice = {
  "pragmática e voltada à viagem",
  "protetor do estoque e um pouco resmungão",
  "cuidadosa e atenta às pessoas",
  "direta e focada nos sistemas"
};

String[][] editorial_catalog = {
  {"V-01", "Um sinal para casa", "A antena está perdendo força. Vamos deixar o canal pronto.", "A rota precisa de um canal aberto para continuar segura.", "Leve a bobina de transmissão da reserva até a antena."},
  {"V-02", "Rumo a Marte", "Confira este cartão no console. Não podemos desperdiçar energia na rota.", "Cada ajuste de rota poupa uma decisão difícil mais adiante.", "Leve o cartão de rota com Vera até o console da rota."},
  {"B-01", "Reserva em ordem", "Tem provisão separada na prateleira. Leve ao estoque antes que vire bagunça.", "Uma reserva organizada dá margem para a próxima falha.", "Leve a caixa de provisões da reserva até o estoque de comida."},
  {"B-02", "Peças para a próxima falha", "Traga a chave de torque. Quero as peças prontas quando precisarmos.", "A oficina só ajuda se as peças certas estiverem à mão.", "Leve a chave de torque da reserva até Bento."},
  {"N-01", "Água para o grupo", "O filtro está no console. Leve à mesa comum; eu cuido do restante.", "Água tratada mantém o grupo estável durante a viagem.", "Leve o filtro de água do console da rota até a mesa comum."},
  {"N-02", "Um pouco de conversa", "Leve estes cartões à mesa do grupo. Podemos começar ouvindo uns aos outros.", "Uma conversa guiada evita que o cansaço vire distância.", "Leve os cartões de mediação com Neusa até a mesa do grupo."},
  {"S-01", "Energia sem desperdício", "Pegue o módulo no console e leve à distribuição. Vamos acertar essa carga.", "A distribuição precisa de uma regulagem antes da próxima noite.", "Leve o módulo de relé do console da rota até a distribuição."},
  {"S-02", "Respirar com tranquilidade", "Traga o cartucho ao suporte. Melhor testar agora do que durante uma falha.", "O suporte de vida precisa de uma margem antes de ser exigido.", "Leve o cartucho de oxigênio do console da rota até o suporte."},
  {"ENG-A", "Alinhar o motor", "Com a chave de torque e duas peças, alinhamos esse eixo.", "O motor volta a responder quando o eixo deixa de vibrar.", "Leve a chave de torque do console da rota até a bancada do motor."},
  {"ENG-B", "Estabilizar a rotação", "O atuador custa 8 energia agora; se falhar, o motor será destruído.", "Uma rotação estável compra tempo para chegar a Marte.", "Leve o atuador do motor do console da rota até a bancada do motor."},
  {"HUL-A", "Vedar a ruptura", "Leve o kit até a ruptura. Precisamos segurar o oxigênio.", "O casco precisa de uma vedação antes que a perda se acumule.", "Leve o kit de vedação do console da rota até o ponto do casco."},
  {"HUL-B", "Fixar a blindagem", "A placa fecha a abertura. Prepare energia para fixá-la.", "Uma blindagem firme protege a nave enquanto a rota continua.", "Leve a placa de blindagem do console da rota até o ponto do casco."},
  {"FOOD-A", "Recompor o estoque", "Traga a caixa. Com uma peça, deixamos o estoque funcionando de novo.", "A reserva de comida precisa voltar a ter uma margem segura.", "Leve a caixa de provisões do console da rota até o estoque de comida."},
  {"FOOD-B", "Proteger as provisões", "O selante protege o que resta, mesmo com o estoque apertado.", "Proteger a reserva reduz o desperdício da viagem.", "Leve o selante de estoque do console da rota até o estoque de comida."},
  {"CON-A", "Abrir espaço para ouvir", "Traga os cartões. A conversa vai ser difícil, mas necessária.", "Uma mediação curta pode devolver espaço para o grupo respirar.", "Leve os cartões de mediação do console da rota até a mesa do grupo."},
  {"CON-B", "Sentar à mesma mesa", "Uma refeição juntos pode acalmar os ânimos.", "O grupo precisa de um motivo simples para voltar a se encontrar.", "Leve a refeição quente do console da rota até a mesa do grupo."},
  {"LIFE-A", "Trocar o cartucho", "Traga o cartucho. Uma peça põe o suporte de volta.", "Um cartucho novo devolve segurança ao ar da nave.", "Leve o cartucho de oxigênio do console da rota até o suporte."},
  {"LIFE-B", "Recircular o ar", "O filtro de CO2 resolve, mas a recirculação vai puxar energia.", "Recircular o ar mantém o suporte estável durante a manutenção.", "Leve o filtro de CO2 do console da rota até o suporte."},
  {"PWR-A", "Isolar o circuito", "Busque o fusível. Trocamos a peça e isolamos a falha.", "Um circuito isolado impede que a falha alcance o resto da nave.", "Leve o fusível de potência do console da rota até a distribuição."},
  {"PWR-B", "Redistribuir a carga", "O módulo redistribui a carga. Vai ficar menos confortável para todos.", "Uma carga bem distribuída preserva energia para a chegada.", "Leve o módulo de relé do console da rota até a distribuição."},
  {"COM-A", "Restabelecer o contato", "Traga a bobina à antena. Ainda podemos recuperar o canal.", "O contato com a Terra precisa de uma última tentativa.", "Leve a bobina de transmissão do console da rota até a antena."},
  {"COM-B", "Manter a escuta", "A célula mantém a escuta. Precisamos reservar energia para isso.", "Um sinal fraco ainda pode orientar a nave até Marte.", "Leve a célula de sinal do console da rota até a antena."}
};

String[][] ambient_dialogue = {
  {
    "O canal está quieto hoje. Ainda assim, vale escutar.", "Marte parece longe, mas a rota está certa.",
    "A nave aguenta. Precisamos continuar escolhendo bem.", "Cada correção deixa a viagem um pouco mais segura.",
    "Já dá para sentir a chegada. Só não podemos relaxar.", "A base de Marte está respondendo. Estamos quase lá."
  },
  {
    "Tem lugar para tudo, desde que ninguém abandone a ordem.", "Eu conto cada peça. É assim que a reserva dura.",
    "O estoque está apertado, mas ainda dá para organizar.", "Desgaste aparece primeiro nas prateleiras e depois no resto.",
    "Separei o que sobrou para a reta final.", "Quando pousarmos, vou querer conferir cada caixa."
  },
  {
    "O grupo fala baixo quando está cansado. Eu escuto mesmo assim.", "Uma rotina pequena ajuda a atravessar um dia grande.",
    "Hoje todo mundo parece um pouco mais tenso.", "Ainda temos tempo para cuidar uns dos outros.",
    "A aproximação muda o humor da nave.", "Quero que todos cheguem inteiros à base."
  },
  {
    "Se o motor fizer barulho, me chame antes de improvisar.", "A rota está no console. O resto é atenção.",
    "Não gosto desse ruído, mas sei de onde ele vem.", "A nave está cobrando manutenção de todos os lados.",
    "Os sistemas estão no limite da viagem.", "Mais alguns dias e entrego o motor à equipe de Marte."
  }
};

int[] editorial_last_result;
int[] editorial_last_result_day;
int[] editorial_last_seen_day;
boolean[] editorial_was_presented;
int[] editorial_last_risk_day;
boolean[] editorial_risk_was_presented;
int[] editorial_conversation_count;

void resetEditorialMemory(){
  if (editorial_last_result == null){
    editorial_last_result = new int[CREW_COUNT];
    editorial_last_result_day = new int[CREW_COUNT];
    editorial_last_seen_day = new int[CREW_COUNT];
    editorial_was_presented = new boolean[CREW_COUNT];
    editorial_last_risk_day = new int[CREW_COUNT];
    editorial_risk_was_presented = new boolean[CREW_COUNT];
    editorial_conversation_count = new int[CREW_COUNT];
  }

  for (int crew = 0; crew < CREW_COUNT; crew++){
    editorial_last_result[crew] = EDITORIAL_RESULT_NONE;
    editorial_last_result_day[crew] = 0;
    editorial_last_seen_day[crew] = 0;
    editorial_was_presented[crew] = false;
    editorial_last_risk_day[crew] = 0;
    editorial_risk_was_presented[crew] = false;
    editorial_conversation_count[crew] = 0;
  }
}

String crewDisplayName(int crew){
  if (crew >= 0 && crew < crew_display_name.length) return crew_display_name[crew];
  return "tripulante";
}


String editorialSentenceCase(String value){
  if (value == null || value.length() == 0) return "";
  String lower = value.toLowerCase();
  return lower.substring(0, 1).toUpperCase() + lower.substring(1);
}


int editorialCatalogIndex(int q){
  if (q < 0 || q >= quest_id.length) return -1;
  if (editorial_catalog == null) return -1;
  for (int i = 0; i < editorial_catalog.length; i++){
    if (editorial_catalog[i] != null && editorial_catalog[i].length > EDITORIAL_QUEST_ID
      && quest_id[q].equals(editorial_catalog[i][EDITORIAL_QUEST_ID])) return i;
  }
  return -1;
}


boolean editorialContainsTechnicalId(String value){
  if (value == null) return true;
  for (String id : quest_id) if (value.indexOf(id) >= 0) return true;
  return false;
}


boolean editorialTextValid(String value){
  return editorialTextValid(value, -1);
}


boolean editorialTextValid(String value, int field){
  if (value == null || value.trim().length() == 0 || value.length() > 160
    || editorialContainsTechnicalId(value)) return false;
  if (!Character.isUpperCase(value.charAt(0))) return false;
  int sentence_endings = 0;
  for (int i = 0; i < value.length(); i++){
    char current = value.charAt(i);
    if (current == '.' || current == '!' || current == '?') sentence_endings++;
  }
  return sentence_endings <= 2
    && (field == EDITORIAL_VISIBLE_TITLE || sentence_endings >= 1);
}


boolean editorialCatalogValid(){
  if (editorial_catalog == null || editorial_catalog.length != 22
    || editorial_catalog.length != quest_id.length) return false;
  for (int i = 0; i < editorial_catalog.length; i++){
    if (editorial_catalog[i] == null || editorial_catalog[i].length < EDITORIAL_FIELD_COUNT) return false;
    String id = editorial_catalog[i][EDITORIAL_QUEST_ID];
    if (id == null || editorialCatalogIndexForId(id) < 0) return false;
    for (int j = i + 1; j < editorial_catalog.length; j++){
      if (editorial_catalog[j] == null || editorial_catalog[j].length < EDITORIAL_FIELD_COUNT) return false;
      if (id.equals(editorial_catalog[j][EDITORIAL_QUEST_ID])) return false;
    }
    for (int field = EDITORIAL_VISIBLE_TITLE; field < EDITORIAL_FIELD_COUNT; field++){
      if (!editorialTextValid(editorial_catalog[i][field], field)) return false;
    }
  }
  return true;
}


int editorialCatalogIndexForId(String id){
  for (int q = 0; q < quest_id.length; q++) if (quest_id[q].equals(id)) return q;
  return -1;
}


String editorialMechanicalFallback(int q){
  if (q < 0 || q >= quest_id.length) return "Há uma tarefa pendente na nave.";
  String title = editorialSentenceCase(quest_title[q]);
  String object = editorialSentenceCase(quest_object[q]);
  String origin = editorialSentenceCase(point_label[quest_origin[q]]);
  String destination = editorialSentenceCase(point_label[quest_destination[q]]);
  return "A tarefa é " + title + ": leve " + object + " de " + origin + " até " + destination + ".";
}


String editorialCatalogValue(int q, int field){
  int index = editorialCatalogIndex(q);
  if (index >= 0 && field >= 0 && field < EDITORIAL_FIELD_COUNT
    && editorial_catalog[index].length > field
    && editorialTextValid(editorial_catalog[index][field], field)) return editorial_catalog[index][field];
  return editorialFactualFallback(q);
}


String editorialFactualFallback(int q){
  int index = editorialCatalogIndex(q);
  if (index >= 0 && editorial_catalog[index].length > EDITORIAL_FACTUAL_FALLBACK
    && editorialTextValid(editorial_catalog[index][EDITORIAL_FACTUAL_FALLBACK], EDITORIAL_FACTUAL_FALLBACK))
    return editorial_catalog[index][EDITORIAL_FACTUAL_FALLBACK];
  return editorialMechanicalFallback(q);
}


String questVisibleTitle(int q){
  int index = editorialCatalogIndex(q);
  if (index >= 0 && editorial_catalog[index].length > EDITORIAL_VISIBLE_TITLE
    && editorialTextValid(editorial_catalog[index][EDITORIAL_VISIBLE_TITLE], EDITORIAL_VISIBLE_TITLE))
    return editorial_catalog[index][EDITORIAL_VISIBLE_TITLE];
  return q >= 0 && q < quest_title.length ? editorialSentenceCase(quest_title[q]) : "Tarefa";
}


String questMotivation(int q){
  return editorialCatalogValue(q, EDITORIAL_SHORT_MOTIVATION);
}


String questBaseLine(int q){
  return editorialCatalogValue(q, EDITORIAL_BASE_LINE);
}


String editorialQuestResult(int q){
  if (q < 0 || q >= quest_id.length) return "Resultado mecânico pendente.";
  if (q < PREVENTIVE_COUNT){
    return "+" + preventiveReward(q) + " "
      + editorialSentenceCase(resourceName(preventive_resource[q])) + ".";
  }
  int solution = q - PREVENTIVE_COUNT;
  return "Custo na entrega: -" + solution_cost[solution] + " "
    + editorialSentenceCase(resourceName(solution_resource[solution])) + ".";
}


int editorialResultPriority(int result){
  if (result == EDITORIAL_RESULT_RESCUE) return 4;
  if (result == EDITORIAL_RESULT_HELP) return 3;
  if (result == EDITORIAL_RESULT_FAILURE) return 2;
  if (result == EDITORIAL_RESULT_OMISSION) return 1;
  return 0;
}


void recordEditorialResult(int q, int result){
  if (q < 0 || q >= quest_owner.length || result == EDITORIAL_RESULT_NONE) return;
  recordEditorialCrewResult(quest_owner[q], result);
}


void recordEditorialCrewResult(int crew, int result){
  if (crew < 0 || crew >= CREW_COUNT || result == EDITORIAL_RESULT_NONE
    || !crew_alive[crew]) return;
  if (editorial_last_result_day[crew] == day
    && editorialResultPriority(editorial_last_result[crew]) >= editorialResultPriority(result)) return;
  editorial_last_result[crew] = result;
  editorial_last_result_day[crew] = day;
  editorial_last_seen_day[crew] = 0;
  editorial_was_presented[crew] = false;
}


void recordEditorialRisk(int crew){
  if (crew < 0 || crew >= CREW_COUNT || !crew_alive[crew]) return;
  editorial_last_risk_day[crew] = day;
  editorial_risk_was_presented[crew] = false;
}


void clearEditorialRisk(int crew){
  if (crew < 0 || crew >= CREW_COUNT) return;
  editorial_last_risk_day[crew] = 0;
  editorial_risk_was_presented[crew] = false;
}


int editorialQuestForCrew(int crew){
  for (int q = 0; q < PREVENTIVE_COUNT; q++){
    if (quest_owner[q] == crew) return q;
  }
  return -1;
}


String editorialRecognition(int crew){
  if (crew < 0 || crew >= CREW_COUNT || !crew_alive[crew]
    || editorial_last_result[crew] == EDITORIAL_RESULT_NONE
    || editorial_last_result_day[crew] < day - 1 || editorial_was_presented[crew]) return "";
  int result = editorial_last_result[crew];
  if (result == EDITORIAL_RESULT_RESCUE) return crew == CREW_VERA
    ? "Rota estabilizada. Obrigada por me manter em movimento."
    : crew == CREW_BENTO ? "Você segurou a situação. Agora eu cuido do estoque."
    : crew == CREW_NEUSA ? "Obrigada por me ajudar a estabilizar a situação."
    : "Situação estabilizada. O sistema pode continuar.";
  if (result == EDITORIAL_RESULT_HELP) return crew == CREW_VERA
    ? "Rota conferida. Estamos um pouco mais perto."
    : crew == CREW_BENTO ? "Tudo no lugar. Assim eu consigo trabalhar."
    : crew == CREW_NEUSA ? "Obrigada. Hoje deu para respirar um pouco."
    : "Resolvido. Já era hora de esse motor colaborar.";
  if (result == EDITORIAL_RESULT_FAILURE) return "Eu sei que a ordem ficou para trás. Ainda há trabalho pela frente.";
  if (result == EDITORIAL_RESULT_OMISSION) return "A necessidade continua aqui. Quando puder, olhe para ela.";
  return "";
}


boolean editorialRiskAvailable(int crew){
  return crew >= 0 && crew < CREW_COUNT && crew_alive[crew]
    && editorial_last_risk_day[crew] >= day - 1
    && editorial_last_risk_day[crew] <= day
    && !editorial_risk_was_presented[crew];
}


String editorialRiskLine(int crew){
  if (!editorialRiskAvailable(crew)) return "";
  return "Não vou fingir que está tudo bem. Preciso de cuidado agora.";
}


void markEditorialPresentation(int crew){
  markEditorialPresentation(crew, editorialContextLine(crew));
}


void markEditorialPresentation(int crew, String captured_line){
  if (crew < 0 || crew >= CREW_COUNT || !crew_alive[crew]) return;
  String risk_line = editorialRiskLine(crew);
  if (risk_line.length() > 0 && risk_line.equals(captured_line)){
    editorial_risk_was_presented[crew] = true;
    return;
  }
  String recognition = editorialRecognition(crew);
  if (recognition.length() > 0 && recognition.equals(captured_line)){
    editorial_was_presented[crew] = true;
    editorial_last_seen_day[crew] = day;
  }
}


String editorialPhaseLine(int crew){
  if (crew < 0 || crew >= CREW_COUNT) return "A viagem exige atenção a cada dia.";
  int phase = day <= 3 ? 0 : day <= 7 ? 1 : 2;
  int variant = editorial_conversation_count[crew] % 2;
  return ambient_dialogue[crew][phase * 2 + variant];
}


String editorialContextLine(int crew){
  if (crew < 0 || crew >= CREW_COUNT || !crew_alive[crew]) return "";
  if (selected_preventive_id >= 0 && quest_owner[selected_preventive_id] == crew){
    return "Minha oferta está pronta. Aceite para assumir “"
      + questVisibleTitle(selected_preventive_id) + "”.";
  }
  if (selected_preventive_id >= 0){
    return "Fale com " + crewDisplayName(quest_owner[selected_preventive_id]) + " para confirmar a escolha.";
  }
  if (active_quest >= 0){
    int owner = quest_owner[active_quest];
    if (owner == crew){
      if (quest_stage == QUEST_COLLECT)
        return "A etapa atual é pegar " + editorialSentenceCase(quest_object[active_quest])
          + " em " + editorialSentenceCase(point_label[quest_origin[active_quest]]) + ".";
      if (quest_origin[active_quest] == crew_point[owner])
        return "Já entreguei " + editorialSentenceCase(quest_object[active_quest]) + ". Siga até "
          + editorialSentenceCase(point_label[quest_destination[active_quest]]) + ".";
      return "A etapa atual é levar " + editorialSentenceCase(quest_object[active_quest]) + " até "
        + editorialSentenceCase(point_label[quest_destination[active_quest]]) + ".";
    }
    return crewDisplayName(owner) + " espera " + editorialSentenceCase(quest_object[active_quest])
      + " em " + editorialSentenceCase(point_label[quest_destination[active_quest]]) + ".";
  }
  int risk = urgentRisk();
  if (risk == crew){
    String risk_line = editorialRiskLine(crew);
    return risk_line.length() > 0 ? risk_line : "Preciso de ajuda antes que a noite chegue.";
  }
  String recognition = editorialRecognition(crew);
  if (recognition.length() > 0) return recognition;
  int offer = offerOf(crew);
  if (offer >= 0) return "Minha oferta: " + questBaseLine(offer);
  int urgent = urgentProblem();
  if (urgent >= 0) return "O problema urgente é " + editorialSentenceCase(problem_short[urgent]) + ".";
  if (quest_completed) return "O trabalho de hoje acabou. Seu beliche encerra o dia.";
  return editorialPhaseLine(crew);
}


void beginNpcConversation(int crew){
  if (crew < 0 || crew >= CREW_COUNT || !crew_alive[crew]
    || (dialog_open && dialog_crew == crew)) return;
  dialog_crew = crew;
  dialog_name = crew_name[crew];
  dialog_text = editorialContextLine(crew);
  dialog_result = "";
  dialog_open = true;
  editorial_conversation_count[crew]++;
  markEditorialPresentation(crew, dialog_text);
}
