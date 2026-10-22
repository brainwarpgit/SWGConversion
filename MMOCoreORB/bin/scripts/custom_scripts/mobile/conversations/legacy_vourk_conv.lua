-- CreatureTemplateManager registers this template; its handler runs in DirectorManager.
local template = ConvoTemplate:new {
	initialScreen = "offer", templateType = "Lua", luaClassHandler = "legacyVourkConvoHandler", screens = {}
}

local function addScreen(id, text, options, custom)
	local screen = {id = id, stopConversation = #options == 0 and "true" or "false", options = options}
	if custom then
		screen.customDialogText = text
	else
		screen.leftDialog = "@conversation/c_newbie_secondchance:" .. text
	end
	template:addScreen(ConvoScreen:new(screen))
end

-- Han is the local starting contact; Vourk keeps his later original chain role.
addScreen("offer", "Looking for a way to get around Mos Eisley? Speak to Han Solo in Chalmun's Cantina. You'll find him with Chewbacca in an alcove inside.", {}, true)
addScreen("busy", "Follow Han's directions. When you've finished with the speeder and spoken to Pall, we'll talk again.", {
	{"Remind me where I left off.", "resume"}, {"I'll get back to it.", "decline"}
}, true)

addScreen("bib_offer", "s_116", {{"@conversation/c_newbie_secondchance:s_118", "why_jabba"}})
-- Adapt only the tutorial-specific backstory: PRECU entrants were not abducted on Tansarii.
addScreen("why_jabba", "I can't explain everything right now. Jabba has taken an interest in your dealings with Han, and he thinks you could be useful to him.", {
	{"@conversation/c_newbie_secondchance:s_122", "bib_contact"}, {"@conversation/c_newbie_secondchance:s_170", "explain_debt"}
}, true)
addScreen("bib_contact", "s_124", {{"@conversation/c_newbie_secondchance:s_126", "not_killed"}})
addScreen("not_killed", "s_128", {{"@conversation/c_newbie_secondchance:s_130", "trust"}})
addScreen("trust", "s_132", {
	{"@conversation/c_newbie_secondchance:s_134", "mayor_accepted"}, {"I need some time to think about this.", "decline"}
})
addScreen("explain_debt", "Han Solo has a talent for attracting Jabba's attention. By helping you, he's drawn that attention your way. Jabba figures you could be useful, and he doesn't make it easy to refuse him.", {
	{"@conversation/c_newbie_secondchance:s_64", "bib_representative"}
}, true)
addScreen("bib_representative", "s_66", {{"@conversation/c_newbie_secondchance:s_68", "inside_contact"}})
addScreen("inside_contact", "s_70", {{"@conversation/c_newbie_secondchance:s_72", "reimos_plan"}})
addScreen("reimos_plan", "s_74", {{"@conversation/c_newbie_secondchance:s_76", "earn_trust"}})
addScreen("earn_trust", "s_79", {{"@conversation/c_newbie_secondchance:s_83", "trust"}})
-- The original level-only Niko split is not a skill gate. This milestone grants only the approved Mayor route.
addScreen("mayor_accepted", "s_136", {})
addScreen("mayor_pending", "s_98", {
	{"@conversation/c_newbie_secondchance:s_100", "follow_bib"}, {"@conversation/c_newbie_secondchance:s_108", "wait_bib"},
	{"Remind me where I left off.", "resume"}
})
addScreen("follow_bib", "s_102", {{"@conversation/c_newbie_secondchance:s_104", "good_luck"}})
addScreen("good_luck", "s_106", {})
addScreen("wait_bib", "s_110", {{"@conversation/c_newbie_secondchance:s_112", "bye"}})
addScreen("bye", "s_114", {})
addScreen("complete", "You've spoken to the Mayor. I don't have another job for you right now.", {}, true)
addScreen("blocked", "We can't sort this out right now. Check your current assignment and speak to me again.", {
	{"Remind me where I left off.", "resume"}, {"I'll come back later.", "decline"}
}, true)
addScreen("resume", "Let's see where you were.", {}, true)
addScreen("decline", "Come back when you're ready.", {}, true)

addConversationTemplate("legacy_vourk_conv", template)
