-- CreatureTemplateManager registers this template; its handler runs in DirectorManager.
local template = ConvoTemplate:new {
	initialScreen = "unavailable", templateType = "Lua", luaClassHandler = "legacyPallConvoHandler", screens = {}
}

template:addScreen(ConvoScreen:new {
	id = "unavailable", leftDialog = "@conversation/tatooine_eisley_majolnir:s_65", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "ready", customDialogText = "Did Han send you for a vehicle customization kit?", stopConversation = "false",
	options = {{"He said you could help me customize my new speeder.", "kit_received"}, {"I'll come back later.", "decline"}}
})
template:addScreen(ConvoScreen:new {
	id = "kit_received", leftDialog = "@conversation/tatooine_eisley_majolnir:s_18", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "complete", leftDialog = "@conversation/tatooine_eisley_majolnir:s_24", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "blocked", customDialogText = "I can't hand you a kit right now. Check that you have room for it, then speak to me again.",
	stopConversation = "false", options = {{"Let me check my progress.", "resume"}, {"I'll come back later.", "decline"}}
})
template:addScreen(ConvoScreen:new {
	id = "resume", customDialogText = "Let's see where you were.", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "decline", customDialogText = "Come back when you're ready.", stopConversation = "true", options = {}
})

addConversationTemplate("legacy_pall_conv", template)
