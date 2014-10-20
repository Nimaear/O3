local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.GlyphButton = UI.Panel:extend({
	fontSize = 14,
	_fontStringStyle = {
		font = O3.Media:font('Glyph'),
		fontFlags = nil,
		offset = {1, 1, 1, 1},
		color = {0.9, 0.9, 0.9, 0.95},
	},
	type = 'Button',
	text = 'Button',
	enable = function (self)
		if (not self._enabled) then
			self._enabled = true
			self.frame:SetAlpha(1)
			if self.bg then
				self.bg:SetVertexColor(unpack(self.color))
			end
			self.text:SetTextColor(unpack(self.text.style.color))
		end
	end,
	preInit = function (self)
		self._enabled = true
	end,
	disable = function (self)
		if (self._enabled) then
			local color = self.text.style.color
			self._enabled = false
			self.frame:SetAlpha(0.7)
			if self.bg then
				self.bg:SetVertexColor(0.5, 0.5, 0.5, 1)
			end
			self.text:SetTextColor(color[1]/3, color[2]/3, color[3]/3, color[4])
		end
	end,	
	hook = function (self)
		self.frame:RegisterForClicks('AnyUp')
		self.frame:SetScript('OnEnter', function (frame)
			if (not self._enabled) then
				return
			end
			if self.bg then
				self.highlight:Show()
			else
				local color = self.text.style.color
				self.text:SetTextColor(color[1]/2, color[2]/2, color[3]/2, color[4])
			end
			if (self.onEnter) then
				self:onEnter()
			end
		end)
		self.frame:SetScript('OnLeave', function (frame)
			if (not self._enabled) then
				return
			end
			if self.bg then
				self.highlight:Hide()
			else
				self.text:SetTextColor(unpack(self.text.style.color))
			end
			if (self.onLeave) then
				self:onLeave()
			end
		end)
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
		local text = self:createFontString({
			-- fontFlags = 'OUTLINE',
			fontSize = self.fontSize,
		})
		text:SetJustifyH('CENTER')
		text:SetJustifyV('CENTER')
		text:SetText(self.text)
		self.text = text

		if (self.bg) then

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
			self.highlight = self:createTexture({
				layer = 'ARTWORK',
				subLayer = 4,
				gradient = 'VERTICAL',
				color = {1,1,1,0.05},
				colorEnd = {1,1,1,0.20},
				offset = {1,1,1,1},
			})
			self.highlight:Hide()
		end
	end,
})


