local addon, ns = ...
local O3 = ns.O3


O3:module({
	config = {
		enabled = true,
		lastMessage = nil,
		font = O3.Media:font('Normal'),
		fontSize = 10,
		fontStyle = '',
	},
	settings = {},
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Font',
		})
		self:addOption('font', {
			type = 'FontDropDown',
			label = 'Font',
		})
		self:addOption('fontSize', {
			type = 'Range',
			min = 6,
			max = 20,
			step = 1,
			label = 'Font size',
		})
		self:addOption('fontStyle', {
			type = 'DropDown',
			label = 'Outline',
			_values = O3.Media.fontStyles
		})
	end,
	events = {
		SYSMSG = true,
		UI_INFO_MESSAGE = true,
		UI_ERROR_MESSAGE = true,
	},
	name = 'Error',
	readable = 'Error frame',
	createPanel = function (self)
		self.panel = self.O3.UI.Panel:instance({
			name = self.name,
			offset = {nil, nil, 0, nil},
			width = 320,
			height = 20,
			createRegions = function (panel)
				self.text = panel:createFontString({
					offset = {0,0,-2,0},
				})
			end,
			style = function (panel)
				panel:createTexture({
					layer = 'BACKGROUND',
					file = O3.Media:texture('Background'),
					tile = true,
					color = {0.5, 0.5, 0.5, 0.9},
					offset = {1,1,1,1},
				})
				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {1, 1, 1, 1},
					-- width = 2,
					-- height = 2,
				})
				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0 },
				})			
			end,
		})
	end,
	postInit = function (self)
		O3:destroy(UIErrorsFrame)
	end,
	SYSMSG = function (self, message, r, g, b)
		if (self.lastMessage ~= message) then
			self.lastMessage = message
			self.text:SetText(message)
			self.text:SetTextColor(r, g, b)
		end
	end,
	UI_INFO_MESSAGE = function (self, message)
		if (self.lastMessage ~= message) then
			self.lastMessage = message
			self.text:SetText(message)
			self.text:SetTextColor(1, 1, 0)
		end
	end,
	UI_ERROR_MESSAGE = function (self, message)
		if (self.lastMessage ~= message) then
			self.lastMessage = message
			self.text:SetText(message)
			self.text:SetTextColor(1, 0.1, 0.1)
		end
	end,
	applyOptions = function (self)
		self.text:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontStyle)
	end,
})