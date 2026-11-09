--!strict
-- A readable cutaway living room, built entirely from anchored native parts.
local Builder = {}
local C = {
	cream = Color3.fromRGB(245, 228, 196), wood = Color3.fromRGB(151, 101, 75),
	purple = Color3.fromRGB(126, 88, 196), mint = Color3.fromRGB(117, 218, 180),
	coral = Color3.fromRGB(246, 126, 133), yellow = Color3.fromRGB(255, 209, 106),
	ink = Color3.fromRGB(42, 51, 78), cyan = Color3.fromRGB(105, 211, 233),
	green = Color3.fromRGB(74, 155, 112), white = Color3.fromRGB(255, 248, 230),
}
local O = Vector3.new(0, 48, 0)

function Builder.build()
	local room = Instance.new("Model")
	room.Name = "TRILObservationRoom"
	local items = {}
	local function model(name, label)
		local m = Instance.new("Model")
		m.Name = name
		m:SetAttribute("DisplayName", label or name)
		m.Parent = room
		return m
	end
	local function block(parent, name, position, size, color, shape, rotation)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = CFrame.new(O + position) * (rotation or CFrame.identity)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = true
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		if shape then p.Shape = shape end
		p.Parent = parent
		if parent:IsA("Model") and not parent.PrimaryPart then parent.PrimaryPart = p end
		return p
	end
	local function ball(parent, name, position, size, color)
		return block(parent, name, position, size, color, Enum.PartType.Ball)
	end
	local function item(m, label, colorPart)
		local record = { model = m, label = label, colorPart = colorPart or m.PrimaryPart }
		table.insert(items, record)
		return record
	end
	local architecture = model("Architecture", "The living room")
	local backdrop=block(architecture,"Backdrop",Vector3.new(0,-4,0),Vector3.new(512,1,512),Color3.fromRGB(34,43,65))
	backdrop.CanCollide=false
	block(architecture, "Floor", Vector3.new(0, -0.6, 0), Vector3.new(36, 1, 28), C.wood)
	for z = -13, 13, 2 do
		block(architecture, "Floorboard", Vector3.new(0, -0.03, z), Vector3.new(35.8, 0.08, 1.94), if z % 4 == 1 then Color3.fromRGB(195, 153, 113) else Color3.fromRGB(210, 169, 129))
	end
	block(architecture, "BackWall", Vector3.new(0, 7.4, -14), Vector3.new(36, 15, 0.5), Color3.fromRGB(180, 199, 206))
	block(architecture, "LeftWall", Vector3.new(-18, 7.4, 0), Vector3.new(0.5, 15, 28), Color3.fromRGB(215, 207, 230))
	block(architecture, "BaseboardBack", Vector3.new(0, 0.55, -13.6), Vector3.new(36, 1, 0.3), C.white)
	block(architecture, "BaseboardLeft", Vector3.new(-17.6, 0.55, 0), Vector3.new(0.3, 1, 28), C.white)
	block(architecture, "CrownBack", Vector3.new(0, 14.5, -13.6), Vector3.new(36, 0.45, 0.4), C.white)
	block(architecture, "CrownLeft", Vector3.new(-17.6, 14.5, 0), Vector3.new(0.4, 0.45, 28), C.white)
	-- Low front/right edges keep every important item visible from the camera.
	block(architecture, "FrontEdge", Vector3.new(0, -0.25, 14), Vector3.new(36, 0.7, 0.5), C.white)
	block(architecture, "RightEdge", Vector3.new(18, -0.25, 0), Vector3.new(0.5, 0.7, 28), C.white)

	local rug = model("Rug", "Lavender rug")
	block(rug, "Border", Vector3.new(-2, 0.1, 4), Vector3.new(23, 0.15, 15), C.white)
	local rugColor = block(rug, "Fabric", Vector3.new(-2, 0.2, 4), Vector3.new(22, 0.12, 14), Color3.fromRGB(163, 144, 202))
	for x = -11, 7, 3 do block(rug, "Stitch", Vector3.new(x, 0.28, 4), Vector3.new(0.09, 0.04, 12), Color3.fromRGB(198, 183, 226)) end
	item(rug, "lavender rug", rugColor)

	local sofa = model("Sofa", "The coral sofa")
	for _, x in ipairs({ -13, -3 }) do
		for _, z in ipairs({ -6, -2 }) do block(sofa, "Foot", Vector3.new(x, 0.5, z), Vector3.new(0.5, 1, 0.5), C.wood) end
	end
	block(sofa, "Base", Vector3.new(-8, 1.2, -4), Vector3.new(12, 1.2, 5.6), C.coral)
	local sofaBack = block(sofa, "Back", Vector3.new(-8, 3.2, -6.4), Vector3.new(12.8, 3.4, 1.2), C.coral)
	for _, x in ipairs({ -14, -2 }) do block(sofa, "Arm", Vector3.new(x, 2.5, -4), Vector3.new(1.3, 2.5, 5.8), C.coral) end
	for x = -12, -4, 4 do block(sofa, "Seat", Vector3.new(x, 2, -3.8), Vector3.new(3.8, 0.7, 4.3), Color3.fromRGB(255, 156, 158)) end
	item(sofa, "coral sofa", sofaBack)
	for index, spec in ipairs({ {"MintCushion", -11, C.mint}, {"GoldCushion", -5, C.yellow} }) do
		local m = model(spec[1], if index == 1 then "Mint cushion" else "Gold cushion")
		local p = block(m, "Cushion", Vector3.new(spec[2], 3.35, -5.3), Vector3.new(2.2, 2.1, 0.9), spec[3], nil, CFrame.Angles(0, 0, math.rad(if index == 1 then -12 else 12)))
		item(m, string.lower(m:GetAttribute("DisplayName")), p)
	end
	local tableModel = model("CoffeeTable", "Coffee table")
	local tabletop = block(tableModel, "Top", Vector3.new(-6, 2, 4.2), Vector3.new(10, 0.5, 5), C.cream)
	for _, x in ipairs({ -10, -2 }) do for _, z in ipairs({ 2.6, 5.8 }) do block(tableModel, "Leg", Vector3.new(x, 1, z), Vector3.new(0.4, 2, 0.4), C.wood) end end
	item(tableModel, "coffee table", tabletop)
	local books = model("TableBooks", "Coffee table books")
	block(books, "BookA", Vector3.new(-8, 2.45, 3.5), Vector3.new(2.6, 0.35, 1.8), C.purple)
	local bookTop = block(books, "BookB", Vector3.new(-8, 2.8, 3.5), Vector3.new(2.3, 0.32, 1.7), C.cyan, nil, CFrame.Angles(0, math.rad(12), 0))
	item(books, "stack of books", bookTop)
	local mug = model("Mug", "Cyan mug")
	local cup = block(mug, "Cup", Vector3.new(-3.3, 2.7, 4.5), Vector3.new(1, 1, 1), C.cyan, Enum.PartType.Cylinder, CFrame.Angles(0, 0, math.pi/2))
	block(mug, "Handle", Vector3.new(-2.7, 2.7, 4.5), Vector3.new(0.4, 0.6, 0.4), C.cyan)
	item(mug, "cyan mug", cup)
	local bowl = model("FruitBowl", "Fruit bowl")
	block(bowl, "Bowl", Vector3.new(-5.5, 2.55, 3.8), Vector3.new(2.2, 0.5, 1.7), C.mint)
	ball(bowl, "Apple", Vector3.new(-5.9, 3, 3.8), Vector3.new(0.85, 0.85, 0.85), C.coral)
	ball(bowl, "Orange", Vector3.new(-5.1, 3, 3.8), Vector3.new(0.85, 0.85, 0.85), C.yellow)
	item(bowl, "fruit bowl")

	local stand = model("TVStand", "Television stand")
	block(stand, "Cabinet", Vector3.new(10, 1.8, -11.3), Vector3.new(11, 3, 3.6), C.wood)
	for x = 7, 13, 3 do block(stand, "Door", Vector3.new(x, 1.9, -9.4), Vector3.new(2.8, 2.4, 0.1), C.cream); block(stand, "Handle", Vector3.new(x, 2.4, -9.25), Vector3.new(0.6, 0.15, 0.15), C.ink) end
	item(stand, "television stand")
	local television = model("Television", "Television")
	block(television, "Foot", Vector3.new(10, 3.6, -11.2), Vector3.new(3.5, 0.3, 1.6), C.ink)
	block(television, "Frame", Vector3.new(10, 6.5, -11.4), Vector3.new(9.5, 5.7, 0.5), C.ink)
	local screen = block(television, "Screen", Vector3.new(10, 6.5, -11.08), Vector3.new(8.8, 5, 0.1), Color3.fromRGB(68, 100, 125))
	block(television, "TestCardA", Vector3.new(8.6, 6.5, -10.98), Vector3.new(2.3, 3, 0.1), C.purple)
	block(television, "TestCardB", Vector3.new(11.2, 6.5, -10.98), Vector3.new(2.3, 3, 0.1), C.mint)
	item(television, "television", screen)
	local speaker = model("Speaker", "Radio speaker")
	block(speaker, "Case", Vector3.new(15, 4.2, -11.2), Vector3.new(1.5, 1.7, 1.4), C.ink)
	ball(speaker, "Cone", Vector3.new(15, 4.2, -10.45), Vector3.new(0.8, 0.8, 0.1), C.yellow)
	item(speaker, "radio speaker")

	local shelf = model("Bookshelf", "Bookshelf")
	for _, x in ipairs({ -16, -10 }) do block(shelf, "Side", Vector3.new(x, 5, -11.8), Vector3.new(0.4, 10, 3), C.white) end
	for y = 0.3, 10, 2.5 do block(shelf, "Shelf", Vector3.new(-13, y, -11.8), Vector3.new(6.4, 0.3, 3), C.white) end
	item(shelf, "bookshelf")
	for row = 1, 3 do
		local m = model("ShelfBooks" .. row, "Shelf books " .. row)
		for n = 1, 5 do
			block(m, "Spine" .. n, Vector3.new(-15.5+n*0.7, (row-1)*2.5+1.2, -11.5), Vector3.new(0.5, 1.6+(n%2)*0.4, 1.6), ({C.coral,C.cyan,C.yellow,C.purple,C.mint})[n], nil, CFrame.Angles(0,0,if n==5 then 0.12 else 0))
		end
		item(m, "row " .. row .. " of books")
	end
	local duck = model("Duck", "Little yellow duck")
	ball(duck, "Body", Vector3.new(-13.5, 8.3, -11.5), Vector3.new(1.4, 1.2, 1.6), C.yellow)
	ball(duck, "Head", Vector3.new(-13.5, 9.1, -11.2), Vector3.new(1, 1, 1), C.yellow)
	block(duck, "Beak", Vector3.new(-13.5, 8.95, -10.55), Vector3.new(0.6, 0.2, 0.6), C.coral)
	for _, x in ipairs({ -13.8, -13.2 }) do ball(duck,"Eye",Vector3.new(x,9.25,-10.75),Vector3.new(0.13,0.13,0.13),C.ink) end
	item(duck, "little yellow duck")

	local function painting(name, x, color)
		local m=model(name, "Sunset painting")
		block(m,"Frame",Vector3.new(x,9.4,-13.55),Vector3.new(4.5,4.8,0.3),C.wood)
		local canvas=block(m,"Canvas",Vector3.new(x,9.4,-13.3),Vector3.new(3.9,4.2,0.15),color)
		ball(m,"Sun",Vector3.new(x+0.6,10.15,-13.15),Vector3.new(1.3,1.3,0.08),C.yellow)
		block(m,"Horizon",Vector3.new(x,8.4,-13.12),Vector3.new(3.7,1.3,0.1),C.mint)
		return item(m,"sunset painting",canvas)
	end
	painting("Painting",-5.8,C.purple)
	local clock=model("Clock","Wall clock")
	local dial=block(clock,"Dial",Vector3.new(1,11,-13.35),Vector3.new(3,3,0.35),C.cream)
	block(clock,"HourHand",Vector3.new(0.6,11,-13.05),Vector3.new(0.9,0.15,0.1),C.ink)
	block(clock,"MinuteHand",Vector3.new(1,11.6,-13.05),Vector3.new(0.15,1.3,0.1),C.ink)
	item(clock,"wall clock",dial)

	local window=model("Window","Sunny window")
	block(window,"Frame",Vector3.new(-17.6,9,1),Vector3.new(0.35,7.6,7),C.white)
	block(window,"Sky",Vector3.new(-17.35,9,1),Vector3.new(0.1,6.8,6.2),Color3.fromRGB(147,214,232))
	block(window,"CrossV",Vector3.new(-17.15,9,1),Vector3.new(0.2,7,0.18),C.white)
	block(window,"CrossH",Vector3.new(-17.15,9,1),Vector3.new(0.2,0.18,6.7),C.white)
	item(window,"sunny window")
	for _, z in ipairs({ -3.1, 5.1 }) do
		local curtain=model(if z<0 then "CurtainLeft" else "CurtainRight","Lilac curtain")
		local fabric=block(curtain,"Fabric",Vector3.new(-17,8.5,z),Vector3.new(0.6,8,1.5),C.purple)
		item(curtain,"lilac curtain",fabric)
	end

	local function plant(name,pos)
		local m=model(name,"Indoor plant")
		local pot=block(m,"Pot",pos+Vector3.new(0,0.9,0),Vector3.new(2,1.8,2),C.cream)
		block(m,"Stem",pos+Vector3.new(0,2.7,0),Vector3.new(0.22,3.2,0.22),C.wood)
		for n=1,5 do local angle=n*math.pi*0.4; ball(m,"Leaf",pos+Vector3.new(math.cos(angle),3.1+(n%2)*0.6,math.sin(angle)),Vector3.new(1.7,1,1.2),if n%2==0 then C.green else C.mint) end
		return item(m,"indoor plant",pot)
	end
	plant("LargePlant",Vector3.new(-14,0,9))
	plant("SmallPlant",Vector3.new(15,0,9))
	local chair=model("Armchair","Mustard armchair")
	block(chair,"Base",Vector3.new(11,1.4,2.5),Vector3.new(5,1.5,5),C.yellow)
	local chairBack=block(chair,"Back",Vector3.new(11,3.3,0.3),Vector3.new(5,3.8,1),C.yellow)
	for _, x in ipairs({8.5,13.5}) do block(chair,"Arm",Vector3.new(x,2.5,2.5),Vector3.new(0.8,2,5),C.yellow) end
	item(chair,"mustard armchair",chairBack)
	local ottoman=model("Ottoman","Mint ottoman")
	local top=block(ottoman,"Top",Vector3.new(7,1.1,9),Vector3.new(5,2,4),C.mint)
	item(ottoman,"mint ottoman",top)
	local lamp=model("FloorLamp","Floor lamp")
	block(lamp,"Base",Vector3.new(15,0.25,-4),Vector3.new(2.5,0.4,2.5),C.ink)
	block(lamp,"Stem",Vector3.new(15,3.5,-4),Vector3.new(0.25,6.5,0.25),C.ink)
	local shade=block(lamp,"Shade",Vector3.new(15,7,-4),Vector3.new(3.5,2.3,3.5),C.yellow)
	local light=Instance.new("PointLight") light.Color=C.yellow light.Brightness=0.8 light.Range=16 light.Shadows=true light.Parent=shade
	item(lamp,"floor lamp",shade)
	local side=model("SideTable","Side table")
	block(side,"Top",Vector3.new(1,2.8,-3.5),Vector3.new(3.2,0.3,3.2),C.wood)
	block(side,"Pedestal",Vector3.new(1,1.4,-3.5),Vector3.new(0.5,2.8,0.5),C.wood)
	item(side,"side table")
	local vase=model("Vase","Coral vase")
	local body=ball(vase,"Body",Vector3.new(1,3.7,-3.5),Vector3.new(1.5,1.7,1.5),C.coral)
	block(vase,"Neck",Vector3.new(1,4.5,-3.5),Vector3.new(0.6,0.5,0.6),C.coral)
	item(vase,"coral vase",body)
	local basket=model("Basket","Woven basket")
	block(basket,"Basket",Vector3.new(-13,0.9,3),Vector3.new(2.5,1.8,2.5),Color3.fromRGB(192,140,86))
	for y=0.4,1.6,0.4 do block(basket,"Weave",Vector3.new(-13,y,4.27),Vector3.new(2.4,0.09,0.06),C.cream) end
	item(basket,"woven basket")
	local slippers=model("Slippers","Cozy slippers")
	for _, x in ipairs({-10,-8.8}) do ball(slippers,"Slipper",Vector3.new(x,0.35,9.5),Vector3.new(0.85,0.6,1.8),C.coral) end
	item(slippers,"cozy slippers")
	local star=model("Star","Golden star trophy")
	block(star,"Base",Vector3.new(4,0.3,-10.5),Vector3.new(2,0.5,2),C.purple)
	block(star,"Stem",Vector3.new(4,1.5,-10.5),Vector3.new(0.2,2,0.2),C.yellow)
	block(star,"StarA",Vector3.new(4,2.8,-10.5),Vector3.new(2,2,0.3),C.yellow,nil,CFrame.Angles(0,0,math.pi/4))
	item(star,"golden trophy")
	local gift=model("SurpriseGift","Surprise gift")
	block(gift,"Box",Vector3.new(3,0.9,7),Vector3.new(2.2,1.8,2.2),C.purple)
	block(gift,"Ribbon",Vector3.new(3,1.85,7),Vector3.new(2.3,0.2,0.4),C.yellow)
	for _,p in gift:GetDescendants() do if p:IsA("BasePart") then p.Transparency=1 p.CanCollide=false end end
	-- All registry metadata and original transforms remain in server memory.
	return { model=room, items=items, origin=O, gift=gift }
end
return Builder
