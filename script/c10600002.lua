--Merlin, the Last Prophesser
--Scripted by GuiiZ

local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	--Control limit
	c:SetUniqueOnField(1,0,id)
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,4,s.lcheck)
	--Set original ATK
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Gains effects
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_PROPHECY,SET_SPELLBOOK}
s.listed_names={33981008}	

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_PROPHECY,lc,sumtype,tp)
end

function s.filter(c)
	return c:IsSetCard(SET_SPELLBOOK) and c:IsSpell()
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE|LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)<0 end
	--Set original ATK
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(g:GetClassCount(Card.GetCode)*600)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE|LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)<=0 end
	
	--Place "The Grand Spellbook Tower" face-up in your Field Zone
	if g:GetClassCount(Card.GetCode)>=2 then
		local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1,{id,0})
			e1:SetTarget(s.pltg)
			e1:SetOperation(s.plop)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	--Send 1 card your opponent controls to the GY
	if g:GetClassCount(Card.GetCode)>=3 then
		local e2=Effect.CreateEffect(c)
			e2:SetCategory(CATEGORY_TOGRAVE)
			e2:SetType(EFFECT_TYPE_QUICK_O)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EVENT_CHAINING)
			e2:SetCountLimit(1,{id,1})
			e2:SetTarget(s.tgtg)
			e2:SetOperation(s.tgop)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e2)
	end
	--Cannot be targeted by your opponent's monster effects
	if g:GetClassCount(Card.GetCode)>=4 then
		local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e3:SetRange(LOCATION_MZONE)
			e3:SetValue(s.efffilter)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e3)
	end
end

function s.plfilter(c)
	return c:IsCode(33981008) and not c:IsForbidden()
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end

function s.tgfilter(c)
	return c:IsSetCard(SET_SPELLBOOK) and c:IsSpell() and c:IsAbleToRemove()
end
	
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) 
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_GRAVE|LOCATION_ONFIELD,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE|LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g2>0 then
				Duel.HintSelection(g2,true)
				Duel.SendtoGrave(g2,REASON_EFFECT)
			end
	end
end

function s.efffilter(e,re,rp)
	return rp~=e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER) 
end