--!strict
local TweenService=game:GetService("TweenService")
local UI={}
local colors={ink=Color3.fromRGB(23,28,48),purple=Color3.fromRGB(128,91,225),cyan=Color3.fromRGB(102,222,239),mint=Color3.fromRGB(119,234,188),coral=Color3.fromRGB(255,133,144),cream=Color3.fromRGB(255,240,194),white=Color3.fromRGB(239,243,255)}
local function round(object,radius)
	local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,radius) c.Parent=object
end
local function label(parent,name,text,size,color)
	local l=Instance.new("TextLabel") l.Name=name l.BackgroundTransparency=1
	l.Font=Enum.Font.GothamBold l.TextSize=size l.TextColor3=color l.Text=text
	l.TextXAlignment=Enum.TextXAlignment.Left l.TextWrapped=true l.Parent=parent return l
end
local function panel(parent,name)
	local f=Instance.new("Frame") f.Name=name f.BackgroundColor3=colors.ink f.BackgroundTransparency=0.07 f.BorderSizePixel=0 f.Parent=parent round(f,16)
	local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(89,77,131) stroke.Transparency=0.3 stroke.Parent=f
	return f
end
function UI.new(playerGui,onVote)
	local self={state=nil,profile=nil,choice=nil,roundId=-1}
	local gui=Instance.new("ScreenGui") gui.Name="TRILObservationHUD" gui.ResetOnSpawn=false gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.DisplayOrder=20 gui.Parent=playerGui
	self.gui=gui
	local header=panel(gui,"Header") header.AnchorPoint=Vector2.new(0.5,0) header.Position=UDim2.new(0.5,0,0,10)
	local limit=Instance.new("UISizeConstraint") limit.MaxSize=Vector2.new(980,120) limit.Parent=header
	local logo=label(header,"Logo","THE ROOM IS LYING",22,colors.cream) logo.Position=UDim2.fromOffset(16,8) logo.Size=UDim2.new(0.68,0,0,27)
	local phase=label(header,"Phase","CONNECTING TO THE ROOM",14,colors.cyan) phase.Position=UDim2.fromOffset(16,36) phase.Size=UDim2.new(0.75,-20,0,24)
	local timer=label(header,"Timer","--",30,colors.white) timer.AnchorPoint=Vector2.new(1,0.5) timer.Position=UDim2.new(1,-16,0.43,0) timer.Size=UDim2.fromOffset(60,44) timer.TextXAlignment=Enum.TextXAlignment.Right
	local track=Instance.new("Frame") track.Name="TimerTrack" track.BackgroundColor3=Color3.fromRGB(57,54,87) track.BorderSizePixel=0 track.Position=UDim2.new(0,16,1,-8) track.Size=UDim2.new(1,-32,0,3) track.Parent=header round(track,2)
	local fill=Instance.new("Frame") fill.Name="Fill" fill.BorderSizePixel=0 fill.BackgroundColor3=colors.cyan fill.Size=UDim2.fromScale(1,1) fill.Parent=track round(fill,2)

	local card=panel(gui,"Decision") card.AnchorPoint=Vector2.new(0.5,1) card.Position=UDim2.new(0.5,0,1,-12)
	local cardLimit=Instance.new("UISizeConstraint") cardLimit.MaxSize=Vector2.new(760,220) cardLimit.Parent=card
	local stats=label(card,"Stats","SCORE 0   /   STREAK 0   /   MIND COINS 0",13,colors.cream) stats.Position=UDim2.fromOffset(16,9) stats.Size=UDim2.new(1,-104,0,20)
	local message=label(card,"Message","Look carefully. Trust your memory.",18,colors.white) message.Position=UDim2.fromOffset(16,34) message.Size=UDim2.new(1,-32,0,27)
	local detail=label(card,"Detail","A shared observation game. One room. One truth.",13,Color3.fromRGB(185,193,218)) detail.Position=UDim2.fromOffset(16,65) detail.Size=UDim2.new(1,-32,0,36)
	local function button(name,text,color,x)
		local b=Instance.new("TextButton") b.Name=name b.Text=text b.TextSize=17 b.Font=Enum.Font.GothamBold b.TextColor3=colors.ink b.BackgroundColor3=color b.AutoButtonColor=true b.BorderSizePixel=0
		b.AnchorPoint=Vector2.new(0,1) b.Position=UDim2.new(x,if x==0 then 16 else 5,1,-12) b.Size=UDim2.new(0.5,-21,0,48) b.Parent=card round(b,12)
		return b
	end
	local changed=button("Changed","SOMETHING CHANGED",colors.purple,0) changed.TextColor3=colors.white
	local same=button("Same","NOTHING CHANGED",colors.cyan,0.5)
	local ranks=Instance.new("TextButton") ranks.Name="Ranks" ranks.Text="RANKS" ranks.Font=Enum.Font.GothamBold ranks.TextSize=12 ranks.TextColor3=colors.cyan ranks.BackgroundTransparency=1 ranks.AnchorPoint=Vector2.new(1,0) ranks.Position=UDim2.new(1,-12,0,6) ranks.Size=UDim2.fromOffset(70,24) ranks.Parent=card
	local board=panel(gui,"Leaderboard") board.AnchorPoint=Vector2.new(1,0) board.Position=UDim2.new(1,-12,0,94) board.Size=UDim2.fromOffset(300,280) board.Visible=false
	local boardTitle=label(board,"Title","SERVER LEADERBOARD",16,colors.cream) boardTitle.Position=UDim2.fromOffset(16,12) boardTitle.Size=UDim2.new(1,-32,0,24)
	local boardRows=label(board,"Rows","",14,colors.white) boardRows.Position=UDim2.fromOffset(16,48) boardRows.Size=UDim2.new(1,-32,1,-60) boardRows.TextYAlignment=Enum.TextYAlignment.Top
	local close=Instance.new("TextButton") close.Name="Close" close.Text="X" close.Font=Enum.Font.GothamBold close.TextSize=16 close.TextColor3=colors.cyan close.BackgroundTransparency=1 close.AnchorPoint=Vector2.new(1,0) close.Position=UDim2.new(1,-4,0,3) close.Size=UDim2.fromOffset(36,36) close.Parent=board
	close.Activated:Connect(function() board.Visible=false end)
	ranks.Activated:Connect(function() board.Visible=not board.Visible end)
	local blackoutGui=Instance.new("ScreenGui") blackoutGui.Name="TRILBlackout" blackoutGui.IgnoreGuiInset=true blackoutGui.ScreenInsets=Enum.ScreenInsets.None blackoutGui.ResetOnSpawn=false blackoutGui.DisplayOrder=100 blackoutGui.Parent=playerGui
	local blackout=Instance.new("Frame") blackout.Name="Curtain" blackout.Size=UDim2.fromScale(1,1) blackout.BackgroundColor3=Color3.fromRGB(8,10,20) blackout.BorderSizePixel=0 blackout.BackgroundTransparency=0 blackout.Active=true blackout.Parent=blackoutGui
	local blackoutText=label(blackout,"Whisper","DON'T TRUST THE ROOM.",22,colors.cyan) blackoutText.AnchorPoint=Vector2.new(0.5,0.5) blackoutText.Position=UDim2.fromScale(0.5,0.5) blackoutText.Size=UDim2.fromScale(0.8,0.15) blackoutText.TextXAlignment=Enum.TextXAlignment.Center
	local curtainTween=nil
	function self:cover(hidden)
		if curtainTween then curtainTween:Cancel() end
		blackout.Active=hidden
		blackoutText.TextTransparency=if hidden then 0 else 1
		curtainTween=TweenService:Create(blackout,TweenInfo.new(0.22),{BackgroundTransparency=if hidden then 0 else 1}) curtainTween:Play()
	end
	function self:layout(viewport)
		self.viewport=viewport
		local compact=viewport.Y<550
		local narrow=viewport.X<550
		local side=compact and viewport.X/viewport.Y>1.3
		self.side=side
		header.AnchorPoint=Vector2.new(if side then 1 else 0.5,0)
		header.Position=if side then UDim2.new(1,-12,0,10) else UDim2.new(0.5,0,0,10)
		header.Size=UDim2.new(0.94,0,0,if compact then 58 else 76)
		logo.TextSize=if compact or narrow then 16 else 22
		logo.Size=UDim2.new(1,-100,0,26)
		phase.Position=UDim2.fromOffset(16,if compact then 29 else 36)
		phase.TextSize=if compact or narrow then 11 else 13
		phase.Size=UDim2.new(1,-100,0,if narrow then 30 else 22)
		timer.TextSize=if compact then 26 else 32
		local voting=self.state and self.state.phase=="Vote"
		card.Size=UDim2.new(0.94,0,0,if voting then (if compact then 136 else 154) else (if compact then 102 else 124))
		stats.TextSize=if narrow then 10 else 12
		message.TextSize=if compact or narrow then 14 else 18
		message.Position=UDim2.fromOffset(16,32) message.Size=UDim2.new(1,-32,0,if narrow then 36 else 27)
		detail.Position=UDim2.fromOffset(16,if compact then 58 else 65) detail.Size=UDim2.new(1,-32,0,40) detail.TextSize=if compact then 11 else 13
		detail.Visible=not voting
		changed.TextSize=if narrow or compact then 12 else 17 same.TextSize=changed.TextSize
		changed.Size=UDim2.new(0.5,-21,0,if compact then 44 else 48) same.Size=changed.Size
		board.Size=UDim2.new(0,math.min(300,viewport.X-24),0,math.min(280,viewport.Y-140))
		card.AnchorPoint=Vector2.new(if side then 1 else 0.5,1)
		card.Position=if side then UDim2.new(1,-12,1,-12) else UDim2.new(0.5,0,1,-12)
		changed.AnchorPoint=Vector2.new(0,1) same.AnchorPoint=Vector2.new(0,1)
		changed.Position=UDim2.new(0,16,1,-12) same.Position=UDim2.new(0.5,5,1,-12)
		stats.Position=UDim2.fromOffset(16,9) stats.Size=UDim2.new(1,-104,0,20)
		if side then
			local width=if viewport.X<700 then 212 else 232
			header.Size=UDim2.fromOffset(width,70) card.Size=UDim2.fromOffset(width,if voting then 204 else 142)
			logo.TextSize=13 logo.Size=UDim2.new(1,-62,0,28)
			phase.TextSize=10 phase.Position=UDim2.fromOffset(14,33) phase.Size=UDim2.new(1,-28,0,27)
			timer.TextSize=22 timer.Size=UDim2.fromOffset(40,26) timer.Position=UDim2.new(1,-12,0,21)
			stats.Size=UDim2.new(1,-82,0,34) stats.TextSize=10
			message.Position=UDim2.fromOffset(14,46) message.Size=UDim2.new(1,-28,0,42) message.TextSize=13
			detail.Position=UDim2.fromOffset(14,90) detail.Size=UDim2.new(1,-28,0,42) detail.TextSize=11
			changed.AnchorPoint=Vector2.zero same.AnchorPoint=Vector2.zero
			changed.Position=UDim2.fromOffset(14,96) same.Position=UDim2.fromOffset(14,150)
			changed.Size=UDim2.new(1,-28,0,42) same.Size=changed.Size
		end
		local p=self.profile
		if p then stats.Text=if side then string.format("%d PTS / %d STREAK\n%d MIND COINS",p.score,p.streak,p.coins) else string.format("SCORE %d   /   STREAK %d   /   MIND COINS %d",p.score,p.streak,p.coins) end
	end
	function self:buttons()
		local s=self.state local p=self.profile
		local open=s and s.phase=="Vote" and p and p.eligible and not p.voted and self.choice==nil
		changed.Visible=s and s.phase=="Vote" or false same.Visible=changed.Visible
		for _,b in ipairs({changed,same}) do b.Active=open==true b.AutoButtonColor=open==true b.BackgroundTransparency=if open then 0 else 0.35 end
		changed.Text=if self.choice==true then "CHANGED  /  LOCKED" else "SOMETHING CHANGED"
		same.Text=if self.choice==false then "UNCHANGED  /  LOCKED" else "NOTHING CHANGED"
	end
	function self:submit(choice)
		local s=self.state local p=self.profile
		if not s or s.phase~="Vote" or not p or not p.eligible or p.voted or self.choice~=nil then return end
		if workspace:GetServerTimeNow()>=s.endsAt then return end
		self.choice=choice self:buttons() message.Text="Vote sent. Waiting for the reveal..." onVote(s.round,choice)
	end
	changed.Activated:Connect(function() self:submit(true) end)
	same.Activated:Connect(function() self:submit(false) end)
	function self:render()
		local s=self.state local p=self.profile if not s then return end
		local names={Waiting="WAITING FOR OBSERVERS",Memorize="MEMORIZE THE ROOM",Blackout="THE ROOM IS THINKING...",Vote="DID SOMETHING CHANGE?",Results="THE TRUTH IS OUT"}
		phase.Text=string.format("ROUND %02d  /  %s  /  %s",s.round,({"ROOKIE","SLEUTH","SHARP EYE"})[s.difficulty] or "ROOKIE",names[s.phase] or s.phase)
		if p then stats.Text=if self.side then string.format("%d PTS / %d STREAK\n%d MIND COINS",p.score,p.streak,p.coins) else string.format("SCORE %d   /   STREAK %d   /   MIND COINS %d",p.score,p.streak,p.coins) end
		message.Text="Look carefully. Trust your memory."
		detail.Text="Remember positions, colors, sizes, and decorations."
		if s.phase=="Memorize" then message.Text=string.format("%d seconds. A room full of little secrets.",s.duration) detail.Text="Study the scene. After the blackout, decide if anything changed." end
		if s.phase=="Vote" then message.Text=if p and p.voted then "Vote locked. Trust your first instinct." else "Same room... or a convincing lie?" end
		if p and not p.eligible and s.phase~="Waiting" then message.Text="You're watching this round." detail.Text="You'll join automatically when the next memorization begins." end
		if s.phase=="Results" and s.reveal then
			local r=p and p.result
			message.Text=if not r then "The room has revealed its secret." else if r.correct then string.format("NICE EYE!  +%d points  +%d Mind Coins",r.points,r.coins) else if r.status=="MISSED" then "TIME'S UP. A new mystery is on its way." else "The room fooled you. You'll get the next one."
			message.TextColor3=if r and r.correct then colors.mint else if r then colors.coral else colors.white
			detail.Text=s.reveal.description
		else message.TextColor3=colors.white end
		local rows={} for i,entry in ipairs(s.leaders or {}) do table.insert(rows,string.format("%d.  %s   %d pts / %d streak",i,entry.name,entry.score,entry.streak)) end
		boardRows.Text=table.concat(rows,"\n\n")
		self:buttons()
	end
	function self:roundState(state)
		local old=self.state
		if state.round~=self.roundId then self.roundId=state.round self.choice=nil end
		self.state=state
		if not old or old.phase~=state.phase then self:cover(state.phase=="Blackout" or state.phase=="Waiting") end
		self:render()
		if self.viewport then self:layout(self.viewport) end
	end
	function self:personal(profile) self.profile=profile self:render() end
	function self:tick(now)
		local s=self.state if not s then return end
		local remaining=math.max(0,s.endsAt-now)
		timer.Text=if s.phase=="Waiting" then "--" else string.format("%02d",math.ceil(remaining))
		fill.Size=UDim2.fromScale(if s.duration>0 then math.clamp(remaining/s.duration,0,1) else 0,1)
		fill.BackgroundColor3=if remaining<=3 then colors.coral else colors.cyan
	end
	function self:destroy() gui:Destroy() blackoutGui:Destroy() end
	return self
end
return UI
