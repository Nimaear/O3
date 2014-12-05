local addon, ns = ...
local O3 = ns.O3

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
					if GameMenuFrame:IsShown() then
						HideUIPanel(GameMenuFrame)
					else
						ShowUIPanel(GameMenuFrame)
					end
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
			icon = 'Interface\\Icons\\inv_misc_book_06',
			onClick = function (self, frame, button, down)
				if down then
					ToggleSpellBook('spell')
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
			attributes = {type = 'click', clickbutton = TalentMicroButton},
			clickRegister = 'AnyDown',
		},
		{
			icon = 'Interface\\Icons\\inv_misc_book_09',
			attributes = {type = 'click', clickbutton = EJMicroButton},
			clickRegister = 'AnyDown',
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
			buttonTemplate.width = 24
			buttonTemplate.height = 24
			if (not buttonTemplate.icon) then
				buttonTemplate.icon = O3.Media:texture('Crest\\'..class)
			end
			local button = O3.UI.IconButton:instance(buttonTemplate)
			if lastButton then
				if (i > 9) then
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
