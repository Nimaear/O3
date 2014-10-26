local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.EditBox = UI.Panel:extend({
	type = 'EditBox',
	lines = 1,
	numeric = false,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = 0,
			color = {0, 0, 0, 0.95},
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})
		self.outline = self:createOutline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.08 },
			colorEnd = {1, 1, 1, 0.12 },
			offset = {1, 1, 1, 1},
		})
	end,
	setup = function (self, frame)
		local style = self._fontStringStyle
		frame:SetAutoFocus(true)

		frame:SetFont(style.font, style.fontSize, style.fontFlags)
		frame:SetTextInsets(4, 4, 0, 0)
		frame:SetMultiLine(self.lines > 1)
		frame:EnableMouse(true)
		frame:Disable()
		if (self.numeric) then
			frame:SetNumeric(true)
			if (self.value) then
				frame:SetNumber(self.value)
			end
		else
			if (self.value) then
				frame:SetText(self.value)
			end			
		end
		if self.justifyV then
			frame:SetJustifyV(self.justifyV)
		end
		if self.justifyH then
			frame:SetJustifyH(self.justifyH)
		end

	end,
	clearKeyboardFocus = function (self)
		local keyboardFocus = GetCurrentKeyBoardFocus()
		if (keyboardFocus) then
			keyboardFocus:Disable()
		end
	end,
	enable = function (self)
		self.frame:Enable()
	end,
	disable = function (self)
		self.frame:Disable()
	end,
	hook = function (self)
		local frame = self.frame
		frame:SetScript('OnMouseDown', function (frame)
			self:clearKeyboardFocus()
			frame:Enable()
		end)
		frame:SetScript('OnEscapePressed', function (frame)
			frame:Disable()
			if (self.onEscapePressed) then
				self:onEscapePressed(frame)
			end
		end)

		if (self.onEnterPressed) then
			frame:SetScript('OnEnterPressed', function (frame) 
				self:onEnterPressed(frame)
			end)
		end

		if (self.onChar) then
			frame:SetScript('OnChar', function (frame) 
				self:onChar(frame)
			end)
		end

		if (self.onEditFocusLost) then
			frame:SetScript('OnEditFocusLost', function (frame)
				self:onEditFocusLost(frame)
			end)
		end

		if (self.onTabPressed) then
			frame:SetScript('OnTabPressed', function (frame) 
				self:onTabPressed(frame)
			end)
		end

		if (self.onCursorChanged) then
			frame:SetScript('onCursorChanged', function (frame, x, y, width, height)
				self:onCursorChanged(frame, x, y, width, height)
			end)
		end

		frame:SetScript('OnLeave', function (frame)
			if (self.onLeave) then
				self:onLeave(frame)
			end
		end)
		frame:SetScript('OnEnter', function (frame)
			if (self.onEnter) then
				self:onEnter(frame)
			end
		end)
	end
})


UI.GoldEditBox = UI.Panel:extend({
	money = nil,
	gold = nil,
	silver = nil,
	copper = nil,
	width = 168,
	setMoney = function (self, money)
		if (not money) then
			money = ((self.goldControl.frame:GetNumber() or 0)*10000)+((self.silverControl.frame:GetNumber() or 0)*100)+((self.copperControl.frame:GetNumber() or 0))
		else
			self.gold = math.floor(money / 10000)
			self.silver = math.floor(money-self.gold*10000 / 100)
			self.copper = money % 100
			self.goldControl.frame:SetNumber(self.gold)
			self.silverControl.frame:SetNumber(self.silver)
			self.copperControl.frame:SetNumber(self.copper)			
		end
		self.money = money
	end,	
	createRegions = function (self)
		self.goldControl = UI.EditBox:instance({
			width = 80,
			parentFrame = self.frame,
			offset = {0, nil, 0, 0},
			createRegions = function (goldControl)
				goldControl:createTexture({
					width = 16,
					height = 16,
					layer = 'ARTWORK',
					offset = {nil, 0, nil, nil},
					file = [[INTERFACE\MONEYFRAME\UI-MoneyIcons]],
					coords = {0, 0.25, 0, 1},
				})
			end,
			onChar = function (goldControl)
				self:setMoney()
			end,			
			onEnterPressed = function (goldControl, frame)
				frame:Disable()
				self.silverControl.frame:Enable()
			end,
			onTabPressed = function (goldControl, frame)
				frame:Disable()
				self.silverControl.frame:Enable()
			end,
		})

		self.silverControl = UI.EditBox:instance({
			width = 40,
			parentFrame = self.frame,
			offset = {nil, nil, 0, 0},
			createRegions = function (silverControl)
				silverControl:createTexture({
					width = 16,
					height = 16,
					offset = {nil, 0, nil, nil},
					layer = 'ARTWORK',
					file = [[INTERFACE\MONEYFRAME\UI-MoneyIcons]],
					coords = {0.25, 0.5, 0, 1},
				})
			end,
			onChar = function (silverControl)
				self:setMoney()
			end,
			onEnterPressed = function (silverControl, frame)
				frame:Disable()
				self.copperControl.frame:Enable()
			end,
			onTabPressed = function (silverControl, frame)
				frame:Disable()
				self.copperControl.frame:Enable()
			end,
		})
		self.silverControl:point('LEFT', self.goldControl.frame, 'RIGHT', 4, 0)

		self.copperControl = UI.EditBox:instance({
			width = 40,
			parentFrame = self.frame,
			offset = {nil, nil, 0, 0},
			createRegions = function (copperControl)
				copperControl:createTexture({
					width = 16,
					height = 16,
					layer = 'ARTWORK',
					offset = {nil, 0, nil, nil},
					file = [[INTERFACE\MONEYFRAME\UI-MoneyIcons]],
					coords = {0.5, 0.75, 0, 1},
				})
			end,
			onChar = function (copperControl, frame)
				self:setMoney()
			end,
			onEnterPressed = function (copperControl, frame)
				self:onEnterPressed(frame)
			end,
			onTabPressed = function (copperControl, frame)
				self:onTabPressed(frame)
			end,
		})
		self.copperControl:point('LEFT', self.silverControl.frame, 'RIGHT', 4, 0)
	end,
	enable = function (self)
		self.goldControl.frame:Enable()
	end,
	onEnterPressed = function (self)
	end,
	onTabPressed = function (self)
	end,
})