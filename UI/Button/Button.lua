local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Button = UI.Panel:extend({
	type = 'Button',
	text = 'Button',
	color = {0.8, 0.1, 0.1, 0.95},
	height = 22,
	attributes = {},
	enable = function (self)
		self._enabled = true
		self.bg:SetVertexColor(unpack(self.color))
		self.frame:SetAlpha(1)
	end,
	disable = function (self)
		self._enabled = false
		self.frame:SetAlpha(0.5)
		self.bg:SetVertexColor(0.5, 0.5, 0.5, 1)
	end,	
	preInit = function (self)
		self._enabled = true
	end,
	setup = function (self, frame)
		for k, v in pairs(self.attributes) do
			frame:SetAttribute(k, v)
		end	
	end,
	hook = function (self)
		self.frame:RegisterForClicks('AnyUp')
		self.frame:SetScript('OnEnter', function (frame)
			if (not self._enabled) then
				return
			end
			self.highlight:Show()
			if (self.onEnter) then
				self:onEnter()
			end
		end)
		self.frame:SetScript('OnLeave', function (frame)
			if (not self._enabled) then
				return
			end
			self.highlight:Hide()
			if (self.onLeave) then
				self:onLeave()
			end
		end)
		if (self.onMouseUp) then
			self.frame:SetScript('OnMouseUp', function (frame)
				if (not self._enabled) then
					return
				end
				if (self.onMouseUp) then
					self:onMouseUp()
				end
			end)
		end
		if (self.onMouseDown) then
			self.frame:SetScript('OnMouseDown', function (frame)
				if (not self._enabled) then
					return
				end
				if (self.onMouseDown) then
					self:onMouseDown()
				end
			end)
		end
		self.frame:SetScript('OnClick', function (frame)
			if (not self._enabled) then
				return
			end
			if (self.onClick) then
				self:onClick()
			end
		end)
	end,
	style = function (self)
		-- self.frame:SetBackdrop( { 
			
		-- 	bgFile      = O3.Media:texture('Solid'),
		-- 	insets = {
		-- 		left    = 0, 
		-- 		right   = 0, 
		-- 		top     = 0, 
		-- 		bottom  = 0
		-- 	},
		-- })
		-- self.frame:SetBackdropColor(0, 0, 0, 1)

		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			subLayer = 0,
			color = {0, 0, 0, 0.95},
		})
		self.bg = self:createTexture({
			layer = 'BACKGROUND',
			subLayer = 2,
			file = O3.Media:texture('Background'),
			tile = true,
			color = self.color,
			offset = {1,1,1,1},
		})

		local gloss = self:createTexture({
			layer = 'ARTWORK',
			subLayer = 2,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.03},
			colorEnd = {1, 1, 1, 0.1},
			offset = {2,2,2,nil},
		})
		gloss:SetPoint('BOTTOM', self.frame, 'CENTER')
		
		self:createOutline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.05 },
			colorEnd = {1, 1, 1, 0.1 },
			offset = {1, 1, 1, 1},
		})
		self.text = self:createFontString({
			shadowOffset = {1, -1},
			offset = {1,1,1,1},
			justifyH = 'CENTER',
			justifyV = 'MIDDLE',
			text = self.text,
		})
		self.highlight = self:createTexture({
			layer = 'ARTWORK',
			subLayer = 4,
			gradient = 'VERTICAL',
			color = {1,1,1,0.05},
			colorEnd = {1,1,1,0.20},
			offset = {1,1,1,1},
		})
		self.highlight:Hide()
	end,
})


--testButton:show()
--testButton:point('CENTER', UIParent, 'CENTER')