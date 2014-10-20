local addon, ns = ...
local O3 = ns.O3
local RAID_CLASS_COLORS, FACTION_BAR_COLORS = RAID_CLASS_COLORS, FACTION_BAR_COLORS

O3:module({
    config = {
        enabled = true,
        showSpellId = true,
        showCaster = true,
        font = O3.Media:font('Normal'),
        fontSize = 10,
        headerSize = 12,
        smallSize = 8,
        fontStyle = '',
        hideButtons = false,
        cursor = false,
        statusBar = O3.Media:statusBar('Default'),
        hideInRaidCombat = false,
        hideInCombat = false,
        hideOnUF = false,
        xOffset = 0,
        yOffset = 0,
    },
    settings = {},
    events = {
        MERCHANT_SHOW = true,
        PLAYER_ENTERING_WORLD = true,
    },
    name = 'Tooltip',
    readable = 'Tooltip enhancements',
    addOptions = function (self)
        self:addOption('_1', {
            type = 'Title',
            label = 'Enhancements',
        })
        self:addOption('showCaster', {
            type = 'Toggle',
            label = 'Show caster of a buff/debuff',
        })
        self:addOption('showSpellId', {
            type = 'Toggle',
            label = 'Show spell id',
        })
        self:addOption('_2', {
            type = 'Title',
            label = 'General',
        })
        self:addOption('hideOnUF', {
            type = 'Toggle',
            label = 'Hide on unit frames',
        })
        self:addOption('hideButtons', {
            type = 'Toggle',
            label = 'Hide tips on action buttons',
        })
        self:addOption('hideInCombat', {
            type = 'Toggle',
            label = 'Hide in combat',
        })
        self:addOption('hideInRaidCombat', {
            type = 'Toggle',
            label = 'Hide in raid',
        })
        self:addOption('colorReaction', {
            type = 'Toggle',
            label = 'Color reaction',
        })


        self:addOption('_4', {
            type = 'Title',
            label = 'Anchor',
        })
        self:addOption('cursor', {
            type = 'Toggle',
            label = 'Anchor to cursor',
        })
        self:addOption('xOffset', {
            type = 'Range',
            min = 0,
            max = 300,
            step = 5,
            label = 'X Offset',
        })
        self:addOption('yOffset', {
            type = 'Range',
            min = 0,
            max = 300,
            step = 5,
            label = 'Y Offset',
        })

        self:addOption('_4', {
            type = 'Title',
            label = 'Style',
        })
        self:addOption('statusBar', {
            type = 'StatusBarDropDown',
            color = {0.5, 1, 0.5},
            label = 'Health texture',
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
        self:addOption('headerSize', {
            type = 'Range',
            min = 6,
            max = 20,
            step = 1,
            label = 'Header size',
        })
        self:addOption('smallSize', {
            type = 'Range',
            min = 6,
            max = 20,
            step = 1,
            label = 'Small size',
        })
        self:addOption('fontStyle', {
            type = 'DropDown',
            label = 'Outline',
            _values = O3.Media.fontStyles
        })   

    end,
    applyOptions = function (self)
        self.healthBar:SetStatusBarTexture(self.settings.statusBar)
        if (self.healthBar.text) then
            self.healthBar.text:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontStyle)
        end
        GameTooltipHeaderText:SetFont(self.settings.font, self.settings.headerSize, self.settings.fontStyle)
        GameTooltipText:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontStyle)
        Tooltip_Small:SetFont(self.settings.font, self.settings.smallSize, self.settings.fontStyle)
    end,
    postInit = function (self)

        self:showCaster()
        self:showSpellId()
        self:setUnit()
        self:fixHealthbar()

        GameTooltipHeaderText:SetFont(self.settings.font, self.settings.headerSize, self.settings.fontStyle)
        GameTooltipText:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontStyle)
        Tooltip_Small:SetFont(self.settings.font, self.settings.smallSize, self.settings.fontStyle)
        Tooltip_Small:SetShadowColor(0,0,0,0)
        Tooltip_Small:SetShadowOffset(0, 0)


        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(toolTip, parent)
            if self.settings.cursor == true then
                toolTip:SetOwner(parent, "ANCHOR_CURSOR")  
            else
                toolTip:SetOwner(parent, "ANCHOR_NONE")
                toolTip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 2-self.settings.xOffset, 2+self.settings.yOffset)
            end
            toolTip.default = 1
        end)

        GameTooltip:HookScript("OnUpdate",function(toolTip, ...)
            local inInstance, instanceType = IsInInstance()
            if toolTip:GetAnchorType() == "ANCHOR_CURSOR" and refreshBackdropBorder == true and config.cursor ~= true then
                -- h4x for world object tooltip border showing last border color 
                -- or showing background sometime ~blue :x
                refreshBackdropBorder = false
                frameLib.style(toolTip)
            elseif toolTip:GetAnchorType() == "ANCHOR_NONE" then
                toolTip:ClearAllPoints()
                if InCombatLockdown() and self.settings.hideInCombat == true and (self.settings.hideInRaidCombat == true and inInstance and (instanceType == "raid")) then
                    toolTip:Hide()
                elseif InCombatLockdown() and self.settings.hideInCombat == true and self.settings.hideInRaidCombat == false then
                    toolTip:Hide()
                else
                    toolTip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 2-self.settings.xOffset, 2+self.settings.yOffset)
                end
            end
        end)

    end,
    fixHealthbar = function (self)
        -- update HP value on status bar
        GameTooltipStatusBar:SetScript("OnValueChanged", function(toolTip, value)
            if not value then
                return
            end
            local min, max = toolTip:GetMinMaxValues()
            
            if (value < min) or (value > max) then
                return
            end
            local _, unit = GameTooltip:GetUnit()
            
            -- fix target of target returning nil
            if (not unit) then
                local mouseFocus = GetMouseFocus()
                unit = mouseFocus and mouseFocus:GetAttribute("unit")
            end

            if not self.healthBar.text then
                local text = toolTip:CreateFontString(nil, "OVERLAY")
                text:SetPoint("CENTER", self.healthBar, 'CENTER', 0, 0)
                text:SetFont(self.settings.font, self.settings.fontSize, self.settings.fontStyle)
                text:Show()
                if unit then
                    min, max = UnitHealth(unit), UnitHealthMax(unit)
                    local hp = O3:shortValue(min).." / "..O3:shortValue(max)
                    if UnitIsGhost(unit) then
                        text:SetText("Ghost")
                    elseif min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) then
                        text:SetText("Dead")
                    else
                        text:SetText(hp)
                    end
                end
                self.healthBar.text = text
            else
                local text = self.healthBar.text
                if unit then
                    min, max = UnitHealth(unit), UnitHealthMax(unit)
                    text:Show()
                    local hp = O3:shortValue(min).." / "..O3:shortValue(max)
                    if min == 0 or min == 1 then
                        text:SetText("Dead")
                    else
                        text:SetText(hp)
                    end
                else
                    text:Hide()
                end
            end
        end)
    end,
    getColor = function(self, unit)
        if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
            local _, class = UnitClass(unit)
            local color = RAID_CLASS_COLORS[class]
            if not color then return end -- sometime unit too far away return nil for color :(
            local r,g,b = color.r, color.g, color.b
            return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255), r, g, b  
        else
            local color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
            if not color then return end -- sometime unit too far away return nil for color :(
            local r,g,b = color.r, color.g, color.b     
            return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255), r, g, b      
        end
    end,    
    setUnit = function(self)
        local classification = {
            worldboss = "|cffAF5050Boss|r",
            rareelite = "|cffAF5050+ Rare|r",
            elite = "|cffAF5050+|r",
            rare = "|cffAF5050Rare|r",
        }

        GameTooltip:HookScript("OnTooltipSetUnit", function(toolTip)
            local lines = toolTip:NumLines()
            local mouseFOcus = GetMouseFocus()
            local unit = (select(2, toolTip:GetUnit())) or (mouseFOcus and mouseFOcus:GetAttribute("unit"))
            
            -- A mage's mirror images sometimes doesn't return a unit, this would fix it
            if (not unit) and (UnitExists("mouseover")) then
                unit = "mouseover"
            end
            
            -- Sometimes when you move your mouse quicky over units in the worldframe, we can get here without a unit
            if not unit then toolTip:Hide() return end
            
            -- for hiding tooltip on unitframes
            if (toolTip:GetOwner() ~= UIParent and self.settings.hideOnUF) then 
                toolTip:Hide() 
                return 
            end

            if toolTip:GetOwner() ~= UIParent and unit then
                toolTip:ClearAllPoints()
                if InCombatLockdown() and self.settings.hideInCombat == true and (self.settings.hideInRaidCombat == true and inInstance and (instanceType == "raid")) then
                    toolTip:Hide()
                    return
                elseif InCombatLockdown() and self.settings.hideInCombat == true and self.settings.hideInRaidCombat == false then
                    toolTip:Hide()
                    return
                else
                    toolTip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 2-self.settings.xOffset, 2+self.settings.xOffset)
                end
            end 
            
            -- A "mouseover" unit is better to have as we can then safely say the tip should no longer show when it becomes invalid.
            if (UnitIsUnit(unit,"mouseover")) then
                unit = "mouseover"
            end

            local race = UnitRace(unit)
            local class = UnitClass(unit)
            local level = UnitLevel(unit)
            local guild = GetGuildInfo(unit)
            local name, realm = UnitName(unit)
            local crtype = UnitCreatureType(unit)
            local classif = UnitClassification(unit)
            local title = UnitPVPName(unit)
            if level == -1 then level = MAX_PLAYER_LEVEL + 5 end
            local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

            local color = self:getColor(unit)    
            if not color then color = "|CFFFFFFFF" end -- just safe mode for when getColor(unit) return nil for unit too far away

            _G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", color, title or name, realm and realm ~= "" and " - "..realm.."|r" or "|r")
            
            if level == MAX_PLAYER_LEVEL + 5 then level = "??" end
            if(UnitIsPlayer(unit)) then
                if UnitIsAFK(unit) then
                    toolTip:AppendText((" %s"):format(CHAT_FLAG_AFK))
                elseif UnitIsDND(unit) then 
                    toolTip:AppendText((" %s"):format(CHAT_FLAG_DND))
                end

                local offset = 2
                if guild then
                    local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit);
                    if guildRankName then
                    -- can't use setformated text because some assholes have % signs in their guild ranks
                        _G["GameTooltipTextLeft2"]:SetText("<|cff00ff10"..guildName.."|r> [|cff00ff10"..guildRankName.."|r]")
                    else
                        _G["GameTooltipTextLeft2"]:SetFormattedText("<|cff00ff10%s|r>", GetGuildInfo(unit))
                    end
                    offset = offset + 1
                end

                for i= offset, lines do
                    if(_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
                        _G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", r*255, g*255, b*255, level, race, color, class.."|r")
                        break
                    end
                end
            else
                for i = 2, lines do
                    if((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
                        _G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level ~= 0 and level or "", classification[classif] or "", crtype or "")
                        break
                    end
                end
            end

            local pvpLine
            for i = 1, lines do
                if text and text == PVP_ENABLED then
                    pvpLine = _G["GameTooltipTextLeft"..i]
                    pvpLine:SetText()
                    break
                end
            end

            -- ToT line
            if UnitExists(unit.."target") and unit~="player" then
                local hex, r, g, b = self:getColor(unit.."target")
                if not r and not g and not b then r, g, b = 1, 1, 1 end
                GameTooltip:AddLine(UnitName(unit.."target"), r, g, b)
            end
            
            -- Sometimes this wasn't getting reset, the fact a cleanup isn't performed at this point, now that it was moved to "OnTooltipCleared" is very bad, so this is a fix
            toolTip.fadeOut = nil
        end)    
    end,
    PLAYER_ENTERING_WORLD = function(self)

        local healthBar = GameTooltipStatusBar
        healthBar:ClearAllPoints()
        O3.UI:style(healthBar)
        healthBar:SetHeight(10)
        healthBar:SetPoint("BOTTOMLEFT", healthBar:GetParent(), "TOPLEFT", 2, 4)
        healthBar:SetPoint("BOTTOMRIGHT", healthBar:GetParent(), "TOPRIGHT", -2, 4)
        healthBar:SetStatusBarTexture(self.settings.statusBar)
        O3.UI:shadow(healthBar)

        self.healthBar = healthBar

        local tooltips = {GameTooltip,ItemRefTooltip,ShoppingTooltip1,ShoppingTooltip2,ShoppingTooltip3,WorldMapTooltip}
        for _, tt in pairs(tooltips) do
            tt:HookScript("OnShow", function (toolTip)
                self:style(toolTip)
            end)
        end
        O3.UI:style(FriendsTooltip)
        O3.UI:style(BNToastFrame)
        O3.UI:style(DropDownList1MenuBackdrop)
        O3.UI:style(DropDownList2MenuBackdrop)
        O3.UI:style(DropDownList1Backdrop)
        O3.UI:style(DropDownList2Backdrop)
        
        BNToastFrame:HookScript("OnShow", function(self)
            self:ClearAllPoints()
            self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 5)
        end)
        
        -- Hide tooltips in combat for actions, pet actions and shapeshift
        local CombatHideActionButtonsTooltip = function(toolTip)
            if not IsShiftKeyDown() and self.settings.hideButtons then
                toolTip:Hide()
            end
        end
         
        hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
        hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
        hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
    end,
    style = function (self, toolTip)


        local mouseFocus = GetMouseFocus()
        local unit = (select(2, toolTip:GetUnit())) or (mouseFocus and mouseFocus:GetAttribute("unit"))
            
        local reaction = unit and UnitReaction(unit, "player")
        local player = unit and UnitIsPlayer(unit)
        local tapped = unit and UnitIsTapped(unit)
        local tappedbyme = unit and UnitIsTappedByPlayer(unit)
        local connected = unit and UnitIsConnected(unit)
        local dead = unit and UnitIsDead(unit)
        local r,g,b

        O3.UI:style(toolTip)
        
        if (reaction) and (tapped and not tappedbyme or not connected or dead) then
            r, g, b = 0.55, 0.57, 0.61
            toolTip:SetBackdropBorderColor(r, g, b)
            self.healthBar:SetBackdropBorderColor(r, g, b)
            self.healthBar:SetStatusBarColor(r, g, b)
        elseif player and not self.settings.colorReaction == true then
            local class = select(2, UnitClass(unit))
            r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
            toolTip:SetBackdropBorderColor(r, g, b)
            self.healthBar:SetBackdropBorderColor(r, g, b)
            self.healthBar:SetStatusBarColor(r, g, b)
        elseif reaction then
            r, g, b = FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
            toolTip:SetBackdropBorderColor(r, g, b)
            self.healthBar:SetBackdropBorderColor(r, g, b)
            self.healthBar:SetStatusBarColor(r, g, b)
        else
            local _, link = toolTip:GetItem()
            local quality = link and select(3, GetItemInfo(link))
            if quality and quality >= 2 then
                local r, g, b = GetItemQualityColor(quality)
                toolTip:SetBackdropBorderColor(r, g, b)
            else
                toolTip:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
                self.healthBar:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
                self.healthBar:SetStatusBarColor(0.1, 0.1, 0.1, 1)
            end
        end 
        -- need this
        toolTip.refreshBackdropBorder = true
    end,
    showCaster = function (self)
        hooksecurefunc(GameTooltip, "SetUnitAura", function(toolTip,...)
            local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId  = UnitAura(...)
            if spellId then
                if (self.settings.showSpellId) then
                    toolTip:AddDoubleLine("SpellID",spellId)
                end
            end
            if unitCaster and self.settings.showCaster then

                local src = GetUnitName(unitCaster, true)
                if unitCaster == "pet" or unitCaster == "vehicle" then
                    src = format("%s (%s)", src, GetUnitName("player", true))
                else
                    local partypet = unitCaster:match("^partypet(%d+)$")
                    local raidpet = unitCaster:match("^raidpet(%d+)$")
                    if partypet then
                        src = format("%s (%s)", src, GetUnitName("party"..partypet, true))
                    elseif raidpet then
                        src = format("%s (%s)", src, GetUnitName("raid"..raidpet, true))
                    end
                end

                toolTip:AddDoubleLine("Caster",src)
            end
            if spellId or unitCaster then
                toolTip:Show()
            end
        end)
    end,
    showSpellId = function (self)
        hooksecurefunc(GameTooltip, "SetUnitBuff", function(toolTip,...)
            local id = select(11,UnitBuff(...))
            if id then
                if (self.settings.showSpellId) then
                    toolTip:AddDoubleLine("SpellID:",id)
                end
                toolTip:Show()
            end
        end)

        hooksecurefunc(GameTooltip, "SetUnitDebuff", function(toolTip,...)
            local id = select(11,UnitDebuff(...))
            if id then
                if (self.settings.showSpellId) then
                    toolTip:AddDoubleLine("SpellID:",id)
                end
                toolTip:Show()
            end
        end)

        hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
            if string.find(link,"^spell:") then
                local id = string.sub(link,7)
                if (self.settings.showSpellId) then
                    ItemRefTooltip:AddDoubleLine("SpellID:",id)
                end
                ItemRefTooltip:Show()
            end
        end)

        GameTooltip:HookScript("OnTooltipSetSpell", function(toolTip)
            local id = select(3,toolTip:GetSpell())
            if id then
                if (self.settings.showSpellId) then
                    toolTip:AddDoubleLine("SpellID:",id)
                end
                toolTip:Show()
            end
        end)    
    end,    

})

