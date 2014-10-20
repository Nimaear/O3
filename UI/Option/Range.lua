local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Option.Range = UI.Option:extend({
	min = 0,
	max = 100,
	step = 5,
	change = function (self, value)
		local parent = self.parent
		self.value = value
		self.editBox.frame:SetNumber(value)
		self.slider.frame:SetValue(value)
		parent.settings[self.token] = self.value

		if parent[self.setter] then
			parent[self.setter](parent, self.token, self.value, self)
		end
		if parent.changeOption then
			parent.changeOption(parent, self.token, value, self)
		end
		if parent.applyOptions then
			parent.applyOptions(parent, self)
		end		
		parent:saveOption(self.token)
	end,	
	createControl = function (self)
		self.editBox = O3.UI.EditBox:instance({
			parentFrame = self.frame,
			offset = {self.labelWidth+5, nil, 0, 0},
			width = 45,
			hook = function (editBox)
				local control = editBox.frame
				control:SetScript('OnEnterPressed', function ()
					if editBox.lines == 1 then
						self:change(control:GetText())
						control:Disable()
					end
					if (editBox.onEnterPressed) then
						editBox:onEnterPressed(control)
					end
				end)

				control:SetScript('OnEscapePressed', function () 
					self:change(control:GetText())
					control:Disable()
					if (editBox.onEscapePressed) then
						editBox:onEscapePressed(control)
					end
				end)
				control:SetScript('OnMouseDown', function () 
					control:Enable()
					if (editBox.onMouseDown) then
						editBox:onMouseDown(control)
					end
				end)
			end,
		})

		self.control = O3.UI.Panel:instance({
			type = 'Slider',
			parentFrame = self.frame,
			offset = {nil, 0, 0, 0},
			postInit = function (slider)
				local frame = slider.frame
				frame:SetMinMaxValues(self.min, self.max)
				frame:SetValueStep(self.step)
				frame:SetValue(self.value or 0)
				frame:SetOrientation('HORIZONTAL')
				-- frame:SetScale(1)
				-- print('hi')
				frame:SetFrameStrata(self.parentFrame:GetFrameStrata())
			end,
			createRegions = function (slider)
				slider:createTexture({
					offset = {1, 1, 8, nil},
					drawLayer = 'BACKGROUND',
					color = {0.4, 0.4, 0.4, 0.9},
					height = 1,
				})
				slider:createTexture({
					drawLayer = 'BACKGROUND',
					offset = {1, 1, 9, nil},
					color = {0.1, 0.1, 0.1, 0.9},
					height = 1,
				})

				slider.thumb = slider:createTexture({
					layer = 'BACKGROUND',
					file = O3.Media:texture('Background'),
					tile = true,
					width = 4,
					height = 4,
				})
				slider.thumb:SetTexture(nil)
				slider.frame:SetThumbTexture(slider.thumb)


				local text = slider:createFontString({
					fontSize = 18,
					color = {0.5, 0.5, 0.5, 1},
					font = O3.Media:font('Glyph'),
					text = '',
				})
				text:SetPoint('BOTTOM', slider.thumb, 'BOTTOM', 0, 0)
			end,
		})
		self.control.frame:SetScript('OnValueChanged', function (slider, value)
			self:change(value)
		end)
		self.control:point('LEFT', self.editBox.frame, 'RIGHT', 2, 0)
	end,
	update = function (self)
		self.editBox.frame:SetNumber(self.value)
		self.control.frame:SetValue(self.value)		
	end,
	change = function (self, value, doNotExecuteHooks)
		local handler = self.handler
		self.value = value
		handler.settings[self.token] = self.value
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
})


