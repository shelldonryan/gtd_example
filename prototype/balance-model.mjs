#!/usr/bin/env node
/**
 * PROTÓTIPO EXECUTÁVEL — balanceamento da issue #26.
 *
 * O modelo usa o contrato de quests físicas: uma quest concluída por dia,
 * preventivas nos dias sem incidente e soluções físicas nos dias pares.
 * Simulação automática: node prototype/balance-model.mjs --simulate
 * Exploração interativa: node prototype/balance-model.mjs
 */

import readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";
import { pathToFileURL } from "node:url";

export const MAX_RESOURCE = 100;
export const BAR_RESOURCES = Object.freeze([
  "energy", "oxygen", "water", "food", "morale",
]);
export const INCIDENT_DAYS = Object.freeze([2, 4, 6, 8, 10]);
const INCIDENT_DAY_SET = new Set(INCIDENT_DAYS);
export const NON_INCIDENT_DAYS = Object.freeze([1, 3, 5, 7, 9]);
export const SURVIVORS = Object.freeze(["Vera", "Bento", "Neusa", "Sílvia"]);
export const DEFAULT_INCIDENT_SEQUENCE = Object.freeze([
  "engine", "food", "conflict", "hull", "lifeSupport",
]);

export const DAILY_CONSUMPTION = Object.freeze({
  energy: 7,
  oxygen: 4,
  water: 6,
  food: 6,
  morale: 2,
});

const INITIAL_RESOURCES = Object.freeze({
  energy: 80,
  oxygen: 85,
  water: 80,
  food: 70,
  morale: 80,
  parts: 4,
});

const PREVENTIVE_REWARD = Object.freeze({
  energy: 8,
  oxygen: 8,
  water: 8,
  food: 8,
  morale: 8,
  parts: 2,
});

const PREVENTIVE_FAILURE = Object.freeze({
  energy: 3,
  oxygen: 3,
  water: 3,
  food: 3,
  morale: 3,
  parts: 1,
});

const PREVENTIVE_NEGLECT = Object.freeze({
  energy: 4,
  oxygen: 4,
  water: 4,
  food: 4,
  morale: 4,
  parts: 2,
});

function freeze(value) {
  return Object.freeze(value);
}

export const PREVENTIVE_ORDERS = freeze([
  freeze({
    id: "V-01", responsible: "Vera", title: "Calibrar a antena",
    object: "bobina de transmissão", origin: "reserva (Depósito)",
    destination: "antena (Comando)", resource: "morale",
    reward: PREVENTIVE_REWARD.morale, failure: PREVENTIVE_FAILURE.morale,
  }),
  freeze({
    id: "V-02", responsible: "Vera", title: "Atualizar a rota",
    object: "cartão de rota", origin: "Vera (Comando)",
    destination: "console da rota (Comando)", resource: "energy",
    reward: PREVENTIVE_REWARD.energy, failure: PREVENTIVE_FAILURE.energy,
  }),
  freeze({
    id: "B-01", responsible: "Bento", title: "Reforçar a reserva",
    object: "caixa de provisões", origin: "prateleira de reserva (Depósito)",
    destination: "estoque de comida (Depósito)", resource: "food",
    reward: PREVENTIVE_REWARD.food, failure: PREVENTIVE_FAILURE.food,
  }),
  freeze({
    id: "B-02", responsible: "Bento", title: "Separar peças de emergência",
    object: "chave de torque", origin: "prateleira de reserva (Depósito)",
    destination: "Bento (Depósito)", resource: "parts",
    reward: PREVENTIVE_REWARD.parts, failure: PREVENTIVE_FAILURE.parts,
  }),
  freeze({
    id: "N-01", responsible: "Neusa", title: "Preparar água do grupo",
    object: "filtro de água", origin: "console da rota (Comando)",
    destination: "mesa comum (Dormitório)", resource: "water",
    reward: PREVENTIVE_REWARD.water, failure: PREVENTIVE_FAILURE.water,
  }),
  freeze({
    id: "N-02", responsible: "Neusa", title: "Abrir espaço para a conversa",
    object: "cartões de mediação", origin: "Neusa (Dormitório)",
    destination: "mesa do grupo (Dormitório)", resource: "morale",
    reward: PREVENTIVE_REWARD.morale, failure: PREVENTIVE_FAILURE.morale,
  }),
  freeze({
    id: "S-01", responsible: "Sílvia", title: "Regular a distribuição",
    object: "módulo de relé", origin: "console da rota (Comando)",
    destination: "painel de distribuição (Máquinas)", resource: "energy",
    reward: PREVENTIVE_REWARD.energy, failure: PREVENTIVE_FAILURE.energy,
  }),
  freeze({
    id: "S-02", responsible: "Sílvia", title: "Testar o suporte de vida",
    object: "cartucho de oxigênio", origin: "console da rota (Comando)",
    destination: "painel de suporte de vida (Máquinas)", resource: "oxygen",
    reward: PREVENTIVE_REWARD.oxygen, failure: PREVENTIVE_FAILURE.oxygen,
  }),
]);

export const PREVENTIVE_PAIRS = Object.freeze([
  Object.freeze(["V-01", "B-01"]),
  Object.freeze(["V-02", "N-01"]),
  Object.freeze(["B-02", "S-02"]),
  Object.freeze(["N-02", "S-01"]),
]);

function solution(id, responsible, object, cost, origin, destination, result) {
  return freeze({
    id, responsible, object, cost: freeze(cost), origin, destination, result,
  });
}

export const PROBLEMS = Object.freeze({
  engine: freeze({
    id: "engine", name: "Falha no motor", family: "falhas técnicas",
    loss: freeze({ resource: "energy", perDay: 4 }), deadline: 3,
    crisis: freeze({
      text: "MOTOR DESTRUÍDO", reset: null, motorOperational: false,
    }),
    solutions: freeze([
      solution("ENG-A", "Sílvia", "chave de torque", { parts: 2 },
        "console da rota (Comando)", "bancada do motor (Máquinas)",
        "alinhar o eixo do motor"),
      solution("ENG-B", "Sílvia", "atuador do motor", { energy: 8 },
        "console da rota (Comando)", "bancada do motor (Máquinas)",
        "estabilizar a rotação"),
    ]),
  }),
  hull: freeze({
    id: "hull", name: "Dano no casco", family: "falhas técnicas",
    loss: freeze({ resource: "oxygen", perDay: 4 }), deadline: 3,
    crisis: freeze({
      text: "RUPTURA: -12 OXIGÊNIO", reset: 2, oxygen: -12,
    }),
    solutions: freeze([
      solution("HUL-A", "Sílvia", "kit de vedação", { parts: 1 },
        "console da rota (Comando)", "ponto de casco sorteado",
        "fechar a ruptura"),
      solution("HUL-B", "Sílvia", "placa de blindagem", { energy: 6 },
        "console da rota (Comando)", "ponto de casco sorteado",
        "sustentar a placa"),
    ]),
  }),
  lifeSupport: freeze({
    id: "lifeSupport", name: "Falha no suporte de vida", family: "falhas técnicas",
    loss: freeze({ resource: "oxygen", perDay: 3 }), deadline: 3,
    crisis: freeze({
      text: "CONTAMINAÇÃO: -10 OXIGÊNIO E UMA PESSOA EM RISCO",
      reset: 2, oxygen: -10, putsAtRisk: true,
    }),
    solutions: freeze([
      solution("LIFE-A", "Sílvia", "cartucho de oxigênio", { parts: 1 },
        "console da rota (Comando)", "painel de suporte de vida (Máquinas)",
        "repor o cartucho"),
      solution("LIFE-B", "Sílvia", "filtro de CO2", { energy: 6 },
        "console da rota (Comando)", "painel de suporte de vida (Máquinas)",
        "recircular o ar"),
    ]),
  }),
  power: freeze({
    id: "power", name: "Falha no sistema de energia", family: "falhas técnicas",
    loss: freeze({ resource: "energy", perDay: 3 }), deadline: 3,
    crisis: freeze({
      text: "APAGÃO: -10 ENERGIA", reset: 2, energy: -10,
    }),
    solutions: freeze([
      solution("PWR-A", "Sílvia", "fusível de potência", { parts: 1 },
        "console da rota (Comando)", "painel de distribuição (Máquinas)",
        "isolar o circuito"),
      solution("PWR-B", "Sílvia", "módulo de relé", { morale: 5 },
        "console da rota (Comando)", "painel de distribuição (Máquinas)",
        "redistribuir a carga"),
    ]),
  }),
  communications: freeze({
    id: "communications", name: "Falha nas comunicações", family: "falhas técnicas",
    loss: freeze({ resource: "morale", perDay: 2 }), deadline: 4,
    crisis: freeze({
      text: "ISOLAMENTO: -8 MORAL", reset: 2, morale: -8,
    }),
    solutions: freeze([
      solution("COM-A", "Vera", "bobina de transmissão", { parts: 1 },
        "console da rota (Comando)", "antena (Comando)",
        "restabelecer o contato"),
      solution("COM-B", "Vera", "célula de sinal", { energy: 5 },
        "console da rota (Comando)", "antena (Comando)",
        "manter a escuta"),
    ]),
  }),
  food: freeze({
    id: "food", name: "Falta de comida", family: "suprimentos",
    loss: freeze({ resource: "food", perDay: 3 }), deadline: 3,
    crisis: freeze({
      text: "FOME: -8 COMIDA E UMA PESSOA EM RISCO",
      reset: 2, food: -8, putsAtRisk: true,
    }),
    solutions: freeze([
      solution("FOOD-A", "Bento", "caixa de provisões", { parts: 1 },
        "console da rota (Comando)", "estoque de comida (Depósito)",
        "recompor o estoque"),
      solution("FOOD-B", "Bento", "selante de estoque", { morale: 4 },
        "console da rota (Comando)", "estoque de comida (Depósito)",
        "proteger a reserva"),
    ]),
  }),
  conflict: freeze({
    id: "conflict", name: "Conflito no dormitório", family: "tripulação",
    loss: freeze({ resource: "morale", perDay: 3 }), deadline: 3,
    crisis: freeze({
      text: "AGRESSÃO: -8 MORAL E UMA PESSOA EM RISCO",
      reset: 2, morale: -8, putsAtRisk: true,
    }),
    solutions: freeze([
      solution("CON-A", "Neusa", "cartões de mediação", { morale: 5 },
        "console da rota (Comando)", "mesa do grupo (Dormitório)",
        "mediar a conversa"),
      solution("CON-B", "Neusa", "refeição quente", { food: 4 },
        "console da rota (Comando)", "mesa do grupo (Dormitório)",
        "reunir o grupo"),
    ]),
  }),
});

const PROBLEM_IDS = Object.freeze(Object.keys(PROBLEMS));
const PREVENTIVE_BY_ID = Object.freeze(
  Object.fromEntries(PREVENTIVE_ORDERS.map((order) => [order.id, order])),
);
const RESCUE_COST = Object.freeze({ water: 8, food: 2 });

function copyState(state) {
  return structuredClone(state);
}

function shuffledProblems() {
  const problems = [...PROBLEM_IDS];
  for (let index = problems.length - 1; index > 0; index--) {
    const swapIndex = Math.floor(Math.random() * (index + 1));
    [problems[index], problems[swapIndex]] = [problems[swapIndex], problems[index]];
  }
  return problems.slice(0, INCIDENT_DAYS.length);
}

function validateIncidentSequence(sequence) {
  if (!Array.isArray(sequence) || sequence.length !== INCIDENT_DAYS.length) {
    throw new Error("A sequência precisa conter cinco incidentes.");
  }
  if (new Set(sequence).size !== sequence.length
    || sequence.some((id) => !PROBLEMS[id])) {
    throw new Error("A sequência contém incidente inválido ou repetido.");
  }
}

export function initialState(incidentSequence = shuffledProblems()) {
  validateIncidentSequence(incidentSequence);
  return {
    day: 1,
    resources: { ...INITIAL_RESOURCES },
    alive: Object.fromEntries(SURVIVORS.map((name) => [name, true])),
    risk: null,
    activeProblems: [],
    pendingIncident: null,
    retrySolutions: [],
    dailyOffers: [],
    selectedOffer: null,
    acceptedQuest: null,
    loadedItem: null,
    questCompleted: false,
    completedQuestKind: null,
    motorOperational: true,
    outcome: "ongoing",
    reason: "",
    incidentSequence: [...incidentSequence],
    incidentsSeen: [],
    offerHistory: [],
    questHistory: [],
    crises: [],
    deaths: [],
    riskHistory: [],
    lastMessage: "Dia 1 aguardando início.",
  };
}


function canPay(state, cost) {
  return Object.entries(cost).every(([resource, amount]) => state.resources[resource] >= amount);
}

function pay(state, cost) {
  for (const [resource, amount] of Object.entries(cost)) {
    state.resources[resource] -= amount;
  }
}

function addResources(state, gain) {
  for (const [resource, amount] of Object.entries(gain)) {
    state.resources[resource] += amount;
  }
}

function clampResources(state) {
  for (const resource of BAR_RESOURCES) {
    state.resources[resource] = Math.max(0, Math.min(MAX_RESOURCE, state.resources[resource]));
  }
  state.resources.parts = Math.max(0, Math.floor(state.resources.parts));
}

function checkOutcome(state) {
  if (state.resources.energy <= 0) {
    state.outcome = "defeat";
    state.reason = "energia chegou a zero";
  } else if (state.resources.oxygen <= 0) {
    state.outcome = "defeat";
    state.reason = "oxigênio chegou a zero";
  } else if (state.resources.morale <= 0) {
    state.outcome = "defeat";
    state.reason = "moral chegou a zero";
  } else if (!state.motorOperational) {
    state.outcome = "defeat";
    state.reason = "motor destruído";
  } else if (Object.values(state.alive).every((alive) => !alive)) {
    state.outcome = "defeat";
    state.reason = "nenhum sobrevivente vivo";
  }
}

function incidentForDay(day, sequence) {
  if (!INCIDENT_DAY_SET.has(day)) return null;
  return sequence[INCIDENT_DAYS.indexOf(day)];
}

function living(order, alive) {
  return Boolean(alive[order.responsible]);
}

function selectPreventiveOffers(day, alive) {
  if (!NON_INCIDENT_DAYS.includes(day)) return [];
  const pairIndex = NON_INCIDENT_DAYS.indexOf(day) % PREVENTIVE_PAIRS.length;
  const reference = PREVENTIVE_PAIRS[pairIndex]
    .map((id) => PREVENTIVE_BY_ID[id])
    .filter((order) => living(order, alive));

  if (reference.length === 2) return reference;

  const selected = [...reference];
  const resources = new Set(selected.map((order) => order.resource));
  const candidates = PREVENTIVE_ORDERS.filter((order) => living(order, alive));
  for (const order of candidates) {
    if (selected.some((item) => item.id === order.id)) continue;
    if (resources.has(order.resource) && selected.length < 2) continue;
    selected.push(order);
    resources.add(order.resource);
    if (selected.length === 2) return selected;
  }

  for (const order of candidates) {
    if (selected.length === 2) break;
    if (!selected.some((item) => item.id === order.id)) selected.push(order);
  }
  return selected.slice(0, 2);
}

function findPreventive(state, id) {
  return state.dailyOffers.find((order) => order.id === id) ?? null;
}

function findSolution(state, id) {
  if (!state.pendingIncident) return null;
  return PROBLEMS[state.pendingIncident.id].solutions.find((item) => item.id === id) ?? null;
}

function addActiveProblem(state, id, solutionId = null) {
  const definition = PROBLEMS[id];
  const current = state.activeProblems.find((problem) => problem.id === id);
  if (current) {
    if (solutionId) current.solutionId = solutionId;
    return current;
  }
  const problem = {
    id,
    solutionId,
    deadline: definition.deadline,
    activatedDay: state.day,
    activationOrder: state.activeProblems.length + state.crises.length + 1,
  };
  state.activeProblems.push(problem);
  return problem;
}

function clearActiveProblem(state, id) {
  state.activeProblems = state.activeProblems.filter((problem) => problem.id !== id);
}

function addRisk(state, source) {
  if (state.risk) return;
  const candidates = SURVIVORS.filter((name) => state.alive[name]);
  if (candidates.length === 0) return;
  const name = candidates[state.riskHistory.length % candidates.length];
  state.risk = { name, source, deadline: 2, startedDay: state.day };
  state.riskHistory.push({ day: state.day, name, source });
}

function applyCrisis(state, problem) {
  const definition = PROBLEMS[problem.id];
  const crisis = definition.crisis;
  state.crises.push({ day: state.day, id: problem.id, text: crisis.text });
  if (crisis.energy) state.resources.energy += crisis.energy;
  if (crisis.oxygen) state.resources.oxygen += crisis.oxygen;
  if (crisis.food) state.resources.food += crisis.food;
  if (crisis.morale) state.resources.morale += crisis.morale;
  if (crisis.motorOperational === false) state.motorOperational = false;
  if (crisis.putsAtRisk) addRisk(state, problem.id);
  problem.deadline = crisis.reset;
}

function processRisk(state) {
  if (!state.risk) return;
  state.risk.deadline--;
  if (state.risk.deadline > 0) return;
  const { name } = state.risk;
  state.alive[name] = false;
  state.deaths.push({ day: state.day, name });
  state.lastMessage = `${name} não resistiu.`;
  state.risk = null;
}

function processProblems(state) {
  for (const problem of state.activeProblems) {
    const definition = PROBLEMS[problem.id];
    problem.deadline--;
    if (problem.deadline <= 0) applyCrisis(state, problem);
    if (definition.crisis.reset === null && state.outcome === "defeat") break;
  }
}

function beginDay(state) {
  const next = copyState(state);
  if (next.outcome !== "ongoing") return next;
  next.pendingIncident = null;
  next.dailyOffers = [];
  next.retrySolutions = [];
  next.selectedOffer = null;
  next.acceptedQuest = null;
  next.loadedItem = null;
  next.questCompleted = false;
  next.completedQuestKind = null;

  const incidentId = incidentForDay(next.day, next.incidentSequence);
  next.retrySolutions = next.activeProblems.flatMap((problem) => {
    const option = PROBLEMS[problem.id].solutions.find((item) => item.id === problem.solutionId);
    return option ? [{ ...option, problemId: problem.id, deadline: problem.deadline }] : [];
  });
  if (incidentId && !next.activeProblems.some((problem) => problem.id === incidentId)) {
    next.pendingIncident = { id: incidentId };
    next.incidentsSeen.push({ day: next.day, id: incidentId });
    next.lastMessage = `Incidente: ${PROBLEMS[incidentId].name}. Escolha uma solução.`;
  } else {
    next.dailyOffers = selectPreventiveOffers(next.day, next.alive);
    next.offerHistory.push({ day: next.day, ids: next.dailyOffers.map((order) => order.id) });
    next.lastMessage = next.dailyOffers.length === 2
      ? `Dia ${next.day}: duas ordens preventivas disponíveis.`
      : `Dia ${next.day}: não há ordens preventivas disponíveis.`;
  }
  return next;
}

function choosePreventive(state, id) {
  const next = copyState(state);
  if (next.pendingIncident) {
    next.lastMessage = "O incidente exige uma solução física.";
    return next;
  }
  if (next.acceptedQuest || next.questCompleted) {
    next.lastMessage = "A quest do dia já foi escolhida.";
    return next;
  }
  const order = findPreventive(next, id);
  if (!order) {
    next.lastMessage = "Essa ordem não está entre as ofertas do dia.";
    return next;
  }
  next.selectedOffer = order.id;
  next.lastMessage = `${order.id}: confirme com ${order.responsible}.`;
  return next;
}

function acceptPreventive(state) {
  const next = copyState(state);
  if (next.acceptedQuest || next.questCompleted) {
    next.lastMessage = "A quest do dia já foi escolhida.";
    return next;
  }
  const order = next.selectedOffer ? findPreventive(next, next.selectedOffer) : null;
  if (!order) {
    next.lastMessage = "Escolha uma ordem antes da confirmação presencial.";
    return next;
  }
  if (!next.alive[order.responsible]) {
    next.lastMessage = `${order.responsible} não pode confirmar esta ordem.`;
    return next;
  }
  next.acceptedQuest = {
    kind: "preventive", id: order.id, object: order.object,
    resource: order.resource, destination: order.destination, stage: "COLETAR",
  };
  next.selectedOffer = null;
  next.dailyOffers = [];
  next.lastMessage = `${order.responsible}: ordem confirmada. Ela não pode ser cancelada.`;
  return next;
}

function chooseSolution(state, id) {
  const next = copyState(state);
  if (next.acceptedQuest || next.questCompleted || next.selectedOffer) {
    next.lastMessage = "A quest do dia já foi escolhida.";
    return next;
  }

  const problemId = next.pendingIncident?.id;
  const selected = next.pendingIncident
    ? findSolution(next, id)
    : next.retrySolutions.find((option) => option.id === id);
  if (!selected) {
    next.lastMessage = next.pendingIncident
      ? "Essa solução não pertence ao incidente atual."
      : "Essa retomada não pertence a um problema ativo.";
    return next;
  }

  const activeProblemId = problemId ?? selected.problemId;
  addActiveProblem(next, activeProblemId, selected.id);
  next.acceptedQuest = {
    kind: "incident", id: selected.id, problemId: activeProblemId,
    object: selected.object, cost: { ...selected.cost },
    destination: selected.destination, stage: "COLETAR",
  };
  next.pendingIncident = null;
  next.lastMessage = `${selected.id}: objeto aceito. Colete e entregue em ${selected.destination}.`;
  return next;
}

function collectQuestObject(state) {
  const next = copyState(state);
  if (!next.acceptedQuest || next.acceptedQuest.stage !== "COLETAR") {
    next.lastMessage = "Não há objeto aguardando coleta.";
    return next;
  }
  next.loadedItem = next.acceptedQuest.object;
  next.acceptedQuest.stage = "ENTREGAR";
  next.lastMessage = `${next.loadedItem} coletado. Destino: ${next.acceptedQuest.destination}.`;
  return next;
}

function deliverQuest(state) {
  const next = copyState(state);
  if (!next.acceptedQuest || next.acceptedQuest.stage !== "ENTREGAR" || !next.loadedItem) {
    next.lastMessage = "A entrega exige o objeto carregado.";
    return next;
  }
  const quest = next.acceptedQuest;
  if (quest.kind === "incident") {
    if (!canPay(next, quest.cost)) {
      next.lastMessage = "Recursos insuficientes para concluir a solução.";
      return next;
    }
    pay(next, quest.cost);
    clearActiveProblem(next, quest.problemId);
  } else {
    const order = PREVENTIVE_BY_ID[quest.id];
    addResources(next, { [order.resource]: order.reward });
  }
  next.questHistory.push({ day: next.day, kind: quest.kind, id: quest.id, completed: true });
  next.acceptedQuest = null;
  next.loadedItem = null;
  next.questCompleted = true;
  next.completedQuestKind = quest.kind;
  clampResources(next);
  next.lastMessage = quest.kind === "incident"
    ? `${quest.id}: solução concluída.`
    : `ORDEM CONCLUÍDA: +${PREVENTIVE_BY_ID[quest.id].reward} ${quest.resource}.`;
  checkOutcome(next);
  return next;
}

function rescue(state) {
  const next = copyState(state);
  if (next.pendingIncident) {
    next.lastMessage = "Escolha uma solução antes do socorro.";
    return next;
  }
  if (!next.risk) {
    next.lastMessage = "Ninguém está em risco.";
    return next;
  }
  if (next.acceptedQuest || next.questCompleted || next.selectedOffer) {
    next.lastMessage = "A quest do dia já foi escolhida.";
    return next;
  }
  if (!canPay(next, RESCUE_COST)) {
    next.lastMessage = "Recursos insuficientes para o socorro.";
    return next;
  }
  const rescued = next.risk.name;
  pay(next, RESCUE_COST);
  next.risk = null;
  next.questHistory.push({ day: next.day, kind: "rescue", id: `RESCUE-${rescued}`, completed: true });
  next.questCompleted = true;
  next.completedQuestKind = "rescue";
  next.lastMessage = `${rescued} foi estabilizado.`;
  return next;
}

function applyQuestConsequences(state) {
  const preventiveCommitted = state.acceptedQuest?.kind === "preventive"
    || state.completedQuestKind === "preventive";
  if (state.acceptedQuest) {
    if (state.acceptedQuest.kind === "preventive") {
      const order = PREVENTIVE_BY_ID[state.acceptedQuest.id];
      state.resources[order.resource] -= order.failure;
      state.questHistory.push({ day: state.day, kind: "preventive", id: order.id, completed: false });
      state.lastMessage = `ORDEM NÃO CONCLUÍDA: -${order.failure} ${order.resource}.`;
    } else {
      state.questHistory.push({
        day: state.day, kind: "incident", id: state.acceptedQuest.id, completed: false,
      });
      state.lastMessage = `SOLUÇÃO NÃO CONCLUÍDA. ${PROBLEMS[state.acceptedQuest.problemId].name} PERMANECE ATIVO.`;
    }
  }
  if (state.dailyOffers.length === 0 || preventiveCommitted) return;

  const losses = {};
  for (const order of state.dailyOffers) {
    losses[order.resource] = Math.max(losses[order.resource] ?? 0, PREVENTIVE_NEGLECT[order.resource]);
  }
  for (const [resource, amount] of Object.entries(losses)) state.resources[resource] -= amount;
  state.questHistory.push({
    day: state.day, kind: "preventive", id: "NONE", completed: false, losses,
  });
  const neglectMessage = "NENHUMA ORDEM ACEITA: as duas perdas de negligência foram aplicadas.";
  state.lastMessage = state.acceptedQuest?.kind === "incident"
    ? `${state.lastMessage} ${neglectMessage}`
    : neglectMessage;
}

function clearDailyQuest(state) {
  state.acceptedQuest = null;
  state.selectedOffer = null;
  state.dailyOffers = [];
  state.loadedItem = null;
}

function processNight(state) {
  for (const [resource, amount] of Object.entries(DAILY_CONSUMPTION)) {
    state.resources[resource] -= amount;
  }
  for (const problem of state.activeProblems) {
    const { resource, perDay } = PROBLEMS[problem.id].loss;
    state.resources[resource] -= perDay;
  }
  processRisk(state);
  processProblems(state);
  clampResources(state);
}

function sleep(state) {
  const next = copyState(state);
  if (next.pendingIncident) {
    next.lastMessage = "Escolha uma solução antes de dormir.";
    return next;
  }
  if (next.outcome !== "ongoing") return next;

  applyQuestConsequences(next);
  clearDailyQuest(next);
  processNight(next);
  checkOutcome(next);
  if (next.outcome !== "ongoing") {
    next.lastMessage = `Derrota no dia ${next.day}: ${next.reason}.`;
    return next;
  }
  if (next.day >= 10) {
    next.outcome = "victory";
    next.reason = "chegada a Marte";
    next.lastMessage = "Vitória: a nave chegou a Marte.";
    return next;
  }
  next.questCompleted = false;
  next.day++;
  next.lastMessage = `Dia ${next.day} iniciado.`;
  return next;
}

export function reduce(state, action) {
  switch (action.type) {
    case "begin": return beginDay(state);
    case "choose_preventive": return choosePreventive(state, action.id);
    case "accept_preventive": return acceptPreventive(state);
    case "choose_solution": return chooseSolution(state, action.id);
    case "collect": return collectQuestObject(state);
    case "deliver": return deliverQuest(state);
    case "rescue": return rescue(state);
    case "sleep": return sleep(state);
    default: {
      const next = copyState(state);
      next.lastMessage = "Ação desconhecida.";
      return next;
    }
  }
}

function completeQuest(state) {
  return reduce(reduce(state, { type: "collect" }), { type: "deliver" });
}

function resourcePressure(resource, resources) {
  const daily = DAILY_CONSUMPTION[resource];
  if (!daily) return resources[resource] === 0 ? 1 : 0;
  return (MAX_RESOURCE - resources[resource]) / daily;
}

function chooseMostPressuredOffer(offers, resources) {
  return [...offers].sort((left, right) =>
    resourcePressure(right.resource, resources) - resourcePressure(left.resource, resources),
  )[0] ?? null;
}

function feasibleSolution(state, problemId, preference = "balanced") {
  const options = PROBLEMS[problemId].solutions;
  const feasible = options.filter((option) => canPay(state, option.cost));
  if (feasible.length === 0) return options[0];
  if (preference === "parts-first") {
    return feasible.find((option) => option.cost.parts) ?? feasible[0];
  }
  if (preference === "resource-first") {
    return [...feasible].sort((left, right) => {
      const leftCost = Object.entries(left.cost)
        .reduce((sum, [resource, amount]) => sum + amount / Math.max(1, state.resources[resource]), 0);
      const rightCost = Object.entries(right.cost)
        .reduce((sum, [resource, amount]) => sum + amount / Math.max(1, state.resources[resource]), 0);
      return leftCost - rightCost;
    })[0];
  }
  return [...feasible].sort((left, right) => {
    const leftRemaining = Math.min(...Object.entries(left.cost)
      .map(([resource, amount]) => state.resources[resource] - amount));
    const rightRemaining = Math.min(...Object.entries(right.cost)
      .map(([resource, amount]) => state.resources[resource] - amount));
    return rightRemaining - leftRemaining;
  })[0];
}

function runStrategy(strategy, incidentSequence = DEFAULT_INCIDENT_SEQUENCE) {
  let state = initialState(incidentSequence);
  const messages = [];
  while (state.outcome === "ongoing") {
    state = reduce(state, { type: "begin" });
    messages.push(`D${state.day}: ${state.lastMessage}`);

    if (state.pendingIncident) {
      const option = strategy.chooseSolution(state, state.pendingIncident.id);
      if (option) state = reduce(state, { type: "choose_solution", id: option.id });
      if (strategy.completeIncident(state)) state = completeQuest(state);
    } else if (state.risk && strategy.rescue(state)) {
      state = reduce(state, { type: "rescue" });
    } else {
      const retry = strategy.chooseRetry(state, state.retrySolutions);
      if (retry) {
        state = reduce(state, { type: "choose_solution", id: retry.id });
        if (strategy.completeIncident(state)) state = completeQuest(state);
      } else {
        const selected = strategy.choosePreventive(state, state.dailyOffers);
        if (selected) {
          state = reduce(state, { type: "choose_preventive", id: selected.id });
          state = reduce(state, { type: "accept_preventive" });
          if (strategy.completePreventive(state)) state = completeQuest(state);
        }
      }
    }

    state = reduce(state, { type: "sleep" });
    messages.push(`D${state.day}: ${state.lastMessage}`);
  }
  return { state, messages };
}

const COMPLETE_QUESTS = Object.freeze({
  chooseRetry: (state, retries) => retries[0] ?? null,
  completeIncident: () => true,
  completePreventive: () => true,
  rescue: () => true,
});

const STRATEGIES = Object.freeze({
  balanced: {
    title: "Triagem equilibrada",
    chooseSolution(state, problemId) {
      return feasibleSolution(state, problemId, "resource-first");
    },
    choosePreventive(state, offers) {
      return chooseMostPressuredOffer(offers, state.resources);
    },
    ...COMPLETE_QUESTS,
  },
  partsFirst: {
    title: "Reserva de peças",
    chooseSolution(state, problemId) {
      return feasibleSolution(state, problemId, "parts-first");
    },
    choosePreventive(state, offers) {
      return offers.find((order) => order.resource === "parts")
        ?? chooseMostPressuredOffer(offers, state.resources);
    },
    ...COMPLETE_QUESTS,
  },
  riskFirst: {
    title: "Proteção da tripulação",
    chooseSolution(state, problemId) {
      return feasibleSolution(state, problemId, "parts-first");
    },
    choosePreventive(state, offers) {
      return chooseMostPressuredOffer(offers, state.resources);
    },
    ...COMPLETE_QUESTS,
  },
  omission: {
    title: "Omissão",
    chooseSolution: (state, problemId) => PROBLEMS[problemId].solutions[0],
    chooseRetry: () => null,
    choosePreventive: () => null,
    completeIncident: () => false,
    completePreventive: () => false,
    rescue: () => false,
  },
});

function compactResources(resources) {
  return `E${resources.energy} O${resources.oxygen} A${resources.water} C${resources.food} M${resources.morale} P${resources.parts}`;
}
const RESOURCE_LABELS = Object.freeze({
  energy: "energia", oxygen: "oxigênio", water: "água",
  food: "comida", morale: "moral", parts: "peças",
});

function formatCost(cost) {
  return Object.entries(cost)
    .map(([resource, amount]) => `-${amount} ${RESOURCE_LABELS[resource]}`)
    .join(" e ");
}

function formatPreventiveOffer(order) {
  return `${order.id} ${order.title} | RESPONSÁVEL: ${order.responsible} | OBJETO: ${order.object}`
    + ` | COLETA: ${order.origin} | ENTREGA: ${order.destination}`
    + ` | RECOMPENSA: +${order.reward} ${RESOURCE_LABELS[order.resource]}`
    + ` | SE FALHAR: -${order.failure} ${RESOURCE_LABELS[order.resource]}`;
}

function formatSolutionOption(problem, option, deadline = problem.deadline) {
  const failure = `${problem.loss.perDay} ${RESOURCE_LABELS[problem.loss.resource]}/dia; prazo ${deadline}; ${problem.crisis.text}`;
  return `${option.id} | RESPONSÁVEL: ${option.responsible} | OBJETO: ${option.object}`
    + ` | CUSTO: ${formatCost(option.cost)} | COLETA: ${option.origin}`
    + ` | ENTREGA: ${option.destination} | RESULTADO: ${option.result}`
    + ` | SE FALHAR: -${failure}`;
}

function orderedSelections(items, length, prefix = []) {
  if (prefix.length === length) return [prefix];
  const remaining = items.filter((item) => !prefix.includes(item));
  return remaining.flatMap((item) => orderedSelections(items, length, [...prefix, item]));
}

function preventiveComparison() {
  let accepted = initialState(DEFAULT_INCIDENT_SEQUENCE);
  accepted = reduce(accepted, { type: "begin" });
  accepted = reduce(accepted, { type: "choose_preventive", id: "V-01" });
  accepted = reduce(accepted, { type: "accept_preventive" });
  accepted = reduce(accepted, { type: "sleep" });

  let ignored = initialState(DEFAULT_INCIDENT_SEQUENCE);
  ignored = reduce(ignored, { type: "begin" });
  ignored = reduce(ignored, { type: "sleep" });

  let completed = initialState(DEFAULT_INCIDENT_SEQUENCE);
  completed = reduce(completed, { type: "begin" });
  completed = reduce(completed, { type: "choose_preventive", id: "V-01" });
  completed = reduce(completed, { type: "accept_preventive" });
  completed = completeQuest(completed);
  completed = reduce(completed, { type: "sleep" });

  return { accepted, ignored, completed };
}

function riskScenario() {
  let state = initialState(["food", "power", "hull", "communications", "conflict"]);
  const strategy = STRATEGIES.riskFirst;
  while (state.outcome === "ongoing") {
    state = reduce(state, { type: "begin" });
    if (state.pendingIncident) {
      const option = strategy.chooseSolution(state, state.pendingIncident.id);
      state = reduce(state, { type: "choose_solution", id: option.id });
      if (state.day !== 2) state = completeQuest(state);
    } else if (state.risk) {
      state = reduce(state, { type: "rescue" });
      return state;
    } else {
      const offer = strategy.choosePreventive(state, state.dailyOffers);
      if (offer) {
        state = reduce(state, { type: "choose_preventive", id: offer.id });
        state = reduce(state, { type: "accept_preventive" });
        state = completeQuest(state);
      }
    }
    state = reduce(state, { type: "sleep" });
  }
  return state;
}

function nearLimitScenario() {
  let state = initialState(DEFAULT_INCIDENT_SEQUENCE);
  state.resources.energy = 8;
  state.resources.oxygen = 12;
  state.resources.morale = 10;
  state.resources.parts = 0;
  state = reduce(state, { type: "begin" });
  state = reduce(state, { type: "choose_preventive", id: "V-01" });
  state = reduce(state, { type: "accept_preventive" });
  state = completeQuest(state);
  state = reduce(state, { type: "sleep" });
  state = reduce(state, { type: "begin" });
  state = reduce(state, { type: "choose_solution", id: "ENG-B" });
  state = reduce(state, { type: "collect" });
  const beforeDelivery = copyState(state);
  const attempted = reduce(state, { type: "deliver" });
  const afterSleep = reduce(attempted, { type: "sleep" });
  return { state: afterSleep, beforeDelivery, attempted };
}

function checkPoolInvariants() {
  for (const day of NON_INCIDENT_DAYS) {
    const offers = selectPreventiveOffers(day, Object.fromEntries(SURVIVORS.map((name) => [name, true])));
    if (offers.length !== 2) return false;
    if (new Set(offers.map((order) => order.resource)).size !== 2) return false;
    if (offers.some((order) => !order.reward || !order.failure)) return false;
  }
  const oneAlive = Object.fromEntries(SURVIVORS.map((name) => [name, name === "Bento"]));
  return selectPreventiveOffers(3, oneAlive).length === 2;
}

function checkNonDominance() {
  for (const pair of PREVENTIVE_PAIRS) {
    const offers = pair.map((id) => PREVENTIVE_BY_ID[id]);
    const firstResource = offers[0].resource;
    const secondResource = offers[1].resource;
    const firstLow = firstResource === "parts" ? 0 : 20;
    const firstHigh = firstResource === "parts" ? 1 : 80;
    const secondLow = secondResource === "parts" ? 0 : 10;
    const secondHigh = secondResource === "parts"
      ? 5 : firstResource === "parts" ? 100 : 80;
    const firstState = {
      ...INITIAL_RESOURCES, [firstResource]: firstLow, [secondResource]: secondHigh,
    };
    const secondState = {
      ...INITIAL_RESOURCES, [firstResource]: firstHigh, [secondResource]: secondLow,
    };
    if (chooseMostPressuredOffer(offers, firstState).id !== offers[0].id) return false;
    if (chooseMostPressuredOffer(offers, secondState).id !== offers[1].id) return false;
  }
  return true;
}

function printSimulation(title, result) {
  const state = result.state ?? result;
  const alive = Object.values(state.alive).filter(Boolean).length;
  console.log(`- ${title}: ${state.outcome.toUpperCase()} (${state.reason})`);
  console.log(`  recursos ${compactResources(state.resources)} | vivos ${alive}`);
  console.log(`  incidentes ${state.incidentsSeen.map((entry) => `${entry.day}:${entry.id}`).join(",") || "nenhum"}`
    + ` | quests ${state.questHistory.length} | crises ${state.crises.length}`);
}

export function simulateAll() {
  console.log("BALANCEAMENTO DO CICLO DE QUESTS — ISSUE #26");
  console.log(`estoque inicial: ${compactResources(INITIAL_RESOURCES)}`);
  console.log(`consumo diário: ${compactResources({ ...DAILY_CONSUMPTION, parts: 0 })}`);

  const balanced = runStrategy(STRATEGIES.balanced);
  const partsFirst = runStrategy(STRATEGIES.partsFirst);
  const riskFirst = runStrategy(STRATEGIES.riskFirst, [
    "food", "power", "hull", "communications", "conflict",
  ]);
  const omission = runStrategy(STRATEGIES.omission, [
    "engine", "food", "conflict", "hull", "lifeSupport",
  ]);
  const comparison = preventiveComparison();
  const risk = riskScenario();
  const nearLimit = nearLimitScenario();

  console.log("\nCENÁRIOS REPRESENTATIVOS");
  printSimulation("triagem equilibrada", balanced);
  printSimulation("reserva de peças", partsFirst);
  printSimulation("proteção da tripulação", riskFirst);
  printSimulation("omissão", omission);
  console.log(`- preventiva aceita e não concluída: moral ${comparison.accepted.resources.morale}`);
  console.log(`- nenhuma preventiva aceita: moral ${comparison.ignored.resources.morale}`);
  console.log(`- preventiva concluída: moral ${comparison.completed.resources.morale}`);
  console.log(`- risco individual: ${risk.risk ? "ativo" : "resolvido"}; vivos ${Object.values(risk.alive).filter(Boolean).length}`);
  console.log(`- recursos próximos do limite: ${nearLimit.state.outcome.toUpperCase()} (${compactResources(nearLimit.state.resources)})`);
  console.log(`- tentativa inviável perto do limite: ${nearLimit.attempted.lastMessage}`);

  const allSequences = orderedSelections(PROBLEM_IDS, INCIDENT_DAYS.length);
  const robustWins = allSequences.filter((sequence) =>
    runStrategy(STRATEGIES.partsFirst, sequence).state.outcome === "victory").length;
  const checks = [
    ["preventiva concluída supera dormir", comparison.completed.resources.morale > comparison.ignored.resources.morale],
    ["negligência supera falha após aceitar", comparison.ignored.resources.morale < comparison.accepted.resources.morale],
    ["mais de uma estratégia vence", balanced.state.outcome === "victory"
      && partsFirst.state.outcome === "victory" && riskFirst.state.outcome === "victory"],
    ["omissão perde", omission.state.outcome === "defeat"],
    ["pool mantém duas ofertas distintas", checkPoolInvariants()],
    ["pool alterna a escolha conforme o recurso", checkNonDominance()],
    ["custos urgentes estão definidos", Object.values(PROBLEMS).every((problem) =>
      problem.solutions.every((option) => Object.keys(option.cost).length === 1
        && Object.values(option.cost)[0] > 0))],
    ["risco individual pode ser socorrido", risk.risk === null
      && risk.deaths.length === 0 && risk.riskHistory.length > 0],
    ["limite recusa custo sem overdraft", nearLimit.attempted.lastMessage.includes("insuficientes")
      && nearLimit.attempted.resources.energy === nearLimit.beforeDelivery.resources.energy],
    ["reserva de peças vence as 2.520 sequências", robustWins === allSequences.length],
  ];

  console.log(`\nROBUSTEZ: reserva de peças venceu ${robustWins}/${allSequences.length} sequências.`);
  console.log("\nCRITÉRIOS");
  for (const [label, passed] of checks) console.log(`- ${label}: ${passed ? "OK" : "FALHOU"}`);
  const passed = checks.every(([, value]) => value);
  console.log(`\nBALANCE CHECK: ${passed ? "PASS" : "FAIL"}`);
  if (!passed) process.exitCode = 1;
  return { checks, balanced, partsFirst, riskFirst, omission, comparison, risk, nearLimit, robustWins };
}

function renderState(state) {
  if (output.isTTY) console.clear();
  console.log("\nPROTÓTIPO DE BALANCEAMENTO — ISSUE #26");
  console.log(`Dia ${state.day}/10 | Estado ${state.outcome}`);
  console.log(`Recursos ${compactResources(state.resources)}`);
  console.log(`Vivos ${SURVIVORS.filter((name) => state.alive[name]).join(", ") || "nenhum"}`);
  console.log(`Problemas ${state.activeProblems.map((problem) => `${problem.id}:${problem.deadline}`).join(", ") || "nenhum"}`);
  console.log(`Risco ${state.risk ? `${state.risk.name}:${state.risk.deadline}` : "nenhum"}`);
  if (state.pendingIncident) {
    const problem = PROBLEMS[state.pendingIncident.id];
    console.log(`INCIDENTE: ${problem.name}`);
    for (const option of problem.solutions) console.log(`  ${formatSolutionOption(problem, option)}`);
  } else {
    if (state.dailyOffers.length > 0) {
      console.log("ORDENS PREVENTIVAS:");
      for (const order of state.dailyOffers) console.log(`  ${formatPreventiveOffer(order)}`);
    }
    if (state.retrySolutions.length > 0) {
      console.log("RETOMADAS DE SOLUÇÕES:");
      for (const option of state.retrySolutions) {
        console.log(`  ${formatSolutionOption(PROBLEMS[option.problemId], option, option.deadline)}`);
      }
    }
  }
  console.log(`Quest ${state.acceptedQuest ? `${state.acceptedQuest.id}:${state.acceptedQuest.stage}` : "nenhuma"}`);
  console.log(state.lastMessage);
  console.log("\n[escolher ID] [solução ID] [aceitar] [coletar] [entregar] [socorrer] [dormir] [estado] [sair]");
}

async function interactive() {
  const terminal = readline.createInterface({ input, output });
  let state = reduce(initialState(), { type: "begin" });
  while (state.outcome === "ongoing") {
    renderState(state);
    const line = (await terminal.question("> ")).trim();
    const [command, ...rest] = line.split(/\s+/);
    const value = rest.join(" ");
    if (command === "sair") break;
    if (command === "escolher") state = reduce(state, { type: "choose_preventive", id: value });
    else if (command === "aceitar") state = reduce(state, { type: "accept_preventive" });
    else if (command === "coletar") state = reduce(state, { type: "collect" });
    else if (command === "entregar") state = reduce(state, { type: "deliver" });
    else if (command === "socorrer") state = reduce(state, { type: "rescue" });
    else if (command === "dormir") state = reduce(state, { type: "sleep" });
    else if (command === "estado") continue;
    else if (command === "solução" || command === "solucao") state = reduce(state, { type: "choose_solution", id: value });
    else state = reduce(state, { type: "unknown" });
    if (state.outcome === "ongoing" && state.day > 1 && !state.pendingIncident
      && state.dailyOffers.length === 0 && !state.acceptedQuest && !state.questCompleted) {
      state = reduce(state, { type: "begin" });
    }
  }
  renderState(state);
  terminal.close();
}

const isMain = process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;
if (isMain && process.argv.includes("--simulate")) simulateAll();
else if (isMain) await interactive();
