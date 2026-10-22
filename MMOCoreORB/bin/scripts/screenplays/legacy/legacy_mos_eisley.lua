local Runtime = require("legacy.quest_runtime")

-- Original quest/task identities are retained. NGE level 1/level-10 routing is
-- reference data only; eligibility never depends on level or profession.
LegacyMosEisley = ScreenPlay:new {
	screenplayName = "LegacyMosEisley",
	planet = "tatooine",
	-- Original tatooine_6_2 buildout groups within 150 m of the steering array.
	-- Coordinates include that buildout area's (+2048, -6144) world offset.
	-- Source behavior 0 is normalized to 2 (loiter) by ai_lib; Core3's normal
	-- outdoor idle behavior supplies the equivalent wandering without new paths.
	campTuskenGroups = {
		-- id, x, z, y, heading, radius, minimum/maximum respawn seconds, count
		{id = "01", x = 4094.31, z = 5.15873, y = -4744.51, heading = 86.4356, radius = 5, minimum = 60, maximum = 75, count = 3},
		{id = "03", x = 4076.09, z = 5, y = -4816.24, heading = -26.0295, radius = 2, minimum = 45, maximum = 60, count = 3},
		{id = "04", x = 4050, z = 5, y = -4858, heading = 33.8373, radius = 5, minimum = 60, maximum = 90, count = 3},
		{id = "05", x = 4049, z = 5, y = -4799, heading = 179.2223, radius = 3, minimum = 60, maximum = 90, count = 3},
		{id = "06", x = 4068.67, z = 5, y = -4757.71, heading = -164.3255, radius = 3, minimum = 60, maximum = 90, count = 3},
		{id = "07", x = 4021, z = 5, y = -4804, heading = -129.4569, radius = 3, minimum = 60, maximum = 90, count = 3},
		{id = "08", x = 4001, z = 5, y = -4781, heading = 135.8635, radius = 3, minimum = 60, maximum = 90, count = 3},
		{id = "09", x = 3990, z = 5, y = -4806, heading = -157.0996, radius = 3, minimum = 60, maximum = 90, count = 3},
		{id = "10", x = 4046.19, z = 5, y = -4766.07, heading = 108.7863, radius = 3, minimum = 60, maximum = 90, count = 3},
		{id = "11", x = 4019, z = 5, y = -4764, heading = -101.7796, radius = 3, minimum = 60, maximum = 90, count = 3},
		{id = "12", x = 3999, z = 5, y = -4853, heading = 1.4335, radius = 5, minimum = 60, maximum = 75, count = 3},
	},
	quests = {
		{
			name = "speeder_quest", sourceLevel = 1,
			reward = "object/tangible/deed/vehicle_deed/landspeeder_xp38_deed.iff",
			tasks = {
				[0] = {kind = "comm", speaker = "Han Solo", message = "@quest/ground/speeder_quest:task00_comm_message_text"},
				{kind = "retrieve", object = "speeder_debris_wiring", x = 3632.2, z = 4.96843, y = -4684.57, waypoint = "@quest/ground/speeder_quest:task01_waypoint_name", menu = "@quest/ground/speeder_quest:task01_retrieve_menu_text"},
				{kind = "comm", speaker = "Han Solo", message = "@quest/ground/speeder_quest:task02_comm_message_text"},
				{kind = "retrieve", object = "speeder_junk_power", x = 3814.83, z = 5.08059, y = -4671.24, waypoint = "@quest/ground/speeder_quest:task03_waypoint_name", menu = "@quest/ground/speeder_quest:task03_retrieve_menu_text"},
				{kind = "comm", speaker = "Han Solo", message = "@quest/ground/speeder_quest:task04_comm_message_text"},
				{kind = "retrieve", object = "speeder_junk_steering", x = 3978.75, z = 5.15812, y = -4795.92, waypoint = "@quest/ground/speeder_quest:task05_waypoint_name", menu = "@quest/ground/speeder_quest:task05_retrieve_menu_text"},
				{kind = "comm", speaker = "Han Solo", message = "@quest/ground/speeder_quest:task06_comm_message_text"},
				{kind = "retrieve", object = "speeder_junk_engine", x = 4069.66, z = 5, y = -4827.8, waypoint = "@quest/ground/speeder_quest:task07_waypoint_name", menu = "@quest/ground/speeder_quest:task07_retrieve_menu_text"},
				{kind = "comm", speaker = "Han Solo", message = "@quest/ground/speeder_quest:task08_comm_message_text"},
			},
		},
		{
			name = "find_majolnir", sourceLevel = 1,
			reward = "object/tangible/item/legacy_vehicle_customization.iff",
			tasks = {
				[0] = {kind = "timer", minimum = 20, maximum = 22},
				{kind = "comm", speaker = "Han Solo", message = "@quest/ground/find_majolnir:task01_comm_message_text"},
				{kind = "location", x = 3526, z = 5, y = -4619, radius = 10, waypoint = "@quest/ground/find_majolnir:task02_waypoint_name"},
				{kind = "signal", signal = "giveCustomizationKit", role = "pall", x = 3526.47, z = 5, y = -4619.67, waypoint = "@quest/ground/find_majolnir:task02_waypoint_name"},
			},
		},
		{
			name = "tatooine_eisley_legacy", sourceLevel = 1, sourceBranchLevel = 10,
			tasks = {
				[0] = {kind = "timer", minimum = 20, maximum = 21},
				{kind = "comm", speaker = "Han Solo", message = "@quest/ground/tatooine_eisley_legacy:task01_comm_message_text"},
				{kind = "signal", signal = "tat_eisley_legacy_e2", role = "vourk", x = 3524, z = 5, y = -4812, waypoint = "@quest/ground/tatooine_eisley_legacy:task02_waypoint_name"},
				{kind = "complete"},
			},
		},
		{
			name = "tatooine_eisley_gotomayor", sourceLevel = 1,
			tasks = {
				[0] = {kind = "timer", minimum = 5, maximum = 9},
				{kind = "comm", speaker = "Bib Fortuna", message = "@quest/ground/tatooine_eisley_gotomayor:task01_comm_message_text"},
				{kind = "signal", signal = "tat_eisley_gotomayor_e3", role = "mayor", x = 3436.4, z = 7.5, y = -4720, waypoint = "@quest/ground/tatooine_eisley_gotomayor:task02_waypoint_name"},
				{kind = "complete"},
			},
		},
	},
}

registerScreenPlay("LegacyMosEisley", true)

function LegacyMosEisley:start()
	writeData(self.screenplayName .. ":ready", 0)
	if not isZoneEnabled("tatooine") then return end
	local pCamp = getSceneObject(7106074)
	if pCamp == nil or LuaSceneObject(pCamp):getServerObjectCRC() ~= getHashCode("object/static/structure/tatooine/stone_hovel_tatooine_style_01.iff") then
		printLuaError("LegacyMosEisley: salvage camp snapshot is unavailable; install the updated TRE archives on the server and client.")
		return
	end
	-- Do not expose a partially registered chain before the staged TRE is built
	-- and made available to both the server and the PRECU client.
	for _, quest in ipairs(self.quests) do
		local pTasks = getQuestTasks(Runtime:crc(quest))
		if pTasks == nil or LuaQuestTasks(pTasks):getNumberOfTasks() ~= #quest.tasks + 1 then
			printLuaError("LegacyMosEisley: missing or incompatible quest data for " .. quest.name .. "; build/register the staged TRE archives before enabling the chain.")
			return
		end
	end
	local pBuilding = getSceneObject(1279956)
	if pBuilding == nil or not LuaSceneObject(pBuilding):isBuildingObject() then
		printLuaError("LegacyMosEisley: Mos Eisley Commerce Hall (1279956) is unavailable.")
		return
	end
	local pCell = LuaBuildingObject(pBuilding):getNamedCell("mainroom")
	if pCell == nil then
		printLuaError("LegacyMosEisley: Commerce Hall mainroom is unavailable.")
		return
	end
	local pCantina = getSceneObject(1082874)
	if pCantina == nil or not LuaSceneObject(pCantina):isBuildingObject() then
		printLuaError("LegacyMosEisley: Mos Eisley cantina (1082874) is unavailable.")
		return
	end
	local pAlcove = LuaBuildingObject(pCantina):getNamedCell("alcove1")
	if pAlcove == nil then
		printLuaError("LegacyMosEisley: cantina alcove1 is unavailable.")
		return
	end
	local spawned = {}
	local function keep(pObject)
		if pObject ~= nil then table.insert(spawned, pObject) end
		return pObject
	end
	local npcs = {
		{"han", "legacy_han_solo", 14.7, -0.9, -19.8, 62, LuaSceneObject(pAlcove):getObjectID()},
		{"chewbacca", "legacy_chewbacca", 15.7, -0.9, -21, 26, LuaSceneObject(pAlcove):getObjectID()},
		{"vourk", "legacy_vourk", 3524, 5, -4812, 20.25, 0},
		{"pall", "legacy_pall", 3526.47, 5, -4619.67, 105, 0},
		{"mayor", "legacy_mos_eisley_mayor", -0.1, 2.5, 5.9, 58, LuaSceneObject(pCell):getObjectID()},
	}
	local ok = true
	for _, npc in ipairs(npcs) do
		local pNpc = keep(spawnMobile("tatooine", npc[2], 0, npc[3], npc[4], npc[5], npc[6], npc[7]))
		if pNpc == nil then
			ok = false
		else
			LuaAiAgent(pNpc):addObjectFlag(AI_STATIC)
			if npc[1] == "han" then self:setMoodString(pNpc, "npc_sitting_chair") end
			writeData(self.screenplayName .. ":npc:" .. npc[1], LuaSceneObject(pNpc):getObjectID())
		end
	end
	local rotations = {
		[1] = {0.844089, 0.0525162, 0.532236, -0.0384726},
		[3] = {0.92751, -0.159213, 0.333321, 0.0572169},
		[5] = {0.758144, -0.218469, 0.434911, -0.433984},
		[7] = {-0.556783, -0.0096573, 0.830582, -0.00562745},
	}
	for step, task in pairs(self.quests[1].tasks) do
		if task.kind == "retrieve" then
			local q = rotations[step]
			local pObject = keep(spawnSceneObject("tatooine", "object/tangible/quest/" .. task.object .. ".iff", task.x, task.z, task.y, 0, q[1], q[2], q[3], q[4]))
			if pObject == nil then ok = false else writeData(self.screenplayName .. ":retrieve:" .. step, LuaSceneObject(pObject):getObjectID()) end
		end
	end
	-- These guards protect the salvage location; kills are never quest gates.
	for _, offset in ipairs({{-1.5, -1}, {1.5, -1}, {0, 1.5}}) do
		if keep(spawnMobile("tatooine", "legacy_tusken_scavenger", getRandomNumber(25, 45), 4069.8 + offset[1], 5, -4828.1 + offset[2], 0, 0)) == nil then ok = false end
	end
	for groupIndex, group in ipairs(self.campTuskenGroups) do
		for slot = 1, group.count do
			if keep(self:spawnCampTusken(groupIndex, slot)) == nil then ok = false end
		end
	end
	local pArea = keep(spawnActiveArea("tatooine", "object/active_area.iff", 3526, 5, -4619, 10, 0))
	if pArea == nil then ok = false end
	if not ok then
		for _, pObject in ipairs(spawned) do
			local id = LuaSceneObject(pObject):getObjectID()
			if readData(self.screenplayName .. ":campTuskenMember:" .. id .. ":group") > 0
				and LuaSceneObject(pObject):isAiAgent() then
				-- ready remains zero, so observer cleanup cannot schedule replacements.
				LuaAiAgent(pObject):doDespawn()
			else
				LuaSceneObject(pObject):destroyObjectFromWorld()
			end
		end
		printLuaError("LegacyMosEisley: a required spawn failed; chain disabled.")
		return
	end
	createObserver(ENTEREDAREA, self.screenplayName, "enteredPallArea", pArea)
	writeData(self.screenplayName .. ":ready", 1)
	local pRegion = getRegion(self.planet, "@tatooine_region_names:mos_eisley")
	if pRegion == nil then
		printLuaError("LegacyMosEisley: Mos Eisley region is unavailable; arrival invitations are disabled.")
	else
		writeData(self.screenplayName .. ":arrivalRegion", LuaSceneObject(pRegion):getObjectID())
		createObserver(ENTEREDAREA, self.screenplayName, "enteredArrivalCity", pRegion)
	end
end

function LegacyMosEisley:spawnCampTusken(groupIndex, slot)
	local group = self.campTuskenGroups[groupIndex]
	if group == nil or slot == nil or slot < 1 or slot > group.count or not isZoneEnabled(self.planet) then return nil end
	local key = self.screenplayName .. ":campTusken:" .. group.id .. ":" .. slot
	local existingId = readData(key)
	local pExisting = getSceneObject(existingId)
	if pExisting ~= nil and LuaSceneObject(pExisting):isAiAgent()
		and LuaSceneObject(pExisting):getZoneName() == self.planet and LuaSceneObject(pExisting):getParentID() == 0
		and not LuaCreatureObject(pExisting):isDead() and not LuaCreatureObject(pExisting):isIncapacitated() then return pExisting end
	if existingId ~= 0 then
		if pExisting ~= nil then
			dropObserver(CREATUREDESPAWNED, self.screenplayName, "campTuskenDespawned", pExisting)
			dropObserver(DEFENDERADDED, self.screenplayName, "campTuskenDefenderAdded", pExisting)
			if LuaSceneObject(pExisting):isAiAgent() then LuaAiAgent(pExisting):doDespawn() end
		end
		deleteData(self.screenplayName .. ":campTuskenMember:" .. existingId .. ":group")
		deleteData(self.screenplayName .. ":campTuskenMember:" .. existingId .. ":slot")
		writeData(key, 0)
	end
	local point
	for attempt = 1, 16 do
		local candidate = getSpawnPointInArea(self.planet, group.x, group.y, group.radius)
		if candidate ~= nil then
			local dx, dy = candidate[1] - group.x, candidate[3] - group.y
			if dx * dx + dy * dy <= group.radius * group.radius then
				point = candidate
				break
			end
		end
	end
	if point == nil then
		printLuaError("LegacyMosEisley: no valid spawn point for Tusken group " .. group.id)
		return nil
	end
	-- Native randomRespawn uses 50%-150% jitter. Own these slots instead so
	-- each life keeps the original group's exact delay range and spawn radius.
	local pMobile = spawnMobile(self.planet, "legacy_tusken_zealot", 0, point[1], point[2], point[3], group.heading, 0)
	if pMobile == nil then return nil end
	local id = LuaSceneObject(pMobile):getObjectID()
	writeData(key, id)
	writeData(self.screenplayName .. ":campTuskenMember:" .. id .. ":group", groupIndex)
	writeData(self.screenplayName .. ":campTuskenMember:" .. id .. ":slot", slot)
	createObserver(CREATUREDESPAWNED, self.screenplayName, "campTuskenDespawned", pMobile)
	createObserver(DEFENDERADDED, self.screenplayName, "campTuskenDefenderAdded", pMobile)
	return pMobile
end

function LegacyMosEisley:campTuskenDefenderAdded(pMobile, pDefender)
	if pMobile == nil or pDefender == nil or readData(self.screenplayName .. ":ready") ~= 1
		or not isZoneEnabled(self.planet) or not LuaSceneObject(pMobile):isAiAgent()
		or not LuaSceneObject(pDefender):isCreatureObject()
		or LuaCreatureObject(pMobile):isDead() or LuaCreatureObject(pMobile):isIncapacitated()
		or LuaAiAgent(pMobile):isRetreating()
		or LuaCreatureObject(pDefender):isDead() or LuaCreatureObject(pDefender):isIncapacitated()
		or LuaSceneObject(pMobile):getZoneName() ~= self.planet
		or LuaSceneObject(pDefender):getZoneName() ~= self.planet then return 0 end
	local id = LuaSceneObject(pMobile):getObjectID()
	local memberKey = self.screenplayName .. ":campTuskenMember:" .. id
	local group = self.campTuskenGroups[readData(memberKey .. ":group")]
	local slot = readData(memberKey .. ":slot")
	if group == nil or slot < 1 or slot > group.count
		or readData(self.screenplayName .. ":campTusken:" .. group.id .. ":" .. slot) ~= id then return 0 end
	-- setDefender synchronously emits DEFENDERADDED for the helper. Keep one
	-- shared chain guard until all immediate assists finish, preventing relays.
	local guard = self.screenplayName .. ":campTuskenAssist"
	if readData(guard) == 1 then return 0 end
	writeData(guard, 1)
	local ok, err = pcall(function()
		for _, otherGroup in ipairs(self.campTuskenGroups) do
			for otherSlot = 1, otherGroup.count do
				local pHelper = getSceneObject(readData(self.screenplayName .. ":campTusken:" .. otherGroup.id .. ":" .. otherSlot))
				if pHelper ~= nil and LuaSceneObject(pHelper):getObjectID() ~= id
					and LuaSceneObject(pHelper):isAiAgent()
					and not LuaCreatureObject(pHelper):isDead() and not LuaCreatureObject(pHelper):isIncapacitated()
					and not LuaCreatureObject(pHelper):isInCombat()
					and not LuaAiAgent(pHelper):isRetreating()
					and LuaSceneObject(pHelper):getZoneName() == self.planet
					and LuaSceneObject(pHelper):getParentID() == LuaSceneObject(pMobile):getParentID()
					and LuaSceneObject(pHelper):isInRangeWithObject3d(pMobile, 4)
					and LuaAiAgent(pHelper):checkLineOfSight(pMobile)
					and LuaCreatureObject(pDefender):isAttackableBy(pHelper) then
					LuaAiAgent(pHelper):setDefender(pDefender)
				end
			end
		end
	end)
	deleteData(guard)
	if not ok then printLuaError("LegacyMosEisley: bounded Tusken assistance failed: " .. tostring(err)) end
	return 0
end

function LegacyMosEisley:campTuskenDespawned(pMobile)
	if pMobile == nil then return 1 end
	local id = LuaSceneObject(pMobile):getObjectID()
	dropObserver(DEFENDERADDED, self.screenplayName, "campTuskenDefenderAdded", pMobile)
	local memberKey = self.screenplayName .. ":campTuskenMember:" .. id
	local groupIndex = readData(memberKey .. ":group")
	local slot = readData(memberKey .. ":slot")
	deleteData(memberKey .. ":group")
	deleteData(memberKey .. ":slot")
	local group = self.campTuskenGroups[groupIndex]
	if group == nil or slot < 1 or slot > group.count then return 1 end
	local key = self.screenplayName .. ":campTusken:" .. group.id .. ":" .. slot
	if readData(key) ~= id then return 1 end
	writeData(key, 0)
	if readData(self.screenplayName .. ":ready") == 1 and isZoneEnabled(self.planet) then
		-- Match Core3's corpse cleanup lifecycle; never retain a destroyed subject.
		createEvent(getRandomNumber(group.minimum, group.maximum) * 1000, self.screenplayName,
			"respawnCampTusken", nil, groupIndex .. ":" .. slot)
	end
	return 1
end

function LegacyMosEisley:respawnCampTusken(pUnused, args)
	if readData(self.screenplayName .. ":ready") ~= 1 or not isZoneEnabled(self.planet) then return end
	local groupIndex, slot = string.match(args or "", "^(%d+):(%d+)$")
	groupIndex, slot = tonumber(groupIndex), tonumber(slot)
	local group = self.campTuskenGroups[groupIndex]
	if group == nil or slot == nil or slot < 1 or slot > group.count then return end
	if self:spawnCampTusken(groupIndex, slot) == nil then
		createEvent(getRandomNumber(group.minimum, group.maximum) * 1000, self.screenplayName,
			"respawnCampTusken", nil, groupIndex .. ":" .. slot)
	end
end

function LegacyMosEisley:hasStarted(pPlayer)
	local ghost = Runtime:ghost(pPlayer)
	if ghost == nil then return false end
	local crc = Runtime:crc(self.quests[1])
	return ghost:isJournalQuestActive(crc) or ghost:isJournalQuestComplete(crc)
end

function LegacyMosEisley:isComplete(pPlayer)
	local ghost = Runtime:ghost(pPlayer)
	return ghost ~= nil and ghost:isJournalQuestComplete(Runtime:crc(self.quests[4]))
end

function LegacyMosEisley:nearContact(pPlayer, role)
	if readData(self.screenplayName .. ":ready") ~= 1 or not Runtime:canInteract(pPlayer) then return false end
	local pNpc = getSceneObject(readData(self.screenplayName .. ":npc:" .. role))
	return pNpc ~= nil and not LuaCreatureObject(pNpc):isDead()
		and not LuaCreatureObject(pNpc):isIncapacitated() and not LuaCreatureObject(pNpc):isInCombat()
		and LuaSceneObject(pPlayer):getZoneName() == "tatooine"
		and LuaSceneObject(pPlayer):getParentID() == LuaSceneObject(pNpc):getParentID()
		and LuaSceneObject(pPlayer):isInRangeWithObject3d(pNpc, 10)
end

function LegacyMosEisley:accept(pPlayer)
	if not self:nearContact(pPlayer, "han") or self:hasStarted(pPlayer) then return false end
	Runtime:ghost(pPlayer):activateJournalQuest(Runtime:crc(self.quests[1]), true)
	if not self:hasStarted(pPlayer) then return false end
	self:cancelArrivalInvitation(pPlayer)
	return self:resume(pPlayer)
end

function LegacyMosEisley:resume(pPlayer)
	if readData(self.screenplayName .. ":ready") ~= 1 then return false end
	return Runtime:resume(self, pPlayer)
end

function LegacyMosEisley:signal(pPlayer, expected, role)
	if not self:nearContact(pPlayer, role) then return false end
	local quest, step = Runtime:current(pPlayer, self.quests)
	if quest == nil then return false end
	local task = quest.tasks[step]
	if task.kind ~= "signal" or task.signal ~= expected or task.role ~= role then return false end
	if not Runtime:advance(self, pPlayer, quest, step) then return false end
	return self:resume(pPlayer)
end

function LegacyMosEisley:talkToPall(pPlayer)
	return self:signal(pPlayer, "giveCustomizationKit", "pall")
end

function LegacyMosEisley:chooseMayor(pPlayer)
	-- Only the approved Mayor route is converted. Niko is a separate pending
	-- conversion, not a level, profession, or skill-based unlock.
	return self:signal(pPlayer, "tat_eisley_legacy_e2", "vourk")
end

function LegacyMosEisley:acknowledgeMayor(pPlayer)
	return self:signal(pPlayer, "tat_eisley_gotomayor_e3", "mayor")
end

function LegacyMosEisley:getConversationState(pPlayer, role)
	if not self:nearContact(pPlayer, role) then return "unavailable" end
	local ghost = Runtime:ghost(pPlayer)
	if role == "han" then
		if self:isComplete(pPlayer) then return "complete" end
		return self:hasStarted(pPlayer) and "busy" or "offer"
	elseif role == "pall" then
		if ghost:isJournalQuestComplete(Runtime:crc(self.quests[2])) then return "complete" end
	elseif self:isComplete(pPlayer) then
		return "complete"
	end
	local quest, step = Runtime:current(pPlayer, self.quests)
	if role == "vourk" then
		if not self:hasStarted(pPlayer) then return "offer" end
		if quest == self.quests[3] and step == 2 then return "bib_offer" end
		if quest == self.quests[4] then return "mayor_pending" end
		return "busy"
	end
	if quest ~= nil and quest.tasks[step].kind == "signal" and quest.tasks[step].role == role then return "ready" end
	return "unavailable"
end

function LegacyMosEisley:retrieveTask(pObject, pPlayer)
	if pObject == nil or not Runtime:canInteract(pPlayer, true) then return nil end
	local quest, step = Runtime:current(pPlayer, self.quests)
	if quest ~= self.quests[1] then return nil end
	local task = quest.tasks[step]
	if task.kind ~= "retrieve" or readData(self.screenplayName .. ":ready") ~= 1
		or LuaSceneObject(pPlayer):getZoneName() ~= "tatooine"
		or LuaSceneObject(pObject):getObjectID() ~= readData(self.screenplayName .. ":retrieve:" .. step)
		or LuaSceneObject(pObject):getServerObjectCRC() ~= getHashCode("object/tangible/quest/" .. task.object .. ".iff")
		or LuaSceneObject(pPlayer):getParentID() ~= LuaSceneObject(pObject):getParentID()
		or not LuaSceneObject(pPlayer):isInRangeWithObject3d(pObject, 5) then return nil end
	return task, step
end

function LegacyMosEisley:retrieve(pObject, pPlayer)
	local task, step = self:retrieveTask(pObject, pPlayer)
	if task == nil then return false end
	if not Runtime:advance(self, pPlayer, self.quests[1], step) then return false end
	if step ~= 7 then
		LuaSceneObject(pObject):playEffect("clienteffect/quest_item_electrical_spark.cef", "")
	end
	return self:resume(pPlayer)
end

function LegacyMosEisley:enteredPallArea(pArea, pPlayer)
	if Runtime:canInteract(pPlayer, true) and self:hasStarted(pPlayer) then self:resume(pPlayer) end
	return 0
end

function LegacyMosEisley:onTimer(pPlayer, token)
	local quest, step = Runtime:current(pPlayer, self.quests)
	if quest ~= nil and token == quest.name .. ":" .. step then self:resume(pPlayer) end
end

function LegacyMosEisley:isInArrivalCity(pPlayer)
	if pPlayer == nil or LuaSceneObject(pPlayer):getZoneName() ~= self.planet then return false end
	local pRegion = getSceneObject(readData(self.screenplayName .. ":arrivalRegion"))
	if pRegion == nil then return false end
	-- World coordinates include players in the starport or other city interiors.
	local dx = LuaSceneObject(pPlayer):getWorldPositionX() - LuaSceneObject(pRegion):getWorldPositionX()
	local dy = LuaSceneObject(pPlayer):getWorldPositionY() - LuaSceneObject(pRegion):getWorldPositionY()
	local radius = LuaActiveArea(pRegion):getRadius()
	return dx * dx + dy * dy <= radius * radius
end

function LegacyMosEisley:cancelArrivalInvitation(pPlayer)
	local ghost = Runtime:ghost(pPlayer)
	if ghost == nil then return end
	cancelEvent(self.screenplayName, "showArrivalInvitation", pPlayer)
	local id = tonumber(readScreenPlayData(pPlayer, self.screenplayName, "invitationWaypoint")) or 0
	if id ~= 0 then ghost:removeWaypoint(id, true) end
	writeScreenPlayData(pPlayer, self.screenplayName, "invitationWaypoint", "0")
	if readScreenPlayData(pPlayer, self.screenplayName, "arrivalInvitation") == "pending" then
		writeScreenPlayData(pPlayer, self.screenplayName, "arrivalInvitation", "cancelled")
	end
end

function LegacyMosEisley:scheduleArrivalInvitation(pPlayer)
	local ghost = Runtime:ghost(pPlayer)
	if ghost == nil then return end
	cancelEvent(self.screenplayName, "showArrivalInvitation", pPlayer)
	if self:hasStarted(pPlayer) then
		self:cancelArrivalInvitation(pPlayer)
		return
	end
	if readData(self.screenplayName .. ":ready") ~= 1 or not ghost:isOnline()
		or readScreenPlayData(pPlayer, self.screenplayName, "arrivalInvitation") ~= "pending"
		or not self:isInArrivalCity(pPlayer) then return end
	createEvent(5000, self.screenplayName, "showArrivalInvitation", pPlayer, "")
end

function LegacyMosEisley:enteredArrivalCity(pRegion, pPlayer)
	if pRegion ~= nil and LuaSceneObject(pRegion):getObjectID() == readData(self.screenplayName .. ":arrivalRegion") then
		self:scheduleArrivalInvitation(pPlayer)
	end
	return 0
end

function LegacyMosEisley:showArrivalInvitation(pPlayer)
	local ghost = Runtime:ghost(pPlayer)
	if ghost == nil then return end
	if self:hasStarted(pPlayer) then
		self:cancelArrivalInvitation(pPlayer)
		return
	end
	if readData(self.screenplayName .. ":ready") ~= 1 or not ghost:isOnline()
		or readScreenPlayData(pPlayer, self.screenplayName, "arrivalInvitation") ~= "pending"
		or not self:isInArrivalCity(pPlayer) then return end
	if ghost:isOnLoadScreen() or not Runtime:canInteract(pPlayer) then
		self:scheduleArrivalInvitation(pPlayer)
		return
	end
	local id = tonumber(readScreenPlayData(pPlayer, self.screenplayName, "invitationWaypoint")) or 0
	if id == 0 or getSceneObject(id) == nil then
		id = ghost:addWaypoint(self.planet, "Chalmun's Cantina - Han Solo", "", 3467.8815, 5, -4852.2944,
			WAYPOINT_BLUE, true, true, 0)
		if id == nil or id == 0 then
			self:scheduleArrivalInvitation(pPlayer)
			return
		end
		writeScreenPlayData(pPlayer, self.screenplayName, "invitationWaypoint", tostring(id))
	end
	local sui = SuiMessageBox.new(self.screenplayName, "closeArrivalInvitation")
	sui.setTitle("Welcome to Mos Eisley")
	sui.setPrompt("Han Solo and Chewbacca are in a side alcove inside Chalmun's Cantina. Han has a lead on a speeder if you are interested in some work.\n\nA waypoint to the cantina has been added to your datapad. Visit Han when you are ready.")
	sui.hideCancelButton()
	local pageId = sui.sendTo(pPlayer)
	if pageId ~= nil and pageId ~= 0 then
		writeScreenPlayData(pPlayer, self.screenplayName, "arrivalInvitation", "shown")
	else
		self:scheduleArrivalInvitation(pPlayer)
	end
end

function LegacyMosEisley:closeArrivalInvitation(pPlayer, pSui, eventIndex)
	-- Informational only: dismissing this invitation never accepts a quest.
end

function LegacyMosEisley:playerLoggedIn(pPlayer)
	self:refreshQuestMarkers(pPlayer)
	if self:hasStarted(pPlayer) then self:resume(pPlayer) end
	self:scheduleArrivalInvitation(pPlayer)
end

function LegacyMosEisley:playerLoggedOut(pPlayer)
	cancelEvent(self.screenplayName, "onTimer", pPlayer)
	cancelEvent(self.screenplayName, "showArrivalInvitation", pPlayer)
end

function LegacyMosEisley:closeTransmission(pPlayer, pSui, eventIndex)
	-- Communications are informational; closing one never advances a task.
end

LegacyRetrieveMenuComponent = {}

function LegacyRetrieveMenuComponent:fillObjectMenuResponse(pObject, pResponse, pPlayer)
	local task = LegacyMosEisley:retrieveTask(pObject, pPlayer)
	if task ~= nil then LuaObjectMenuResponse(pResponse):addRadialMenuItem(20, 3, task.menu) end
end

function LegacyRetrieveMenuComponent:handleObjectMenuSelect(pObject, pPlayer, selectedID)
	if selectedID == 20 then LegacyMosEisley:retrieve(pObject, pPlayer) end
	return 0
end

includeFile("legacy/conversations/legacy_pall.lua")
includeFile("legacy/conversations/legacy_han.lua")
includeFile("legacy/conversations/legacy_vourk.lua")
includeFile("legacy/conversations/legacy_mayor.lua")

function LegacyMosEisley:refreshQuestMarkers(pPlayer)
    if Runtime:ghost(pPlayer) == nil then return end
    for _, role in ipairs({"han", "pall", "vourk", "mayor"}) do
        local pNpc = getSceneObject(readData(self.screenplayName .. ":npc:" .. role))
        if pNpc ~= nil and LuaSceneObject(pNpc):getZoneName() == LuaSceneObject(pPlayer):getZoneName()
            and LuaSceneObject(pNpc):isInRangeWithObject3d(pPlayer, 128) then
            LuaAiAgent(pNpc):sendQuestMarkerTo(pPlayer)
        end
    end
end
