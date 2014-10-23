local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

local Panel 

Panel = O3.Class:extend({
	type = 'Frame',
	template = nil,
	frameStrata = nil,
	alpha = nil,
	_textureStyle = {
		layer = 'ARTWORK',
		subLayer = 0,
		coords = {0,1,0,1},
		-- color = {1, 1, 1, 1},
		-- colorEnd = {1, 1, 1, 1},
		offset = {0, 0, 0, 0},
		file = nil,
		tile = false,
	},
	_outlineStyle = {
		width = 1,
		height = 1,
		layer = 'ARTWORK',
		subLayer = 0,
		color = {1, 1, 1, 1},
		colorEnd = {1, 1, 1, 1},
		gradient = nil,
		offset = {0, 0, 0, 0},
	},
	_fontStringStyle = {
		font = O3.Media:font('Normal'),
		fontSize = 11,
		fontFlags = '',
		offset = nil,
		color = nil,
		justifyH = nil,
		justifyV = nil,
		shadowOffset = nil,
		shadowColor = {0,0,0,0.95},	
	},
	offset = nil,
	hook = function (self)
	end,
	createRegions = function (self)
	end,
	createPanel = function (self, template)
		local template = template or {}
		local Constructor = Panel
		if template.type and UI[template.type] then
			Constructor = UI[template.type]
		end
		template.parent = self
		template.parentFrame = self.frame
		template.frameStrata = template.frameStrata or self.frameStrata

		return Constructor:instance(template)
	end,
	style = function (self)
	end,
	createTexture = function (self, style)
		style = style or {}
		local texture = style.texture or self.frame:CreateTexture()
		setmetatable(style, {__index = self._textureStyle})
		local color, colorEnd = style.color, style.colorEnd
		local anchor = style.anchor or self.frame

		texture:SetTexCoord(style.coords[1],style.coords[2],style.coords[3],style.coords[4])
		texture:SetDrawLayer(style.layer, style.subLayer)
	
		if style.offset then
			if style.offset[1] 	then 
				texture:SetPoint('LEFT', anchor, 'LEFT', style.offset[1], 0)
			end
			if style.offset[2] 	then 
				texture:SetPoint('RIGHT', anchor, 'RIGHT', -style.offset[2], 0)
			end
			if style.offset[3] 	then 
				texture:SetPoint('TOP', anchor, 'TOP', 0, -style.offset[3])
			end		
			if style.offset[4] then 
				texture:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, style.offset[4])
			end
		end
		if style.width then 
			texture:SetWidth(style.width)
		end
		if style.height	then
			texture:SetHeight(style.height)
		end
		if style.file then 
			texture:SetTexture(style.file,style.tile)
			texture:SetHorizTile(style.tile)
			texture:SetVertTile(style.tile)
			if color then
				texture:SetVertexColor(color[1], color[2], color[3], color[4])
			end
		elseif (color) then
			texture:SetTexture(color[1], color[2], color[3], color[4])	
		end
		if style.gradient then
			texture:SetTexture(1,1,1,1)
			texture:SetGradientAlpha(style.gradient, color[1], color[2], color[3], color[4], colorEnd[1], colorEnd[2], colorEnd[3], colorEnd[4])		
		end
		texture.style = style
		return texture
	end,
	createFontString = function (self, style)
		style = style or {} 
		setmetatable(style, {__index = self._fontStringStyle})
		local fontString = self.frame:CreateFontString()
		fontString:SetFont(style.font, style.fontSize, style.fontFlags)
		if (style.color) then
			fontString:SetTextColor(unpack(style.color))
		end
		if style.justifyV then
			fontString:SetJustifyV(style.justifyV)
		end
		if style.justifyH then
			fontString:SetJustifyH(style.justifyH)
		end
		if style.shadowOffset then
			fontString:SetShadowOffset(unpack(style.shadowOffset))
			fontString:SetShadowColor(unpack(style.shadowColor))
		end	
		if style.offset then
			if style.offset[1] 	then 
				fontString:SetPoint('LEFT', style.offset[1], 0)
			end
			if style.offset[2] 	then 
				fontString:SetPoint('RIGHT', -style.offset[2], 0)
			end
			if style.offset[3] 	then 
				fontString:SetPoint('TOP', 0, -style.offset[3])
			end		
			if style.offset[4] then 
				fontString:SetPoint('BOTTOM', 0, style.offset[4])
			end
		end
		if style.width then 
			fontString:SetWidth(style.width)
		end
		if style.height	then
			fontString:SetHeight(style.height)
		end
		if (style.text) then
			fontString:SetText(style.text)
		end
		fontString.style = style
		return fontString
	end,
	createShadow = function (self)
		if (self._shadow) then
			return
		end
		local shadow = CreateFrame('Frame', nil, self.frame)
		shadow:SetBackdrop({ 
			edgeFile = O3.Media:border('Shadow1'), 
			edgeSize = 28 
		})
		shadow:SetBackdropBorderColor(0, 0, 0, 0.4)
		shadow:SetPoint('BOTTOMLEFT', -20, -20)
		shadow:SetPoint('TOPRIGHT', 20, 20)
		self._shadow = shadow
	end,
	createOutline = function (self, style)
		local frame = self.frame

		style = style or {}
		setmetatable(style, {__index = self._outlineStyle})
		local color, colorEnd = style.color, style.colorEnd
		local anchor = style.anchor or frame

		local topTexture = frame:CreateTexture()
		local bottomTexture = frame:CreateTexture()
		local leftTexture = frame:CreateTexture()
		local rightTexture = frame:CreateTexture()


		leftTexture:SetDrawLayer(style.layer, style.subLayer)

		rightTexture:SetDrawLayer(style.layer, style.subLayer)

		topTexture:SetDrawLayer(style.layer, style.subLayer)

		bottomTexture:SetDrawLayer(style.layer, style.subLayer)

		if style.offset[1] then 
			leftTexture:SetPoint('LEFT', anchor, 'LEFT', style.offset[1],0)
			topTexture:SetPoint('LEFT', anchor, 'LEFT', style.offset[1]+style.width,0)
			bottomTexture:SetPoint('LEFT', anchor, 'LEFT', style.offset[1]+style.width,0)
		else
			leftTexture:SetPoint('LEFT', anchor, 'LEFT', 0 ,0)
			topTexture:SetPoint('LEFT', anchor, 'LEFT', style.width, 0)
			bottomTexture:SetPoint('LEFT', anchor, 'LEFT', style.width, 0)
		end	
		if style.offset[2] then 
			rightTexture:SetPoint('RIGHT', anchor, 'RIGHT', -style.offset[2],0)
			topTexture:SetPoint('RIGHT', anchor, 'RIGHT', -style.offset[2]-style.width,0)
			bottomTexture:SetPoint('RIGHT', anchor, 'RIGHT', -style.offset[2]-style.width,0)
		else
			rightTexture:SetPoint('RIGHT', anchor, 'RIGHT', 0,0)
			topTexture:SetPoint('RIGHT', anchor, 'RIGHT', -style.width, 0)
			bottomTexture:SetPoint('RIGHT', anchor, 'RIGHT', -style.width, 0)
		end
		if style.offset[3] then
			rightTexture:SetPoint('TOP', anchor, 'TOP', 0, -style.offset[3])	
			leftTexture:SetPoint('TOP', anchor, 'TOP', 0, -style.offset[3])
			topTexture:SetPoint('TOP', anchor, 'TOP', 0, -style.offset[3])
		else
			rightTexture:SetPoint('TOP', anchor, 'TOP', 0,0)	
			leftTexture:SetPoint('TOP', anchor, 'TOP', 0,0)
			topTexture:SetPoint('TOP', anchor, 'TOP', 0,0)
		end
		if style.offset[4] then 
			leftTexture:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, style.offset[4]) 
			rightTexture:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, style.offset[4])
			bottomTexture:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, style.offset[4])
		else
			leftTexture:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, 0) 
			rightTexture:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, 0)
			bottomTexture:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, 0)
		end

		topTexture:SetHeight(style.height)
		bottomTexture:SetHeight(style.height)
		leftTexture:SetWidth(style.width)
		rightTexture:SetWidth(style.width)


		if style.gradient then
			if style.gradient == 'VERTICAL' then
				leftTexture:SetTexture(1,1,1,1)
				rightTexture:SetTexture(1,1,1,1)
				leftTexture:SetGradientAlpha('VERTICAL', colorEnd[1], colorEnd[2], colorEnd[3], colorEnd[4], color[1], color[2], color[3], color[4])
				rightTexture:SetGradientAlpha('VERTICAL', colorEnd[1], colorEnd[2], colorEnd[3], colorEnd[4], color[1], color[2], color[3], color[4])

				topTexture:SetTexture(color[1], color[2], color[3], color[4])
				bottomTexture:SetTexture(colorEnd[1], colorEnd[2], colorEnd[3], colorEnd[4])

			else
				leftTexture:SetTexture(color[1], color[2], color[3], color[4])
				rightTexture:SetTexture(colorEnd[1], colorEnd[2], colorEnd[3], colorEnd[4])

				topTexture:SetTexture(1,1,1,1)
				bottomTexture:SetTexture(1,1,1,1)
				topTexture:SetGradientAlpha('HORIZONTAL', color[1], color[2], color[3], color[4], colorEnd[1], colorEnd[2], colorEnd[3], colorEnd[4])
				bottomTexture:SetGradientAlpha('HORIZONTAL', color[1], color[2], color[3], color[4], colorEnd[1], colorEnd[2], colorEnd[3], colorEnd[4])
			end
		else
			leftTexture:SetTexture(color[1], color[2], color[3], color[4])
			rightTexture:SetTexture(color[1], color[2], color[3], color[4])
			topTexture:SetTexture(color[1], color[2], color[3], color[4])
			bottomTexture:SetTexture(color[1], color[2], color[3], color[4])
		end
		return leftTexture, rightTexture, topTexture, bottomTexture
	end,
	position = function (self)
		local offset = self.offset
		if offset then
			if offset[1] then
				self.frame:SetPoint('LEFT', offset[1], 0)
			end
			if offset[2] then
				self.frame:SetPoint('RIGHT', -offset[2], 0)
			end
			if offset[3] then
				self.frame:SetPoint('TOP', 0, -offset[3])
			end
			if offset[4] then
				self.frame:SetPoint('BOTTOM', 0, offset[4])
			end
		end
		if (self.width) then
			self.frame:SetWidth(self.width)
		end
		if (self.height) then
			self.frame:SetHeight(self.height)
		end
	end,
	setWidth = function (self, width)
		self.frame:SetWidth(width)
	end,
	setHeight = function (self, height)
		self.frame:SetHeight(height)
	end,
	setSize = function (self, width, height)
		self.frame:SetSize(width, height)
	end,
	point = function (self, ...)
		self.frame:SetPoint(...)
	end,
	show = function (self)
		if (not self.frame:IsVisible()) then
			self.frame:Show()
			if (self.onShow) then
				self:onShow()
			end
		end
	end,
	hide = function (self)
		if (self.frame:IsVisible()) then
			self.frame:Hide()
			if (self.onHide) then
				self:onHide()
			end
		end
	end,
	toggle = function (self)
		if (self.frame:IsVisible()) then
			self:hide()
		else
			self:show()
		end
	end,
	clearAllPoints = function (self)
		self.frame:ClearAllPoints()
	end,
	visible = function (self)
		return self.frame and self.frame:IsVisible()
	end,
	setAlpha = function (self, alpha)
		self.frame:SetAlpha(alpha)
	end,
	init = function (self, ...)
		self:preInit(...)

		if self.frame then
			self.name = self.frame:GetName()
			self.parentFrame = self.frame:GetParent()
		else
			self.name = self.name or nil
			self.parentFrame = self.parentFrame or UIParent
			self.frame = CreateFrame(self.type, self.name, self.parentFrame, self.template)
		end
		if (self.frameStrata) then
			self.frame:SetFrameStrata(self.frameStrata)
		end
		if (self.alpha ~= nil) then
			self.frame:SetAlpha(self.alpha)
		end
		self:setup(self.frame)
		self:createRegions()
		self:hook()
		self:style()
		self:position()
		self:postInit(...)
	end,
	setup = function (self)
	end,
	postInit = function (self, ...)
	end,
	preInit = function (self, ...)
	end,
})
UI.Panel = Panel