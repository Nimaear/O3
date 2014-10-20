local addon, ns = ...
local O3 = O3

O3:module({
    editPanel = nil,
    config = {
        enabled = true,
        font = O3.Media:font('Normal'),
        fontSize = 10,
        fontStyle = '',
        tabFont = O3.Media:font('Normal'),
        tabFontSize = 10,
        tabFontStyle = '',
        customColor = true,
        urlColor = "16FF5D",
        useBrackets = true,
    },
    settings = {},
    name = 'Chat',
    mainChat = nil,
    addOptions = function (self)
        self:addOption('_1', {
            type = 'Title',
            label = 'Chat Font',
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
        self:addOption('_2', {
            type = 'Title',
            label = 'Tab Font',
        })
        self:addOption('tabFont', {
            type = 'FontDropDown',
            label = 'Font',
        })
        self:addOption('tabFontSize', {
            type = 'Range',
            min = 6,
            max = 20,
            step = 1,
            label = 'Font size',
        })
        self:addOption('tabFontStyle', {
            type = 'DropDown',
            label = 'Outline',
            _values = O3.Media.fontStyles
        })
        self:addOption('_1', {
            type = 'Title',
            label = 'URL copy',
        })
        self:addOption('useBrackets', {
            type = 'Toggle',
            label = 'Use brackets',
        })
        self:addOption('customColor', {
            type = 'Toggle',
            label = 'Use a custom color',
        })
        self:addOption('urlColor', {
            type = 'String',
            label = 'URL Color',
        })
    end,
    applyOptions = function (self)
        for i = 1, NUM_CHAT_WINDOWS do
            local frame = _G[format("ChatFrame%s", i)]
            _G["ChatFrame"..i.."TabText"]:SetFont(self.config.tabFont, self.config.tabFontSize, self.config.tabFontStyle)
            _G["ChatFrame"..i]:SetFont(self.config.font, self.config.fontSize, self.config.fontStyle)
        end    
    end,
    createChatWindow = function (self)
        local chatFrame = CreateFrame('Frame', nil, UIParent)
        chatFrame:SetSize(374, 174)
        chatFrame:SetPoint('BOTTOMLEFT')
        chatFrame:SetFrameStrata("BACKGROUND")

        O3.UI.Panel:instance({
            frame = chatFrame,
            createRegions = function (self)
                self.header = self:createPanel({
                    type = 'Frame',
                    offset = {0,0,0,nil},
                    height = 22,
                    style = function (self)
                        local _, class = UnitClass('player')

                        local color = RAID_CLASS_COLORS[class]

                        self:createTexture({
                            layer = 'BACKGROUND',
                            file = O3.Media:texture('Background'),
                            tile = true,
                            color = {color.r, color.g, color.b, 1},
                            -- color = {1, 0.2, 0.2, 0.95},
                            offset = {1,1,1,1},
                        })
                        self:createOutline({
                            layer = 'BORDER',
                            gradient = 'VERTICAL',
                            color = {0, 0, 0, 1},
                            colorEnd = {0, 0, 0, 1},
                            offset = {0, 0, 0, 0 },
                        })
                        self:createOutline({
                            layer = 'BORDER',
                            gradient = 'VERTICAL',
                            color = {1, 1, 1, 0.03 },
                            colorEnd = {1, 1, 1, 0.05 },
                            offset = {1, 1, 1, 1 },
                        })
                    end,
                })            
            end,
            style = function (self)
                self.content = self:createPanel({
                    offset = {1, 1, 22, 1},
                    style = function (self)
                        self:createOutline({
                            layer = 'BORDER',
                            gradient = 'VERTICAL',
                            color = {1, 1, 1, 0.03 },
                            colorEnd = {1, 1, 1, 0.05 },
                            offset = {0, 0, 0, 0 },
                        })
                        self:createTexture({
                            layer = 'BACKGROUND',
                            file = O3.Media:texture('Background'),
                            tile = true,
                            color = {0.5, 0.5, 0.5, 0.5},
                            offset = {0,0,0,0},
                        })
                    end,
                })

                self:createOutline({
                    layer = 'BORDER',
                    gradient = 'VERTICAL',
                    color = {0, 0, 0, 1},
                    colorEnd = {0, 0, 0, 1},
                    offset = {0, 0, 0, 0 },
                })
                self:createTexture({
                    layer = 'BACKGROUND',
                    color = {0, 0, 0, 0.85},
                    -- offset = {0, 0, 0, nil},
                    -- height = 1,
                })
                self:createShadow()
            end,
        })
        -- O3.UI:wod(chatFrame)

        return chatFrame
    end,
    postInit = function (self)
        if not IsAddOnLoaded("Blizzard_CombatLog") then
            LoadAddOn("Blizzard_CombatLog")
        end

        local panelLeft = self:createChatWindow()
        panelLeft:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",4, 4)
        self.mainChat = panelLeft

        local panelLeftTop = self:createChatWindow()
        panelLeftTop:SetPoint("BOTTOMLEFT", panelLeft, "TOPLEFT", 0, 26)

        self:setupChat()

        self:setupChatPosAndFont(panelLeft, panelLeftTop)

        self:urlCopy()

        if GetCVar("chatMouseScroll") == "1" then
            FloatingChatFrame_OnMouseScroll = function(self, direction)
                if (direction > 0) then
                    if (IsShiftKeyDown()) then
                        self:ScrollToTop()
                    elseif (IsControlKeyDown()) then
                        self:PageUp()
                    else
                        self:ScrollUp()
                    end
                elseif (direction < 0) then
                    if (IsShiftKeyDown()) then
                        self:ScrollToBottom()
                    elseif (IsControlKeyDown()) then
                        self:PageDown()
                    else
                        self:ScrollDown()
                    end
                end
            end
        end
    end,
    setupChatPosAndFont = function(self, panelLeft, panelLeftTop)
        for i = 1, NUM_CHAT_WINDOWS do
            local frame = _G[format("ChatFrame%s", i)]
            _G["ChatFrame"..i.."TabText"]:SetFont(self.config.font, self.config.fontSize, self.config.fontStyle)
            _G["ChatFrame"..i]:SetFont(self.config.font, self.config.fontSize, self.config.fontStyle)
            _G["ChatFrame"..i]:SetScale(1)
            if (i == 1) then
                frame:ClearAllPoints()
                frame:SetPoint("TOPLEFT",panelLeft,"TOPLEFT",6,-22)
                frame:SetPoint("BOTTOMRIGHT",panelLeft,"BOTTOMRIGHT",-6,10)
                frame:SetFrameStrata("LOW")
                _G["ChatFrame1Tab"]:SetFrameStrata("LOW")
                FCF_SavePositionAndDimensions(frame)
            elseif (_G["ChatFrame"..i.."TabText"]:GetText() == "Private") then
                frame:ClearAllPoints()
                frame:SetPoint("TOPLEFT",panelLeftTop,"TOPLEFT",6,-22)
                frame:SetPoint("BOTTOMRIGHT",panelLeftTop,"BOTTOMRIGHT",-6,10)
                frame:SetFrameStrata("LOW")
                _G["ChatFrame"..i.."Tab"]:SetFrameStrata("LOW")
                FCF_SavePositionAndDimensions(frame)
            end
        end
    end,
    setChatStyle = function (self, frame)
        local id = frame:GetID()
        local chat = frame:GetName()
        local tab = _G[chat.."Tab"]
        local origs = {}
        local editBox = _G[chat.."EditBox"]

        -- always set alpha to 1, don't fade it anymore
        tab:SetAlpha(1)
        tab.SetAlpha = UIFrameFadeRemoveFrame
        
        -- yeah baby
        _G[chat]:SetClampRectInsets(0,0,0,0)
        
        -- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen.
        _G[chat]:SetClampedToScreen(false)
                
        -- Stop the chat chat from fading out
        _G[chat]:SetFading(false)
        
        local editPanel = O3.UI.Panel:instance({
            parentFrame = self.mainChat,
            height = 22,
            offset = {0, 0, -24, nil},
            style = function (self)
                self:createTexture({
                    layer = 'BACKGROUND',
                    subLayer = 0,
                    color = {0, 0, 0, 0.95},
                    -- offset = {0, 0, 0, nil},
                    -- height = 1,
                })
                self.outline = self:createOutline({
                    layer = 'ARTWORK',
                    subLayer = 3,
                    gradient = 'VERTICAL',
                    color = {1, 1, 1, 0.08 },
                    colorEnd = {1, 1, 1, 0.12 },
                    offset = {1, 1, 1, 1},
                })
            end,
        })
        editPanel:hide()
        -- move the chat edit box
        editBox:ClearAllPoints()
        editBox:SetHeight(22)
        editBox:SetPoint("BOTTOMLEFT", editPanel.frame, 0, 0)
        editBox:SetPoint("BOTTOMRIGHT", editPanel.frame, 0, 0)

        editBox:SetScript('OnShow', function ()
            editPanel:show()
        end)

        editBox:SetScript('OnHide', function ()
            editPanel:hide()
        end)

        -- Hide textures
        for j = 1, #CHAT_FRAME_TEXTURES do
            _G[chat..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
        end

        -- Removes Default ChatFrame Tabs texture               
        O3:destroy(_G[format("ChatFrame%sTabLeft", id)])
        O3:destroy(_G[format("ChatFrame%sTabMiddle", id)])
        O3:destroy(_G[format("ChatFrame%sTabRight", id)])

        O3:destroy(_G[format("ChatFrame%sTabSelectedLeft", id)])
        O3:destroy(_G[format("ChatFrame%sTabSelectedMiddle", id)])
        O3:destroy(_G[format("ChatFrame%sTabSelectedRight", id)])
        
        O3:destroy(_G[format("ChatFrame%sTabHighlightLeft", id)])
        O3:destroy(_G[format("ChatFrame%sTabHighlightMiddle", id)])
        O3:destroy(_G[format("ChatFrame%sTabHighlightRight", id)])

        -- Kills off the new method of handling the Chat Frame scroll buttons as well as the resize button
        -- Note: This also needs to include the actual frame textures for the ButtonFrame onHover
        O3:destroy(_G[format("ChatFrame%sButtonFrameUpButton", id)])
        O3:destroy(_G[format("ChatFrame%sButtonFrameDownButton", id)])
        O3:destroy(_G[format("ChatFrame%sButtonFrameBottomButton", id)])
        O3:destroy(_G[format("ChatFrame%sButtonFrameMinimizeButton", id)])
        O3:destroy(_G[format("ChatFrame%sButtonFrame", id)])

        -- Kills off the retarded new circle around the editbox
        O3:destroy(_G[format("ChatFrame%sEditBoxFocusLeft", id)])
        O3:destroy(_G[format("ChatFrame%sEditBoxFocusMid", id)])
        O3:destroy(_G[format("ChatFrame%sEditBoxFocusRight", id)])

        -- Kill off editbox artwork
        local a, b, c = select(6, editBox:GetRegions())
        O3:destroy (a)
        O3:destroy (b)
        O3:destroy (c)
                    
        -- Disable alt key usage
        editBox:SetAltArrowKeyMode(false)
        
        -- hide editbox on login
        editBox:Hide()

        -- script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
        editBox:HookScript("OnEditFocusLost", function(self) self:Hide() end)
        
        -- hide edit box every time we click on a tab
        _G[chat.."Tab"]:HookScript("OnClick", function() editBox:Hide() end)
                
        -- rename combag log to log
        if _G[chat] == _G["ChatFrame2"] then
            FCF_SetWindowName(_G[chat], "Log")
        end

        local count = 0
        -- update border color according where we talk
        hooksecurefunc("ChatEdit_UpdateHeader", function(chatEdit)

            local type = editBox:GetAttribute("chatType")

            if ( type == "CHANNEL" ) then
                local id = GetChannelName(chatEdit:GetAttribute("channelTarget"))
                if id == 0 then
                    -- editPanel.texture:SetVertexColor(0.3, 0.3, 0.3)
                    -- if (not editPanel.ag:IsPlaying()) then
                    --     editPanel.ag:setEndColor(0.3, 0.3, 0.3)
                    --     editPanel.ag:Play()
                    -- end
                else
                    -- editPanel.texture:SetVertexColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
                    -- if (not editPanel.ag:IsPlaying()) then
                    --     editPanel.ag:setEndColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
                    --     editPanel.ag:Play()
                    -- end
                end
            else
                -- editPanel.texture:SetVertexColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
                -- if (not editPanel.ag:IsPlaying()) then
                --     editPanel.ag:setEndColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
                --     editPanel.ag:Play()
                -- end
            end 

        end)
      
        if _G[chat] ~= _G["ChatFrame2"] then
            origs[_G[chat]] = _G[chat].AddMessage
            _G[chat].AddMessage = function (self, text, ...)
                if(type(text) == "string") then
                    text = text:gsub('|h%[(%d+)%. .-%]|h', '|h[%1]|h')
                end
                return origs[self](self, text, ...)

            end
        end
    end,
    setupChat = function (self)
        for i = 1, NUM_CHAT_WINDOWS do
            local frame = _G[format("ChatFrame%s", i)]
            self:setChatStyle(frame)
            FCFTab_UpdateColors(_G["ChatFrame"..i.."Tab"], false)
        end
                    
        -- Remember last channel
        ChatTypeInfo.WHISPER.sticky = 1
        ChatTypeInfo.BN_WHISPER.sticky = 1
        ChatTypeInfo.OFFICER.sticky = 1
        ChatTypeInfo.RAID_WARNING.sticky = 1
        ChatTypeInfo.CHANNEL.sticky = 1
    end,
    link = function (self, url)
        
        if (self.config.customColor) then
            if (self.config.useBrackets) then
                url = " |cff"..self.config.urlColor.."|Hurl:"..url.."|h["..url.."]|h|r "
            else
                url = " |cff"..self.config.urlColor.."|Hurl:"..url.."|h"..url.."|h|r "
            end
        else
            if (self.config.useBrackets) then
                url = " |Hurl:"..url.."|h["..url.."]|h "
            else
                url = " |Hurl:"..url.."|h"..url.."|h "
            end
        end
        return url
    end, 
    addLinkSyntax = function (self, chatMessage)
        if (type(chatMessage) == "string") then
            local extraspace
            if (not strfind(chatMessage, "^ ")) then
                extraspace = true
                chatMessage = " "..chatMessage
            end
            chatMessage = gsub (chatMessage, " www%.([_A-Za-z0-9-]+)%.(%S+)%s?", self:link("www.%1.%2"))
            chatMessage = gsub (chatMessage, " (%a+)://(%S+)%s?", self:link("%1://%2"))
            chatMessage = gsub (chatMessage, " ([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", self:link("%1@%2%3%4"))
            chatMessage = gsub (chatMessage, " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?", self:link("%1.%2.%3.%4:%5"))
            chatMessage = gsub (chatMessage, " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", self:link("%1.%2.%3.%4"))
            if (extraspace) then
                chatMessage = strsub(chatMessage, 2)
            end
        end
        return chatMessage
    end, 
    urlCopy = function (self)
        local setItemRefOriginal = SetItemRef

        local setItemRef = function(link, text, button, chatFrame)
            if (strsub(link, 1, 3) == "url") then
                local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
                local url = strsub(link, 5);
                if (not ChatFrameEditBox:IsShown()) then
                    ChatEdit_ActivateChat(ChatFrameEditBox)
                end
                ChatFrameEditBox:Insert(url)
                ChatFrameEditBox:HighlightText()

            else
                setItemRefOriginal(link, text, button, chatFrame)
            end
        end
        SetItemRef = setItemRef

        --Hook all the AddMessage funcs
        for i=1, NUM_CHAT_WINDOWS do
            local frame = getglobal("ChatFrame"..i)
            local addMessage = frame.AddMessage
            frame.AddMessage = function(chatFrame, text, ...) 
                addMessage(chatFrame, self:addLinkSyntax(text), ...) 
            end
        end
    end,
})