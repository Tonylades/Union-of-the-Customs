local s,id=GetID()
function s.initial_effect(c)
    --Target 1 Kozmo Monster and apply one effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsSetCard(0xd2) and c:IsMonster()
end
function s.rescon(sg,e,tp,mg)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(rg,e,tp,1,1,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	e:SetLabel(g:GetFirst():GetRace())
	Duel.SetPossibleOperationInfo(s.kozstfilter,0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(s.kozmonfilter,0,CATEGORY_DESTROY+CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.kozstfilter(c,e)
    return c:IsSetCard(0xd2) and c:IsSpell() or c:IsTrap()
function s.kozmonfilter(c,e)
    return c:IsSetCard(0xd2) and c:IsMonster() and c:IsFaceUp()
function s.activate(e,tp,eg,ep,sg)
   local c=Duel.GetFirstTarget()
   local c:Duel.GetRace()
   if c:IsRace(RACE_PSYCHIC) then
      Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	  local sg=Duel.SelectMatchingCard(tp,s.kozstfilter,tp,LOCATION_DECK,0,1,1,nil)
	  end
   if c:IsRace(RACE_MACHINE) then
      Duel.SetOperationInfo(tp,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
      Duel.SetOperationInfo(tp,s.kozmonfilter,tp,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
      end
end