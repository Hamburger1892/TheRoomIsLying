--!strict
local Tween=game:GetService("TweenService")
local Interface={}
local C={ink=Color3.fromRGB(15,20,28),gold=Color3.fromRGB(220,186,117),cream=Color3.fromRGB(239,232,211),muted=Color3.fromRGB(164,173,184),mint=Color3.fromRGB(130,218,193),red=Color3.fromRGB(209,119,122)}
local function corners(o,n) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,n) c.Parent=o end
local function text(parent,name,content,size,color)
	local l=Instance.new("TextLabel") l.Name=name l.BackgroundTransparency=1 l.Font=Enum.Font.Gotham l.Text=content l.TextColor3=color or C.cream l.TextSize=size l.TextWrapped=true l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=parent return l
end
local function panel(parent,name)
	local f=Instance.new("Frame") f.Name=name f.BackgroundColor3=C.ink f.BackgroundTransparency=0.1 f.BorderSizePixel=0 f.Parent=parent corners(f,10)
	local s=Instance.new("UIStroke") s.Color=C.gold s.Transparency=0.65 s.Thickness=1 s.Parent=f return f
end
local function button(parent,name,content,color)
	local b=Instance.new("TextButton") b.Name=name b.Font=Enum.Font.GothamBold b.Text=content b.TextSize=16 b.TextWrapped=true b.TextColor3=if color then C.ink else C.cream b.BackgroundColor3=color or Color3.fromRGB(44,48,58) b.BorderSizePixel=0 b.Parent=parent corners(b,8) return b
end
function Interface.new(playerGui,settings,send,onLight)
	local self={state=nil,choice=nil,lastRound="",modal=nil,viewport=Vector2.new(1280,720)}
	local gui=Instance.new("ScreenGui") gui.Name="TRILHorrorUI" gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.ResetOnSpawn=false gui.DisplayOrder=30 gui.Parent=playerGui self.gui=gui
	local header=panel(gui,"Header") header.AnchorPoint=Vector2.new(0.5,0) header.Position=UDim2.new(0.5,0,0,10) header.Size=UDim2.new(0.94,0,0,70)
	local headerLimit=Instance.new("UISizeConstraint") headerLimit.MaxSize=Vector2.new(1000,100) headerLimit.Parent=header
	local title=text(header,"Title","THE ROOM IS LYING",24,C.gold) title.Font=Enum.Font.Garamond title.Position=UDim2.fromOffset(16,7) title.Size=UDim2.new(0.6,0,0,28)
	local status=text(header,"Status","BLACKTHORN STATION  /  ARRIVE CURIOUS. LEAVE CERTAIN.",11,C.muted) status.Position=UDim2.fromOffset(16,39) status.Size=UDim2.new(0.7,-20,0,20)
	local wallet=text(header,"Wallet","0 MIND COINS",14,C.gold) wallet.AnchorPoint=Vector2.new(1,0) wallet.Position=UDim2.new(1,-16,0,12) wallet.Size=UDim2.fromOffset(200,22) wallet.TextXAlignment=Enum.TextXAlignment.Right
	local timeLabel=text(header,"Timer","",16,C.cream) timeLabel.AnchorPoint=Vector2.new(1,0) timeLabel.Position=UDim2.new(1,-16,0,38) timeLabel.Size=UDim2.fromOffset(140,20) timeLabel.TextXAlignment=Enum.TextXAlignment.Right
	local play=button(gui,"Play","PLAY",C.gold) play.AnchorPoint=Vector2.new(0.5,1) play.Position=UDim2.new(0.5,0,1,-25) play.Size=UDim2.fromOffset(280,54)
	local lobbyHint=text(gui,"LobbyHint","EXPLORE THE COURTYARD • SPEAK TO THE CURATOR • FOLLOW THE LANTERNS",11,C.cream) lobbyHint.AnchorPoint=Vector2.new(0.5,1) lobbyHint.Position=UDim2.new(0.5,0,1,-88) lobbyHint.Size=UDim2.new(0.9,0,0,30) lobbyHint.TextXAlignment=Enum.TextXAlignment.Center
	local leave=button(gui,"Leave","RETURN TO LOBBY") leave.Position=UDim2.fromOffset(14,88) leave.Size=UDim2.fromOffset(150,32) leave.TextSize=11 leave.Visible=false
	local torch=button(gui,"Flashlight","F  /  LIGHT") torch.AnchorPoint=Vector2.new(1,0.5) torch.Position=UDim2.new(1,-14,0.55,0) torch.Size=UDim2.fromOffset(110,42) torch.TextSize=12
	local lens=button(gui,"Lens","Q  /  TRUTH LENS",C.gold) lens.AnchorPoint=Vector2.new(0,0.5) lens.Position=UDim2.new(0,14,0.55,0) lens.Size=UDim2.fromOffset(130,42) lens.TextSize=11 lens.Visible=false
	local decision=panel(gui,"Decision") decision.AnchorPoint=Vector2.new(0.5,1) decision.Position=UDim2.new(0.5,0,1,-12) decision.Size=UDim2.new(0.9,0,0,124) decision.Visible=false
	local decisionLimit=Instance.new("UISizeConstraint") decisionLimit.MaxSize=Vector2.new(780,240) decisionLimit.Parent=decision
	local objective=text(decision,"Objective","",17,C.cream) objective.Position=UDim2.fromOffset(14,10) objective.Size=UDim2.new(1,-28,0,30)
	local sub=text(decision,"Detail","",12,C.muted) sub.Position=UDim2.fromOffset(14,43) sub.Size=UDim2.new(1,-28,0,52)
	local yes=button(decision,"Changed","1  /  SOMETHING IS MISSING",C.gold) yes.Position=UDim2.new(0,12,1,-58) yes.Size=UDim2.new(0.5,-18,0,46)
	local no=button(decision,"Same","2  /  NOTHING IS MISSING") no.Position=UDim2.new(0.5,6,1,-58) no.Size=yes.Size
	local toastPanel=panel(gui,"Toast") toastPanel.AnchorPoint=Vector2.new(0.5,0) toastPanel.Position=UDim2.new(0.5,0,0,124) toastPanel.Size=UDim2.new(0.9,0,0,52) toastPanel.Visible=false
	local toastLimit=Instance.new("UISizeConstraint") toastLimit.MaxSize=Vector2.new(650,100) toastLimit.Parent=toastPanel
	local toastText=text(toastPanel,"Text","",14,C.gold) toastText.Position=UDim2.fromOffset(14,6) toastText.Size=UDim2.new(1,-28,1,-12)
	local toastVersion=0
	function self:toast(content,good)
		toastVersion+=1 local version=toastVersion toastText.Text=content toastText.TextColor3=if good then C.mint else C.red toastPanel.Visible=true
		task.delay(4,function() if toastVersion==version then toastPanel.Visible=false end end)
	end
	local shade=Instance.new("Frame") shade.Name="ModalShade" shade.Size=UDim2.fromScale(1,1) shade.BackgroundColor3=Color3.new(0,0,0) shade.BackgroundTransparency=0.35 shade.BorderSizePixel=0 shade.Visible=false shade.Active=true shade.ZIndex=10 shade.Parent=gui
	local modal=panel(shade,"Modal") modal.ZIndex=11 modal.AnchorPoint=Vector2.new(0.5,0.5) modal.Position=UDim2.fromScale(0.5,0.5) modal.Size=UDim2.new(0.9,0,0,390)
	local modalLimit=Instance.new("UISizeConstraint") modalLimit.MaxSize=Vector2.new(720,440) modalLimit.Parent=modal
	local modalTitle=text(modal,"Title","CHOOSE YOUR INVESTIGATION",26,C.gold) modalTitle.Font=Enum.Font.Garamond modalTitle.Position=UDim2.fromOffset(22,18) modalTitle.Size=UDim2.new(1,-80,0,38) modalTitle.ZIndex=12
	local close=button(modal,"Close","X") close.AnchorPoint=Vector2.new(1,0) close.Position=UDim2.new(1,-12,0,12) close.Size=UDim2.fromOffset(36,36) close.ZIndex=12
	local bodyScroll=Instance.new("ScrollingFrame") bodyScroll.Name="BodyScroll" bodyScroll.BackgroundTransparency=1 bodyScroll.BorderSizePixel=0 bodyScroll.ScrollBarThickness=3 bodyScroll.ScrollBarImageColor3=C.gold bodyScroll.ScrollingDirection=Enum.ScrollingDirection.Y bodyScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y bodyScroll.CanvasSize=UDim2.new() bodyScroll.Position=UDim2.fromOffset(22,66) bodyScroll.Size=UDim2.new(1,-44,0,180) bodyScroll.ZIndex=12 bodyScroll.Parent=modal
	local body=text(bodyScroll,"Body","",15,C.cream) body.Position=UDim2.fromOffset(0,0) body.Size=UDim2.new(1,-12,0,0) body.AutomaticSize=Enum.AutomaticSize.Y body.TextYAlignment=Enum.TextYAlignment.Top body.ZIndex=12
	local solo=button(modal,"Solo","ENTER THE KEEPER'S STUDY\nSOLO • SMALL MAP",C.gold) solo.Position=UDim2.new(0,22,1,-93) solo.Size=UDim2.new(0.5,-30,0,68) solo.ZIndex=12
	local trio=button(modal,"Trio","QUEUE FOR BLACKTHORN MANOR\n1–3 PLAYERS • LARGE MAP") trio.Position=UDim2.new(0.5,8,1,-93) trio.Size=solo.Size trio.ZIndex=12
	local buy=button(modal,"BuyLens","BUY TRUTH LENS  /  1,000 MIND COINS",C.gold) buy.Position=UDim2.new(0,22,1,-81) buy.Size=UDim2.new(1,-44,0,56) buy.ZIndex=12
	local guideDone=button(modal,"GuideDone","I'LL REMEMBER.",C.gold) guideDone.Position=UDim2.new(0,22,1,-81) guideDone.Size=buy.Size guideDone.ZIndex=12
	function self:open(kind)
		self.modal=kind shade.Visible=true
		bodyScroll.CanvasPosition=Vector2.zero
		solo.Visible=kind=="Play" trio.Visible=solo.Visible buy.Visible=kind=="Shop" guideDone.Visible=kind=="Guide"
		if kind=="Play" then
			modalTitle.Text="CHOOSE YOUR INVESTIGATION"
			body.Text="THE KEEPER'S STUDY\nA compact, private room for one observer.\n\nBLACKTHORN MANOR\nA sprawling four-chamber manor for up to three. The queue starts when full or after 15 seconds.\n\nWalk, memorize, then report what disappeared."
		elseif kind=="Shop" then
			modalTitle.Text="THE CURATOR'S COLLECTION"
			body.Text="THE TRUTH LENS\n\nAn antique magnifying glass that reveals whether anything is missing, and how many objects vanished.\n\nPermanent ownership. One use per search round. It does not mark missing locations—evidence bonuses are earned on foot."
			buy.Text=if self.state and self.state.ownsLens then "OWNED  /  EQUIPPED FROM YOUR HUD" else "BUY TRUTH LENS  /  1,000 MIND COINS"
		else
			modalTitle.Text="THE ARCHIVIST'S WARNING"
			body.Text="Study every display before the lights go out. When they return, the room may have kept everything... or stolen several objects.\n\nLock your MISSING / UNCHANGED answer, then keep exploring. Hold E (or tap) at empty display spots to document each disappearance. Every unique find earns 75 bonus Mind Coins, even after voting.\n\nUse F for your flashlight. The Curator's lens tells the truth, but it cannot do the searching for you."
		end
	end
	local function dismiss() shade.Visible=false self.modal=nil end
	close.Activated:Connect(dismiss) guideDone.Activated:Connect(dismiss)
	play.Activated:Connect(function() if self.state and self.state.location=="Queue" then send("Leave") else self:open("Play") end end)
	solo.Activated:Connect(function() send("Play","Solo") dismiss() end)
	trio.Activated:Connect(function() send("Play","Trio") dismiss() end)
	buy.Activated:Connect(function() send("BuyLens") end)
	leave.Activated:Connect(function() send("Leave") end)
	torch.Activated:Connect(onLight)
	lens.Activated:Connect(function() send("Lens") end)
	function self:vote(choice)
		local s=self.state
		if not s or s.phase~="Search" or s.voted or self.choice~=nil or workspace:GetServerTimeNow()>=s.endsAt then return end
		self.choice=choice send("Vote",s.round,choice)
	end
	yes.Activated:Connect(function() self:vote(true) end) no.Activated:Connect(function() self:vote(false) end)
	local blackGui=Instance.new("ScreenGui") blackGui.Name="TRILHorrorBlackout" blackGui.IgnoreGuiInset=true blackGui.ScreenInsets=Enum.ScreenInsets.None blackGui.ResetOnSpawn=false blackGui.DisplayOrder=200 blackGui.Enabled=false blackGui.Parent=playerGui
	local black=Instance.new("Frame") black.Name="Curtain" black.Size=UDim2.fromScale(1,1) black.BackgroundColor3=Color3.fromRGB(3,5,9) black.BorderSizePixel=0 black.BackgroundTransparency=1 black.Active=true black.Parent=blackGui
	local whisper=text(black,"Whisper","THE ROOM IS KEEPING SOMETHING.",26,C.gold) whisper.Font=Enum.Font.Garamond whisper.AnchorPoint=Vector2.new(0.5,0.5) whisper.Position=UDim2.fromScale(0.5,0.5) whisper.Size=UDim2.fromScale(0.8,0.2) whisper.TextXAlignment=Enum.TextXAlignment.Center
	local curtainTween=nil
	function self:cover(hidden)
		if curtainTween then curtainTween:Cancel() end
		if hidden then blackGui.Enabled=true end
		local tween=Tween:Create(black,TweenInfo.new(0.25),{BackgroundTransparency=if hidden then 0 else 1}) curtainTween=tween tween:Play()
		if not hidden then tween.Completed:Once(function() if curtainTween==tween then blackGui.Enabled=false end end) end
	end
	function self:layout(viewport)
		self.viewport=viewport local compact=viewport.Y<550 local narrow=viewport.X<600
		title.TextSize=if compact or narrow then 18 else 24
		title.Size=UDim2.new(1,-180,0,28) wallet.TextSize=if narrow then 11 else 14 wallet.Size=UDim2.fromOffset(if narrow then 150 else 200,22)
		status.TextSize=if narrow then 9 else 11 status.Size=UDim2.new(1,-130,0,22)
		local safeHeight=if gui.AbsoluteSize.Y>0 then gui.AbsoluteSize.Y else viewport.Y
		modal.Size=UDim2.new(0.92,0,0,math.max(220,math.min(410,safeHeight-24)))
		modalTitle.TextSize=if compact or narrow then 20 else 26 body.TextSize=if compact or narrow then 12 else 15
		bodyScroll.Position=UDim2.fromOffset(20,58) bodyScroll.Size=UDim2.new(1,-40,1,-160)
		solo.TextSize=if narrow or compact then 11 else 14 trio.TextSize=solo.TextSize buy.TextSize=if narrow then 12 else 16
		local s=self.state local voting=s and s.phase=="Search" and not s.voted
		decision.Size=UDim2.new(0.92,0,0,if voting then (if compact then 120 else 128) else (if compact then 91 else 112))
		objective.TextSize=if compact or narrow then 13 else 17 sub.TextSize=if compact or narrow then 10 else 12
		objective.Size=UDim2.new(1,-28,0,if narrow then 34 else 30)
		yes.TextSize=if compact or narrow then 11 else 14 no.TextSize=yes.TextSize
		play.Size=UDim2.fromOffset(if narrow then 240 else 280,if compact then 46 else 54)
		lobbyHint.TextSize=if narrow then 9 else 11
		torch.Size=UDim2.fromOffset(if narrow then 88 else 110,40) lens.Size=UDim2.fromOffset(if narrow then 110 else 130,40)
		toastPanel.Position=UDim2.new(0.5,0,0,if compact then 85 else 124)
	end
	function self:update(s)
		local old=self.state self.state=s
		local roundKey=tostring(s.mapId)..":"..tostring(s.round)
		if self.lastRound~=roundKey then self.choice=nil self.lastRound=roundKey end
		if s.voted then self.choice=s.choice end
		wallet.Text=string.format("%s  MIND COINS",tostring(s.coins))
		local inMatch=s.location=="Match"
		play.Visible=not inMatch lobbyHint.Visible=not inMatch decision.Visible=inMatch leave.Visible=inMatch
		lens.Visible=s.ownsLens and inMatch lens.Text=if s.lensUsed then "LENS USED" else "Q  /  TRUTH LENS"
		title.Text=if inMatch then s.mapName or "ENTERING THE ROOM" else "THE ROOM IS LYING"
		if not inMatch then
			status.Text=if s.saveMode=="SESSION" then "BLACKTHORN STATION  /  SESSION PROGRESS" else "BLACKTHORN STATION  /  "..(s.saveMode or "LOADING")
			play.Text=if not s.ready then "LOADING YOUR RECORD..." else if s.location=="Queue" then "CANCEL QUEUE" else "PLAY"
			play.Active=s.ready play.AutoButtonColor=s.ready
			lobbyHint.Text=if s.location=="Queue" then string.format("MANOR QUEUE  /  %d OF 3 OBSERVERS",s.queueCount or 1) else "EXPLORE THE COURTYARD • SPEAK TO THE CURATOR • FOLLOW THE LANTERNS"
		else
			status.Text=string.format("ROUND %d / %d  /  %s  /  %d OBSERVER%s",s.round or 0,s.total or 3,s.phase or "Loading",s.party or 1,if s.party==1 then "" else "S")
			if s.phase=="Memorize" then objective.Text="Walk the room. Remember every display." sub.Text="The lanterns will go out soon. Memorize what belongs on each brass stand."
			elseif s.phase=="Search" then
				objective.Text=if s.voted then string.format("ANSWER LOCKED  /  %d DISAPPEARANCES FOUND",s.finds or 0) else string.format("IS ANYTHING MISSING?  /  %d EVIDENCE FOUND",s.finds or 0)
				sub.Text=s.hint or "Keep exploring. Hold E at empty display spots. Each unique find: +75 Mind Coins."
			elseif s.phase=="Results" and s.result and s.reveal then
				local r=s.result
				objective.Text=string.format("%s  /  +%d ANSWER COINS  /  %d FOUND (+%d BONUS)",if r.correct then "CORRECT" else if r.missed then "NO ANSWER" else "INCORRECT",r.coins,r.finds,r.bonus)
				sub.Text=if s.reveal.changed then "MISSING: "..table.concat(s.reveal.labels,", ") else "Nothing disappeared. The room told the truth."
			else objective.Text="THE ROOM IS PREPARING..." sub.Text="" end
		end
		yes.Visible=inMatch and s.phase=="Search" and not s.voted no.Visible=yes.Visible
		sub.Visible=not yes.Visible
		if not old or old.phase~=s.phase or old.location~=s.location then self:cover(inMatch and (s.phase=="Blackout" or s.phase=="Loading")) end
		if inMatch then dismiss() end
		if self.modal=="Shop" then buy.Text=if s.ownsLens then "OWNED  /  EQUIPPED FROM YOUR HUD" else "BUY TRUTH LENS  /  1,000 MIND COINS" end
		self:layout(self.viewport)
	end
	function self:tick(t)
		local s=self.state if not s then return end
		if s.location=="Queue" then timeLabel.Text=string.format("STARTS IN %02d",math.max(0,math.ceil((s.endsAt or t)-t)))
		elseif s.location=="Match" and s.endsAt then local remaining=math.max(0,math.ceil(s.endsAt-t)) timeLabel.Text=string.format("%02d:%02d",math.floor(remaining/60),remaining%60)
		else timeLabel.Text="" end
	end
	function self:destroy() gui:Destroy() blackGui:Destroy() end
	return self
end
return Interface
