--!strict
return function(Builder,Anomalies,Rules)
	local count=0
	local function check(condition,message) count+=1 assert(condition,message) end
	local room=Builder.build()
	local ok,problem=pcall(function()
		check(room.model.Parent==nil,"Builder must return a detached room")
		check(#room.items>=20,"At least 20 recognizable objects required")
		local saved=Anomalies.capture(room)
		local function unchanged()
			for _,s in saved do
				local p=s.object
				if p:IsA("BasePart") then
					check((p.Position-s.cf.Position).Magnitude<0.001,"Object failed to reset position")
					check((p.Size-s.size).Magnitude<0.001,"Object failed to reset size")
					check(p.Color==s.color and p.Transparency==s.transparency and p.CanCollide==s.collide,"Object failed to reset appearance")
					check((p.CFrame.RightVector-s.cf.RightVector).Magnitude<0.001,"Object failed to reset rotation")
				else check(p.Color==s.color and p.Enabled==s.enabled,"Light failed to reset") end
			end
		end
		for difficulty=1,3 do
			for _,kind in Anomalies.kinds do
				local answer=Anomalies.apply(room,kind,difficulty)
				check(answer.changed and #answer.targets>0,"Changed rounds must reveal a target")
				local changed=false
				for _,s in saved do
					local p=s.object
					if p:IsA("BasePart") and (p.CFrame~=s.cf or p.Color~=s.color or p.Size~=s.size or p.Transparency~=s.transparency) then changed=true end
				end
				check(changed,"Anomaly did not change visible geometry: "..kind)
				Anomalies.restore(saved) unchanged()
			end
		end
		local answer=Anomalies.apply(room,"None",1)
		check(not answer.changed and #answer.targets==0,"Unchanged round must not have targets") unchanged()
		local p=Rules.profile() p.eligibleRound=7
		check(not Rules.vote(p,7,true,"Memorize",7,0,10),"Reject early votes")
		check(not Rules.vote(p,6,true,"Vote",7,0,10),"Reject stale round")
		check(not Rules.vote(p,7,1,"Vote",7,0,10),"Reject non-boolean vote")
		check(not Rules.vote(p,7,true,"Vote",7,10,10),"Reject deadline vote")
		local spectator=Rules.profile()
		check(not Rules.vote(spectator,7,true,"Vote",7,0,10),"Reject late spectator")
		check(Rules.vote(p,7,true,"Vote",7,0,10),"Valid vote rejected")
		check(not Rules.vote(p,7,false,"Vote",7,1,10),"Reject duplicate vote")
		check(p.vote==true,"Duplicate changed original answer")
		local tuning={CorrectPoints=100,CorrectCoins=10}
		local result=Rules.reward(p,true,tuning)
		check(result.correct and p.score==100 and p.coins==12 and p.streak==1,"Correct reward mismatch")
		p.vote=false result=Rules.reward(p,true,tuning)
		check(not result.correct and p.score==100 and p.streak==0 and p.bestStreak==1,"Wrong answer reward mismatch")
		p.vote=nil p.streak=4 result=Rules.reward(p,false,tuning)
		check(result.status=="MISSED" and p.streak==0,"Timeout must break streak")
		p.vote=false result=Rules.reward(p,false,tuning)
		check(result.correct,"Unchanged vote must score correctly")
		check(spectator.score==0 and spectator.coins==0,"Player records must be independent")
	end)
	room.model:Destroy()
	assert(ok,problem)
	return string.format("%d checks passed: 27 anomalies/reset cycles, unchanged baseline, vote validation, scoring, streaks, isolation",count)
end
