local AllSeeingEye = LibStub("AceAddon-3.0"):GetAddon("AllSeeingEye")

AllSeeingEye.defaults = {
	profile = {
		hideMinimapToggle = false,
		eventPumper = true,
		someRange = 7,
		someInput = "Hello World",
		someSelect = 2, -- Banana
	},
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
AllSeeingEye.options = {
	type = "group",
	name = "AllSeeingEye",
	handler = AllSeeingEye,
	args = {
		hideMinimapToggle = {
			type = "toggle",
			order = 1,
			name = "Hide Mini-map",
			desc = "Hide the Mini-map Icon?",
			-- inline getter/setter example
			get = function(info)
				return AllSeeingEye.db.profile.minimap.hide
			end,
			set = function(info, value)
				AllSeeingEye.db.profile.minimap.hide = value
				AllSeeingEye:UpdateMinimap()
			end,
		},
		eventPumper = {
			type = "toggle",
			order = 2,
			name = "Enable Event Pumper",
			desc = "If enabled, the internal LibWho system will hook clicks on the game world to drive events",
			-- inline getter/setter example
			get = function(info)
				return AllSeeingEye.db.profile.eventpumper.enabled
			end,
			set = function(info, value)
				AllSeeingEye.db.profile.eventpumper.enabled = value
				AllSeeingEye:UpdateEventPumper()
			end,
		},
		someRange = {
			type = "range",
			order = 3,
			name = "a slider",
			-- this will look for a getter/setter on our handler object
			get = "GetSomeRange",
			set = "SetSomeRange",
			min = 1,
			max = 10,
			step = 1,
		},
		guilds = {
			type = "group",
			order = 4,
			name = "Guilds",
			inline = true,
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				primaryInput = {
					type = "input",
					order = 1,
					name = "Primary Guild:",
					width = "double",
				},
				secondaryInput = {
					type = "input",
					order = 2,
					name = "Secondary Guild:",
					width = "double",
				},
				ternaryInput = {
					type = "input",
					order = 3,
					name = "Tertiary Guild",
					width = "double",
				},
			},
		},
		group1 = {
			type = "group",
			order = 5,
			name = "a group",
			inline = true,
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				someInput = {
					type = "input",
					order = 1,
					name = "message input box - retrieve using: /ase message",
					width = "double",
				},
				someDescription = {
					type = "description",
					order = 2,
					name = function()
						return format("The current time is: |cff71d5ff%s|r", date("%X"))
					end,
					fontSize = "large",
				},
				someSelect = {
					type = "select",
					order = 3,
					name = "a dropdown",
					values = {"Apple", "Banana", "Strawberry"},
				},
			},
		},
	},
}

function AllSeeingEye:GetSomeRange(info)
	return self.db.profile.someRange
end

function AllSeeingEye:SetSomeRange(info, value)
	self.db.profile.someRange = value
end

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function AllSeeingEye:GetValue(info)
	return self.db.profile[info[#info]]
end

function AllSeeingEye:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
