print("Server code running.")

map = game.GetMap()

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

roundtime = GetConVarNumber("inf_roundtime")
preptime = 7--GetConVarNumber("inf_preptime")
endtime = GetConVarNumber("inf_endtime")
endcurrent = 0
prepcurrent = 0
roundcurrent = 0
baddies = {}
goodies = {}
print(roundtime.." "..preptime.." "..endtime)

dataStolen = false
allDefendersDead = false
allInfiltratorsDead = false

function sendTime(thetime, segment)
	umsg.Start("thetimes")
	umsg.String(segment..thetime)
	umsg.End()
end

function checkVictoryType()
	vicType = "Unknown"
	if dataStolen then
		vicType = "Infiltrators"
	elseif allDefendersDead then
		vicType = "Infiltrators"
	elseif allInfiltratorsDead then
		vicType = "Defenders"
	end
	print(vicType)
	return vicType
end

function convertTime(thetime)
	a = thetime/60
	if a >= 1 then
		a = math.floor(a, 0.5)
		thetime = thetime - (a*60)
	else
		a = 0
	end
	if thetime < 10 then
		thetime = "0"..thetime
	end
	endResult = a..":"..thetime
	return endResult
end

function sendVic(vic)
	umsg.Start("victory")
	umsg.String(vic)
	umsg.End()
end

function endGame()
	if endcurrent < endtime then
		endcurrent = endcurrent + 1
		sendTime(convertTime(endtime-endcurrent), "End: ")
		timer.Create("endgametimer", 1, 1, endGame)
	else
		sendVic("")
		endcurrent = 0
		forceSpawnAll()
		begin()
	end
end

function start()
	if roundcurrent < roundtime then
		if dataStolen or allInfiltratorsDead or allDefendersDead then
			roundcurrent = roundtime
		end
		if not checkAlive(baddies) then
			allInfiltratorsDead = true
		end
		if not checkAlive(goodies) then
			allDefendersDead = true
		end
		roundcurrent = roundcurrent + 1
		sendTime(convertTime(roundtime-roundcurrent), "Game: ")
		timer.Create("roundtimetimer", 1, 1, start)
	else
		local vic = checkVictoryType()
		sendVic(vic.." win!")
		roundcurrent = 0
		endGame()
	end
end

--This function chooses which side they are on and also sends the message for them to get their weapons.
function choosePeople()
	plys = player.GetAll()
	local b = #plys/10
	--Set how many Infiltrators there are.
	if b < 1 then
		c = 1
	else
		c = math.floor(b, 0.5) --Rounds so that are are a good number of infiltrators
	end
	d = 0
	baddies = {}
	goodies = {}
	--Set Infiltrators and Defenders.
	while d < c do
		for i = 1, #plys do
			found = false
			local r = math.random(10)
			if r == 1 then
				for z = 1, #baddies do
					if baddies[z][1] == plys[i] then
						found = true
					end
				end
				if not found then
					table.insert(baddies, {plys[i], "baddie"})
					d = d + 1
				else
					table.insert(goodies, {plys[i], "goodie"})
				end
			end
		end
	end
	print("Baddies:")
	for _, q in pairs(baddies) do
		print(q[1]:Nick())
	end
	print("Goodies:")
	for _, e in pairs(goodies) do
		print(e[1]:Nick())
	end
	--Send roles to players.
	found = false
	for s = 1, #plys do
		plys[s]:Give("weapon_crowbar")
		local role = ""
		local msg = "noteam"
		for z = 1, #goodies do
			if goodies[z][1] == plys[s] then
				found = true
			end
		end
		umsg.Start("team", s)
		umsg.String(msg)
		umsg.End()
		found = false
		for _, q in pairs(plys) do
			umsg.Start("spawn", q)
			umsg.String(q)
			umsg.End()
		end
	end
	--Start the main gameplay
	start()
end

function checkAlive(tab)
	alive = false
	for i = 1, #tab do
		if tab[i][1]:Alive() then
			alive = true
		end
	end
	return alive
end

function begin()
	if prepcurrent < preptime then
		prepcurrent = prepcurrent + 1
		sendTime(convertTime(preptime-prepcurrent), "Preparation: ")
		timer.Create("preptimetimer", 1, 1, begin)
	else
		prepcurrent = 0
		choosePeople()
	end
end

--Disables respawning
function disableRespawn(pl)
	return false
end

--Forces everyone to respawn
function forceSpawnAll()
	local plys = player.GetAll()
	for _, v in pairs(plys) do
		v:KillSilent()
		v:Spawn()
	end
end

--Sets spectator mode for dead players.
function onDeath(pl)
	GAMEMODE:PlayerSpawnAsSpectator(pl)
	pl:Spectate(OBS_MODE_ROAMING)
end

forceSpawnAll()
begin()

hook.Add("PlayerDeathThink", "player_step_forcespawn", disableRespawn)
hook.Add("PlayerDeath", "player_death_test", onDeath)