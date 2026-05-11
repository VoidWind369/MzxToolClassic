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
    -- 初始化位置
    VoidModClassicCharacterDB.point.totem_tool = VoidModClassicCharacterDB.point.totem_tool or {
        p = totem_tool.up.p,
        x = totem_tool.up.x,
        y = totem_tool.up.y,
    }
    local point = VoidModClassicCharacterDB.point.totem_tool
    -- 加载图腾配置
    VoidModClassicCharacterDB.totem.default_btn = VoidModClassicCharacterDB.totem.default_btn or {}

    -- 创建主框体
    self.voidTotemTool = CreateFrame("Frame", "TotemTool", UIParent, "BackdropTemplate")
    self.voidTotemTool:SetSize(220, 60)
    self.voidTotemTool:SetPoint(point.p, point.x, point.y)
    SetInfoFrameStyle(self.voidTotemTool)

    self.voidTotemToolIcons = {}
    for index, totem in ipairs(totems) do
        if not totem[1] then
            totem[1] = {
                icon = totem_tool.default_btn[index].icon,
                spellID = totem_tool.default_btn[index].spell_id,
                name = totem_tool.default_btn[index].name
            }
        end
        -- 初始化保存的图腾
        local db = VoidModClassicCharacterDB.totem.default_btn[index] or {
            icon = totem[1].icon,
            spellID = totem[1].spellID,
            name = totem[1].name
        }

        -- 创建主框体上的图标
        local icon = CreateFrame("Button", nil, self.voidTotemTool, "SecureActionButtonTemplate")
        icon.bg = CreateFrame("Frame", nil, self.voidTotemTool, "BackdropTemplate")
        -- 添加边框
        SetButtonFrameStyle(icon.bg, 46, 46, "LEFT", index * 50 - 38, 0)

        -- 加载保存的图腾按钮
        AddLeftButton(icon, db.icon, db.spellID, 36, "LEFT", index * 50 - 33, 0)
        MzxDebug("加载图腾", db.spellID, db.name)

        -- 创建每系图腾的框体
        icon.totem_frame = CreateFrame("Frame", "TotemFrame" .. index, icon, "BackdropTemplate")
        icon.totem_frame.tex = icon.totem_frame:CreateTexture()

        -- 创建用于战斗显示的遮罩
        icon.totem_frame.blocker = CreateFrame("Frame", nil, icon.totem_frame)
        self:TotemFrame(icon.totem_frame, totem, index) -- Start blocking (popup starts hidden)

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

        -- 鼠标离开事件
        icon:SetScript("OnLeave", function(s)
            GameTooltip:Hide()
            s.bg:SetBackdropColor(0.8, 0, 0.7, 0.8)
            s.bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
        end)

        -- 鼠标右击事件
        icon:SetScript("OnMouseUp", function(s, button)
            if button == "RightButton" and s.totem_frame then
                if totem_tool.button_frame[index] then
                    -- s.totem_frame:Hide()
                    totem_tool.button_frame[index] = false
                    HideTotemFrame(s.totem_frame)
                else
                    -- s.totem_frame:Show()
                    totem_tool.button_frame[index] = true
                    ShowTotemFrame(s.totem_frame)
                end
            end
        end)
        self.voidTotemToolIcons[index] = icon
    end
end

-- 四系图腾列表框体
function VoidFrame:TotemFrame(frame, totem_spells, type_index)
    local len = #totem_spells
    frame:SetSize(45, len * 40 + 6)
    frame:SetPoint("BOTTOM", 0, 45)
    SetInfoFrameStyle(frame)
    -- SetInfoTextureStyle(frame.tex)
    frame.blocker:SetAllPoints(frame)
    frame.blocker:SetFrameLevel(frame:GetFrameLevel() + 100) -- Above all buttons
    frame.blocker:EnableMouse(true)                          -- Start blocking (popup starts hidden)

    frame.icons = {}
    for index, totem in ipairs(totem_spells) do
        -- icons[index] = frame:CreateTexture()
        -- AddIconBottom(icons[index], totem.icon, 34, 0, (index - 1) * 40 + 5)
        local icon = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        icon.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        -- 添加边框
        SetButtonFrameStyle(icon.bg, 43, 43, "BOTTOM", 0, (index - 1) * 44 + 1)
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
                    name = totem.name
                }
                for index, value in ipairs(self.voidTotemToolIcons) do
                    -- value.totem_frame:Hide()
                    value.totem_frame:SetAlpha(0)
                    HideTotemFrame(value.totem_frame)
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
        -- icon:EnableMouse(false)
        frame.icons[index] = icon
    end

    -- frame:SetAlpha(0)
    -- frame:Show()

    if totem_tool.button_frame[type_index] then
        frame:Show()
        frame:SetAlpha(1)
    else
        frame:Hide()
        frame:SetAlpha(0)
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

function ShowTotemFrame(frame)
    if not InCombatLockdown() then
        frame:Show()
        frame:EnableMouse(true)
        for _, btn in ipairs(frame.icons or {}) do
            btn:EnableMouse(true)
        end
    end
    frame:SetAlpha(1)
    if frame.blocker then
        frame.blocker:EnableMouse(false) -- 允许点击穿透到按钮
    end
end

function HideTotemFrame(frame)
    if InCombatLockdown() then
        frame:SetAlpha(0)
        if frame.blocker then
            frame.blocker:EnableMouse(true) -- 阻止隐藏弹出窗口的点击
        end
    else
        frame:EnableMouse(false)
        for _, btn in ipairs(frame.icons or {}) do
            btn:EnableMouse(false)
        end
        frame:Hide()
        if frame.blocker then
            frame.blocker:EnableMouse(true)
        end
    end
end

function VoidFrame:TotemRegenDisabled()
    MzxDebug("图腾工具进入战斗")
    for elem, container in pairs(self.voidTotemToolIcons) do
        if not container.totem_frame:IsShown() then
            container.totem_frame:Show()
            container.totem_frame:SetAlpha(0)
        end
        -- Ensure mouse is enabled on all buttons (may have been disabled from HidePopup)
        container.totem_frame:EnableMouse(true)
        for _, btn in ipairs(container.totem_frame.icons or {}) do
            btn:EnableMouse(true)
        end
        -- Toggle blocker based on popup visibility
        if container.totem_frame.blocker then
            if not totem_tool.button_frame[elem] then
                container.totem_frame.blocker:EnableMouse(true)
            else
                container.totem_frame.blocker:EnableMouse(false)
            end
        end
    end
end

function VoidFrame:TotemRegenEnabled()
    MzxDebug("图腾工具离开战斗")
    for elem, container in pairs(self.voidTotemToolIcons) do
        if not totem_tool.button_frame[elem] then
            container.totem_frame:EnableMouse(false)
            for _, btn in ipairs(container.totem_frame.icons or {}) do
                btn:EnableMouse(false)
            end
            container.totem_frame:Hide()
            if container.totem_frame.blocker then
                container.totem_frame.blocker:EnableMouse(true)
            end
        end
    end
end
