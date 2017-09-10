
local BLTUIButton_init = BLTUIButton.init
local BLTModItem_init = BLTModItem.init
local BLTDownloadControl_init = BLTDownloadControl.init

local box_height = 128
local icon_size = 32
local padding = 10

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function BLTMod:HasModImage()
	-- suppress image loading
	return false
end

function BLTUIButton:init(panel, parameters, ...)

	local found

	-- identify download manager button
	if parameters and parameters.text and parameters.text == managers.localization:text("blt_download_manager_help") then
		found = true
		-- fix height param
		parameters.h = box_height
		-- delete image param
		parameters.image = nil
	end

	-- let the button be generated
	local result = BLTUIButton_init(self, panel, parameters, ...)

	if found then
		-- fix text positioning
		local title = self._panel:child("title")
		local desc = self._panel:child("desc")
		if title and desc then

			-- center y
			local full_height = title:h() + desc:h() + 5
			title:set_top((self._panel:h() - full_height) * 0.5)
			desc:set_top(title:bottom() + 5)

		end
	end

	return result
end

function BLTModItem:init(panel, index, mod, ...)

	-- let the item be generated
	local result = BLTModItem_init(self, panel, index, mod, ...)

	-- fix box positioning
	local w = (panel:w() - (self.layout.x + 1) * padding) / self.layout.x
	local column, row = self:_get_col_row(index)
	self._panel:set_x((w + padding) * (column - 1))
	self._panel:set_y((box_height + padding) * (row - 1))

	-- fix box height
	self._panel:set_height(box_height)

	-- scan for child panels and remove them. these are:
	-- 1. the "no image" box and
	-- 2. the 4 white corners - their alignments are set to "grow", so they got stretched by the box resizing
	-- also check if there are icons
	local has_icons
	for _, child in pairs(self._panel:children()) do
		if alive(child) then
			if child.type_name == "Panel" then
				self._panel:remove(child)
			elseif child.type_name == "Bitmap" and child.texture ~= "guis/textures/test_blur_df" then -- ignore the background
				has_icons = true
			end
		end
	end

	-- recreate the white corners with correct size
	BoxGuiObject:new(self._panel, {sides = {1, 1, 1, 1}})

	-- fix text positions / sizes
	local mod_name = self._panel:child("mod_name")
	local mod_desc = self._panel:child("mod_desc")
	if mod_name and mod_desc then

		-- fix width (prevent overlapping with icons)
		if has_icons then
			local w = self._panel:w() - padding * 4 - icon_size * 2
			mod_name:set_w(w)
			mod_desc:set_w(w)
		end

		-- truncate title text
		local name = mod:GetName()
		local max_len = 18
		if name:len() > max_len then
			name = name:sub(1, max_len) .. ".."
		end
		mod_name:set_text(name)
		mod_name:set_align("center")

		-- truncate description text and remove line breaks
		local desc = mod:GetDescription():gsub("\n", " ")
		local max_len = 95
		if desc:len() > max_len then
			desc = desc:sub(1, max_len) .. "..."
		end
		mod_desc:set_text(desc)
		mod_desc:set_align("center")

		-- refresh sizes
		make_fine_text(mod_name)
		make_fine_text(mod_desc)

		-- center x
		mod_name:set_center_x(self._panel:w() * 0.5)
		mod_desc:set_center_x(self._panel:w() * 0.5)

		-- center y
		local full_height = mod_name:h() + mod_desc:h() + 5
		mod_name:set_top((self._panel:h() - full_height) * 0.5)
		mod_desc:set_top(mod_name:bottom() + 5)

	end

	return result
end

function BLTDownloadControl:init(panel, parameters, ...)

	-- let the control be generated
	local result = BLTDownloadControl_init(self, panel, parameters, ...)

	-- scan for the "no image" panel and remove it
	for _, child in pairs(self._info_panel:children()) do
		if alive(child) and child.type_name == "Panel" then
			self._info_panel:remove(child)
		end
	end

	-- fix download info position/ size
	local title = self._info_panel:child("title")
	local state = self._info_panel:child("state") or self._panel:child("state") -- blt bug fix
	local download_progress = self._info_panel:child("download_progress")
	for _, obj in pairs({title, state, download_progress}) do
		if alive(obj) then
			obj:set_x(padding * 2)
			obj:set_w(self._info_panel:w() - padding * 3)
		end
	end

	return result
end