AllSeeingEye.defaults = {
	profile = {
		someToggle = true,
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
		minimapToggle = {
			type = "toggle",
			order = 1,
			name = "Hide Mini-map",
			desc = "Hide the Mini-map Icon?",
			-- inline getter/setter example
			get = function(info) return AllSeeingEye.db.profile.minimap.hide end,
			set = function(info, value)
				AllSeeingEye.db.profile.minimap.hide = value
				AllSeeingEye:UpdateMinimap()
			end,
		},
		someToggle = {
			type = "toggle",
			order = 2,
			name = "a checkbox",
			desc = "some description",
			-- inline getter/setter example
			get = function(info) return AllSeeingEye.db.profile.someToggle end,
			set = function(info, value) AllSeeingEye.db.profile.someToggle = value end,
		},
		someRange = {
			type = "range",
			order = 3,
			name = "a slider",
			-- this will look for a getter/setter on our handler object
			get = "GetSomeRange",
			set = "SetSomeRange",
			min = 1, max = 10, step = 1,
		},
		group1 = {
			type = "group",
			order = 4,
			name = "a group",
			inline = true,
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				someInput = {
					type = "input",
					order = 1,
					name = "an input box",
					width = "double",
				},
				someDescription = {
					type = "description",
					order = 2,
					name = function() return format("The current time is: |cff71d5ff%s|r", date("%X")) end,
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
