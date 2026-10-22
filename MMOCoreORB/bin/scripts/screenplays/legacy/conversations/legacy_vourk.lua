legacyVourkConvoHandler = conv_handler:new {}

function legacyVourkConvoHandler:getInitialScreen(pPlayer, pNpc, pConvTemplate)
	if LegacyMosEisley:hasStarted(pPlayer) then
		LegacyMosEisley:resume(pPlayer)
	end
	local template = LuaConversationTemplate(pConvTemplate)
	return template:getScreen(LegacyMosEisley:getConversationState(pPlayer, "vourk")) or template:getScreen("blocked")
end

function legacyVourkConvoHandler:runScreenHandlers(pConvTemplate, pPlayer, pNpc, selectedOption, pConvScreen)
	local screenId = LuaConversationScreen(pConvScreen):getScreenID()
	local template = LuaConversationTemplate(pConvTemplate)
	if screenId == "mayor_accepted" then
		if not LegacyMosEisley:chooseMayor(pPlayer) then
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
