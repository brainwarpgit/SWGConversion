-- Small CRC-journal task adapter. Gameplay stays in Core3; NGE tables are metadata.
local Runtime = {}

function Runtime:ghost(pPlayer)
	if pPlayer == nil or not LuaSceneObject(pPlayer):isPlayerCreature() then
		return nil
	end
	local pGhost = LuaCreatureObject(pPlayer):getPlayerObject()
	if pGhost ~= nil then
		return LuaPlayerObject(pGhost)
	end
	return nil
end

function Runtime:canInteract(pPlayer, allowCombat)
	return self:ghost(pPlayer) ~= nil and not LuaCreatureObject(pPlayer):isDead()
		and not LuaCreatureObject(pPlayer):isIncapacitated()
		and (allowCombat or not LuaCreatureObject(pPlayer):isInCombat())
end

function Runtime:crc(quest)
	return getHashCode("quest/" .. quest.name)
end

function Runtime:current(pPlayer, quests)
	local ghost = self:ghost(pPlayer)
	if ghost == nil then return nil end
	for index, quest in ipairs(quests) do
		local crc = self:crc(quest)
		if ghost:isJournalQuestActive(crc) then
			for step = 0, #quest.tasks do
				if ghost:isJournalQuestTaskActive(crc, step) then
					return quest, step, index
				end
			end
		end
	end
	return nil
end

function Runtime:clearWaypoint(owner, pPlayer)
	local ghost = self:ghost(pPlayer)
	local id = tonumber(readScreenPlayData(pPlayer, owner.screenplayName, "waypoint")) or 0
	if ghost ~= nil and id ~= 0 then ghost:removeWaypoint(id, true) end
	writeScreenPlayData(pPlayer, owner.screenplayName, "waypoint", "0")
	writeScreenPlayData(pPlayer, owner.screenplayName, "waypointTask", "")
end

function Runtime:waypoint(owner, pPlayer, quest, step, task)
	if task.x == nil then return end
	-- Include the destination so persisted waypoints follow corrected placements.
	local token = quest.name .. ":" .. step .. ":" .. (task.planet or owner.planet)
		.. ":" .. task.x .. ":" .. (task.z or 0) .. ":" .. task.y
	local oldToken = readScreenPlayData(pPlayer, owner.screenplayName, "waypointTask")
	local oldId = tonumber(readScreenPlayData(pPlayer, owner.screenplayName, "waypoint")) or 0
	if oldToken == token and oldId ~= 0 and getSceneObject(oldId) ~= nil then return end
	self:clearWaypoint(owner, pPlayer)
	local id = self:ghost(pPlayer):addWaypoint(task.planet or owner.planet, task.waypoint, "", task.x, task.z or 0, task.y,
		WAYPOINT_ORANGE, true, true, WAYPOINTQUESTTASK)
	if id ~= nil then
		writeScreenPlayData(pPlayer, owner.screenplayName, "waypoint", tostring(id))
		writeScreenPlayData(pPlayer, owner.screenplayName, "waypointTask", token)
	end
end

function Runtime:reward(owner, pPlayer, quest)
	if quest.reward == nil then return true end
	local key = "reward:" .. quest.name
	if readScreenPlayData(pPlayer, owner.screenplayName, key) == "1" then return true end
	local pInventory = LuaSceneObject(pPlayer):getSlottedObject("inventory")
	if pInventory == nil or LuaSceneObject(pInventory):isContainerFullRecursive() then
		LuaCreatureObject(pPlayer):sendSystemMessage("Make room in your inventory, then speak to your quest contact to collect your reward.")
		return false
	end
	-- Respect container capacity; an unsuccessful transfer leaves the final task active.
	local pReward = giveItem(pInventory, quest.reward, -1)
	if pReward == nil then
		LuaCreatureObject(pPlayer):sendSystemMessage("Your quest reward could not be delivered. Your progress has been kept; speak to your quest contact to retry.")
		return false
	end
	writeScreenPlayData(pPlayer, owner.screenplayName, key, "1")
	return true
end

function Runtime:advance(owner, pPlayer, quest, step)
	local ghost = self:ghost(pPlayer)
	local crc = self:crc(quest)
	if ghost == nil or not ghost:isJournalQuestActive(crc)
		or not ghost:isJournalQuestTaskActive(crc, step) then return false end
	if step == #quest.tasks and not self:reward(owner, pPlayer, quest) then return false end
	self:clearWaypoint(owner, pPlayer)
	ghost:completeJournalQuestTask(crc, step, true)
	if step == #quest.tasks then
		ghost:completeJournalQuest(crc, true)
	else
		ghost:activateJournalQuestTask(crc, step + 1, true)
	end
	return true
end

function Runtime:communicate(owner, pPlayer, task)
	local sui = SuiMessageBox.new(owner.screenplayName, "closeTransmission")
	sui.setTitle(task.speaker .. " — transmission")
	sui.setPrompt(task.message)
	sui.hideCancelButton()
	sui.sendTo(pPlayer)
end

-- Restore deadlines/waypoints from persistent player data, never from shared memory.
-- The native journal is authoritative for objective and quest completion.
function Runtime:resume(owner, pPlayer)
	local ghost = self:ghost(pPlayer)
	if ghost == nil or not owner:hasStarted(pPlayer) then return false end
	cancelEvent(owner.screenplayName, "onTimer", pPlayer)
	for unused = 1, 32 do
		local quest, step = self:current(pPlayer, owner.quests)
		if quest == nil then
			for i = 2, #owner.quests do
				if ghost:isJournalQuestComplete(self:crc(owner.quests[i - 1]))
					and not ghost:isJournalQuestComplete(self:crc(owner.quests[i])) then
					ghost:activateJournalQuest(self:crc(owner.quests[i]), true)
					quest, step = self:current(pPlayer, owner.quests)
					break
				end
			end
		end
		if quest == nil then
			self:clearWaypoint(owner, pPlayer)
			return true
		end
		local task = quest.tasks[step]
		if task == nil then return false end
		if task.kind == "comm" then
			-- Deliver the reward before showing a message claiming it was received.
			if not self:advance(owner, pPlayer, quest, step) then return false end
			self:communicate(owner, pPlayer, task)
		elseif task.kind == "complete" then
			if not self:advance(owner, pPlayer, quest, step) then return false end
		elseif task.kind == "timer" then
			local key = "deadline:" .. quest.name .. ":" .. step
			local deadline = tonumber(readScreenPlayData(pPlayer, owner.screenplayName, key)) or 0
			if deadline == 0 then
				deadline = getTimestamp() + getRandomNumber(task.minimum, task.maximum)
				writeScreenPlayData(pPlayer, owner.screenplayName, key, tostring(deadline))
			end
			local remaining = deadline - getTimestamp()
			if remaining > 0 then
				createEvent(remaining * 1000, owner.screenplayName, "onTimer", pPlayer, quest.name .. ":" .. step)
				return true
			end
			if not self:advance(owner, pPlayer, quest, step) then return false end
		elseif task.kind == "location" then
			self:waypoint(owner, pPlayer, quest, step, task)
			if not self:canInteract(pPlayer, true) or LuaSceneObject(pPlayer):getZoneName() ~= (task.planet or owner.planet)
				or LuaSceneObject(pPlayer):getParentID() ~= 0
				or LuaSceneObject(pPlayer):getDistanceToPosition(task.x, task.z or 0, task.y) > task.radius then return true end
			if not self:advance(owner, pPlayer, quest, step) then return false end
		else
			self:waypoint(owner, pPlayer, quest, step, task)
			return true
		end
	end
	return false
end

return Runtime
