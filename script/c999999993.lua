local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Add this card from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
s.listed_names={999999991}
--(1)
function s.filter(c,e,tp)
	return c:IsCode(999999991)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
      local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=rg:Select(tp,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
end
--(2)
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
				Duel.SendtoDeck(c,tp,LOCATION_DECKBOT,REASON_EFFECT)
	end
end