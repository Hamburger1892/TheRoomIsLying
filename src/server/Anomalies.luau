--!strict
local Anomalies = {}
Anomalies.kinds = { "Disappeared", "Color", "Moved", "Rotated", "Resized", "Appeared", "Painting", "Swapped", "Light" }

function Anomalies.capture(room)
	local saved = {}
	for _, object in room.model:GetDescendants() do
		if object:IsA("BasePart") then
			table.insert(saved, { object=object, cf=object.CFrame, size=object.Size, color=object.Color, transparency=object.Transparency, collide=object.CanCollide })
		elseif object:IsA("PointLight") then
			table.insert(saved, { object=object, color=object.Color, enabled=object.Enabled })
		end
	end
	return saved
end

function Anomalies.restore(saved)
	for _, state in saved do
		local object=state.object
		if object:IsA("BasePart") then
			object.CFrame=state.cf object.Size=state.size object.Color=state.color
			object.Transparency=state.transparency object.CanCollide=state.collide
		else
			object.Color=state.color object.Enabled=state.enabled
		end
	end
end

function Anomalies.apply(room, kind: string, difficulty: number)
	local m=room.model
	local targets={}
	local description="Nothing changed. The room was telling the truth this time."
	local function target(name)
		local object=m:FindFirstChild(name)
		assert(object and object:IsA("Model"), "Missing observation object " .. name)
		table.insert(targets,object)
		return object
	end
	if kind=="None" then return { changed=false, kind=kind, description=description, targets=targets } end
	if kind=="Disappeared" then
		for _,p in target("Duck"):GetDescendants() do if p:IsA("BasePart") then p.Transparency=1 p.CanCollide=false end end
		description="The little yellow duck disappeared from the bookshelf."
	elseif kind=="Color" then
		local cushion=target("MintCushion")
		cushion.PrimaryPart.Color=Color3.fromRGB(248,136,200)
		description="The mint cushion turned pink."
	elseif kind=="Moved" then
		local tableModel=target("CoffeeTable")
		-- Table-top objects stay with the table as one readable change.
		local delta=Vector3.new(if difficulty==1 then 3 else if difficulty==2 then 2 else 1.2,0,0)
		for _,name in ipairs({"CoffeeTable","TableBooks","Mug","FruitBowl"}) do
			local object=m[name] object:PivotTo(object:GetPivot()+delta)
		end
		description="The coffee table and everything on it slid to the right."
	elseif kind=="Rotated" then
		local duck=target("Duck") duck:PivotTo(duck:GetPivot()*CFrame.Angles(0,math.rad(if difficulty==1 then 100 else 50),0))
		description="The duck turned to face a different direction."
	elseif kind=="Resized" then
		local vase=target("Vase") local pivot=vase:GetPivot()
		local factor=if difficulty==1 then 1.6 else if difficulty==2 then 1.4 else 1.25
		for _,p in vase:GetDescendants() do
			if p:IsA("BasePart") then
				local offset=pivot:ToObjectSpace(p.CFrame)
				p.Size*=factor p.CFrame=pivot*CFrame.new(offset.Position*factor)*offset.Rotation
			end
		end
		description="The coral vase grew larger."
	elseif kind=="Appeared" then
		for _,p in target("SurpriseGift"):GetDescendants() do if p:IsA("BasePart") then p.Transparency=0 p.CanCollide=true end end
		description="A mysterious purple gift appeared on the rug."
	elseif kind=="Painting" then
		local painting=target("Painting") painting:PivotTo(painting:GetPivot()*CFrame.Angles(0,0,math.rad(if difficulty==1 then 90 else 30)))
		description="The sunset painting tilted on the wall."
	elseif kind=="Swapped" then
		local a=target("MintCushion") local b=target("GoldCushion")
		local ca,cb=a:GetPivot(),b:GetPivot()
		a:PivotTo(CFrame.new(cb.Position)*ca.Rotation) b:PivotTo(CFrame.new(ca.Position)*cb.Rotation)
		description="The mint and gold cushions swapped places."
	elseif kind=="Light" then
		local lamp=target("FloorLamp")
		lamp.Shade.Color=Color3.fromRGB(128,183,255) lamp.Shade.PointLight.Color=Color3.fromRGB(128,183,255)
		description="The warm floor lamp changed to cool blue."
	else
		error("Unknown anomaly " .. kind)
	end
	return { changed=true, kind=kind, description=description, targets=targets }
end
return Anomalies
