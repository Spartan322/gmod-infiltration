include("shared.lua")
a = ""
b = "noteam"
c = "No Team"
d = ""
cc = Color(255, 255, 255, 255)

Teams= {}

Teams.Infil = {}
Teams.Guard = {}
Teams.Infil.Hud = {name = "Infiltrator", color = Color(255,0,0,255)}
Teams.Guard.Hud = {name = "Defender", color = Color(0,255,0,255)}

function getTime(thetime)
	a = thetime:ReadString()
end

function getTeam(team)
	b = team:ReadString()
end

function getVictory(vic)
	d = vic:ReadString()
end

function GM:HUDPaint() --Draw text on screen.
	draw.SimpleText(a, "DermaLarge", ScrW() / 2, ScrH() - 63, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if b == "noteam" then
		c = "No Team"
		cc = Color(250, 250, 210, 255)
	elseif b == "baddies" then
		c = Teams.Infil.Hud.name
		cc = Teams.Infil.Hud.color
	elseif b == "goodies" then
		c = Teams.Guard.Hud.name
		cc = Teams.Guard.Hud.color
	end
	draw.SimpleText(c, "DermaLarge", ScrW() / 2, 63, cc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(d, "DermaLarge", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function spawnDerma(pl)
	dchosen = ""
	dammotype = ""
	dammo = 0
	ichosen = ""
	iammotype = ""
	iammo = 0
	local frame = vgui.Create("DFrame")
	frame:SetPos(50, 50)
	frame:SetSize(ScrW()-100, ScrH()-100)
	frame:SetTitle("Choose Your Gear")
	frame:SetVisible(true)
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	local finish = vgui.Create("DButton", frame)
	finish:SetPos(100, ScrH()-200)
	finish:SetSize(ScrW()-1000, 50)
	if b == "goodies" then
		finish:SetText("Start with no gear")
		finish.DoClick = function()
			RunConsoleCommand("give", dchosen)
			frame:SetVisible(false)
		end
	else
		finish:SetText("Start with no gear")
		finish.DoClick = function()
			RunConsoleCommand("give", dchosen)
			RunConsoleCommand("give", ichosen)
			frame:SetVisible(false)
		end
	end
	
	local defendCat = vgui.Create("DCollapsibleCategory", frame)
	defendCat:SetPos(100, 100)
	defendCat:SetSize(ScrW()/2 - 175, 50)
	defendCat:SetExpanded(1)
	defendCat:SetLabel("Generic Gear")
	
	local dlist = vgui.Create("DPanelList")
	dlist:SetAutoSize(true)
	dlist:SetSpacing(5)
	dlist:EnableHorizontal(false)
	dlist:EnableVerticalScrollbar(true)
	
	defendCat:SetContents(dlist)
	
	local dl1 = vgui.Create("DButton")
	dl1:SetText("Pistol (18 shots)")
	dl1.DoClick = function()
		dchosen = "weapon_pistol"
		dammotype = "Pistol"
		dammo = 36
		if b == "goodies" then
			finish:SetText("Start with "..dchosen)
		else
			finish:SetText("Start with "..dchosen.." and "..ichosen)
		end
	end
	dlist:AddItem(dl1)
	
	local dl2 = vgui.Create("DButton")
	dl2:SetText("357 (6 shots)")
	dl2.DoClick = function()
		dchosen = "weapon_357"
		dammotype = "357"
		dammo = 6
		if b == "goodies" then
			finish:SetText("Start with "..dchosen)
		else
			finish:SetText("Start with "..dchosen.." and "..ichosen)
		end
	end
	dlist:AddItem(dl2)
	
	--if b == "baddies" then
		local infilCat = vgui.Create("DCollapsibleCategory", frame)
		infilCat:SetPos(ScrW()/2, 100)
		infilCat:SetSize(ScrW()/2 - 175, 50)
		infilCat:SetExpanded(1)
		infilCat:SetLabel("Infiltrator Gear")
		
		local ilist = vgui.Create("DPanelList")
		ilist:SetAutoSize(true)
		ilist:SetSpacing(5)
		ilist:EnableHorizontal(false)
		ilist:EnableVerticalScrollbar(true)
		
		infilCat:SetContents(ilist)
		
		local il1 = vgui.Create("DButton")
		il1:SetText("Shotgun (6 shots)")
		il1.DoClick = function()
			ichosen = "weapon_shotgun"
			iammotype = "Buckshot"
			iammo = 6
			if b == "goodies" then
				finish:SetText("Start with "..dchosen)
			else
				finish:SetText("Start with "..dchosen.." and "..ichosen)
			end
		end
		ilist:AddItem(il1)
		
		local il2 = vgui.Create("DButton")
		il2:SetText("Crossbow (5 bolts)") --Until I figure this out properly, it's stuck at an overpowered level.
		il2.DoClick = function()
			ichosen = "weapon_crossbow"
			iammotype = "XBowBolt"
			iammo = 1
			if b == "goodies" then
				finish:SetText("Start with "..dchosen)
			else
				finish:SetText("Start with "..dchosen.." and "..ichosen)
			end
		end
		ilist:AddItem(il2)
	--end
	
end

usermessage.Hook("thetimes", getTime)
usermessage.Hook("team", getTeam)
usermessage.Hook("victory", getVictory)
usermessage.Hook("spawn", spawnDerma)
