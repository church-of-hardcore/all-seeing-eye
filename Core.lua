-- we can mixin more Ace libs here
AllSeeingEye = LibStub("AceAddon-3.0"):NewAddon("AllSeeingEye", "AceEvent-3.0", "AceConsole-3.0")

local COLORS = { -- https://pixelimperfectdotcom.wordpress.com/2013/09/05/all-world-of-warcraft-hex-color-codes/
	NORMAL = "|r",
	GENERAL = "|cfffec1c0",
	SYSTEM = "|cffffff00",
	GUILD = "|cff3ce13f",
	OFFICER = "|cff40bc40",
	-- ...
	WHISPER = "|cffff7eff",
	YELL = "|cffff3f40",
	-- ...
	BNET_WHISPER = "|cff00faf6",
	BNET_CONVERSATION = "|cff00afef",
	-- ...
	POOR = "|cff889d9d",
	COMMON = "|cffffffff",
	UNCOMMON = "|cff1eff0c",
	RARE = "|cff0070ff",
	SUPERIOR = "|cffa335ee",
	LEGENDARY = "|cffff8000",
	HEIRLOOM = "|cffe6cc80",
	-- ...
	LIGHT_BLUE = "|cff00afef",
}

local DBI = LibStub("LibDBIcon-1.0")

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local AceGUI = LibStub("AceGUI-3.0")

local AseLDB = LibStub("LibDataBroker-1.1"):NewDataObject("All-Seeing Eye", {
	type = "data source",
	text = "All-Seeing Eye Text",
	-- icon = "Interface\\Icons\\INV_Chest_Cloth_17",
	icon = "Interface\\Icons\\spell_shadow_unholyfrenzy",
	OnClick = function(clicked_frame, button)
		if button == "RightButton" then
			AllSeeingEye:ShowConfig()
		else
			-- AllSeeingEye:Toggle()
			AllSeeingEye:MainWindow()
		end
	end,

	OnTooltipShow = function(tt)
		tt:AddLine(COLORS.HEIRLOOM .. "AllSeeingEye" .. COLORS.NORMAL)
		tt:AddLine(COLORS.UNCOMMON .. "Click" .. COLORS.NORMAL .. " to toggle the All-Seeing Eye window")
		tt:AddLine(COLORS.UNCOMMON .. "Right-click" .. COLORS.NORMAL .. " to open the options menu")
	end,
})

local icon = LibStub("LibDBIcon-1.0")

function AllSeeingEye:OnInitialize()
	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	self.db = LibStub("AceDB-3.0"):New("AllSeeingEyeDB", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})
	icon:Register("AllSeeingEye", AseLDB, self.db.profile.minimap)

	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-registry-3-0
	AC:RegisterOptionsTable("AllSeeingEye_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("AllSeeingEye_Options", "All-Seeing Eye")

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("AllSeeingEye_Profiles", profiles)
	ACD:AddToBlizOptions("AllSeeingEye_Profiles", "Profiles", "AllSeeingEye_Options")

	self.AceGUI = AceGUI

	-- define other useful booleans for now
	self.main_window_exists = false

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("ase", "SlashCommand")
	self:RegisterChatCommand("allseeingeye", "SlashCommand")

	self:GetCharacterInfo()
end

function AllSeeingEye:OnEnable()
	self:RegisterEvent("PLAYER_STARTED_MOVING")
	-- self:RegisterEvent("CHAT_MSG_CHANNEL")
end

function AllSeeingEye:PLAYER_STARTED_MOVING(event)
	print(event)
end

--[[ function AllSeeingEye:CHAT_MSG_CHANNEL(event, text, ...)
	-- prints the whole event payload
	print(event, text, ...)
end ]]

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

	elseif input == "options" then
		self:ShowConfig()

	elseif input == "message" then
		self:Print(COLORS.HEIRLOOM .. "Stored Message: " .. COLORS.NORMAL .. self.db.profile.someInput)

	elseif input == "toggle" then
		AllSeeingEye:Toggle()
		local state = "Shown"
		if self.db.profile.minimap.hide then state = "Hidden" end
		print(COLORS.HEIRLOOM .. "All-Seeing Eye:" .. COLORS.NORMAL .. state)

	else -- A R G B -> |caarrggb blsadfjsdhf |r default-text blah
		self:Print(COLORS.HEIRLOOM .. "All-Seeing Eye" .. COLORS.NORMAL)
		self:Print(COLORS.LIGHT_BLUE .. "Syntax:" .. COLORS.NORMAL .. " /allseeingeye [command]")
		self:Print(COLORS.LIGHT_BLUE .. "Syntax:" .. COLORS.NORMAL .. " /ase [command]")
		self:Print(COLORS.UNCOMMON .. "Commands:" .. COLORS.NORMAL .. " enable disable options toggle message")
	end
end

function AllSeeingEye:Toggle()
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	AllSeeingEye:UpdateMinimap()
end

function AllSeeingEye:UpdateMinimap()
	if self.db.profile.minimap.hide then
		icon:Hide("AllSeeingEye")
	else
		icon:Show("AllSeeingEye")
	end
end

function AllSeeingEye:ShowConfig()
	-- https://github.com/Stanzilla/WoWUIBugs/issues/89
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end
