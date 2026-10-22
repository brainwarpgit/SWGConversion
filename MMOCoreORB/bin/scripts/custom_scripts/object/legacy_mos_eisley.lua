-- Original NGE object identifiers, with Core3 object behavior.
local questMobiles = {
	"majolnir",
	"dressed_tatooine_opening_santos",
	"dressed_mayor_mikdanyell_guhrantt",
}

for _, name in ipairs(questMobiles) do
	local sharedPath = "object/mobile/shared_" .. name .. ".iff"
	local shared = SharedCreatureObjectTemplate:new { clientTemplateFileName = sharedPath }
	ObjectTemplates:addClientTemplate(shared, sharedPath)
	ObjectTemplates:addTemplate(shared:new {}, "object/mobile/" .. name .. ".iff")
end

local retrieveObjects = {
	"speeder_debris_wiring",
	"speeder_junk_power",
	"speeder_junk_steering",
	"speeder_junk_engine",
}

for _, name in ipairs(retrieveObjects) do
	local sharedPath = "object/tangible/quest/shared_" .. name .. ".iff"
	local shared = SharedTangibleObjectTemplate:new { clientTemplateFileName = sharedPath }
	ObjectTemplates:addClientTemplate(shared, sharedPath)
	ObjectTemplates:addTemplate(shared:new {
		objectMenuComponent = "LegacyRetrieveMenuComponent",
	}, "object/tangible/quest/" .. name .. ".iff")
end

local xp38ControlPath = "object/intangible/vehicle/shared_landspeeder_xp38_pcd.iff"
local xp38Control = SharedIntangibleObjectTemplate:new { clientTemplateFileName = xp38ControlPath }
ObjectTemplates:addClientTemplate(xp38Control, xp38ControlPath)
ObjectTemplates:addTemplate(xp38Control:new {
	objectName = "@quest/ground/legacy_mos_eisley:xp38_name",
}, "object/intangible/vehicle/landspeeder_xp38_pcd.iff")

local xp38DeedPath = "object/tangible/deed/vehicle_deed/shared_landspeeder_xp38_deed.iff"
local xp38Deed = SharedTangibleObjectTemplate:new { clientTemplateFileName = xp38DeedPath }
ObjectTemplates:addClientTemplate(xp38Deed, xp38DeedPath)
ObjectTemplates:addTemplate(xp38Deed:new {
	templateType = VEHICLEDEED,
	objectName = "@quest/ground/legacy_mos_eisley:xp38_deed_name",
	detailedDescription = "@quest/ground/legacy_mos_eisley:xp38_description",
	controlDeviceObjectTemplate = "object/intangible/vehicle/landspeeder_xp38_pcd.iff",
	generatedObjectTemplate = "object/mobile/vehicle/landspeeder_xp38.iff",
}, "object/tangible/deed/vehicle_deed/landspeeder_xp38_deed.iff")

-- Two uses, using the existing PRECU kit appearance and customization behavior.
ObjectTemplates:addTemplate(object_tangible_item_vehicle_customization:new {
	objectMenuComponent = "VehicleCustomKitObjectMenuComponent",
	useCount = 2,
}, "object/tangible/item/legacy_vehicle_customization.iff")
