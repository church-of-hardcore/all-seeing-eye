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
	if type(func) == "function" then
		return xpcall(func, errorhandler, ...)
	end
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
	if self.main_window_exists == true then
		return
	end
	self.main_window_exists = true

	local window = self.AceGUI:Create("Window")
	window:SetTitle("All-Seeing Eye")
	window:SetCallback("OnClose", function(widget) self:DestroyMainWindow(widget) end)
	window:SetLayout("AllSeeingEye_Validation") -- was: Flow
	window:SetWidth(700)

	local frame = window.frame

	local heading = self.AceGUI:Create("InteractiveLabel")
	heading:SetText("The All-Seeing Eye is Open")

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

	window:AddChild(heading)
	window:AddChild(label)
	window:AddChild(editbox)
end


-- AceGUI Layout for main window
AceGUI:RegisterLayout("AllSeeingEye_Validation",
	function(content, children)
		if layoutrecursionblock then return end
		--used height so far
		local height = 0
		--width used in the current row
		local usedwidth = 0
		--height of the current row
		local rowheight = 0
		local rowoffset = 0

		local width = content.width or content:GetWidth() or 0

		--control at the start of the row
		local rowstart
		local rowstartoffset
		local isfullheight

		local frameoffset
		local lastframeoffset
		local oversize
		for i = 1, #children do
			local child = children[i]
			oversize = nil
			local frame = child.frame
			local frameheight = frame.height or frame:GetHeight() or 0
			local framewidth = frame.width or frame:GetWidth() or 0
			lastframeoffset = frameoffset
			-- HACK: Why did we set a frameoffset of (frameheight / 2) ?
			-- That was moving all widgets half the widgets size down, is that intended?
			-- Actually, it seems to be neccessary for many cases, we'll leave it in for now.
			-- If widgets seem to anchor weirdly with this, provide a valid alignoffset for them.
			-- TODO: Investigate moar!
			frameoffset = child.alignoffset or (frameheight / 2)

			if child.width == "relative" then
				framewidth = width * child.relWidth
			end

			frame:Show()
			frame:ClearAllPoints()
			if i == 1 then
				-- anchor the first control to the top center
				frame:SetPoint("TOP", content)
				rowheight = frameheight
				rowoffset = frameoffset
				rowstart = frame
				rowstartoffset = frameoffset
				usedwidth = framewidth
				if usedwidth > width then
					oversize = true
				end
			else
				-- if there isn't available width for the control start a new row
				-- if a control is "fill" it will be on a row of its own full width
				if usedwidth == 0 or ((framewidth) + usedwidth > width) or child.width == "fill" then
					if isfullheight then
						-- a previous row has already filled the entire height, there's nothing we can usefully do anymore
						-- (maybe error/warn about this?)
						break
					end
					--anchor the previous row, we will now know its height and offset
					rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
					height = height + rowheight + 3
					--save this as the rowstart so we can anchor it after the row is complete and we have the max height and offset of controls in it
					rowstart = frame
					rowstartoffset = frameoffset
					rowheight = frameheight
					rowoffset = frameoffset
					usedwidth = framewidth
					if usedwidth > width then
						oversize = true
					end
				-- put the control on the current row, adding it to the width and checking if the height needs to be increased
				else
					--handles cases where the new height is higher than either control because of the offsets
					--math.max(rowheight-rowoffset+frameoffset, frameheight-frameoffset+rowoffset)

					--offset is always the larger of the two offsets
					rowoffset = math_max(rowoffset, frameoffset)
					rowheight = math_max(rowheight, rowoffset + (frameheight / 2))

					frame:SetPoint("TOPLEFT", children[i-1].frame, "TOPRIGHT", 0, frameoffset - lastframeoffset)
					usedwidth = framewidth + usedwidth
				end
			end

			if child.width == "fill" then
				safelayoutcall(child, "SetWidth", width)
				frame:SetPoint("RIGHT", content)

				usedwidth = 0
				rowstart = frame
				rowstartoffset = frameoffset

				if child.DoLayout then
					child:DoLayout()
				end
				rowheight = frame.height or frame:GetHeight() or 0
				rowoffset = child.alignoffset or (rowheight / 2)
				rowstartoffset = rowoffset
			elseif child.width == "relative" then
				safelayoutcall(child, "SetWidth", width * child.relWidth)

				if child.DoLayout then
					child:DoLayout()
				end
			elseif oversize then
				if width > 1 then
					frame:SetPoint("RIGHT", content)
				end
			end

			if child.height == "fill" then
				frame:SetPoint("BOTTOM", content)
				isfullheight = true
			end
		end

		--anchor the last row, if its full height needs a special case since  its height has just been changed by the anchor
		if isfullheight then
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -height)
		elseif rowstart then
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
		end

		height = height + rowheight + 3
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end)