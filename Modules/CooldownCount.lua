local addon, ns = ...
local O3 = ns.O3


local UIParent = UIParent
local GetTime = GetTime
local floor = math.floor
local min = math.min
local round = function(x) 
	return floor(x + 0.5) 
end

local  timers = {}

local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times


-- handy locales
local MIN_SCALE
local MIN_DURATION
local EXPIRING_DURATION
local EXPIRING_FORMAT
local SECONDS_FORMAT
local MINUTES_FORMAT
local HOURS_FORMAT
local DAYS_FORMAT




O3:module({
	name = 'CooldownCount',
	events = {
		PLAYER_ENTERING_WORLD = true,
	},
	config = {
		enabled = true,
		font = O3.Media:font('Thin'),
		fontSize = 16, 
		fontFlags = 'OUTLINE',
		expiringDuration = 5,
		minDuration = 3,
		expiringFormat = '|cffff0000%d|r',
		secondsFormat = '|cffffff00%d|r',
		minutesFormat = '|cffffffff%dm|r',
		hoursFormat = '|cff66ffff%dh|r',
		daysFormat = '|cff6666ff%dh|r',
		minScale = 0.6,       
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
            label = 'FontSize',
            min = 6,
            max = 40,
            step = 1,
        })		
	end,
	VARIABLES_LOADED = function (self)
		MIN_SCALE = self.settings.minScale
		MIN_DURATION = self.settings.minDuration
		EXPIRING_DURATION = self.settings.expiringDuration
		EXPIRING_FORMAT = self.settings.expiringFormat
		SECONDS_FORMAT = self.settings.secondsFormat
		MINUTES_FORMAT = self.settings.minutesFormat
		HOURS_FORMAT = self.settings.hoursFormat
		DAYS_FORMAT = self.settings.daysFormat	
	end,
	applyOptions = function  (self)
		for cooldown, timer in pairs(timers) do
			timer.fontScale = nil
			self:onSizeChanged(timer, timer:GetSize())
		end
	end,
	--forces the given timer to update on the next frame
	forceUpdate = function(self, timer)
		self:updateText(timer)
		timer:Show()
	end,
	setNextUpdate = function (self, timer, nextUpdate)
		timer.updater:GetAnimations():SetDuration(nextUpdate)
		if timer.updater:IsPlaying() then
			timer.updater:Stop()
		end
		timer.updater:Play()
	end,
	--returns both what text to display, and how long until the next update
	getTimeText = function (self, s)
		--format text as seconds when at 90 seconds or below
		if s < MINUTEISH then
			local seconds = round(s)
			local formatString = seconds > EXPIRING_DURATION and SECONDS_FORMAT or EXPIRING_FORMAT
			return formatString, seconds, s - (seconds - 0.51)
		--format text as minutes when below an hour
		elseif s < HOURISH then
			local minutes = round(s/MINUTE)
			return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
		--format text as hours when below a day
		elseif s < DAYISH then
			local hours = round(s/HOUR)
			return HOURS_FORMAT, hours, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
		--format text as days
		else
			local days = round(s/DAY)
			return DAYS_FORMAT, days,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
		end
	end,
	updateText = function (self, timer)
		local remain = timer.duration - (GetTime() - timer.start)
		if round(remain) > 0 then
			if (timer.fontScale * timer:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
				timer.text:SetText('')
				self:setNextUpdate(timer, 1)
			else
				local formatStr, time, nextUpdate = self:getTimeText(remain)
				timer.text:SetFormattedText(formatStr, time)
				self:setNextUpdate(timer, nextUpdate)
			end
		else
			self:stop(timer)
		end
	end,
	create = function(self, cooldown)
		--a frame to watch for OnSizeChanged events
		--needed since OnSizeChanged has funny triggering if the frame with the handler is not shown
		local scaler = CreateFrame('Frame', nil, cooldown)
		scaler:SetAllPoints(cooldown)

		local timer = CreateFrame('Frame', nil, scaler)
		timer:Hide()
		timer:SetAllPoints(scaler)

		local updater = timer:CreateAnimationGroup()
		updater:SetLooping('NONE')
		updater:SetScript('OnFinished', function(updater) 
			self:updateText(timer) 
		end)

		local a = updater:CreateAnimation('Animation'); a:SetOrder(1)
		timer.updater = updater 

		local text = timer:CreateFontString(nil, 'OVERLAY')
		text:SetPoint('CENTER', 0, 0)
		text:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontFlags)
		timer.text = text

		self:onSizeChanged(timer, scaler:GetSize())
		scaler:SetScript('OnSizeChanged', function(scaler, ...) 
			self:onSizeChanged(timer, ...) 
		end)

		timers[cooldown] = timer

		return timer
	end,
	--adjust font size whenever the timer's parent size changes
	--hide if it gets too tiny
	onSizeChanged = function (self, timer, width, height)
		local fontScale = round(width) / ICON_SIZE
		if fontScale == timer.fontScale then
			return
		end

		timer.fontScale = fontScale
		if fontScale < MIN_SCALE then
			timer:Hide()
		else
			timer.text:SetFont(self.settings.font, fontScale * self.settings.fontSize, self.settings.fontFlags)
			timer.text:SetShadowColor(0, 0, 0, 0.8)
			timer.text:SetShadowOffset(1, -1)
			if timer.enabled then
				self:forceUpdate(timer)
			end
		end
	end,
	start = function (self, cooldown, start, duration, charges, maxCharges)
		local remainingCharges = charges or 0

		--start timer
		if start > 0 and duration > MIN_DURATION and remainingCharges == 0 and (not cooldown.noCooldownCount) then
			local timer = timers[cooldown] or self:create(cooldown)

			timer.enabled = true
			timer.start = start
			timer.duration = duration
			timer.charges = remainingCharges
			timer.maxCharges = maxCharges

			self:updateText(timer)
			if timer.fontScale >= MIN_SCALE 
				then timer:Show() 
			end
				--stop timer
		else
			local timer = timers[cooldown]
			if timer then
				self:stop(timer)
			end
		end    
	end,
	stop = function (self, timer)
		timer.enabled = nil
		timer.start = nil
		timer.duration = nil
		timer.charges = nil
		timer.maxCharges = nil

		if timer.updater:IsPlaying() then
			timer.updater:Stop()
		end
		timer:Hide()
	end,
	PLAYER_ENTERING_WORLD = function (self)
		for cooldown, timer in pairs(timers) do
			if (timer.start) then
				self:forceUpdate(timer)
			end
		end
	end,
	postCreate = function (self)
		local dummy = CreateFrame('Cooldown')
		hooksecurefunc(getmetatable(dummy).__index, 'SetCooldown', function (cooldown, ...)
			self:start(cooldown, ...)
		end)
	end,
})

