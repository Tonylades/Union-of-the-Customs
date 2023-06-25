local s,id=GetID()
function s.initial_effect(c)
   --Reveal 3 "Monarch" Card from your Deck
   local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MONARCH}
--(e1)
function s.spfilter1(c,tp)
   return c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.thfilter(c)
	return c:IsSetCard(SET_MONARCH) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		e:SetLabelObject(g:GetFirst())
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
	        if e:GetLabelObject():CardIsType(TYPE_MONSTER) then
	        local e2=Effect.CreateEffect(c)
	        e2:SetCategory(CATEGORY_SPSUMMON_PROC)
	        e2:SetType(EFFECT_TYPE_FIELD)
	        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	        e2:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	        e2:SetTarget(aux.TargetBoolFunction(Card.IsMonster,Card.IsAbleToRemoveAsCost,Card.IsLocation(LOCATION_GRAVE)))
	        e2:SetReset(RESET_ENDMAIN)
	        c:RegisterEffect(e2)
	       end
	    end
	end
end