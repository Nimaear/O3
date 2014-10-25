local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.DropDown = UI.Panel:extend({
	type = 'Button',
	lines = 1,
	maxItems = 10,
	choiceHeight = 20,
	add = function (self, value, label)
		table.insert(self._values, {label = label, value = value})
		if (#self.choices < self.maxItems) then
			self:createChoice()
			self:update()
		end
		self._maxOffset = #self._values - self.maxItems
	end,
	update = function (self)
		local height = 0
		for i = 1, #self.choices do
			local value = self._values[i+self._offset]
			local choice = self.choices[i]
			if value then
				height = height + self.choiceHeight + 1
				choice:show()
				self:setChoice(choice, value.value, value.label)
			else
				choice:hide()
			end
		end
		local maxHeight = height-22
		if (#self._values > self.maxItems) then
			self.dropDown.bar:show()
			self.dropDown.bar.thumb.frame:SetPoint('TOP' , 0, -1* math.floor((self._offset/self._maxOffset)*maxHeight)-1)
			self.dropDown:point('TOPRIGHT', self.frame, 'BOTTOMRIGHT', -12, -2)
		else
			self.dropDown.bar:hide()
			self.dropDown:point('TOPRIGHT', self.frame, 'BOTTOMRIGHT', 0, -2)
		end
		self.dropDown.frame:SetHeight(height-1)
	end,
	setChoice = function (self, choice, value, label)
		choice.value = value
		choice.label = label
		choice.text:SetText(label)
	end,
	remove = function (self, value)
		local foundIndex = nil
		for i = 1, #self._values do
			if (self._values[i].value == value) then
				foundIndex = i
				break
			end
		end
		if (foundIndex) then
			table.remove(self._values, foundIndex)
			self._maxOffset = #self._values - self.maxItems
			self:update()
		end
	end,
	selectValue = function (self, value)
		for i = 1, #self._values do
			if (self._values[i].value == value) then
				self:select(value, self._values[i].label)
				break
			end
		end
	end,
	select = function (self, value, label)
		--print(self.token, label, value)
		self.text:SetText(label)
		self.dropDown:hide()
		self.value = value
	end,
	callback = function (self)
	end,
	createChoice = function (self)
		local onClick = self.select
		local parent = self
		local choiceHeight = self.choiceHeight
		local choice = self.dropDown:createPanel({
			type = 'Button',
			enabled = true,
			height = choiceHeight,
			-- offset = {1, 1, nil, nil},
			style = function (self)
				self:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',

					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					--offset = {0, 0, 0, 0 },
				})
			end,
			createRegions = function (self)
				self.text = self:createFontString({
					offset = {2, 2, 2, 2},
					justifyV = 'MIDDLE',
					justifyH = 'LEFT',
				})
				self.highlight = self:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {0,1,1,0.10},
					colorEnd = {0,0.5,0.5,0.20},
					offset = {1,1,1,1},
				})
				self.highlight:Hide()
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
					onClick(parent, self.value, self.label)
					if (parent.callback) then
						parent:callback(self.value, self.label)
					end
				end)
			end,
		})
		table.insert(self.choices, choice)
		choice:point('LEFT', self.dropDown.frame)
		choice:point('RIGHT', self.dropDown.frame)
		local itemCount = #self.choices
		if itemCount == 1 then
			choice:point('TOP', self.dropDown.frame)
		else
			choice:point('TOP', self.choices[itemCount-1].frame, 'BOTTOM', 0, -1)
		end
	end,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = 0,
			color = {0, 0, 0, 0.95},
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})
		-- self:createTexture({
		-- 	layer = 'ARTWORK',
		-- 	subLayer = 2,
		-- 	gradiend = 'VERTICAL',
		-- 	color = {0, 0, 0, 0.45},
		-- 	colorEnd = {0, 0, 0, 0.95},
		-- 	offset = {2, 2, 2, 2},
		-- 	-- height = 1,
		-- })
		self.outline = self:createOutline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.08 },
			colorEnd = {1, 1, 1, 0.12 },
			offset = {1, 1, 1, 1},
		})
	end,
	createRegions = function (self)
		local parent = self
		local arrow = self:createFontString({
			width = 20,
			height = 20,
			font = O3.Media:font('Glyph'),
			text = '',
			offset = {nil, 2, nil, nil},
			color = {0.5, 0.5, 0.5, 1},
		})

		self:createButton()

		self.dropDown = UI.Panel:instance({
			-- parentFrame = UIParent,
			frameStrata = 'TOOLTIP',

			height = 300,
			style = function (self)
				self:createTexture({
					layer = 'BACKGROUND',
					subLayer = 0,
					color = {0, 0, 0, 0.95},
					offset = {-1, -1, -1, -1},
					-- height = 1,
				})
			end,
			createRegions = function (self)
				local scrollBar = UI.ScrollBar:instance({
					width = 11,
					parentFrame = self.frame,
					offset = {nil, -13, -1, -1},
				})
				scrollBar:hide()
				self.bar = scrollBar
			end,
			hook = function (self)
				self.frame:SetScript('OnMouseWheel', function (frame, delta)
					parent._offset = parent._offset - delta
					if (parent._offset > parent._maxOffset) then
						parent._offset = parent._maxOffset
					end
					if (parent._offset < 0) then
						parent._offset = 0
					end
					parent:update()
				end)
			end,
		})
		self.dropDown:hide()
		self.dropDown:point('TOPLEFT', self.frame, 'BOTTOMLEFT', 0, -2)
		self.dropDown:point('TOPRIGHT', self.frame, 'BOTTOMRIGHT', 0, -2)
	end,
	createButton = function (self)
		self.text =  self:createFontString({
			offset = {2, 2, 2, 2},
			justifyV = 'MIDDLE',
			justifyH = 'LEFT',
		})	
	end,
	postInit = function (self)
		-- local style = self._fontStringStyle
		self.frame:SetToplevel(true)
		self.choices = {}
		self._offset = 0
		for i = 1, min(#self._values, self.maxItems) do
			local choice = self._values[i]
			self:createChoice()
			if (self.value == choice.value) then
				self:select(choice.value, choice.label)
			end
		end
		self._maxOffset = #self._values - self.maxItems
		self:update()
		-- self.frame:SetFont(style.font, style.fontSize, style.fontFlags)
		-- self.frame:SetTextInsets(4, 4, 0, 0)
		-- self.frame:SetMultiLine(self.lines > 1)
		-- --self.frame:SetAutoFocus(true)
		-- self.frame:Disable()
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

		-- frame:SetScript('OnEscapePressed', function () 
		-- 	frame:Disable()
		-- 	if (self.onEscapePressed) then
		-- 		self:onEscapePressed(frame)
		-- 	end
		-- end)



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
		frame:SetScript('OnClick', function () 
			if (self.onClick) then
				self:onClick(frame)
			end
			self.dropDown:toggle()
		end)
	end
})

UI.FontDropDown = UI.DropDown:extend({
	choices = O3.Media.fontRegistry,
	setChoice = function (self, choice, value, label)
		choice.value = value
		choice.label = label
		choice.text:SetText(label)
		choice.text:SetFont(value, 11)
	end,
	select = function (self, value, label)
		self.text:SetText(label)
		self.text:SetFont(value, 11)
		self.dropDown:hide()
		self.value = value	
	end,
	createChoice = function (self, value, label)
		local onClick = self.select
		local parent = self
		local choice = self.dropDown:createPanel({
			type = 'Button',
			enabled = true,
			height = 20,
			-- offset = {1, 1, nil, nil},
			style = function (self)
				self:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					--offset = {0, 0, 0, 0 },
				})
			end,
			createRegions = function (self)
				self.text = self:createFontString({
					offset = {2, 2, 2, 2},
					justifyV = 'MIDDLE',
					justifyH = 'LEFT',
				})
				self.highlight = self:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {0,1,1,0.10},
					colorEnd = {0,0.5,0.5,0.20},
					offset = {1,1,1,1},
				})
				self.highlight:Hide()
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
					onClick(parent, self.value, self.label)
					if (parent.callback) then
						parent:callback(self.value, self.label)
					end
				end)
			end,
		})
		table.insert(self.choices, choice)
		choice:point('LEFT', self.dropDown.frame)
		choice:point('RIGHT', self.dropDown.frame)
		local itemCount = #self.choices
		if itemCount == 1 then
			choice:point('TOP', self.dropDown.frame)
		else
			choice:point('TOP', self.choices[itemCount-1].frame, 'BOTTOM', 0, -1)
		end
	end,		
})


UI.StatusBarDropDown = UI.DropDown:extend({
	choices = O3.Media.statusBarRegistry,
	setChoice = function (self, choice, value, label)
		choice.value = value
		choice.label = label
		choice.text:SetText(label)
		choice.texture:SetVertexColor(unpack(self.color))
		choice.texture:SetTexture(value)
	end,
	select = function (self, value, label)
		self.text:SetText(label)
		self.texture:SetTexture(value)
		self.texture:SetVertexColor(unpack(self.color))
		self.dropDown:hide()
		self.value = value
	end,
	createChoice = function (self, value, label)
		local onClick = self.select
		local parent = self
		local choice = self.dropDown:createPanel({
			type = 'Button',
			enabled = true,
			height = 20,
			-- offset = {1, 1, nil, nil},
			style = function (choice)
				choice:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.13 },
					colorEnd = {1, 1, 1, 0.25 },
					--offset = {0, 0, 0, 0 },
				})
			end,
			createRegions = function (choice)
				choice.text = choice:createFontString({
					offset = {2, 2, 2, 2},
					justifyV = 'MIDDLE',
					justifyH = 'LEFT',
				})
				choice.texture = choice:createTexture({
					layer = 'BACKGROUND',
					color = self.color,
					offset = {0, 0, 0, 0},
					file = nil,
					tile = false,
				})
				choice.highlight = choice:createTexture({
					layer = 'ARTWORK',
					gradient = 'VERTICAL',
					color = {0,1,1,0.10},
					colorEnd = {0,0.5,0.5,0.20},
					offset = {1,1,1,1},
				})
				choice.highlight:Hide()
			end,
			hook = function (choice)
				choice.frame:SetScript('OnEnter', function (frame)
					choice.highlight:Show()
					if (choice.onEnter) then
						choice:onEnter()
					end
				end)
				choice.frame:SetScript('OnLeave', function (frame)
					choice.highlight:Hide()
					if (choice.onLeave) then
						choice:onLeave()
					end
				end)
				choice.frame:SetScript('OnClick', function (frame)
					onClick(parent, choice.value, choice.label)
					if (parent.callback) then
						parent:callback(choice.value, choice.label)
					end
				end)
			end,
		})
		table.insert(self.choices, choice)
		choice:point('LEFT', self.dropDown.frame)
		choice:point('RIGHT', self.dropDown.frame)		
		local itemCount = #self.choices
		if itemCount == 1 then
			choice:point('TOP', self.dropDown.frame)
		else
			choice:point('TOP', self.choices[itemCount-1].frame, 'BOTTOM', 0, -1)
		end
	end,	
	createButton = function (self)
		self.texture = self:createTexture({
			offset = {1, 1, 1, 1},
			color = self.color,
			file = nil,
			tile = false,
		})
		self.text =  self:createFontString({
			offset = {2, 2, 2, 2},
			justifyV = 'MIDDLE',
			justifyH = 'LEFT',
		})	
	end,
})

-- local dd = O3.UI.DropDown:instance({
-- 	parentFrame = UIParent,
-- 	offset = {600, nil, 400, nil},
-- 	width = 300,
-- 	height = 20,
-- })

-- for i = 1, 3 do
-- 	dd:add('Test'..i, 'test'..i)
-- end