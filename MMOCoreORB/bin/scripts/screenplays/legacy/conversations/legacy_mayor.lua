legacyMayorConvoHandler = conv_handler:new {}

function legacyMayorConvoHandler:getInitialScreen(pPlayer, pNpc, pConvTemplate)
	if LegacyMosEisley:hasStarted(pPlayer) then
		LegacyMosEisley:resume(pPlayer)
	end
	local template = LuaConversationTemplate(pConvTemplate)
	return template:getScreen(LegacyMosEisley:getConversationState(pPlayer, "mayor")) or template:getScreen("blocked")
end

function legacyMayorConvoHandler:runScreenHandlers(pConvTemplate, pPlayer, pNpc, selectedOption, pConvScreen)
	local screenId = LuaConversationScreen(pConvScreen):getScreenID()
	local template = LuaConversationTemplate(pConvTemplate)
	if screenId == "mayor_ack" then
		if not LegacyMosEisley:acknowledgeMayor(pPlayer) then
			return template:getScreen("blocked")
		end
	elseif screenId == "resume" then
		if not LegacyMosEisley:resume(pPlayer) then
			return template:getScreen("blocked")
		end
		return self:getInitialScreen(pPlayer, pNpc, pConvTemplate)
	end
	return pConvScreen
end
