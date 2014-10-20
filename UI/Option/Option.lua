local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI

UI.Option = UI.Panel:extend({
	labelWidth = 120,
	height = 20,
	width = 490,
	label = nil,
	value = nil,
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
	addToObject = function (self, object)
		if (not rawget(object, 'options')) then
			object.options = {}
		end
		if (not rawget(object, 'addOption')) then
			object.addOption = function (self, token, option)
				option.token = token
				table.insert(self.options, option)
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
		object.applyOptions = function (self)
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
	update = function (self)
		if (self.value) then
			self.control.frame:SetText(self.value)
		end
	end,
	createRegions = function (self)
		self.label = self:createFontString({
			offset = {0, nil, 0, 0},
			width = self.labelWidth,
			text = self.label, 
			justifyH = 'RIGHT',
		})
		self:createControl()
	end,
	preInit = function (self)
		self.value = self.handler.settings[self.token]
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


UI.Option:addToObject(O3.Module)

-- UI.Option:instance({
-- 	token = 'test',
-- 	offset = {400, nil, 200, nil},
-- 	label = 'Test',
-- }, test, UIParent)