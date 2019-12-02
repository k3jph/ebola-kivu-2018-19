from pyomo.environ import *

model = AbstractModel()

model.S_SI = Set(ordered = True)

model.P_REP_CASES = Param(model.S_SI)
model.P_POP = Param()

model.I = Var(model.S_SI, bounds = (0, model.P_POP), initialize = 1)
model.S = Var(model.S_SI, bounds = (0, model.P_POP), initialize = model.P_POP)
model.R = Var(model.S_SI, bounds = (0, model.P_POP), initialize = 0)
model.beta = Var(bounds = (0.05, 10000))
model.gamma = Var(bounds = (0.05, 10000))
model.eps_I = Var(model.S_SI, initialize = 0.0)

def _objective(model):
    return sum((model.eps_I[i])**2 for i in model.S_SI)

def _InfDynamics(model, i):
    if i != 1:
        return model.I[i] == (model.beta * model.S[i - 1] * model.I[i - 1]) / model.P_POP - model.I[i - 1] * model.gamma
    return Constraint.Skip

def _SusDynamics(model, i):
    if i != 1:
        return model.S[i] == model.S[i - 1] - model.I[i]
    return Constraint.Skip

def _RecDynamics(model, i):
    if i != 1:
        return model.R[i] == model.R[i - 1] + model.I[i - 1] * model.gamma
    return Constraint.Skip

def _Data(model, i):
    return model.P_REP_CASES[i] == model.I[i] + model.eps_I[i]

model.objective = Objective(rule = _objective, sense = minimize)
model.InfDynamics = Constraint(model.S_SI, rule = _InfDynamics)
model.SusDynamics = Constraint(model.S_SI, rule = _SusDynamics)
model.RecDynamics = Constraint(model.S_SI, rule = _RecDynamics)
model.Data = Constraint(model.S_SI, rule = _Data)

def pyomo_postprocess(options = None, instance = None, results = None):
    print('%2f' % value(instance.beta / instance.gamma))