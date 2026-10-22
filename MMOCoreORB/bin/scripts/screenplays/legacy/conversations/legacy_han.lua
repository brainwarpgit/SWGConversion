legacyHanConvoHandler = conv_handler:new {}

function legacyHanConvoHandler:getInitialScreen(pPlayer, pNpc, pConvTemplate)
	if LegacyMosEisley:hasStarted(pPlayer) then
		LegacyMosEisley:resume(pPlayer)
	end
	local template = LuaConversationTemplate(pConvTemplate)
	return template:getScreen(LegacyMosEisley:getConversationState(pPlayer, "han")) or template:getScreen("blocked")
end

function legacyHanConvoHandler:runScreenHandlers(pConvTemplate, pPlayer, pNpc, selectedOption, pConvScreen)
	local screenId = LuaConversationScreen(pConvScreen):getScreenID()
	local template = LuaConversationTemplate(pConvTemplate)
	if screenId == "accepted" then
		if not LegacyMosEisley:accept(pPlayer) then
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
