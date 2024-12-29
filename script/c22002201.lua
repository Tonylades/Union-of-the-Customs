--Triamid Artisan
--Scripted by GuiiZ

local s,id=GetID()

function s.initial_effect(c)
	--Add 1 "Trimaid" Spell/Trap from your Deck
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetTarget(s.thtg)
		e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Replace a Field Spell
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_MZONE)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetCountLimit(1)
		e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
		e2:SetTarget(s.target)
		e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

s.listed_series={SET_TRIAMID}

function s.filter(c)
	return c:IsSetCard(SET_TRIAMID) and c:IsSpellTrap() and c:IsAbleToHand() and not c:IsForbidden()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(SET_TRIAMID) and tc:IsAbleToGrave() and tc:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp,tc:GetCode()) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local fc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp,tc:GetCode()):GetFirst()
		Duel.ActivateFieldSpell(fc,e,tp,eg,ep,ev,re,r,rp)
	end
end