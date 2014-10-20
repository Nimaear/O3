local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

local raisedWindow = nil

UI.Window = UI.Panel:extend({
	frameStrata = 'MEDIUM',
	width = 350,
	height = 550,
	title = 'O2',
	subTitle = nill,
	managed = false,
	raisedWindow = nil,
	savePositionAndSize = true,
	_weight = 1,
	closeWithEscape = false,
	_defaults = {
		headerHeight = 22,
		footerHeight = 22,
	},
	settings = {

	},
	setTitle = function (self, title, subTitle)
		subTitle = subTitle or self.subTitle or ''
		if self.title then
			self.title:SetText('|cff108010'..title..'|r '..subTitle)
		end
	end,
	raise = function (self)
		if (raisedWindow and raisedWindow ~= self) then
			raisedWindow.frame:SetFrameStrata('MEDIUM')
			raisedWindow.frame:SetFrameLevel(100)
		end
		raisedWindow = self
		raisedWindow.frame:SetFrameStrata('TOOLTIP')
		raisedWindow.frame:SetFrameLevel(101)
	end,
	savePositionAndSize = function (self)
		local windowSettings = O3.settings.Window[self.name]
		if (windowSettings and self.name) then
			O3.settings.Window = O3.settings.Window or {}
			O3.settings.Window[self.name] = O3.settings.Window[self.name] or {}
			O3.settings.Window[self.name].left = self.frame:GetLeft()
			O3.settings.Window[self.name].bottom = self.frame:GetTop()-self.frame:GetHeight()
			O3.settings.Window[self.name].width = self.frame:GetWidth()
			O3.settings.Window[self.name].height = self.frame:GetHeight()
		end
	end,
	loadPosition = function (self)
		local windowSettings = O3.settings.Window[self.name]
		if (windowSettings) then
			self:point('BOTTOMLEFT', self.parentFrame, 'BOTTOMLEFT', windowSettings.left, windowSettings.bottom)
			self.frame:SetSize(windowSettings.width, windowSettings.height)	
		end
	end,
	createContent = function (self)
		local headerHeight = self.settings.headerHeight
		local footerHeight = self.settings.footerHeight
		self.content = self:createPanel({
			offset = {0, 0, headerHeight-1, footerHeight-1},
			style = function (self)
				self:createOutline({
					layer = 'BACKGROUND',
					subLayer = -7,
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {1, 1, 1, 1 },
				})
				self:createOutline({
					layer = 'BACKGROUND',
					subLayer = -6,
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0 },
				})

			end,
		})
		self.contentFrame = self.content.frame
	end,
	createRegions = function (self, parentFrame)
		self:createContent()
		self.header = self:createPanel({
			frameStrata = self.frameStrata,
			type = 'Button',
			offset = {0,0,0,nil},
			height = self.settings.headerHeight,
			style = function (self)
				local _, class = UnitClass('player')

				local color = RAID_CLASS_COLORS[class]

				self:createTexture({
					layer = 'BACKGROUND',
					file = O3.Media:texture('Background'),
					subLayer = -5,
					tile = true,
					color = {color.r, color.g, color.b, 1},
					-- color = {1, 0.2, 0.2, 0.95},
					offset = {1,1,1,1},
				})
				self:createOutline({
					layer = 'BACKGROUND',
					subLayer = -4,
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {1, 1, 1, 1 },
				})
				self:createOutline({
					layer = 'BACKGROUND',
					subLayer = -4,
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0 },
				})
				self:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {1,1,1,0.05},
					colorEnd = {1,1,1,0.10},
					offset = {0,0,0,0},
				})
				
				--[[
				self:createTexture({
					offset = {-32, nil, -24, nil},
					width = 64,
					height = 64,
					file = O3.Media:texture('Crest\\'..class),
					layer = 'BORDER',
					subLayer = 7
				})
				]]--

			end,
			addButton = function (self, button)
				if (self.lastButton) then
					button:point('RIGHT', self.lastButton, 'LEFT', 0, 0)
				else
					button:point('RIGHT', -2, 0)
				end
				self.lastButton = button.frame
			end,
			createRegions = function (self)
				local closeButton = O3.UI.GlyphButton:instance({
					parentFrame = self.frame,
					width = 20,
					height = 20,
					text = '',
					onClick = function ()
						self.parent:hide()
					end,
				})
				self:addButton(closeButton)

				local title = self.parent.title
				self.parent.title = self:createFontString({
					offset = {2, nil, nil, nil},
				})
				self.parent:setTitle(title)
			end,
			hook = function (self)
				self.frame:SetScript("OnMouseDown", function(titleFrame, button)
					self.parent:raise()
					if self.parent.settings.locked or self.parent.managed then
						return
					end
					if button == "LeftButton" and not self.parent.frame.isMoving then
						self.parent.frame:StartMoving()
						self.parent.frame.isMoving = true
					end
				end)
				self.frame:SetScript("OnMouseUp", function(titleFrame, button)
					if button == "LeftButton" and self.parent.frame.isMoving then
						self.parent.frame:StopMovingOrSizing()
						self.parent.frame.isMoving = false
						if not self.parent.managed and self.parent.savePosition then
							self.parent:savePositionAndSize()
						end						
					end
				end)
				self.frame:SetScript("OnHide", function(frame)
					if ( self.parent.frame.isMoving ) then
						self.parent.frame:StopMovingOrSizing()
						self.parent.frame.isMoving = false
						if not self.parent.managed and self.parent.savePosition then
							self.parent:savePositionAndSize()
						end
					end
				end)
			end,
		})
		self.footer = self:createPanel({
			offset = {0,0,nil,0},
			height = self.settings.footerHeight,
			style = function (self)
				-- background
				self:createTexture({
					layer = 'BACKGROUND',
					subLayer = -7,
					file = O3.Media:texture('Background'),
					tile = true,
					color = {147/255, 153/255, 159/255, 0.95},
					offset = {1,1,1,1},
				})
				self:createOutline({
					layer = 'BACKGROUND',
					subLayer = -4,
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {1, 1, 1, 1},
					-- width = 2,
					-- height = 2,
				})
				self:createOutline({
					layer = 'BACKGROUND',
					subLayer = -3,
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0 },
				})

			end,
		})

	end,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			color = {0, 0, 0, 0.95},
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})
		self:createTexture({
			layer = 'BACKGROUND',
			color = {0.5, 0.5, 0.5, 0.5},
			file = O3.Media:texture('Background'),
			subLayer = -6,
			tile = true,
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})
		self:createShadow()
	end,
	postCreate = function (self)
	end,
	preInit = function (self)
	end,
	postInit = function (self)
	end,
	initSettings = function (self)
		setmetatable(self.settings, {__index = self._defaults})
	end,
	create = function (self)
		self.name = self.name or nil
		self.parentFrame = self.parentFrame or UIParent
		self.frame = CreateFrame(self.type, self.name, self.parentFrame)
		self.frame:SetMovable(true)
		self.frame:SetClampedToScreen(true)
		--self.frame:SetToplevel(true)
		self.frame:EnableMouse(true)
		self.frame:SetScript('OnHide', function (frame)
			if (self.onHide) then
				self:onHide()
			end
		end)
		self.frame:SetScript('OnShow', function (frame)
			self:raise()
			if (self.onShow) then
				self:onShow()
			end
		end)
		self:createRegions()
		self:hook()
		self:style()
		self.frame:SetUserPlaced(false)
		if not self.managed and self.savePositionAndSize and O3.settings.Window and O3.settings.Window[self.name] then
			self:loadPosition()
		else
			self:position()	
		end
		self:postCreate()
		if (self.managed) then
			self.Manager:add(self)
		end
		if (self.onShow) then
			self:raise()
			self:onShow()
		end	
	end,
	position = function (self)
		local offset = self.offset
		if offset and not self.managed then
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
	postCreate = function (self)
	end,
	hide = function (self)
		if (not self.frame) then
			self:create()
		end
		if (self.frame:IsVisible()) then
			self.frame:Hide()
			if (self.managed) then
				self.Manager:remove(self)
			end
		end
	end,
	show = function (self)
		if (not self.frame) then
			self:create()
		elseif (not self.frame:IsVisible()) then
			self.frame:Show()
			if (self.managed) then
				self.Manager:add(self)
			end
		end
	end,
	toggle = function (self)
		if (not self.frame) then
			self:create()
		elseif (self.frame:IsVisible()) then
			self:hide()
		else
			self:show()
		end
	end,	
	init = function (self, ...)
		self:preInit(...)
		self:initSettings()
		if (self.name and self.closeWithEscape) then
			tinsert(UISpecialFrames, self.name)
		end
		self:postInit(...)
	end,
})

