--!strict
local Rules={}
function Rules.profile()
	return {coins=0,score=0,streak=0,bestStreak=0,totalCorrect=0,foundTotal=0,xp=0,ownsLens=false}
end
function Rules.buy(profile,price)
	if profile.ownsLens then return false,"You already own the Truth Lens." end
	if profile.coins<price then return false,string.format("You need %d more Mind Coins.",price-profile.coins) end
	profile.coins-=price profile.ownsLens=true
	return true,"The Truth Lens is yours. It can reveal one answer each round."
end
function Rules.vote(record,roundId,choice,match,now)
	if typeof(roundId)~="number" or roundId~=match.round then return false end
	if typeof(choice)~="boolean" or match.phase~="Search" or now>=match.endsAt then return false end
	if record.vote~=nil then return false end
	record.vote=choice return true
end
function Rules.find(record,index,match,now)
	if match.phase~="Search" or now>=match.endsAt then return false,"Study the room first." end
	if not match.missing[index] then return false,"This object is still here. Keep looking." end
	if record.found[index] then return false,"You already documented this disappearance." end
	record.found[index]=true record.finds+=1 return true,"Evidence documented."
end
function Rules.reward(profile,record,changed,settings)
	local correct=record.vote~=nil and record.vote==changed
	local coins=0
	if correct then
		profile.streak+=1 profile.bestStreak=math.max(profile.bestStreak,profile.streak)
		profile.totalCorrect+=1 profile.score+=100+math.min(profile.streak-1,10)*10 profile.xp+=25
		coins=settings.CorrectCoins+math.min(profile.streak-1,10)*10 profile.coins+=coins
	else profile.streak=0 end
	return {correct=correct,missed=record.vote==nil,coins=coins,finds=record.finds,bonus=record.finds*settings.FindCoins}
end
function Rules.record() return {vote=nil,found={},finds=0,lensUsed=false} end
return Rules
