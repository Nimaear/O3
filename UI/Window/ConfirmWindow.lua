local addon, ns = ...
local O3 = ns.O3
local UI = O3.UI


O3.Confirm = UI.Window:instance({
	width = 400,
	height = 200,
	managed = false,
	name = 'O3ConfirmWindow',
	savePosition = false,
	closeWithEscape = true,
	offset = {nil, nil, 300, nil},
	postCreate = function (self)
		self.text = self:createFontString({
			parentFrame = self.content.frame,
			offset = {2, 2, 2, 24}
		})
		self.yes = O3.UI.Button:instance({
			text = 'Yes',
			color = {0.1, 0.9, 0.1, 1},
			width = 80,
			offset = {110, nil, nil, 2},
			parentFrame = self.content.frame,
			onClick = function (button)
				if (self.onYes) then
					self:onYes()
					self:hide()
				end
			end,
		})
		self.no = O3.UI.Button:instance({
			text = 'No',
			color = {0.9, 0.1, 0.1, 1},
			width = 80,
			offset = {nil, 110, nil, 2},
			parentFrame = self.content.frame,
			onClick = function (button)
				if (self.onNo) then
					self:onNo()
					self:hide()
				end
			end,
		})
	end,
	confirm = function (self, question, onYes, onNo, yesLabel, noLabel)
		self:show()
		self:raise()
		self.text:SetText(question)
		self.onYes = onYes
		self.onNo = onNo
		if (yesLabel) then
			self.yes.text:SetText(yesLabel)
		end
		if (noLabel) then
			self.no.text:SetText(noLabel)
		end
	end,
})
O3.Confirm:setCall(O3.Confirm.confirm)

O3.Alert = UI.Window:instance({
	width = 400,
	height = 200,
	managed = false,
	name = 'O3AlertmWindow',
	savePosition = false,
	closeWithEscape = true,
	offset = {nil, nil, 300, nil},
	postCreate = function (self)
		self.text = self:createFontString({
			parentFrame = self.content.frame,
			offset = {2, 2, 2, 24}
		})
		self.button = O3.UI.Button:instance({
			text = 'Yes',
			color = {0.1, 0.9, 0.1, 1},
			width = 80,
			offset = {nil, nil, nil, 2},
			parentFrame = self.content.frame,
			onClick = function (button)
				if (self.onClick) then
					self:onClick()
					self:hide()
				end
			end,
		})
	end,
	alert = function (self, text, onClick, buttonLabel)
		self:show()
		self:raise()
		self.text:SetText(text)
		self.onClick = onClick
		if (buttonLabel) then
			self.button.text:SetText(buttonLabel)
		end
	end,
})
O3.Alert:setCall(O3.Alert.alert)
