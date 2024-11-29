--Magnet Warrior Force
local s,id=GetID()
function s.initial_effect(c)
	 --Activate
	 local e1=Effect.CreateEffect(c)
	 e1:SetType(EFFECT_TYPE_ACTIVATE)
	 e1:SetCode(EVENT_FREE_CHAIN)
	 c:RegisterEffect(e1)
	 --indestructable
	  local e2=Effect.CreateEffect(c)
	  e2:SetType(EFFECT_TYPE_FIELD)
	  e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	  e2:SetRange(LOCATION_SZONE)
	  e2:SetTargetRange(LOCATION_MZONE,0)
	  e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2066))
	  e2:SetValue(s.indct)
	  c:RegisterEffect(e2)
	  --extra summon
	  local e3=Effect.CreateEffect(c)
	  e3:SetDescription(aux.Stringid(id,0))
	  e3:SetType(EFFECT_TYPE_IGNITION)
	  e3:SetRange(LOCATION_SZONE)
	  e3:SetCountLimit(1)
	  e3:SetCondition(s.sumcon)
	  e3:SetCost(s.sumcost)
	  e3:SetTarget(s.sumtg)
	  e3:SetOperation(s.sumop)
	  c:RegisterEffect(e3)
end
s.listed_series={0x2066}
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	 return Duel.IsPlayerCanAdditionalSummon(tp)
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return Duel.CheckLPCost(tp,500) end
	 Duel.PayLPCost(tp,500)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return Duel.IsPlayerCanSummon(tp) end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	 if not e:GetHandler():IsRelateToEffect(e) then return end
	 local e1=Effect.CreateEffect(e:GetHandler())
	 e1:SetType(EFFECT_TYPE_FIELD)
	 e1:SetDescription(aux.Stringid(id,2))
	 e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	 e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	 e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2066))
	 e1:SetReset(RESET_PHASE+PHASE_END)
	 Duel.RegisterEffect(e1,tp)
	 end
function s.indct(e,re,r,rp)
	 if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		  return 1
	 else
		  return 0
	 end
end
function s.tfcond(e,tp,eg,ep,ev,re,r,rp)
	 return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x2066),tp,LOCATION_MZONE,0,1,nil) and Duel.GetTurnPlayer()==tp
end