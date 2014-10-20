local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.IconButton = UI.Button:extend({
	icon = nil,
	style = function (self)
		self:texture({
			layer = 'BACKGROUND',
			subLayer = 0,
			color = {0, 0, 0, 0.95},
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})
		self.icon = self:texture({
			layer = 'BORDER',
			subLayer = 2,
			file = self.icon,
			coords = {.08, .92, .08, .92},
			tile = false,
			-- color = {color.r, color.g, color.b, 0.95},
			-- color = self.color,
			offset = {1,1,1,1},
		})
		self.outline = self:outline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.25 },
			colorEnd = {1, 1, 1, 0.3 },
			offset = {1, 1, 1, 1},
		})
		self.highlight = self:texture({
			layer = 'ARTWORK',
			gradient = 'VERTICAL',
			color = {0,1,1,0.15},
			colorEnd = {0,1,1,0.20},
			offset = {1,1,1,1},
		})
		self.highlight:Hide()
	end,
	hook = function (self)
		self.frame:RegisterForClicks('AnyUp')
		self.frame:SetScript('OnEnter', function (frame)
			self.highlight:Show()
			if (self.onEnter) then
				self:onEnter()
			end
		end)
		self.frame:SetScript('OnLeave', function (frame)
			self.highlight:Hide()
			if (self.onLeave) then
				self:onLeave()
			end
		end)
		self.frame:SetScript('OnClick', function (frame)
			if (self.onClick) then
				self:onClick()
			end
		end)
	end,	
})

UI.EditBox = UI.Panel:extend({
	type = 'EditBox',
	lines = 1,
	style = function (self)
		self:texture({
			layer = 'BACKGROUND',
			subLayer = 0,
			color = {0, 0, 0, 0.95},
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})
		self:texture({
			layer = 'ARTWORK',
			subLayer = 2,
			gradiend = 'VERTICAL',
			color = {0, 0, 0, 0.45},
			colorEnd = {0, 0, 0, 0.95},
			offset = {2, 2, 2, 2},
			-- height = 1,
		})
		self.outline = self:outline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.35 },
			colorEnd = {1, 1, 1, 0.10 },
			offset = {1, 1, 1, 1},
		})
	end,
	postInit = function (self)
		local style = self._fontStringStyle

		self.frame:SetFont(style.font, style.fontSize, style.fontFlags)
		self.frame:SetTextInsets(4, 4, 0, 0)
		self.frame:SetMultiLine(self.lines > 1)
		--self.frame:SetAutoFocus(true)
		self.frame:Disable()
	end,
	hook = function (self)
		local frame = self.frame
		-- frame:SetScript('OnEnterPressed', function ()
		-- 	if self.lines == 1 then
		-- 		frame:Disable()
		-- 	end
		-- 	if (self.onEnterPressed) then
		-- 		self:onEnterPressed(frame)
		-- 	end
		-- end)

		frame:SetScript('OnEscapePressed', function () 
			frame:Disable()
			if (self.onEscapePressed) then
				self:onEscapePressed(frame)
			end
		end)
		frame:SetScript('OnLeave', function ()
			if (self.onLeave) then
				self:onLeave(frame)
			end
		end)
		frame:SetScript('OnEnter', function ()
			if (self.onEnter) then
				self:onEnter(frame)
			end
		end)
		frame:SetScript('OnMouseDown', function () 
			frame:Enable()
			if (self.onMouseDown) then
				self:onMouseDown(frame)
			end
		end)
	end
})