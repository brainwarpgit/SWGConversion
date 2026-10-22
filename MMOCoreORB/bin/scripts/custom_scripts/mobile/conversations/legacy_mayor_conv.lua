-- CreatureTemplateManager registers this template; its handler runs in DirectorManager.
local template = ConvoTemplate:new {
	initialScreen = "unavailable", templateType = "Lua", luaClassHandler = "legacyMayorConvoHandler", screens = {}
}

template:addScreen(ConvoScreen:new {
	id = "unavailable", leftDialog = "@conversation/mos_eisley_mayor:s_85", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "ready", leftDialog = "@conversation/mos_eisley_mayor:s_85", stopConversation = "false",
	options = {{"@conversation/mos_eisley_mayor:s_76", "mayor_ack"}, {"I'll come back later.", "decline"}}
})
template:addScreen(ConvoScreen:new {
	id = "mayor_ack", leftDialog = "@conversation/mos_eisley_mayor:s_80", stopConversation = "false",
	options = {{"I'll keep that in mind.", "complete"}}
})
-- End the four-quest milestone here; later Mayor jobs have not been converted.
template:addScreen(ConvoScreen:new {
	id = "complete", customDialogText = "That's all I need from you for now. I don't have another assignment available.", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "blocked", customDialogText = "I can't discuss that debt with you right now. Check your current assignment and speak to me again.",
	stopConversation = "false", options = {{"Let me check my progress.", "resume"}, {"I'll come back later.", "decline"}}
})
template:addScreen(ConvoScreen:new {
	id = "resume", customDialogText = "Let's see where you were.", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "decline", customDialogText = "Good day, citizen.", stopConversation = "true", options = {}
})

addConversationTemplate("legacy_mayor_conv", template)
