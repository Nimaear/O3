local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.IconButton = UI.Button:extend({
	icon = nil,
	width = 32,
	height = 32,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = 0,
			color = {0, 0, 0, 0.65},
			offset = {0, 0, 0, 0},
			-- height = 1,
		})
		if type(self.icon) == 'table' then
			self.icon:SetParent(self.frame)
			self.icon:SetDrawLayer('BORDER', 2)
			self.icon:SetPoint('BOTTOMLEFT', 1, 1)
			self.icon:SetPoint('TOPRIGHT', -1, -1)
		else
			self.icon = self:createTexture({
				layer = 'BORDER',
				subLayer = 2,
				file = self.icon,
				coords = {.08, .92, .08, .92},
				tile = false,
				-- color = {color.r, color.g, color.b, 0.95},
				-- color = self.color,
				offset = {1,1,1,1},
			})
		end
		self.outline = self:createOutline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.1 },
			colorEnd = {1, 1, 1, 0.2 },
			offset = {1, 1, 1, 1},
		})
		self.highlight = self:createTexture({
			layer = 'ARTWORK',
			gradient = 'VERTICAL',
			color = {0,1,1,0.15},
			colorEnd = {0,1,1,0.20},
			offset = {1,1,1,1},
		})
		self.highlight:Hide()
	end,
	setTexture = function (self, texture)
		self.icon:SetTexture(texture)
	end,	
	hook = function (self)
		self.frame:RegisterForClicks('AnyUp', 'AnyDown')
		self.frame:SetScript('OnEnter', function (frame)
			if (not self._enabled) then
				return
			end
			self.highlight:Show()
			if (self.onEnter) then
				self:onEnter(self.frame)
			end
		end)
		self.frame:SetScript('OnLeave', function (frame)
			if (not self._enabled) then
				return
			end			
			self.highlight:Hide()
			if (self.onLeave) then
				self:onLeave(self.frame)
			end
		end)
		if (self.onMouseUp) then
			self.frame:SetScript('OnMouseUp', function (frame, ...)
				if (not self._enabled) then
					return
				end
				if (self.onMouseUp) then
					self:onMouseUp(...)
				end
			end)
		end
		if (self.onKeyUp) then
			self.frame:SetScript('OnKeyUp', function (frame, ...)
				if (self.onKeyUp) then
					self:onKeyUp(...)
				end
			end)
		end
		if (self.onMouseDown) then
			self.frame:SetScript('OnMouseDown', function (frame, ...)
				if (not self._enabled) then
					return
				end
				if (self.onMouseDown) then
					self:onMouseDown(...)
				end
			end)
		end		
		if (self.onClick) then
			self.frame:SetScript('OnClick', function (frame)
				if (not self._enabled) then
					return
				end
				self:onClick(self.frame)
			end)
		end
	end,	
})

-- UI.EditBox = UI.Panel:extend({
-- 	type = 'EditBox',
-- 	lines = 1,
-- 	style = function (self)
-- 		self:createTexture({
-- 			layer = 'BACKGROUND',
-- 			subLayer = 0,
-- 			color = {0, 0, 0, 0.95},
-- 			-- offset = {0, 0, 0, nil},
-- 			-- height = 1,
-- 		})
-- 		self:createTexture({
-- 			layer = 'ARTWORK',
-- 			subLayer = 2,
-- 			gradiend = 'VERTICAL',
-- 			color = {0, 0, 0, 0.45},
-- 			colorEnd = {0, 0, 0, 0.95},
-- 			offset = {2, 2, 2, 2},
-- 			-- height = 1,
-- 		})
-- 		self.outline = self:createOutline({
-- 			layer = 'ARTWORK',
-- 			subLayer = 3,
-- 			gradient = 'VERTICAL',
-- 			color = {1, 1, 1, 0.35 },
-- 			colorEnd = {1, 1, 1, 0.10 },
-- 			offset = {1, 1, 1, 1},
-- 		})
-- 	end,
-- 	postInit = function (self)
-- 		local style = self._fontStringStyle

-- 		self.frame:SetFont(style.font, style.fontSize, style.fontFlags)
-- 		self.frame:SetTextInsets(4, 4, 0, 0)
-- 		self.frame:SetMultiLine(self.lines > 1)
-- 		--self.frame:SetAutoFocus(true)
-- 		self.frame:Disable()
-- 	end,
-- 	hook = function (self)
-- 		local frame = self.frame
-- 		-- frame:SetScript('OnEnterPressed', function ()
-- 		-- 	if self.lines == 1 then
-- 		-- 		frame:Disable()
-- 		-- 	end
-- 		-- 	if (self.onEnterPressed) then
-- 		-- 		self:onEnterPressed(frame)
-- 		-- 	end
-- 		-- end)

-- 		frame:SetScript('OnEscapePressed', function () 
-- 			frame:Disable()
-- 			if (self.onEscapePressed) then
-- 				self:onEscapePressed(frame)
-- 			end
-- 		end)
-- 		frame:SetScript('OnLeave', function ()
-- 			if (self.onLeave) then
-- 				self:onLeave(frame)
-- 			end
-- 		end)
-- 		frame:SetScript('OnEnter', function ()
-- 			if (self.onEnter) then
-- 				self:onEnter(frame)
-- 			end
-- 		end)
-- 		frame:SetScript('OnMouseDown', function () 
-- 			frame:Enable()
-- 			if (self.onMouseDown) then
-- 				self:onMouseDown(frame)
-- 			end
-- 		end)
-- 	end
-- })