local AceGUI = LibStub("AceGUI-3.0")
local AllSeeingEye = LibStub("AceAddon-3.0"):GetAddon("AllSeeingEye")

local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	-- we check to see if the func is passed is actually a function here and don't error when it isn't
	-- this safecall is used for optional functions like OnInitialize OnEnable etc. When they are not
	-- present execution should continue without hinderance
	if type(func) == "function" then return xpcall(func, errorhandler, ...) end
end

local layoutrecursionblock = nil
local function safelayoutcall(object, func, ...)
	layoutrecursionblock = true
	object[func](object, ...)
	layoutrecursionblock = nil
end

function AllSeeingEye:DestroyMainWindow(widget)
	self.main_window_exists = false
	self.AceGUI:Release(widget)
end

function AllSeeingEye:MainWindow()
	-- This pattern used because AllSeeingEye:CloseVerifiedDialog() above
	-- doesn't *hide* the window, it *destroys* it.
	-- this hard-check prevents reconstructing what's already showing
	if self.main_window_exists == true then return end
	self.main_window_exists = true

	local window = self.AceGUI:Create("Window")
	window:SetTitle("All-Seeing Eye")
	window:SetCallback("OnClose", function(widget)
		self:DestroyMainWindow(widget)
	end)
	window:SetLayout("Flow")
	window:SetWidth(700)

	-- Add the frame as a global variable under the name `AllSeeingEyeMainWindow`
	_G["AllSeeingEyeMainWindow"] = window.frame
	-- Register the global variable `AllSeeingEyeMainWindow` as a "special frame"
	-- so that it is closed when the escape key is pressed.
	tinsert(UISpecialFrames, "AllSeeingEyeMainWindow")

	local frame = window.frame

	local heading = self.AceGUI:Create("Heading")
	heading:SetText("The All-Seeing Eye is Open")
	heading:SetFullWidth(1)

	local label = self.AceGUI:Create("Label")
	label:SetFontObject(GameFontNormalLarge)
	label:SetJustifyH("CENTER")
	label:SetText("Select All (Ctrl-A), Copy (Ctrl-C), and Paste (Ctrl-V)\nthis code to https://hardhead.io/paste")
	label:SetFullWidth(1)

	local editbox = self.AceGUI:Create("MultiLineEditBox")
	editbox:SetLabel("Your validation code:")
	local verification_string = "ASDFASDFASDFASDFJASDJFAJSDFJASJDFJASDJF@#J$@J#$JSZDJFJSADJQ@#$J@#J$JJASDFJASJD#@JR#@JSJDF"
	editbox:SetText(verification_string)
	editbox:SetFullWidth(1)
	editbox:SetNumLines(24)
	editbox:DisableButton(true)
	editbox:HighlightText(0, -1)
	editbox:SetFocus()
	editbox:SetCallback("OnTextChanged", function(widget, event, text)
		widget:SetText(verification_string)
	end)

	local button = self.AceGUI:Create("Button")
	button:SetText("Select All")
	button:SetWidth(200)
	button:SetCallback("OnClick", function()
		editbox:HighlightText(0, -1)
		editbox:SetFocus()
	end)

	window:AddChild(heading)
	window:AddChild(label)
	window:AddChild(editbox)
	window:AddChild(button)
end
