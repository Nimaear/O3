local addon, ns = ...
local O3 = ns.O3


O3.SettingsWindow = O3.UI.ScrollWindow:extend({
	name = 'O3SettingsWindow',
	title = 'O3',
	subTitle = 'Settings',
	frameStrata = 'HIGH',
	width = 200,
	offset = {100, nil, 100, nil},
	settings = {
		width = 220,
		height = 600,
		maximizable = false,
		resizable = false,
		labelFont = O3.Media:font('Normal'),
		labelFontSize = 12,
	},
	activeWindow = nil,
	createButton = function (self, parentFrame, label)
		local button = CreateFrame('Frame', nil, parentFrame)
		button:SetSize(218,28)
		O3.UI:style(button)
		local text = button:CreateFontString()
		text:SetFont(self.settings.labelFont, self.settings.labelFontSize)
		text:SetAllPoints()
		
		button:SetScript('OnEnter', function (button)
			button:SetBackdropColor(0.3, 0.1, 0.1, 0.9)
		end)

		button:SetScript('OnLeave', function (button)
			button:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
		end)

		text:SetText(label)
		text:SetTextColor(1,1,1)
		text:SetJustifyH('CENTER')
		text:SetShadowColor(0.1, 0.1, 0.1)
		text:SetShadowOffset(1,1)
		return button
	end,
	onHide = function (self)
		if (self.activeWindow) then
			self.activeWindow:hide()
		end
	end,
	onShow = function (self)
		self:raise()
	end,
	onClose = function (self)
		if (self.activeWindow) then
			self.activeWindow:hide()
		end
	end,
	createOptionsWindow = function (self, mod)
		local window = O3.UI.OptionsWindow:instance({
			module = mod,
			parentFrame = parentFrame,
			frameStrata = 'HIGH',
			name = mod.name..'OptionsWindow',
			title = 'O3',
			subTitle = mod.readable or mod.name,
		})
		mod.optionsWindow = window

	end,
	postCreate = function (self)
		local contentFrame = self.contentFrame
		local parentFrame = self.frame
		local lastButton = nil
		local parent = self
		local foundModules = {}
		for i = 1, #O3.modules do
			local mod = O3.modules[i]
			if (#mod.options > 0) then
				table.insert(foundModules, mod)
			end
		end
		table.sort(foundModules, function (a, b)
			return a.weight > b.weight
		end)
		for i = 1, #foundModules do
			local mod = foundModules[i]
			local button = O3.UI.Button:instance({
				parentFrame = contentFrame,
				height  = 20,
				width = 192,
				offset = {2, nil, nil, nil},
				text = mod.readable or mod.name,
				onClick = function (self)
					if parent.activeWindow then
						parent.activeWindow:hide()
					end
					if (not mod.optionsWindow) then
						parent:createOptionsWindow(mod)
					end
					mod.optionsWindow:toggle()
					mod.optionsWindow:raise()
					parent.activeWindow = mod.optionsWindow
					mod.optionsWindow:point('TOPLEFT', parentFrame, 'TOPRIGHT', 4, 0)
					mod.optionsWindow:point('BOTTOMLEFT', parentFrame, 'BOTTOMRIGHT', 4, 0)
					mod.optionsWindow.frame:Raise()
				end,
			})
			if lastButton then
				button:point('TOP', lastButton.frame, 'BOTTOM', 0, -2)
			else
				button:point('TOP', contentFrame, 'TOP', 0, -2)
			end
			lastButton = button
		end
		table.wipe(foundModules)
		foundModules = nil
	end,	

	postInit = function (self)
	end,
})

local settingsWindow = O3.SettingsWindow:new()
SLASH_OTWO1 = "/o3"
SlashCmdList.OTWO = function ()
	settingsWindow:toggle()
end
