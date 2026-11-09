--!strict
-- Original native-part environments. No Toolbox scripts or unlicensed asset IDs.
local World={}
local V=Vector3.new
local C={
	stone=Color3.fromRGB(53,60,67),trim=Color3.fromRGB(91,85,78),wood=Color3.fromRGB(65,43,35),
	walnut=Color3.fromRGB(94,60,44),gold=Color3.fromRGB(170,132,70),brass=Color3.fromRGB(211,174,102),
	ink=Color3.fromRGB(20,25,33),blue=Color3.fromRGB(70,111,140),cyan=Color3.fromRGB(118,211,205),
	red=Color3.fromRGB(91,32,42),ivory=Color3.fromRGB(218,208,174),green=Color3.fromRGB(32,56,47),
}
local function context(name,origin,parent)
	local root=Instance.new("Model") root.Name=name root.Parent=parent
	local count=0
	local function group(name)
		local m=Instance.new("Model") m.Name=name m.Parent=root return m
	end
	local function part(parent,name,pos,size,color,material,rotation,shape)
		local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=CFrame.new(origin+pos)*(rotation or CFrame.identity)
		p.Color=color or C.stone p.Material=material or Enum.Material.SmoothPlastic p.Anchored=true
		p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
		if shape then p.Shape=shape end p.Parent=parent
		if parent:IsA("Model") and not parent.PrimaryPart then parent.PrimaryPart=p end
		count+=1 if count%120==0 then task.wait() end
		return p
	end
	local function ball(parent,name,pos,size,color,material) return part(parent,name,pos,size,color,material,nil,Enum.PartType.Ball) end
	local function cylinder(parent,name,pos,size,color,material)
		return part(parent,name,pos,V(size.Y,size.X,size.Z),color,material,CFrame.Angles(0,0,math.pi/2),Enum.PartType.Cylinder)
	end
	local function light(p,color,brightness,range,shadows)
		local l=Instance.new("PointLight") l.Color=color l.Brightness=brightness l.Range=range l.Shadows=shadows or false l.Parent=p return l
	end
	local function sign(p,text,size,color,face)
		local gui=Instance.new("SurfaceGui") gui.Name="Inscription" gui.Face=face or Enum.NormalId.Front gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=32 gui.LightInfluence=0.2 gui.Parent=p
		local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Font=Enum.Font.Garamond t.Text=text t.TextColor3=color or C.ivory t.TextScaled=true t.TextWrapped=true t.Parent=gui
		local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0.05,0) pad.PaddingRight=UDim.new(0.05,0) pad.PaddingTop=UDim.new(0.08,0) pad.PaddingBottom=UDim.new(0.08,0) pad.Parent=t
		return gui
	end
	local function lantern(parent,pos,scale,color)
		scale=scale or 1 color=color or Color3.fromRGB(255,184,95)
		part(parent,"LanternFoot",pos,V(1.5,0.2,1.5)*scale,C.ink,Enum.Material.Metal)
		for _,x in ipairs({-0.55,0.55}) do for _,z in ipairs({-0.55,0.55}) do part(parent,"Iron",pos+V(x,0.9,z)*scale,V(0.09,1.8,0.09)*scale,C.ink,Enum.Material.Metal) end end
		local bulb=part(parent,"WarmGlass",pos+V(0,0.9,0)*scale,V(0.8,1.3,0.8)*scale,color,Enum.Material.Glass) bulb.Transparency=0.35
		ball(parent,"LanternFlame",pos+V(0,0.9,0)*scale,V(0.18,0.8,0.18)*scale,Color3.fromRGB(255,186,104),Enum.Material.Neon)
		part(parent,"Cap",pos+V(0,1.8,0)*scale,V(1.5,0.25,1.5)*scale,C.ink,Enum.Material.Metal)
		light(bulb,color,1.2,16*scale,false)
		return bulb
	end
	local function candles(parent,pos,n)
		for i=1,n do
			local offset=V((i-(n+1)/2)*0.65,0,(i%2)*0.3)
			local h=0.8+(i%3)*0.3
			cylinder(parent,"Wax",pos+offset+V(0,h/2,0),V(0.35,h,0.35),C.ivory)
			local flame=ball(parent,"Flame",pos+offset+V(0,h+0.1,0),V(0.17,0.4,0.17),Color3.fromRGB(255,180,84),Enum.Material.Neon)
			if i==1 then light(flame,Color3.fromRGB(255,180,84),0.7,13,false) end
		end
	end
	local function desk(parent,pos,width)
		part(parent,"DeskTop",pos+V(0,3.1,0),V(width,0.5,4),C.walnut,Enum.Material.Wood)
		for _,x in ipairs({-width/2+0.5,width/2-0.5}) do for _,z in ipairs({-1.4,1.4}) do part(parent,"CarvedLeg",pos+V(x,1.5,z),V(0.45,3,0.45),C.wood,Enum.Material.Wood) end end
		part(parent,"Apron",pos+V(0,2.5,-1.6),V(width-1,0.9,0.3),C.wood,Enum.Material.Wood)
	end
	local function chair(parent,pos,rotation)
		local m=Instance.new("Model") m.Name="VelvetChair" m.Parent=parent
		part(m,"Seat",pos+V(0,1.9,0),V(2.4,0.5,2.4),C.red,Enum.Material.Fabric)
		part(m,"Back",pos+V(0,3.2,-1),V(2.4,2.8,0.4),C.red,Enum.Material.Fabric)
		for _,x in ipairs({-1,1}) do for _,z in ipairs({-0.9,0.9}) do part(m,"Leg",pos+V(x,0.8,z),V(0.22,1.8,0.22),C.walnut,Enum.Material.Wood) end end
		if rotation then local base=CFrame.new(origin+pos) m:PivotTo(base*CFrame.Angles(0,rotation,0)*base:ToObjectSpace(m:GetPivot())) end
		return m
	end
	local function bookcase(parent,pos,width)
		part(parent,"ShelfBack",pos+V(0,5,-0.7),V(width,10,0.3),C.wood,Enum.Material.WoodPlanks)
		for _,x in ipairs({-width/2,width/2}) do part(parent,"ShelfPillar",pos+V(x,5,0),V(0.45,10,2.2),C.walnut,Enum.Material.Wood) end
		for y=0.4,10,2.4 do part(parent,"Shelf",pos+V(0,y,0),V(width+0.4,0.3,2.3),C.walnut,Enum.Material.Wood) end
		for row=1,4 do for book=1,math.floor(width/0.65)-1 do
			local x=-width/2+0.5+book*0.55 local h=1.3+(book%3)*0.2
			part(parent,"OldBook",pos+V(x,(row-1)*2.4+0.55+h/2,0),V(0.4,h,1.5),({C.red,C.green,C.blue,C.gold,C.wood})[(book+row)%5+1],Enum.Material.Fabric)
		end end
	end
	local function window(parent,pos,width,height)
		part(parent,"WindowFrame",pos,V(width+0.8,height+0.8,0.5),C.ink,Enum.Material.Metal)
		local glass=part(parent,"MoonGlass",pos+V(0,0,0.3),V(width,height,0.15),Color3.fromRGB(69,104,145),Enum.Material.Glass) glass.Transparency=0.25
		for _,x in ipairs({-width/3,0,width/3}) do part(parent,"WindowMullion",pos+V(x,0,0.45),V(0.12,height,0.16),C.ink,Enum.Material.Metal) end
		part(parent,"WindowCross",pos+V(0,0.5,0.45),V(width,0.14,0.16),C.ink,Enum.Material.Metal)
		local wash=part(parent,"MoonWash",pos+V(0,0,1),V(0.2,0.2,0.2),C.blue) wash.Transparency=1 wash.CanCollide=false light(wash,Color3.fromRGB(93,145,205),0.6,22,false)
	end
	local function painting(parent,pos,labelText)
		part(parent,"GiltFrame",pos,V(4.5,5.5,0.35),C.gold,Enum.Material.Metal)
		part(parent,"PortraitCanvas",pos+V(0,0,0.25),V(3.9,4.9,0.12),C.ink,Enum.Material.Fabric)
		ball(parent,"PortraitHead",pos+V(0,0.5,0.4),V(1.6,1.9,0.12),C.trim)
		part(parent,"PortraitShoulders",pos+V(0,-1.15,0.4),V(2.8,1.5,0.12),C.wood)
		for _,x in ipairs({-0.3,0.3}) do ball(parent,"PortraitEye",pos+V(x,0.7,0.48),V(0.12,0.12,0.04),C.ivory,Enum.Material.Neon) end
		local plaque=part(parent,"PortraitPlate",pos+V(0,-3.2,0),V(3,0.5,0.15),C.gold,Enum.Material.Metal) sign(plaque,labelText,12,C.ink,Enum.NormalId.Back)
	end
	return {root=root,origin=origin,group=group,part=part,ball=ball,cylinder=cylinder,light=light,sign=sign,lantern=lantern,candles=candles,desk=desk,chair=chair,bookcase=bookcase,window=window,painting=painting}
end

local function npc(b,name,title,pos,coat)
	local m=b.group(name)
	local p=b.part
	local root=p(m,"HumanoidRootPart",pos+V(0,3.2,0),V(2,2,1),C.ink) root.Transparency=1 root.CanCollide=false
	p(m,"LongCoat",pos+V(0,2.7,0),V(2.6,3.6,1.4),coat,Enum.Material.Fabric)
	p(m,"Shoulders",pos+V(0,4.1,0),V(3.2,0.7,1.6),coat,Enum.Material.Fabric)
	for _,x in ipairs({-1.5,1.5}) do
		b.cylinder(m,"Sleeve",pos+V(x,3.1,0),V(0.65,2,0.75),coat,Enum.Material.Fabric)
		b.ball(m,"Glove",pos+V(x,2.15,0),V(0.6,0.65,0.6),C.ink)
		p(m,"Boot",pos+V(x/2,0.5,0.25),V(0.8,1,1.4),C.ink,Enum.Material.Leather)
	end
	local head=b.ball(m,"Head",pos+V(0,5.05,0),V(1.8,2,1.5),C.ivory)
	b.ball(m,"Hood",pos+V(0,5.25,-0.4),V(2.3,2.5,1.8),coat)
	p(m,"Mask",pos+V(0,5.1,0.65),V(1.4,1.55,0.22),C.ivory)
	for _,x in ipairs({-0.35,0.35}) do p(m,"EyeSocket",pos+V(x,5.25,0.79),V(0.28,0.15,0.08),C.ink); b.ball(m,"EyeGlint",pos+V(x,5.25,0.85),V(0.07,0.07,0.05),C.cyan,Enum.Material.Neon) end
	for y=1.6,3.8,0.55 do b.ball(m,"CoatButton",pos+V(0,y,0.76),V(0.17,0.17,0.1),C.brass,Enum.Material.Metal) end
	p(m,"Collar",pos+V(0,4.2,0.65),V(1.6,0.6,0.4),C.gold,Enum.Material.Fabric)
	local humanoid=Instance.new("Humanoid") humanoid.RequiresNeck=false humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None humanoid.Parent=m
	local badge=Instance.new("BillboardGui") badge.Name="Role" badge.Size=UDim2.fromOffset(200,54) badge.StudsOffset=V(0,2.2,0) badge.MaxDistance=35 badge.AlwaysOnTop=false badge.Parent=head
	local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.Font=Enum.Font.Garamond label.Text=name.."\n"..title label.TextSize=20 label.TextColor3=C.ivory label.TextStrokeTransparency=0.25 label.Parent=badge
	local prompt=Instance.new("ProximityPrompt") prompt.ObjectText=name prompt.ActionText=title prompt.HoldDuration=0.2 prompt.MaxActivationDistance=11 prompt.RequiresLineOfSight=false prompt.Parent=head
	return {model=m,prompt=prompt,anchor=head}
end

function World.lobby(parent)
	local b=context("TRILLobby",V(0,8,0),parent)
	local p=b.part local g=b.group("Courtyard")
	p(g,"SurroundingGround",V(0,-3.5,0),V(2048,2,2048),Color3.fromRGB(15,24,23),Enum.Material.Ground)
	p(g,"Foundation",V(0,-1,0),V(110,2,100),C.stone,Enum.Material.Slate)
	for x=-48,48,8 do for z=-40,40,8 do p(g,"Paving",V(x,0.04,z),V(7.8,0.15,7.8),if (x+z)%16==0 then C.stone else Color3.fromRGB(62,66,71),Enum.Material.Cobblestone) end end
	for _,x in ipairs({-54,54}) do p(g,"Perimeter",V(x,3,0),V(2,6,100),C.ink,Enum.Material.Brick) end
	p(g,"RearWall",V(0,3,-49),V(110,6,2),C.ink,Enum.Material.Brick)
	for x=-52,52,4 do
		p(g,"FrontFencePost",V(x,3,49),V(0.22,6,0.22),C.ink,Enum.Material.Metal)
		p(g,"Finial",V(x,6.2,49),V(0.4,0.7,0.4),C.gold,Enum.Material.Metal,CFrame.Angles(0,0,math.pi/4))
	end
	for _,y in ipairs({1.6,4.4}) do p(g,"FenceRail",V(0,y,49),V(108,0.16,0.16),C.ink,Enum.Material.Metal) end
	for _,spec in ipairs({{V(-55,12,0),V(1,24,102)},{V(55,12,0),V(1,24,102)},{V(0,12,50),V(112,24,1)},{V(0,12,-50),V(112,24,1)}}) do local boundary=p(g,"CourtyardBoundary",spec[1],spec[2],C.ink) boundary.Transparency=1 end
	local hotel=b.group("HotelFacade")
	p(hotel,"Facade",V(0,17,-36),V(66,34,5),C.stone,Enum.Material.Brick)
	p(hotel,"PorticoLeft",V(-8,8,-31),V(6,16,8),C.trim,Enum.Material.Slate)
	p(hotel,"PorticoRight",V(8,8,-31),V(6,16,8),C.trim,Enum.Material.Slate)
	p(hotel,"ArchLintel",V(0,16,-30),V(22,4,9),C.trim,Enum.Material.Slate)
	local door=p(hotel,"SealedDoor",V(0,7,-32.7),V(10,14,0.6),C.wood,Enum.Material.WoodPlanks)
	for _,x in ipairs({-2.5,2.5}) do p(hotel,"DoorPanel",V(x,7,-32.25),V(4.4,12,0.3),C.walnut,Enum.Material.Wood); b.cylinder(hotel,"DoorRing",V(x/2,7,-31.8),V(0.5,0.5,0.25),C.gold,Enum.Material.Metal) end
	for _,x in ipairs({-27,-17,17,27}) do b.window(hotel,V(x,21,-33.2),5,9) end
	for _,x in ipairs({-32,32}) do
		p(hotel,"Tower",V(x,23,-36),V(8,46,8),C.stone,Enum.Material.Brick)
		for y=8,40,10 do p(hotel,"TowerCornice",V(x,y,-36),V(9,0.8,9),C.trim,Enum.Material.Slate) end
		local roof=p(hotel,"TowerRoof",V(x,48,-36),V(12,8,12),C.ink,Enum.Material.Slate) roof.Shape=Enum.PartType.Ball
		p(hotel,"Spire",V(x,55,-36),V(0.6,10,0.6),C.ink,Enum.Material.Metal)
	end
	local title=p(hotel,"HotelSign",V(0,24,-32.8),V(23,4,0.4),C.ink,Enum.Material.Metal)
	b.sign(title,"THE ROOM IS LYING\nBLACKTHORN STATION",24,C.brass,Enum.NormalId.Back)
	b.light(title,Color3.fromRGB(255,199,123),1,18,false)
	for _,x in ipairs({-9,9}) do for _,z in ipairs({-20,0,20,38}) do
		local lamp=b.group("CourtyardLantern")
		p(lamp,"Pedestal",V(x,0.5,z),V(2,1,2),C.ink,Enum.Material.Slate)
		p(lamp,"IronPost",V(x,4,z),V(0.28,7,0.28),C.ink,Enum.Material.Metal)
		b.lantern(lamp,V(x,7.3,z),0.85)
	end end
	for _,x in ipairs({-41,41}) do
		local hedge=b.group("GraveGarden")
		p(hedge,"SoilBed",V(x,0.3,10),V(13,0.6,52),C.green,Enum.Material.Ground)
		for z=-8,30,10 do
			p(hedge,"StoneMarker",V(x,1.8,z),V(2.8,3.6,0.7),C.trim,Enum.Material.Slate,CFrame.Angles(0,0,0.08))
			p(hedge,"GraveFoot",V(x,0.4,z+2),V(3.5,0.5,4),C.stone,Enum.Material.Slate)
		end
	end
	for i=1,12 do
		local t=b.group("BareTree") local side=if i%2==0 then -1 else 1 local x=side*(57+(i%3)*8) local z=-40+i*8
		p(t,"Trunk",V(x,11,z),V(1.6,22,1.8),C.wood,Enum.Material.Wood,CFrame.Angles(0,0,side*0.08))
		for n=1,3 do p(t,"DeadBranch",V(x+side*(n+1),11+n*3,z),V(0.7,10,0.8),C.wood,Enum.Material.Wood,CFrame.Angles(0,n*0.7,side*-0.8)) end
	end
	for _,x in ipairs({-22,22}) do
		local bench=b.group("IronBench") p(bench,"Seat",V(x,2,22),V(12,0.4,3),C.walnut,Enum.Material.WoodPlanks)
		p(bench,"Back",V(x,3.5,23.3),V(12,2.6,0.3),C.walnut,Enum.Material.WoodPlanks)
		for _,dx in ipairs({-5,5}) do p(bench,"Leg",V(x+dx,1,22),V(0.4,2,2.8),C.ink,Enum.Material.Metal) end
	end
	local shop=b.group("CuratorsShop")
	p(shop,"StallRoof",V(-25,9,-9),V(17,1,12),C.wood,Enum.Material.WoodPlanks)
	p(shop,"Back",V(-25,4.5,-14),V(17,9,0.6),C.walnut,Enum.Material.WoodPlanks)
	for _,x in ipairs({-33,-17}) do p(shop,"Pillar",V(x,4.5,-4),V(0.6,9,0.6),C.gold,Enum.Material.Metal) end
	b.desk(shop,V(-25,0,-5),14)
	b.lantern(shop,V(-30,3.4,-5),0.8)
	b.candles(shop,V(-20,3.4,-5),3)
	local board=p(shop,"ShopSign",V(-25,7,-3.7),V(12,2.4,0.4),C.ink,Enum.Material.Wood)
	b.sign(board,"THE CURATOR\nTRUTH HAS A PRICE",22,C.brass,Enum.NormalId.Back)
	local lens=b.group("LensDisplay")
	for i=1,12 do local a=i*math.pi/6 p(lens,"LensRim",V(-22+math.sin(a)*0.9,5.4+math.cos(a)*0.9,-5),V(0.25,0.48,0.2),C.gold,Enum.Material.Metal,CFrame.Angles(0,0,-a)) end
	p(lens,"Handle",V(-22,3.9,-5),V(0.25,1.4,0.25),C.walnut,Enum.Material.Wood)
	local glass=b.ball(lens,"Glass",V(-22,5.4,-5),V(1.5,1.5,0.12),C.cyan,Enum.Material.Glass) glass.Transparency=0.35
	for _,piece in lens:GetChildren() do if piece:IsA("BasePart") then piece.CanQuery=false end end
	local guide=npc(b,"THE ARCHIVIST","Ask about missing objects",V(23,0,12),C.green)
	local keeper=npc(b,"THE BELLKEEPER","Choose an investigation",V(0,0,-22),C.red)
	local curator=npc(b,"THE CURATOR","Browse the shop",V(-25,0,-9),C.wood)
	local notice=b.group("NoticeBoard")
	local n=p(notice,"Notice",V(25,6,-10),V(14,9,0.7),C.walnut,Enum.Material.Wood)
	b.sign(n,"HOUSE RULES\n\nMEMORIZE THE ROOM\nVOTE: MISSING OR UNCHANGED\nREPORT EMPTY DISPLAY SPOTS\nEACH FIND: +75 MIND COINS",18,C.ivory,Enum.NormalId.Back)
	b.lantern(notice,V(20,0,-8),1)
	-- Distant silhouettes and low moving mist frame the native moon/star sky.
	for i=1,8 do
		local rock=b.group("DistantSilhouette")
		local a=i*math.pi/4 local pos=V(math.cos(a)*175,18,math.sin(a)*175)
		local mountain=Instance.new("WedgePart") mountain.Name="DistantRoofline" mountain.Size=V(75,38+(i%3)*12,55) mountain.CFrame=CFrame.new(b.origin+pos)*CFrame.Angles(0,a,0) mountain.Anchored=true mountain.Color=Color3.fromRGB(15,22,29) mountain.Material=Enum.Material.Slate mountain.Parent=rock
	end
	local ivy=b.group("ClimbingIvy")
	for _,x in ipairs({-31,-16,16,31}) do for n=1,6 do
		p(ivy,"Vine",V(x+math.sin(n)*0.7,n*3,-33.3),V(0.15,4,0.18),C.green,Enum.Material.Grass,CFrame.Angles(0,0,math.sin(n)*0.25))
		for side=-1,1,2 do b.ball(ivy,"IvyLeaf",V(x+side*0.7,n*3,-33),V(1.1,0.6,0.18),C.green,Enum.Material.Grass) end
	end end
	local moon=b.group("MoonBackdrop")
	local core=b.ball(moon,"Moon",V(0,112,-190),V(27,27,27),Color3.fromRGB(164,189,213),Enum.Material.Neon) core.CanCollide=false core.CanQuery=false
	for _,s in ipairs({{V(-5,115,-176),V(4,4,1)},{V(4,108,-176),V(6,5,1)},{V(6,118,-177),V(3,3,1)}}) do local crater=b.ball(moon,"MoonCrater",s[1],s[2],Color3.fromRGB(100,128,157),Enum.Material.Neon) crater.Transparency=0.55 crater.CanCollide=false crater.CanQuery=false end
	for i=1,4 do local cloud=b.ball(moon,"CloudVeil",V(-60+i*29,91+i*3,-170),V(65,6,12),Color3.fromRGB(80,98,125)) cloud.Transparency=0.82 cloud.CanCollide=false cloud.CanQuery=false end
	local mist=p(g,"MistEmitter",V(0,0.4,15),V(85,0.1,65),C.ink) mist.Transparency=1 mist.CanCollide=false mist.CanQuery=false
	local emitter=Instance.new("ParticleEmitter") emitter.Name="GroundMist" emitter.Texture="rbxasset://textures/particles/smoke_main.dds" emitter.Rate=3 emitter.Lifetime=NumberRange.new(8,12) emitter.Speed=NumberRange.new(0.3,0.7) emitter.SpreadAngle=Vector2.new(180,180) emitter.Rotation=NumberRange.new(0,360) emitter.RotSpeed=NumberRange.new(-3,3) emitter.Color=ColorSequence.new(Color3.fromRGB(113,137,150)) emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.3,0.88),NumberSequenceKeypoint.new(1,1)}) emitter.Size=NumberSequence.new(16) emitter.Parent=mist
	return {model=b.root,spawn=CFrame.new(b.origin+V(0,4,30),b.origin+V(0,4,-20)),shop=curator,guide=guide,keeper=keeper}
end

local function artifact(b,name,label,pos,kind)
	local m=b.group(name) local p=b.part
	local plate=b.cylinder(m,"DisplayBase",pos,V(2.4,0.15,2.4),C.gold,Enum.Material.Metal)
	-- The stand and inspection anchor remain when the actual object disappears.
	local object=Instance.new("Model") object.Name="Object" object.Parent=m
	if kind==1 then
		b.ball(object,"Globe",pos+V(0,1.3,0),V(1.9,1.9,1.9),C.blue)
		b.cylinder(object,"Axis",pos+V(0,0.6,0),V(0.2,1.2,0.2),C.brass,Enum.Material.Metal)
		p(object,"Meridian",pos+V(0,1.3,0),V(2.2,0.12,0.14),C.gold,Enum.Material.Metal,CFrame.Angles(0,0,0.5))
	elseif kind==2 then
		p(object,"MusicBox",pos+V(0,0.7,0),V(1.8,1.1,1.4),C.walnut,Enum.Material.Wood)
		p(object,"Lid",pos+V(0,1.35,-0.4),V(1.9,0.2,1.5),C.gold,Enum.Material.Metal,CFrame.Angles(-0.5,0,0))
		b.ball(object,"Crank",pos+V(1.15,0.7,0),V(0.35,0.35,0.35),C.gold)
	elseif kind==3 then
		b.ball(object,"Mask",pos+V(0,1.2,0),V(1.7,2.2,0.6),C.ivory)
		for _,x in ipairs({-0.38,0.38}) do p(object,"Eye",pos+V(x,1.4,0.32),V(0.35,0.2,0.1),C.ink) end
		p(object,"Stand",pos+V(0,0.5,-0.2),V(0.25,1,0.25),C.gold,Enum.Material.Metal)
	elseif kind==4 then
		p(object,"Typewriter",pos+V(0,0.6,0),V(2,0.7,1.7),C.ink,Enum.Material.Metal)
		for x=-0.7,0.7,0.35 do for z=-0.4,0.4,0.4 do b.ball(object,"Key",pos+V(x,1,z),V(0.16,0.1,0.16),C.ivory) end end
		p(object,"Paper",pos+V(0,1.6,-0.5),V(1.6,1.4,0.1),C.ivory)
	elseif kind==5 then
		b.ball(object,"Kettle",pos+V(0,0.9,0),V(1.7,1.5,1.7),C.brass,Enum.Material.Metal)
		p(object,"Spout",pos+V(1,1,0),V(1,0.4,0.4),C.brass,Enum.Material.Metal,CFrame.Angles(0,0,0.35))
		p(object,"Handle",pos+V(-0.9,1.2,0),V(0.25,1,0.5),C.wood)
	elseif kind==6 then
		p(object,"BottledMemory",pos+V(0,1,0),V(0.9,1.8,0.9),C.green,Enum.Material.Glass)
		p(object,"Cork",pos+V(0,2,0),V(0.65,0.3,0.65),C.walnut,Enum.Material.Wood)
		p(object,"Label",pos+V(0,1,0.48),V(0.7,0.8,0.06),C.ivory)
	elseif kind==7 then
		p(object,"StackA",pos+V(0,0.3,0),V(1.9,0.4,1.6),C.red,Enum.Material.Fabric)
		p(object,"StackB",pos+V(0,0.7,0),V(1.7,0.4,1.5),C.green,Enum.Material.Fabric,CFrame.Angles(0,0.2,0))
		p(object,"StackC",pos+V(0,1.1,0),V(1.8,0.4,1.3),C.blue,Enum.Material.Fabric,CFrame.Angles(0,-0.1,0))
	elseif kind==8 then
		p(object,"KnightBase",pos+V(0,0.4,0),V(1.5,0.6,1.5),C.ivory,Enum.Material.Marble)
		p(object,"KnightNeck",pos+V(0,1.3,0),V(0.7,1.3,0.7),C.ivory,Enum.Material.Marble,CFrame.Angles(0,0,-0.2))
		p(object,"HorseHead",pos+V(0.35,2,0),V(1.3,0.65,0.8),C.ivory,Enum.Material.Marble)
	elseif kind==9 then
		b.ball(object,"DollHead",pos+V(0,1.8,0),V(1,1.1,1),C.ivory)
		p(object,"DollDress",pos+V(0,0.9,0),V(1.3,1.5,0.7),C.red,Enum.Material.Fabric)
		for _,x in ipairs({-0.2,0.2}) do b.ball(object,"DollEye",pos+V(x,1.9,0.47),V(0.12,0.12,0.08),C.ink) end
	else
		p(object,"ClockCase",pos+V(0,1.2,0),V(1.7,2.4,0.8),C.walnut,Enum.Material.Wood)
		local face=p(object,"ClockFace",pos+V(0,1.5,0.45),V(1.3,1.3,0.1),C.ivory)
		p(object,"ClockHand",pos+V(0,1.6,0.55),V(0.1,0.7,0.08),C.ink)
	end
	local anchor=p(m,"Inspect",V(pos.X,math.min(pos.Y+1,4.2),pos.Z+(if pos.Y>6 then 2 else 0)),V(2.5,2.5,2.5),C.ink) anchor.Transparency=1 anchor.CanCollide=false anchor.CanQuery=false
	local prompt=Instance.new("ProximityPrompt") prompt.Name="InspectSpot" prompt.ActionText="Inspect display" prompt.ObjectText="Remember what belonged here" prompt.MaxActivationDistance=8 prompt.HoldDuration=0.35 prompt.RequiresLineOfSight=false prompt.Enabled=false prompt.Parent=anchor
	local saved={}
	for _,o in object:GetDescendants() do if o:IsA("BasePart") then table.insert(saved,{part=o,transparency=o.Transparency,collide=o.CanCollide}) end end
	return {model=m,object=object,label=label,anchor=anchor,prompt=prompt,saved=saved}
end

function World.map(key,origin,parent)
	local big=key=="Trio" local w=if big then 76 else 34 local d=if big then 62 else 32
	local b=context("TRILMap_"..key,origin,parent) local p=b.part
	local architecture=b.group("Architecture")
	p(architecture,"StoneFoundation",V(0,-0.8,0),V(w+2,1.6,d+2),C.stone,Enum.Material.Slate)
	p(architecture,"Floor",V(0,0,0),V(w,0.3,d),C.walnut,Enum.Material.WoodPlanks)
	p(architecture,"BackWall",V(0,8,-d/2),V(w,16,1),C.stone,Enum.Material.Brick)
	p(architecture,"FrontWall",V(0,8,d/2),V(w,16,1),C.stone,Enum.Material.Brick)
	for _,x in ipairs({-w/2,w/2}) do p(architecture,"SideWall",V(x,8,0),V(1,16,d),C.stone,Enum.Material.Brick) end
	p(architecture,"Ceiling",V(0,16,0),V(w+1,0.7,d+1),C.ink,Enum.Material.WoodPlanks)
	for z=-d/2+4,d/2-2,8 do p(architecture,"CeilingBeam",V(0,15.4,z),V(w,1.2,0.7),C.wood,Enum.Material.Wood) end
	for _,z in ipairs({-d/2+0.6,d/2-0.6}) do
		p(architecture,"Skirting",V(0,0.8,z),V(w,1.4,0.3),C.wood,Enum.Material.Wood)
		p(architecture,"DadoRail",V(0,5,z),V(w,0.35,0.35),C.gold,Enum.Material.Wood)
		p(architecture,"Cornice",V(0,15,z),V(w,0.5,0.8),C.trim,Enum.Material.Slate)
		for x=-w/2+2,w/2-1,4 do p(architecture,"WallPanel",V(x,2.6,z),V(3.7,3.3,0.2),C.wood,Enum.Material.Wood) end
	end
	for _,x in ipairs({-w/2+0.6,w/2-0.6}) do
		p(architecture,"SideDado",V(x,5,0),V(0.3,0.35,d),C.gold,Enum.Material.Wood)
		for z=-d/2+2,d/2-1,4 do p(architecture,"WallPanel",V(x,2.6,z),V(0.2,3.3,3.7),C.wood,Enum.Material.Wood) end
	end
	local rug=b.group("WornCarpet")
	p(rug,"CarpetBorder",V(0,0.23,0),V(w-9,0.12,d-10),C.gold,Enum.Material.Fabric)
	p(rug,"Carpet",V(0,0.3,0),V(w-10,0.12,d-11),C.red,Enum.Material.Fabric)
	for z=-d/2+8,d/2-7,7 do p(rug,"CarpetMotif",V(0,0.38,z),V(2.5,0.04,2.5),C.trim,Enum.Material.Fabric,CFrame.Angles(0,math.pi/4,0)) end
	local props=b.group("Furnishings")
	local targets={}
	local kinds={"Celestial globe","Music box","Porcelain mask","Typewriter","Brass kettle","Bottled memory","Old journals","Marble knight","Porcelain doll","Mantel clock"}
	local function add(pos,kind)
		local i=#targets+1 targets[i]=artifact(b,"Display_"..i,kinds[kind],pos,kind)
	end
	local function furnishedZone(cx,cz,zoneIndex)
		b.desk(props,V(cx-5,0,cz-4),10)
		b.chair(props,V(cx-5,0,cz-0.5))
		b.candles(props,V(cx-9,3.4,cz-4),3)
		b.bookcase(props,V(cx-8,0,cz-11.5),8)
		b.window(props,V(cx+4,10,cz-14),6,7)
		b.painting(props,V(cx-5,10,cz-14),if zoneIndex==1 then "THE KEEPER" else if zoneIndex==2 then "THE FIRST GUEST" else "NO NAME")
		b.lantern(props,V(cx+10,6,cz-11.8),0.8,Color3.fromRGB(255,172,91))
		p(props,"LanternBracket",V(cx+10,5.9,cz-12),V(2,0.3,1.4),C.ink,Enum.Material.Metal)
		b.desk(props,V(cx+8,0,cz+6),6)
		b.chair(props,V(cx+8,0,cz+10))
		add(V(cx-6,3.45,cz-4),(zoneIndex*3)%10+1)
		add(V(cx-2,3.45,cz-4),(zoneIndex*3+1)%10+1)
		add(V(cx+8,3.45,cz+6),(zoneIndex*3+2)%10+1)
		add(V(cx-8,10.35,cz-11.5),(zoneIndex*3+3)%10+1)
		local pedestal=p(props,"EvidencePedestal",V(cx+12,1.5,cz-2),V(3,3,3),C.stone,Enum.Material.Marble)
		add(V(cx+12,3.1,cz-2),(zoneIndex*3+4)%10+1)
	end
	if big then
		-- Two long wings connect through wide arch openings and the central gallery.
		for _,x in ipairs({-25,25}) do p(architecture,"WingDivider",V(x,8,0),V(26,16,0.7),C.stone,Enum.Material.Brick) end
		for _,x in ipairs({-12,12}) do
			for _,z in ipairs({-21,21}) do p(architecture,"GalleryPartition",V(x,8,z),V(0.7,16,20),C.stone,Enum.Material.Brick) end
			p(architecture,"DoorLintel",V(x,13,0),V(1.3,6,22),C.trim,Enum.Material.Slate)
			for _,z in ipairs({-10,10}) do p(architecture,"ArchPillar",V(x,6,z),V(1.6,12,1.3),C.trim,Enum.Material.Slate) end
		end
		furnishedZone(-25,-15,1) furnishedZone(25,-15,2)
		furnishedZone(-25,15,3) furnishedZone(25,15,4)
		b.desk(props,V(0,0,-17),12) b.candles(props,V(0,3.4,-17),5)
		add(V(-4,3.45,-17),1) add(V(4,3.45,-17),3)
		for _,z in ipairs({-5,12}) do
			for _,x in ipairs({-5,5}) do p(props,"GalleryPlinth",V(x,1.5,z),V(3,3,3),C.stone,Enum.Material.Marble); add(V(x,3.1,z),if x<0 then 8 else 9) end
		end
		for _,z in ipairs({-27,0,26}) do b.lantern(props,V(0,8,z),1) end
	else
		furnishedZone(0,0,1)
		b.desk(props,V(-9,0,10),8) b.candles(props,V(-12,3.4,10),2)
		add(V(-9,3.45,10),1) add(V(-5.5,3.45,10),2)
		b.desk(props,V(5,0,-11),7)
		add(V(3,3.45,-11),9) add(V(7,3.45,-11),10)
		for _,pos in ipairs({V(-13,0,0),V(12,0,12),V(1,0,7)}) do
			p(props,"StoneStand",pos+V(0,1.5,0),V(2.8,3,2.8),C.stone,Enum.Material.Marble)
			add(pos+V(0,3.1,0),(#targets%10)+1)
		end
		b.lantern(props,V(-14,6,12),0.8)
	end
	-- Low ambient lamps preserve silhouettes while flashlights reveal the details.
	local entry=V(if big then 0 else -2.5,4,d/2-9)
	local entrance=p(props,"EntryDoor",V(0,5,d/2-0.6),V(6,10,0.4),C.wood,Enum.Material.WoodPlanks)
	b.sign(entrance,if big then "BLACKTHORN MANOR\nNO GUEST LEAVES UNCHANGED" else "THE KEEPER'S STUDY\nREMEMBER WHAT BELONGS",18,C.ivory)
	for _,x in ipairs({-4,4}) do b.lantern(props,V(x,5,d/2-1.5),0.65) end
	return {model=b.root,spawn=CFrame.new(origin+entry,origin+V(0,4,0)),targets=targets,key=key}
end

function World.reset(map)
	for _,target in map.targets do
		for _,s in target.saved do s.part.Transparency=s.transparency s.part.CanCollide=s.collide end
		target.prompt.Enabled=false
	end
end
function World.hide(map,missing)
	for index,target in map.targets do
		if missing[index] then for _,s in target.saved do s.part.Transparency=1 s.part.CanCollide=false end end
	end
end
function World.lighting()
	local lighting=game:GetService("Lighting")
	lighting.ClockTime=0.4 lighting.Brightness=1.5 lighting.Ambient=Color3.fromRGB(36,42,60) lighting.OutdoorAmbient=Color3.fromRGB(49,60,82) lighting.ExposureCompensation=0.05 lighting.GlobalShadows=true
	pcall(function() lighting.LightingStyle=Enum.LightingStyle.Realistic lighting.PrioritizeLightingQuality=true end)
	local sky=lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky") sky.Name="TRILNightSky" sky.StarCount=3000 sky.MoonAngularSize=0 sky.CelestialBodiesShown=true sky.Parent=lighting
	local atmosphere=lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere") atmosphere.Name="TRILAtmosphere" atmosphere.Density=0.32 atmosphere.Offset=0.2 atmosphere.Color=Color3.fromRGB(130,151,175) atmosphere.Decay=Color3.fromRGB(36,44,66) atmosphere.Glare=0.15 atmosphere.Haze=1.6 atmosphere.Parent=lighting
	local bloom=lighting:FindFirstChild("TRILBloom") or Instance.new("BloomEffect") bloom.Name="TRILBloom" bloom.Intensity=0.2 bloom.Size=22 bloom.Threshold=1.6 bloom.Parent=lighting
	local grade=lighting:FindFirstChild("TRILGrade") or Instance.new("ColorCorrectionEffect") grade.Name="TRILGrade" grade.Brightness=-0.015 grade.Contrast=0.14 grade.Saturation=-0.15 grade.TintColor=Color3.fromRGB(218,231,255) grade.Parent=lighting
end
return World
