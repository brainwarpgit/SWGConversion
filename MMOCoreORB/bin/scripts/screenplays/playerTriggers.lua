PlayerTriggers = { }

function PlayerTriggers:playerLoggedIn(pPlayer)
	if (pPlayer == nil) then
		return
	end
	ServerEventAutomation:playerLoggedIn(pPlayer)
	BestineElection:playerLoggedIn(pPlayer)
	if LegacyMosEisley ~= nil then
		LegacyMosEisley:playerLoggedIn(pPlayer)
	end
end

function PlayerTriggers:playerLoggedOut(pPlayer)
	if (pPlayer == nil) then
		return
	end
	ServerEventAutomation:playerLoggedOut(pPlayer)
	if LegacyMosEisley ~= nil then
		LegacyMosEisley:playerLoggedOut(pPlayer)
	end
end
