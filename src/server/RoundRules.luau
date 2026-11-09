--!strict
-- Pure rules shared by real player votes and repeatable validation.
local Rules = {}
function Rules.vote(entry, roundId, choice, phase, currentRound, now, deadline)
	if typeof(roundId)~="number" or roundId~=currentRound or roundId%1~=0 then return false,"Stale round" end
	if typeof(choice)~="boolean" then return false,"Invalid vote" end
	if phase~="Vote" or now>=deadline then return false,"Voting is closed" end
	if entry.eligibleRound~=currentRound then return false,"Watching this round" end
	if entry.vote~=nil then return false,"Already voted" end
	entry.vote=choice
	return true,"Vote locked"
end
function Rules.reward(entry, changed: boolean, tuning)
	local result={ correct=false, status="MISSED", points=0, coins=0 }
	if entry.vote==nil then entry.streak=0 return result end
	result.correct=entry.vote==changed
	if not result.correct then entry.streak=0 result.status="INCORRECT" return result end
	entry.streak+=1
	entry.bestStreak=math.max(entry.bestStreak,entry.streak)
	entry.totalCorrect+=1
	result.status="CORRECT"
	result.points=tuning.CorrectPoints+math.min(entry.streak-1,10)*10
	result.coins=tuning.CorrectCoins+math.min(entry.streak,10)*2
	if entry.streak%5==0 then result.coins+=25 end
	entry.score+=result.points entry.coins+=result.coins entry.lifetimeCoins+=result.coins
	entry.xp+=25
	return result
end
function Rules.profile()
	return { score=0,coins=0,lifetimeCoins=0,xp=0,streak=0,bestStreak=0,totalCorrect=0,eligibleRound=0,vote=nil,result=nil }
end
return Rules
