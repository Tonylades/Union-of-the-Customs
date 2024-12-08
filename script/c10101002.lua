--Gusto Forest Paradise
--Scripted by GuiiZ

local s,id=GetID() 

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,{id,0})
		e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activation limited during Battle Phase
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetRange(LOCATION_FZONE)
		e2:SetCondition(s.actcon)
		e2:SetValue(1)
	c:RegisterEffect(e2)
	--Special Summon 1 "Gusto" monster from your GY
	local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
		e3:SetRange(LOCATION_FZONE)
		e3:SetCountLimit(1,{id,2})
		e3:SetCondition(s.spcon)
		e3:SetTarget(s.sptg)
		e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={0x10}

function s.tgfilter(c)
	return c:IsSetCard(0x10) and c:IsAbleToHand()
end

--Add 1 "Gusto" Card from your Deck to your hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler(),95) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

--Your opponent cannot activate cards or effects during the Battle Phase
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsBattlePhase()
end

--Special Summon 1 "Gusto" monster from your GY
function s.condfilter(c,e,tp)
	return c:IsPreviousSetCard(0x10) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.condfilter,1,nil,e,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not e:GetHandler():IsStatus(STATUS_CHAINING) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local dg=eg:Filter(s.condfilter,nil,e,tp):Match(Card.IsRelateToEffect,nil,e)
	if #dg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end