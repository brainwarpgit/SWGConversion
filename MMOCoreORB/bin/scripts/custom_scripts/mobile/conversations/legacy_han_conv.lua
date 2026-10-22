-- CreatureTemplateManager registers this template; its handler runs in DirectorManager.
local template = ConvoTemplate:new {
	initialScreen = "offer", templateType = "Lua", luaClassHandler = "legacyHanConvoHandler", screens = {}
}

template:addScreen(ConvoScreen:new {
	id = "offer",
	customDialogText = "Need a way to get around this place, kid? Chewie and I know where you can find enough salvage to put a speeder together. You'll have to collect the parts yourself, but I can talk you through it.",
	stopConversation = "false",
	options = {{"I'd like a speeder. Tell me where to start.", "accepted"}, {"Not right now.", "decline"}}
})
template:addScreen(ConvoScreen:new {
	id = "accepted", customDialogText = "Keep your commlink handy. I'll send you the first location, then guide you through the rest.",
	stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "busy", customDialogText = "Follow the directions I sent you, kid. Your journal has the next lead, whether you're collecting parts or looking for Pall or Vourk. If you've lost track, I can help you pick up where you left off.",
	stopConversation = "false",
	options = {{"Remind me where I left off.", "resume"}, {"I'll get back to it.", "decline"}}
})
template:addScreen(ConvoScreen:new {
	id = "complete", customDialogText = "You got that speeder sorted out and made it through those introductions. Good. Keep it running, and watch yourself around Jabba's people.",
	stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "unavailable", customDialogText = "Can't talk right now, kid. Catch me here another time.",
	stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "blocked", customDialogText = "We can't get this arranged right now. Check your journal and speak to me again. If you're waiting on a reward, make sure you've got room in your pack.",
	stopConversation = "false",
	options = {{"Let me check my progress.", "resume"}, {"I'll come back later.", "decline"}}
})
template:addScreen(ConvoScreen:new {
	id = "resume", customDialogText = "Let's see where you were.", stopConversation = "true", options = {}
})
template:addScreen(ConvoScreen:new {
	id = "decline", customDialogText = "Suit yourself, kid.", stopConversation = "true", options = {}
})

addConversationTemplate("legacy_han_conv", template)
