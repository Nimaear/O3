local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Option = UI.Panel:extend({
	labelWidth = 120,
	height = 20,
	subModule = nil,
	width = 490,
	label = nil,
	value = nil,
	change = function (self, value, doNotExecuteHooks)
		if value == self.value then
			return
		end
		local handler = self.handler
		self.value = value
		if (self.subModule) then
			handler.settings[self.subModule][self.token] = self.value
		else
			handler.settings[self.token] = self.value
		end
		self:update()
		if doNotExecuteHooks then
			return
		end
		if handler[self.setter] then
			handler[self.setter](handler, self.token, value, self)
		elseif handler.changeOption then
			handler.changeOption(handler, self.token, value, self)
		elseif handler.applyOptions then
			handler.applyOptions(handler, self)
		end
		if (handler.saveOption) then
			handler:saveOption(self.token)
		end
	end,
	addToObject = function (self, object)
		if (not rawget(object, 'options')) then
			object.options = {}
		end
		if (not rawget(object, 'addOption')) then
			object.addOption = function (self, token, option)
				option.token = token
				table.insert(self.options, option)
				return option
			end
		end
		if (not rawget(object, 'addOptions')) then
			object.addOptions = function (self)
			end
		end
		if (not rawget(object, 'saveOption')) then
			object.saveOption = function (self)
			end
		end
		if (not object.applyOptions) then
			object.applyOptions = function (self)
			end
		end
	end,
	createControl = function (self)
		local parent = self
		self.control = O3.UI.EditBox:instance({
			parentFrame = self.frame,
			offset = {nil, 0, 0, 0},
			hook = function (self)
				local control = self.frame
				control:SetScript('OnEnterPressed', function ()
					if self.lines == 1 then
						parent:change(control:GetText())
						control:Disable()
					end
					if (self.onEnterPressed) then
						self:onEnterPressed(control)
					end
				end)

				control:SetScript('OnEscapePressed', function () 
					parent:change(control:GetText())
					control:Disable()
					if (self.onEscapePressed) then
						self:onEscapePressed(control)
					end
				end)
				control:SetScript('OnMouseDown', function () 
					control:Enable()
					if (self.onMouseDown) then
						self:onMouseDown(control)
					end
				end)
			end,
		})
		self.control:point('LEFT', self.label, 'RIGHT', 5, 0)
	end,
	reset = function (self)
		local oldValue = self.value
		if (self.subModule) then
			self.value = self.handler.settings[self.subModule][self.token]
		else
			self.value = self.handler.settings[self.token]
		end
		if (self.value ~= oldValue) then
			self.control.frame:SetText(self.value)
		end
	end,
	update = function (self)
		if (self.value) then
			self.control.frame:SetText(self.value)
		end
	end,
	createRegions = function (self)
		self.label = self:createFontString({
			offset = {0, nil, 0, 0},
			color = {0.9, 0.9, 0.1, 1},
			width = self.labelWidth,
			text = self.label, 
			justifyH = 'RIGHT',
		})
		self:createControl()
	end,
	preInit = function (self)
		if (self.subModule) then
			self.value = self.handler.settings[self.subModule] and self.handler.settings[self.subModule][self.token] or nil
		else
			self.value = self.handler.settings[self.token]
		end
		if (not self.setter) then
			self.setter = self.token..'Set'
		end
	end,
	postInit = function (self)
		self:update()
	end,
})

UI.Option.String = UI.Option:extend({

})


UI.Option.Text = UI.Option:extend({
	height = 100,
	createControl = function (self)
		self.scrollFrame = self:createPanel({
			type = 'ScrollFrame',
			offset = {nil, 0, 0, 0},
			parentFrame = self.frame,
			style = function (scrollFrame)
				scrollFrame:createTexture({
					layer = 'BACKGROUND',
					subLayer = 0,
					color = {0, 0, 0, 0.95},
					-- offset = {0, 0, 0, nil},
					-- height = 1,
				})
				scrollFrame.outline = scrollFrame:createOutline({
					layer = 'ARTWORK',
					subLayer = 3,
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.08 },
					colorEnd = {1, 1, 1, 0.12 },
					offset = {1, 1, 1, 1},
				})
			end,

			createRegions = function (scrollFrame)
				scrollFrame.scrollChild = O3.UI.EditBox:instance({
					parentFrame = scrollFrame.parentFrame,
					justifyH = 'LEFT',
					justifyV = 'TOP',
					--offset = {0, nil, 0, nil},
					width = 286,
					height = 100,
					lines = 10,
					onEscapePressed = function (editBox)
						editBox.frame:Disable()
						self:hide()
					end,
					style = function (editBox)

					end,
					onEscapePressed = function (editBox, frame)
						self:change(frame:GetText())
						frame:Disable()
					end,
					onEditFocusLost = function (editBox, frame)
						self:change(frame:GetText())
					end,
					onCursorChanged =  function (editBox, frame, x, y, width, height)
						local frame = editBox.frame
						y = -1*y
						local scrollHeight = scrollFrame.frame:GetHeight()
						local contentHeight =  math.ceil(frame:GetHeight())
						local scrollMax = scrollFrame.frame:GetVerticalScrollRange()
						local scrollPos = scrollFrame.frame:GetVerticalScroll()
						if y < scrollPos then
							scrollFrame.frame:SetVerticalScroll(y)
						elseif contentHeight < scrollHeight then
							scrollFrame.frame:SetVerticalScroll(0)
						else
							if y > contentHeight - (height*2) then
								scrollFrame.frame:SetVerticalScroll(scrollMax)
							elseif y > scrollHeight then
								scrollFrame.frame:SetVerticalScroll(y-scrollHeight+height*2)
							end
						end
					end,
				})
				self.control = scrollFrame.scrollChild

			end,
			hook = function (scrollFrame)
				scrollFrame.frame:SetScript('OnMouseDown', function ()
					scrollFrame.scrollChild.frame:Enable()
				end)	
			end,
			postInit = function (scrollFrame)
				scrollFrame.frame:SetScrollChild(scrollFrame.scrollChild.frame)
				-- scrollFrame.frame:SetVerticalScroll(0)
				-- scrollFrame.frame:SetHorizontalScroll(0)
				-- scrollFrame.frame:UpdateScrollChildRect()
			end,
		})
		self.scrollFrame:point('LEFT', self.label, 'RIGHT', 5, 0)
	end,
})


UI.Option:addToObject(O3.Module)

-- UI.Option:instance({
-- 	token = 'test',
-- 	offset = {400, nil, 200, nil},
-- 	label = 'Test',
-- }, test, UIParent)