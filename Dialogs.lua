function AllSeeingEye:DestroyMainWindow(widget)
	self.main_window_exists = false
	self.AceGUI:Release(widget)
end

function AllSeeingEye:MainWindow()
	-- This pattern used because AllSeeingEye:CloseVerifiedDialog() above
	-- doesn't *hide* the window, it *destroys* it.
	-- this hard-check prevents reconstructing what's already showing
	if self.main_window_exists == true then
		return
	end
	self.main_window_exists = true

	local window = self.AceGUI:Create("Window") -- this is where I'll choose my own dialog type later
	window:SetTitle("All-Seeing Eye")
	window:SetCallback("OnClose", function(widget) self:DestroyMainWindow(widget) end)
	window:SetLayout("Flow") -- this is where I'll choose my own layout type later
	window:SetWidth(700)

	local frame = window.frame
	
	local label = self.AceGUI:Create("Label")
	label:SetText("Select All (Ctrl-A), Copy (Ctrl-C), and Paste (Ctrl-V)\nthis code to https://hardhead.gg/paste")
	label:SetWidth(700)
	label:SetFontObject(GameFontNormalHuge)

	local editbox = self.AceGUI:Create("MultiLineEditBox")
	editbox:SetLabel("Your validation code:")
	local verification_string = "ASDFASDFASDFASDFJASDJFAJSDFJASJDFJASDJF@#J$@J#$JSZDJFJSADJQ@#$J@#J$JJASDFJASJD#@JR#@JSJDF"
	editbox:SetText(verification_string)
	editbox:SetRelativeWidth(1)
	editbox:SetFullHeight(1)
	editbox:DisableButton(true)
	editbox:HighlightText(0, -1)
	editbox:SetFocus()
	editbox:SetCallback("OnTextChanged", function(widget, event, text) widget:SetText(verification_string) end)

	window:AddChild(label)
	window:AddChild(editbox)
end