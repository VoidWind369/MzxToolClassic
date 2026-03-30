local totem_tool = {
    up = {
        p = "CENTER",
        x = 0,
        y = -28
    },
    button_frame = {
        false, false, false, false
    },
    default_btn = {
        { icon = 136098, spell_id = 8071 },
        { icon = 135825, spell_id = 3599 },
        { icon = 135127, spell_id = 5394 },
        { icon = 136114, spell_id = 8512 }
    }
}

-- # Api接口
function GetTotems()
    local totems = { {}, {}, {}, {} }

    local totem_map = {
        earth = { "石肤图腾", "石爪图腾", "土元素图腾", "大地之力图腾", "地缚图腾", "战栗图腾" },
        fire = { "灼热图腾", "熔岩图腾", "火元素图腾", "火焰新星图腾", "火舌图腾", "抗寒图腾", "天怒图腾" },
        water = { "治疗之泉图腾", "法力之泉图腾", "清毒图腾", "祛病图腾", "抗火图腾" },
        air = { "空气之怒图腾", "风怒图腾", "风之优雅图腾", "风墙图腾", "宁静之风图腾", "根基图腾", "自然抗性图腾", "岗哨图腾" },
    }

    local spells = {}
    for slot = 1, 500 do
        local spellType, id = GetSpellBookItemInfo(slot, "spell")
        if not id then
            MzxDebug("加载", slot - 1, "法术")
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

--- # Api打包
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

--- 创建图腾收纳面板
function VoidFrame:CreateTotemToolFrame(totems)
    VoidModClassicCharacterDB.point.totem_tool = VoidModClassicCharacterDB.point.totem_tool or {
        p = totem_tool.up.p,
        x = totem_tool.up.x,
        y = totem_tool.up.y,
    }
    -- 加载图腾配置
    VoidModClassicCharacterDB.totem.default_btn = VoidModClassicCharacterDB.totem.default_btn or {}

    self.voidTotemTool = CreateFrame("Frame", "TotemTool", UIParent, "BackdropTemplate")
    self.voidTotemTool:SetSize(220, 60)
    self.voidTotemTool:SetPoint(VoidModClassicCharacterDB.point.totem_tool.p,
        VoidModClassicCharacterDB.point.totem_tool.x,
        VoidModClassicCharacterDB.point.totem_tool.y)
    SetInfoFrameStyle(self.voidTotemTool)

    self.voidTotemToolBg = {}
    self.voidTotemToolIcons = {}
    for index, totem in ipairs(totems) do
        -- 初始化
        local db = VoidModClassicCharacterDB.totem.default_btn[index] or {
            icon = totem_tool.default_btn[index].icon,
            spellID = totem_tool.default_btn[index].spell_id,
            name = totem_tool.default_btn[index].name
        }

        -- local icon_bg = CreateFrame("Frame", nil, self.voidTotemTool, "BackdropTemplate")
        local icon = CreateFrame("Button", nil, self.voidTotemTool, "SecureActionButtonTemplate")
        icon.bg = CreateFrame("Frame", nil, self.voidTotemTool, "BackdropTemplate")
        -- 添加边框
        icon.bg:SetSize(46, 46)
        icon.bg:SetPoint("LEFT", index * 50 - 38, 0)
        SetButtonFrameStyle(icon.bg)

        -- 加载保存的图腾按钮
        AddLeftButton(icon, db.icon, db.spellID, 36, "LEFT", index * 50 - 33, 0)
        MzxDebug("加载图腾", db.spellID, db.name)

        icon.totem_frame = CreateFrame("Frame", "TotemFrame" .. index, icon, "SecureHandlerStateTemplate")
        -- 注册右键显示/隐藏状态
        -- RegisterStateDriver(icon.totem_frame, "visibility", "[button:2] show; hide")
        icon.totem_frame.tex = icon.totem_frame:CreateTexture()

        -- 创建一个图腾选择Frame
        -- self.voidTotemToolTotemFrame[index] = CreateFrame("Frame", "TotemFrame" .. index, self.voidTotemTool,
        --     "BackdropTemplate")

        -- totem_frame.bg = CreateFrame("Frame", "TotemFrame" .. index, totem_frame, "BackdropTemplate")
        self:TotemFrame(icon.totem_frame, totem, -75 + (index - 1) * 50, index) -- Start blocking (popup starts hidden)

        -- 鼠标悬停事件
        icon:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.voidTotemToolIcons[index]:GetAttribute("spell"))
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cFF00FF00鼠标左键|r释放图腾", 0.9, 0.9, 0.9)
            GameTooltip:AddLine("|cFF00FF00鼠标右键|r打开该系图腾栏", 0.9, 0.9, 0.9)
            GameTooltip:Show()
            s.bg:SetBackdropColor(1, 0.8, 0.1, 0.8)
            s.bg:SetBackdropBorderColor(0.9, 0.9, 0.9, 1)
        end)

        icon:SetScript("OnLeave", function(s)
            GameTooltip:Hide()
            s.bg:SetBackdropColor(0.8, 0, 0.7, 0.8)
            s.bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
        end)

        -- 鼠标右击事件
        icon:SetScript("OnMouseUp", function(s, button)
            if button == "RightButton" and s.totem_frame then
                if totem_tool.button_frame[index] then
                    s.totem_frame:Hide()
                    totem_tool.button_frame[index] = false
                else
                    s.totem_frame:Show()
                    totem_tool.button_frame[index] = true
                end
            end
        end)
        self.voidTotemToolIcons[index] = icon
    end
end

-- 图腾列表
function VoidFrame:TotemFrame(frame, totem_spells, x, type_index)
    local len = #totem_spells
    frame:SetSize(45, len * 40 + 6)
    frame:SetPoint("BOTTOM", 0, 45)
    SetInfoTextureStyle(frame.tex)

    for index, totem in ipairs(totem_spells) do
        -- icons[index] = frame:CreateTexture()
        -- AddIconBottom(icons[index], totem.icon, 34, 0, (index - 1) * 40 + 5)
        local icon = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        icon.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        -- 添加边框
        icon.bg:SetSize(43, 43)
        icon.bg:SetPoint("BOTTOM", 0, (index - 1) * 44 + 1)
        SetButtonFrameStyle(icon.bg)
        AddLeftButton(icon, totem.icon, totem.spellID, 34, "BOTTOM", 0, (index - 1) * 44 + 5)

        -- 右键设置图标
        icon:SetScript("OnMouseUp", function(s, button)
            if button == "RightButton" then
                self.voidTotemToolIcons[type_index]:SetNormalTexture(totem.icon)
                self.voidTotemToolIcons[type_index]:SetAttribute("spell", totem.spellID)
                -- 保存图腾设置
                VoidModClassicCharacterDB.totem.default_btn[type_index] = {
                    icon = totem.icon,
                    spellID = totem.spellID,
                    name =
                        totem.name
                }
                for index, value in ipairs(self.voidTotemToolIcons) do
                    value.totem_frame:Hide()
                end
                totem_tool.button_frame = { false, false, false, false }
            end
        end)

        -- 鼠标悬停事件
        icon:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(totem.spellID)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cFF00FF00鼠标左键|r释放图腾", 0.9, 0.9, 0.9)
            GameTooltip:AddLine("|cFF00FF00鼠标右键|r设置为常用", 0.9, 0.9, 0.9)
            GameTooltip:Show()
            s.bg:SetBackdropColor(1, 0.8, 0.1, 0.8)
            s.bg:SetBackdropBorderColor(0.9, 0.9, 0.9, 1)
        end)

        icon:SetScript("OnLeave", function(s)
            GameTooltip:Hide()
            s.bg:SetBackdropColor(0.8, 0, 0.7, 0.8)
            s.bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
        end)
    end

    if totem_tool.button_frame[type_index] then
        frame:Show()
    else
        frame:Hide()
    end
end

function VoidFrame:Void_CreateTotemTool()
    local totems = nil
    while (true) do
        local t = GetTotems() -- 用 pcall 捕获错误
        if t then
            totems = t
            break
        end
    end
    self:CreateTotemToolFrame(totems)
    MovableDisplay(self.voidTotemTool)
    MovableFrameStop(self.voidTotemTool, VoidModClassicCharacterDB.point.totem_tool, totem_tool.up)
end
