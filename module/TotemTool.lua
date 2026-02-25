local totem_tool = {
    up = {
        p = "CENTER",
        x = 100,
        y = -180
    },
    button_frame = {
        false, false, false, false
    },
}

function GetTotems()
    local totems = { {}, {}, {}, {} }

    local totem_map = {
        earth = { "石肤图腾", "石爪图腾", "土元素图腾", "大地之力图腾", "地缚图腾", "战栗图腾" },
        fire = { "灼热图腾", "熔岩图腾", "火元素图腾", "火焰新星图腾", "火舌图腾", "抗寒图腾" },
        water = { "治疗之泉图腾", "法力之泉图腾", "清毒图腾", "祛病图腾", "抗火图腾" },
        air = { "空气之怒图腾", "风怒图腾", "风之优雅图腾", "风墙图腾", "宁静之风图腾", "根基图腾", "自然抗性图腾", "岗哨图腾" },
    }

    local spells = {}
    for slot = 1, 500 do
        local spellType, id = GetSpellBookItemInfo(slot, "spell")
        if not id then
            break
        end
        local name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(slot, "spell")
        subtext = C_Spell.GetSpellSubtext(spellID)

        if spells[name] then
            local sava_rank = tonumber(string.match(spells[name].subtext, "(%d+)"))
            local rank = tonumber(string.match(subtext, "(%d+)"))
            if rank > sava_rank then
                spells[name] = TotemArgs(name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon)
            end

            print(name, "等级", sava_rank, rank)
        else
            spells[name] = TotemArgs(name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon)
        end
    end

    for key, spell in pairs(spells) do
        for index, value in ipairs(totem_map.earth) do
            if spell.name == value then
                table.insert(totems[1], spell)
            end
        end
        for index, value in ipairs(totem_map.fire) do
            if spell.name == value then
                table.insert(totems[2], spell)
            end
        end
        for index, value in ipairs(totem_map.water) do
            if spell.name == value then
                table.insert(totems[3], spell)
            end
        end
        for index, value in ipairs(totem_map.air) do
            if spell.name == value then
                table.insert(totems[4], spell)
            end
        end
    end

    return totems
end

function TotemArgs(name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon)
    return {
        name = name,
        subtext = subtext,
        icon = icon,
        castTime = castTime,
        minRange = minRange,
        maxRange = maxRange,
        spellID = spellID,
        originalIcon = originalIcon
    }
end

function VoidFrame:CreateTotemToolFrame()
    local totems = GetTotems()
    VoidModClassicCharacterDB.point.totem_tool = VoidModClassicCharacterDB.point.totem_tool or {
        p = totem_tool.up.p,
        x = totem_tool.up.x,
        y = totem_tool.up.y,
    }
    self.voidTotemTool = CreateFrame("Frame", "TotemTool", UIParent, "BackdropTemplate")
    self.voidTotemTool:SetSize(220, 60)
    self.voidTotemTool:SetPoint(VoidModClassicCharacterDB.point.totem_tool.p,
        VoidModClassicCharacterDB.point.totem_tool.x,
        VoidModClassicCharacterDB.point.totem_tool.y)
    SetInfoFrameStyle(self.voidTotemTool)

    self.voidTotemToolTotemFrame = {}

    self.voidTotemToolIcons = {}
    for index, totem in ipairs(totems) do
        self.voidTotemToolIcons[index] = CreateFrame("Button", nil, self.voidTotemTool,
            "SecureActionButtonTemplate")
        AddLeftButton(self.voidTotemToolIcons[index], totem[1].icon, totem[1].spellID, 40, "LEFT", index * 50 - 35, 0)

        -- 创建一个Frame来承载技能图标和技能名
        self.voidTotemToolTotemFrame[index] = CreateFrame("Frame", "TotemFrame" .. index, self.voidTotemTool,
            "BackdropTemplate")
        self:TotemFrame(self.voidTotemToolTotemFrame[index], totems[index], -75 + (index - 1) * 50, index)

        -- 鼠标悬停事件
        self.voidTotemToolIcons[index]:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.voidTotemToolIcons[index]:GetAttribute("spell"))
            GameTooltip:Show()
        end)

        self.voidTotemToolIcons[index]:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- 鼠标右击事件
        self.voidTotemToolIcons[index]:SetScript("OnMouseUp", function(s, button)
            if button == "RightButton" and self.voidTotemToolTotemFrame[index] then
                if totem_tool.button_frame[index] then
                    print("Right click Hide" .. index)
                    self.voidTotemToolTotemFrame[index]:Hide()
                    totem_tool.button_frame[index] = false
                else
                    print("Right click Show" .. index)
                    self.voidTotemToolTotemFrame[index]:Show()
                    totem_tool.button_frame[index] = true
                end
            end
        end)
    end
end

function VoidFrame:TotemFrame(frame, totem_spells, x, type_index)
    local len = #totem_spells
    frame:SetSize(45, len * 40 + 6)
    frame:SetPoint("BOTTOM", x, 60)
    SetInfoFrameStyle(frame)

    local icons = {}
    for index, totem in ipairs(totem_spells) do
        -- icons[index] = frame:CreateTexture()
        -- AddIconBottom(icons[index], totem.icon, 34, 0, (index - 1) * 40 + 5)
        icons[index] = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        AddLeftButton(icons[index], totem.icon, totem.spellID, 34, "BOTTOM", 0, (index - 1) * 40 + 5)

        icons[index]:SetScript("OnMouseUp", function(s, button)
            if button == "RightButton" then
                self.voidTotemToolIcons[type_index]:SetNormalTexture(totem.icon)
                self.voidTotemToolIcons[type_index]:SetAttribute("spell", totem.spellID) -- 设置要施放的技能名
                for index, value in ipairs(self.voidTotemToolTotemFrame) do
                    value:Hide()
                end
                totem_tool.button_frame = { false, false, false, false }
            end
        end)

        -- 鼠标悬停事件
        icons[index]:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(totem.spellID)
            GameTooltip:Show()
        end)

        icons[index]:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    if totem_tool.button_frame[type_index] then
        frame:Show()
    else
        frame:Hide()
    end
end

function VoidFrame:Void_CreateTotemTool()
    self:CreateTotemToolFrame()
    MovableDisplay(self.voidTotemTool)
    MovableFrameStop(self.voidTotemTool, VoidModClassicCharacterDB.point.totem_tool, totem_tool.up)
end
