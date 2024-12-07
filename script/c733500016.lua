--リターナブル瓶
--Redeemable Jar
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,fusfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),extraop=s.extraop,matfilter=s.matfil,extratg=s.extratg}
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_names{50383626}
--(Fusion Summon)
function s.matfil(c,e,tp,chk)
	return c:IsOnField() and c:IsReleasable(e) and not c:IsImmuneToEffect(e)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil,e,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,2,tp,LOCATION_ONFIELD)
end
function s.extraop(e,tc,tp,sg)
	local res=Duel.Release(sg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)==#sg
	sg:Clear()
	return res
end
--(2)
function s.handcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,50383626),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end