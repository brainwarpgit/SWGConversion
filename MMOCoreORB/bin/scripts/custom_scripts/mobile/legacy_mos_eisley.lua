-- The NPCs are noncombatants. Quest progression is handled by the screenplay.
local questNpcs = {
	{ "legacy_pall", "Pall", "majolnir", "legacy_pall_conv", 1, "quest/find_majolnir" },
	{ "legacy_vourk", "Vourk ver'Zremp", "dressed_tatooine_opening_santos", "legacy_vourk_conv", 1, "quest/tatooine_eisley_legacy" },
	{ "legacy_mos_eisley_mayor", "Mayor Mikdanyell Guh'rantt", "dressed_mayor_mikdanyell_guhrantt", "legacy_mayor_conv", 1, "quest/tatooine_eisley_gotomayor" },
	{ "legacy_han_solo", "Han Solo", "han_solo", "legacy_han_conv", 1, "quest/speeder_quest" },
	{ "legacy_chewbacca", "Chewbacca", "chewbacca", "", 1.27 },
}

for _, npc in ipairs(questNpcs) do
	CreatureTemplates:addCreatureTemplate(Creature:new {
		customName = npc[2],
		socialGroup = "townsperson",
		faction = "townsperson",
		mobType = MOB_NPC,
		level = 1,
		baseHAM = 100,
		baseHAMmax = 100,
		resists = {0, 0, 0, 0, 0, 0, 0, -1, -1},
		pvpBitmask = NONE,
		creatureBitmask = NONE,
		optionsBitmask = AIENABLED + (npc[4] ~= "" and (CONVERSABLE + INTERESTING) or 0),
		diet = HERBIVORE,
		scale = npc[5] or 1,
		questMarkerQuest = npc[6] or "",
		templates = { "object/mobile/" .. npc[3] .. ".iff" },
		conversationTemplate = npc[4],
	}, npc[1])
end

-- NGE's chassis area has three Tusken scavengers. Use fixed PRECU novice
-- encounter statistics (the local slaver profile), never player-level scaling.
local noviceTusken = Creature:new {
	customName = "a Tusken scavenger",
	socialGroup = "tusken_raider",
	faction = "tusken_raider",
	mobType = MOB_NPC,
	level = 4,
	chanceHit = 0.24,
	damageMin = 40,
	damageMax = 45,
	baseXp = 85,
	baseHAM = 113,
	baseHAMmax = 138,
	armor = 0,
	resists = {0, 0, 0, 0, 0, 0, 0, -1, -1},
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK,
	optionsBitmask = AIENABLED,
	diet = HERBIVORE,
	templates = { "object/mobile/tusken_raider.iff" },
	primaryWeapon = "tusken_ranged",
	secondaryWeapon = "tusken_melee",
	primaryAttacks = marksmannovice,
	secondaryAttacks = brawlernovice,
}
CreatureTemplates:addCreatureTemplate(noviceTusken, "legacy_tusken_scavenger")

-- Original zealots use the newbie social group and a four-meter aggression
-- range. Reuse this quest's fixed PRECU combat profile, not NGE level scaling.
CreatureTemplates:addCreatureTemplate(noviceTusken:new {
	customName = "a Tusken zealot",
	socialGroup = "tusken_raider_newbie",
	aggroRadius = 4,
	-- Core3 PACK assistance reaches about 25 m; the screenplay preserves 4 m.
	-- Core3 STALKER adds a separate pre-combat behavior, so retain normal pursuit.
	creatureBitmask = NONE,
}, "legacy_tusken_zealot")
