-- we can mixin more Ace libs here
AllSeeingEye = LibStub("AceAddon-3.0"):NewAddon("AllSeeingEye", "AceEvent-3.0", "AceConsole-3.0")

local DBI = LibStub("LibDBIcon-1.0")

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local AseLDB = LibStub("LibDataBroker-1.1"):NewDataObject("All-Seeing Eye", {
    type = "data source",
    text = "All-Seeing Eye Text",
    icon = "Interface\\Icons\\INV_Chest_Cloth_17",
    OnClick = function() print("THE EYE IS WATCHING YOU") end,
})

local icon = LibStub("LibDBIcon-1.0")

function AllSeeingEye:OnInitialize()
	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	self.db = LibStub("AceDB-3.0"):New("AllSeeingEyeDB", { profile = { minimap = { hide = false, }, }, })	
	icon:Register("AllSeeingEye", AseLDB, self.db.profile.minimap)

	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-registry-3-0
	AC:RegisterOptionsTable("AllSeeingEye_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("AllSeeingEye_Options", "All-Seeing Eye")

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("AllSeeingEye_Profiles", profiles)
	ACD:AddToBlizOptions("AllSeeingEye_Profiles", "Profiles", "AllSeeingEye_Options")

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("ase", "SlashCommand")
	self:RegisterChatCommand("allseeingeye", "SlashCommand")

	self:GetCharacterInfo()
end

function AllSeeingEye:OnEnable()
	self:RegisterEvent("PLAYER_STARTED_MOVING")
	self:RegisterEvent("CHAT_MSG_CHANNEL")
end

function AllSeeingEye:PLAYER_STARTED_MOVING(event)
	print(event)
end

function AllSeeingEye:CHAT_MSG_CHANNEL(event, text, ...)
	-- prints the whole event payload
	print(event, text, ...)
end

function AllSeeingEye:GetCharacterInfo()
	-- stores character-specific data
	self.db.char.level = UnitLevel("player")
end

function AllSeeingEye:SlashCommand(input, editbox)
	if input == "enable" then
		self:Enable()
	elseif input == "disable" then
		-- unregisters all events and calls AllSeeingEye:OnDisable() if you defined that
		self:Disable()
	elseif input == "message" then
		print("this is our saved message:", self.db.profile.someInput)
	else
		self:Print("some useful help message")
		-- https://github.com/Stanzilla/WoWUIBugs/issues/89
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	end
end
