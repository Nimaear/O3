local addon, ns = ...
local O3 = ns.O3


O3:module({
	config = {
		enabled = true,
		lastMessage = nil,
		font = O3.Media:font('Normal'),
		fontSize = 10,
		fontStyle = '',
	},
	settings = {},
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Font',
		})
		self:addOption('font', {
			type = 'FontDropDown',
			label = 'Font',
		})
		self:addOption('fontSize', {
			type = 'Range',
			min = 6,
			max = 20,
			step = 1,
			label = 'Font size',
		})
		self:addOption('fontStyle', {
			type = 'DropDown',
			label = 'Outline',
			_values = O3.Media.fontStyles
		})
	end,
	events = {
		SYSMSG = true,
		UI_INFO_MESSAGE = true,
		UI_ERROR_MESSAGE = true,
	},
	name = 'Error',
	readable = 'Error frame',
	createPanel = function (self)
		self.panel = self.O3.UI.Panel:instance({
			name = self.name,
			offset = {nil, nil, 0, nil},
			width = 320,
			height = 20,
			createRegions = function (panel)
				self.text = panel:createFontString({
					offset = {0,0,-2,0},
				})
			end,
			style = function (panel)
				panel:createTexture({
					layer = 'BACKGROUND',
					file = O3.Media:texture('Background'),
					tile = true,
					color = {0.5, 0.5, 0.5, 0.9},
					offset = {1,1,1,1},
				})
				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {1, 1, 1, 0.03 },
					colorEnd = {1, 1, 1, 0.05 },
					offset = {1, 1, 1, 1},
					-- width = 2,
					-- height = 2,
				})
				panel:createOutline({
					layer = 'BORDER',
					gradient = 'VERTICAL',
					color = {0, 0, 0, 1 },
					colorEnd = {0, 0, 0, 1 },
					offset = {0, 0, 0, 0 },
				})			
			end,
		})
	end,
	postInit = function (self)
		O3:destroy(UIErrorsFrame)
	end,
	SYSMSG = function (self, message, r, g, b)
		if (self.lastMessage ~= message) then
			self.lastMessage = message
			self.text:SetText(message)
			self.text:SetTextColor(r, g, b)
		end
	end,
	UI_INFO_MESSAGE = function (self, message)
		if (self.lastMessage ~= message) then
			self.lastMessage = message
			self.text:SetText(message)
			self.text:SetTextColor(1, 1, 0)
		end
	end,
	UI_ERROR_MESSAGE = function (self, message)
		if (self.lastMessage ~= message) then
			self.lastMessage = message
			self.text:SetText(message)
			self.text:SetTextColor(1, 0.1, 0.1)
		end
	end,
	applyOptions = function (self)
		self.text:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontStyle)
	end,
})

O3:module({
	name = 'MicroMenu',
	readable = 'Micro Menu',
	config = {
		enabled = true,
		font = O3.Media:font('Normal'),
		fontSize = 10,
		fontStyle = '',
	},
	buttons = {
		{
			icon = 'Interface\\Icons\\ability_rogue_tricksofthetrade',
			onClick = function (self, frame, button, down)
				if down then
					ToggleGameMenu()
				end
			end,
		},
		{
			icon = nil,
			onClick = function (self, frame, button, down)
				if down then
					ToggleCharacter("PaperDollFrame")
				end
			end,
		},
		{
			icon = 'Interface\\Icons\\inv_epicguildtabard',
			onClick = function (self, frame, button, down)
				if down then
					ToggleGuildFrame()
				end
			end,
		},
		{
			icon = 'Interface\\Icons\\ability_marksmanship',
			onClick = function (self, frame, button, down)
				if down then
					ToggleTalentFrame()
				end
			end,
		},
		{
			icon = 'Interface\\Icons\\ability_mount_pegasus',
			onClick = function (self, frame, button, down)
				if down then
					TogglePetJournal(1)
				end
			end,
		},
		{
			icon = 'Interface\\Icons\\inv_shield_pandaraid_d_01',
			onClick = function (self, frame, button, down)
				if down then
					ToggleAchievementFrame()
				end
			end,
		},	
		{
			icon = 'Interface\\Icons\\Inv_Gizmo_01',
			onClick = function (self, frame, button, down)
				if down then
					if ( GameTimeCalendarInvitesTexture:IsShown() ) then
						Calendar_LoadUI();
						if ( Calendar_Show ) then
							Calendar_Show();
						end
						GameTimeCalendarInvitesTexture:Hide();
						GameTimeCalendarInvitesGlow:Hide();
						self.pendingCalendarInvites = 0;
						GameTimeFrame.flashInvite = false;
					else
						ToggleCalendar();
					end
				end
			end,
		},
		{
			icon = 'Interface\\Icons\\Ability_Hunter_MasterMarksman',
			onClick = function (self, frame, button, down)
				if down then
					ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, frame, 0, -5);	
				end
			end,
		},
		-- {
		-- 	icon = nil,
		-- 	onClick = function (self, frame, button, down)
		-- 		if down then
		-- 			ToggleGuildFrame()
		-- 		end
		-- 	end,
		-- },
	},
	events = {
		PLAYER_ENTERING_WORLD = true,
	},
	settings = {},
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Font',
		})
		self:addOption('font', {
			type = 'FontDropDown',
			label = 'Font',
		})
		self:addOption('fontSize', {
			type = 'Range',
			min = 6,
			max = 20,
			step = 1,
			label = 'Font size',
		})
		self:addOption('fontStyle', {
			type = 'DropDown',
			label = 'Outline',
			_values = O3.Media.fontStyles
		})
	end,
	createButtons = function (self)
		local _, class = UnitClass('player')
		local lastButton = nil
		for i = 1, #self.buttons do
			local buttonTemplate = self.buttons[i]
			buttonTemplate.template = 'SecureActionButtonTemplate'
			buttonTemplate.parentFrame = self.frame
			buttonTemplate.width = 32
			buttonTemplate.height = 32
			if (not buttonTemplate.icon) then
				buttonTemplate.icon = O3.Media:texture('Crest\\'..class)
			end
			local button = O3.UI.IconButton:instance(buttonTemplate)
			if lastButton then
				if (i > 7) then
					button:point('TOPRIGHT', lastButton.frame, 'TOPLEFT', -1, 0)
				else
					button:point('TOPRIGHT', lastButton.frame, 'BOTTOMRIGHT', 0, -1)
				end
			else
				button:point('TOPRIGHT', 0, 0)
			end
			lastButton = button
		end
	end,
	PLAYER_ENTERING_WORLD = function (self)
		self.panel:point('TOPRIGHT', -4, -4)
		self.panel:setSize(24, 24)
		self:createButtons()
		self:unregisterEvent('PLAYER_ENTERING_WORLD')
	end,
})
