local addon, ns = ...
local O3 = ns.O3

O3:module({
	name = 'SmallPleasures',
	readable = 'Small Pleasures',
    config = {
        enabled = true,
        rareWarning = true,
        rareWarningMessage = "Rare spotted!",
    },
    events = {
    },
    settings = {},
    addOptions = function (self)
        self:addOption('_1', {
            type = 'Title',
            label = 'Rare warning',
        })
        self:addOption('rareWarning', {
            type = 'Toggle',
            label = 'Enabled',
        })
        self:addOption('rareWarningMessage', {
            type = 'String',
            label = 'Warning message',
        })
    end,
    VARIABLES_LOADED = function (self)
        if (self.settings.rareWarning) then
            self:registerEvent('VIGNETTE_ADDED')           
        end
    end,
    VIGNETTE_ADDED = function (self)
        PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
        RaidNotice_AddMessage(RaidWarningFrame, self.settings.message, ChatTypeInfo["RAID_WARNING"])
    end,
    rareWarningSet = function (self)
        if (self.settings.rareWarning) then
            self:registerEvent('VIGNETTE_ADDED')
        else
            self:unregisterEvent('VIGNETTE_ADDED')
        end
    end,
    register = function (self, O3)
    end,
})
