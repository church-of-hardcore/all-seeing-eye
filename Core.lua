-- we can mixin more Ace libs here
AllSeeingEye = LibStub("AceAddon-3.0"):NewAddon("AllSeeingEye", "AceEvent-3.0", "AceConsole-3.0")
LibStub:GetLibrary('LibWho-2.0'):Embed(AllSeeingEye)

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

AllSeeingEye.COLORS = COLORS

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
			eventpuncher = {
				enabled = true,
			},
			guildinviter = {
				primary = "Hardcore",
				secondary = "Mortal",
				tertiary = "HC Elite",
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

	local hookWorldClicks = self.db.profile.eventpuncher.enabled
	
		if hookWorldClicks then
			WorldFrame:HookScript("OnMouseDown", function(self,button)
				LibStub('LibWho-2.0'):AskWhoNext()
			end)
		end
end

function AllSeeingEye:OnEnable()
	self:RegisterEvent("PLAYER_STARTED_MOVING")
	-- self:RegisterEvent("CHAT_MSG_CHANNEL")
end

function AllSeeingEye:PLAYER_STARTED_MOVING(event)
	-- print(event)
	-- LibStub('LibWho-2.0'):AskWhoNext()
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

	elseif input == "toggle" then
		AllSeeingEye:Toggle()
		local state = "Shown"
		if self.db.profile.minimap.hide then state = "Hidden" end
		print(self.COLORS.HEIRLOOM .. "All-Seeing Eye:" .. self.COLORS.NORMAL .. state)

	-- testing code for guild inviter
	elseif input == "ginv" then
		print(self.COLORS.HEIRLOOM .. "All-Seeing Eye:" .. self.COLORS.NORMAL .. 'Hunting Rabbits...')
		AllSeeingEye:GetUserData()

	-- end testing code

	else -- A R G B -> |caarrggb colored-text |r default-text blah
		self:Print(self.COLORS.HEIRLOOM .. "All-Seeing Eye" .. self.COLORS.NORMAL)
		self:Print(self.COLORS.LIGHT_BLUE .. "Syntax:" .. self.COLORS.NORMAL .. " /allseeingeye [command]")
		self:Print(self.COLORS.LIGHT_BLUE .. "Syntax:" .. self.COLORS.NORMAL .. " /ase [command]")
		self:Print(self.COLORS.UNCOMMON .. "Commands:" .. self.COLORS.NORMAL .. " enable disable options toggle ginv")
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

--[[

The goal is to allow the player to activate one of two main functions:
 - join calculated/assigned guild from the field of HC guilds, or
 - join a specific guild from the same field instead

Regardless of which of the above we are catering for (or the method used to decide which
is the correct guild), we need do or know the following:
 - what are the blessed guilds for this server? what if there's only one?
 - get list of players online in a guild
 - message a random player from the list
 - automatically respond to requests for 'invite to guild'

 Initial goal: get a /who for a known guild

]]

function AllSeeingEye:UpdateEventPumper()
	print("UpdateEventPumper")
end

-- set up the queue puncher
function AllSeeingEye:InitQueuePuncher()
	--  Set up an empty frame for updates
	self.updateFrame = CreateFrame("Frame")
	self.updateFrame:SetScript("OnUpdate", AllSeeingEye.QueuePuncher_OnUpdate)

	--[[ CensusPlusWhoButton:SetScript("OnClick",
		function(self, button, down)
			-- As we have not specified the button argument to SetBindingClick,
			-- the binding will be mapped to a LeftButton click.
			AllSeeingEye:AskWhoNext()
		end
	) ]]
end

-- handler for OnUpdate event: NO SELF
function AllSeeingEye.QueuePuncher_OnUpdate()
	-- print(AllSeeingEye.COLORS.HEIRLOOM .. "All-Seeing Eye:" .. AllSeeingEye.COLORS.NORMAL .. 'ONUPDATE SEASON!...')
	LibStub('LibWho-2.0'):AskWhoNext()
end

-- perform a lookup of the active player
function AllSeeingEye:GetUserData(name)
	print(self.COLORS.HEIRLOOM .. "All-Seeing Eye:" .. self.COLORS.NORMAL .. 'Duck Season!...')
	if (name == nil) or (name == '') then
		name, _ = UnitName("player")
	end
	print ("Now hunting...", name)
	local user, time = self:UserInfo(name, { callback = 'UserDataReturned' } )
	if user then
		-- the data was immediately available
		print ("FOUND: ", user, " at ", time)
		self:UserDataReturned(user, time)
	else
		-- nothing
		-- we will be called when the data is available
	end
end

-- callback function
function AllSeeingEye:UserDataReturned(user, time)
	print("User data returned via callback:" .. user.Name)
	local state
	if user.Online == true then
		state = 'Online'
	elseif user.Online == false then
		state = 'Offline'
	else
		-- user.Online is nil
		state = 'Unknown'
	end
	DEFAULT_CHAT_FRAME:AddMessage(user.Name .. ' is ' .. state)
end

