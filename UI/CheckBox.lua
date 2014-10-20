local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.CheckBox = UI.Panel:extend({
	on = true,
	off = false,
	type = 'Button',
	width = 12,
	height = 12,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			file = O3.Media:texture('Background'),
			tile = true,
			color = {0.1, 0.1, 0.1, 0.95},
			offset = {0,0,0,0},
		})
		self:createOutline({
			layer = 'ARTWORK',
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.13 },
			colorEnd = {1, 1, 1, 0.15 },
			offset = {1, 1, 1, 1},
			-- width = 2,
			-- height = 2,
		})
		self.highlight = self:createTexture({
			layer = 'HIGHLIGHT',
			gradient = 'VERTICAL',
			color = {0,1,1,0.10},
			colorEnd = {0,0.5,0.5,0.20},
			offset = {1,1,1,1},
		})
		self.highlight:Hide()				
	end,
	createRegions = function (self)
		self.toggleTexture = self:createTexture({
			layer = 'BORDER',
			subLayer = 2,
			file = O3.Media:texture('Background'),
			tile = true,
			color = {0.3, 0.3, 0.3, 0.95},
			offset = {1,1,1,1},
		})	
	end,
	hook = function (self)
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
			if (self.value == self.on) then
				self.value = self.off
			else
				self.value = self.on
			end
			self:update(self.value)
			self:callback(self.value)
			if (self.onClick) then
				self:onClick()
			end
		end)				
	end,
	callback = function (self, value)

	end,
	setValue = function (self, value)
		self.value = value
		self:update()
	end,
	update = function (self)
		if (self.value == self.on) then			
			self.toggleTexture:SetVertexColor(0, 1, 0, 1)
		else
			self.toggleTexture:SetVertexColor(0.3, 0.3, 0.3, 0.95)
		end

	end,	
})
