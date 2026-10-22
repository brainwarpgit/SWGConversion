#ifndef LEGACY_QUESTMARKER_H_
#define LEGACY_QUESTMARKER_H_

#include "server/zone/objects/creature/ai/AiAgent.h"
#include "server/zone/objects/creature/ai/CreatureTemplate.h"
#include "server/zone/objects/player/PlayerObject.h"
#include "templates/params/OptionBitmask.h"

// Opt-in presentation only. Never mutate the NPC's shared options.
inline uint32 questMarkerOptions(CreatureObject* npc, CreatureObject* viewer) {
    uint32 options = npc->getOptionsBitmask();
    if (!npc->isAiAgent() || viewer == nullptr || !viewer->isPlayerCreature())
        return options;
    auto definition = npc->asAiAgent()->getCreatureTemplate();
    auto ghost = viewer->getPlayerObject();
    if (definition != nullptr && definition->getQuestMarkerQuest() != 0 && ghost != nullptr
            && ghost->isJournalQuestComplete(definition->getQuestMarkerQuest()))
        options &= ~OptionBitmask::INTERESTING;
    return options;
}

#endif
