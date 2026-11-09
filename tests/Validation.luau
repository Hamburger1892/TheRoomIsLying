--!strict
return function(World,Rules,Settings)
	local checks=0
	local function check(ok,message) checks+=1 assert(ok,message) end
	local p=Rules.profile()
	check(not Rules.buy(p,1000),"Insufficient funds must reject purchase")
	check(p.coins==0 and not p.ownsLens,"Failed purchase changed wallet")
	p.coins=999 check(not Rules.buy(p,1000),"999 coins cannot buy a 1000 coin lens")
	p.coins=1000 check(Rules.buy(p,1000),"Exact balance purchase rejected")
	check(p.ownsLens and p.coins==0,"Purchase must deduct exactly 1000 and grant ownership")
	p.coins=1000 check(not Rules.buy(p,1000) and p.coins==1000,"Duplicate purchase charged again")
	check(Settings.Maps.Solo.capacity==1 and Settings.Maps.Trio.capacity==3,"Map party limits incorrect")
	local m={phase="Search",round=2,endsAt=30,missing={[1]=true,[3]=true}}
	local r=Rules.record()
	check(not Rules.vote(r,1,true,m,10),"Reject stale vote")
	check(not Rules.vote(r,2,"yes",m,10),"Reject non-boolean vote")
	check(not Rules.vote(r,2,true,m,30),"Reject vote at deadline")
	check(Rules.vote(r,2,true,m,10),"Valid vote rejected")
	check(not Rules.vote(r,2,false,m,11) and r.vote==true,"Duplicate vote changed answer")
	check(Rules.find(r,1,m,12),"Finding evidence after voting must work")
	check(not Rules.find(r,1,m,13),"Duplicate evidence paid again")
	check(not Rules.find(r,2,m,13),"Present object counted as missing")
	check(Rules.find(r,3,m,14) and r.finds==2,"Multiple evidence finds should accumulate")
	local other=Rules.record() check(Rules.find(other,1,m,15),"Party members need independent evidence credit")
	p=Rules.profile() p.coins=2*Settings.FindCoins
	local reward=Rules.reward(p,r,true,Settings)
	check(reward.correct and reward.bonus==150 and reward.coins==60,"Reward breakdown mismatch")
	check(p.coins==210,"Results must not pay evidence bonuses twice")
	local wrong=Rules.record() wrong.vote=false wrong.finds=2
	reward=Rules.reward(p,wrong,true,Settings)
	check(not reward.correct and reward.coins==0 and p.coins==210 and p.streak==0,"Wrong answer corrupted independent evidence rewards")
	local unchanged=Rules.record() unchanged.vote=false
	check(Rules.reward(p,unchanged,false,Settings).correct,"Unchanged answers must score")
	local built={}
	local ok,problem=pcall(function()
		local solo=World.map("Solo",Vector3.new(0,48,0),nil) table.insert(built,solo.model)
		local trio=World.map("Trio",Vector3.new(500,48,0),nil) table.insert(built,trio.model)
		check(#solo.targets>=12,"Solo map needs 12 distinct displays")
		check(#trio.targets>=24 and #trio.targets>#solo.targets,"Manor must contain substantially more displays")
		check(trio.model.Architecture.Floor.Size.X>solo.model.Architecture.Floor.Size.X*2,"Large map is not substantially larger")
		for _,map in ipairs({solo,trio}) do
			for _,target in map.targets do
				check(target.anchor.Position.Y-map.spawn.Position.Y<2,"Display inspection is unreachable from the floor")
				check(target.prompt.MaxActivationDistance==8 and not target.prompt.Enabled,"Prompt baseline incorrect")
				check(target.anchor.Transparency==1 and not target.anchor.CanCollide,"Inspect anchors must be invisible and non-blocking")
			end
			for cycle=1,3 do
				World.hide(map,{[1]=true,[3]=true,[5]=true})
				for _,index in ipairs({1,3,5}) do for _,s in map.targets[index].saved do check(s.part.Transparency==1 and not s.part.CanCollide,"Missing object remained visible") end end
				World.reset(map)
				for _,target in map.targets do for _,s in target.saved do check(s.part.Transparency==s.transparency and s.part.CanCollide==s.collide,"Object did not reset") end end
			end
		end
		local lobby=World.lobby(nil) table.insert(built,lobby.model)
		check(lobby.shop.prompt~=nil and lobby.guide.prompt~=nil and lobby.keeper.prompt~=nil,"Lobby needs all three NPCs")
		check(lobby.spawn.Position.Y>8,"Lobby spawn must be above its floor")
	end)
	for _,model in built do model:Destroy() end
	assert(ok,problem)
	return string.format("%d checks passed: wallet purchases, votes, independent bonus finds, rewards, both maps, resets, and lobby NPCs",checks)
end
