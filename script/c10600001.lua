--Spellbook Librarian of Prophecy
--Scripted by GuiiZ

local s,id=GetID()

function s.initial_effect(c)
	--Special Summon from hand
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
		e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Send 1 "Porphecy" monster from your Deck to your GY
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetCategory(CATEGORY_TOGRAVE)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCountLimit(1,{id,0})
		e2:SetTarget(s.tg)
		e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Banish to GY to add 1 "Prophecy" Monster from your GY
	local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,1))
		e4:SetCategory(CATEGORY_TOHAND)
		e4:SetType(EFFECT_TYPE_IGNITION)
		e4:SetRange(LOCATION_GRAVE)
		e4:SetCountLimit(1,{id,1})
		e4:SetCost(aux.bfgcost)
		e4:SetTarget(s.thtg)
		e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

s.listed_series={0x6e}

--Special Summon from Hand (If you control an Spellcaster monster)
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,1,nil)
end

--Send 1 "Porphecy" Monster to the GY
function s.filter(c)
	return c:IsSetCard(0x6e) and c:IsMonster() and c:IsAbleToGrave()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK|LOCATION_HAND)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
end

--Add 1 "Prophecy" Monster from your GY to your Hand
function s.thfilter(c)
	return  c:GetLevel()>0 and c:IsSetCard(0x6e) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then	
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				local sg=g:GetFirst()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
				if not g:GetFirst():IsLocation(LOCATION_HAND) then 
					return
				end
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
						return 
				end
				--Normal Summon if is Level 4 or lower
				if sg:GetLevel()<=4 then
					if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
						Duel.BreakEffect()
						local sg=g:GetFirst()
						Duel.Summon(tp,sg,true,nil)
					end
				else
				--Special Summon if is Level 5 or higher
					if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
						local sg=g:GetFirst(tp,1,1,nil)
						Duel.BreakEffect()	
						Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
end
