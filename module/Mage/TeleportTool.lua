-- ============================================
-- 法师传送工具
-- ============================================

local teleport_tool = {
    up = {
        p = "CENTER",
        x = 0,
        y = -28
    },
    button_frame = {
        false, false
    },
    default_btn = {
        { icon = 135764, spell_id = 49359 },
        { icon = 135749, spell_id = 49360 }
    }
}

-- # Api接口
function GetCitys()
    local teleport_types = {}
    local citys = { "奥格瑞玛", "雷霆崖", "幽暗城", "暴风城", "铁炉堡", "达纳苏斯", "斯通纳德", "塞拉摩", "沙塔斯" }

    local spells = {}
    for slot = 1, 500 do
        local spellType, id = GetSpellBookItemInfo(slot, "spell")
        if not id then
            MzxDebug("加载", slot - 1, "法术")
            break
        end
        local name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(slot, "spell")
        subtext = C_Spell.GetSpellSubtext(spellID)

        -- 加载到spells
        spells[name] = SpellArgs(name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon)
    end

    for key, spell in pairs(spells) do
        for index, value in ipairs(citys) do
            if spell.name == "传送：" .. value then
                teleport_types[1] = teleport_types[1] or {}
                table.insert(teleport_types[1], spell)
            end
            if spell.name == "传送门：" .. value then
                teleport_types[2] = teleport_types[2] or {}
                table.insert(teleport_types[2], spell)
            end
        end
    end

    return teleport_types
end

--- 创建收纳面板
--- types：传送或传送门
function MzxToolFrame:CreateTeleportToolFrame(teleport_types)
    -- 初始化位置
    MzxToolClassicCharacterDB.point.teleport_tool = MzxToolClassicCharacterDB.point.teleport_tool or {
        p = teleport_tool.up.p,
        x = teleport_tool.up.x,
        y = teleport_tool.up.y,
    }
    local point = MzxToolClassicCharacterDB.point.teleport_tool
    -- 加载图腾配置
    MzxToolClassicCharacterDB.teleport.default_btn = MzxToolClassicCharacterDB.teleport.default_btn or {}

    -- 创建主框体
    self.voidTeleportTool = CreateFrame("Frame", "TeleportTool", UIParent, "BackdropTemplate")
    self.voidTeleportTool:SetSize(#teleport_types * 50 + 20, 60)
    self.voidTeleportTool:SetPoint(point.p, point.x, point.y)
    SetInfoFrameStyle(self.voidTeleportTool)

    self.voidTeleportToolIcons = {}
    for index, teleport_type in ipairs(teleport_types) do
        if #teleport_type > 0 then
            -- 初始化保存
            local db = MzxToolClassicCharacterDB.teleport.default_btn[index] or {
                icon = teleport_type[1].icon,
                spellID = teleport_type[1].spellID,
                name = teleport_type[1].name
            }

            -- 创建主框体上的图标
            local icon = CreateFrame("Button", nil, self.voidTeleportTool, "SecureActionButtonTemplate")
            icon.bg = CreateFrame("Frame", nil, self.voidTeleportTool, "BackdropTemplate")
            -- 添加边框
            SetButtonFrameStyle(icon.bg, 46, 46, "LEFT", index * 50 - 38, 0)

            -- 加载保存的图腾按钮
            AddLeftButton(icon, db.icon, db.spellID, 36, "LEFT", index * 50 - 33, 0)
            MzxDebug("加载传送技能", db.spellID, db.name)

            -- 创建每系图腾的框体
            icon.teleport_type_frame = CreateFrame("Frame", "TeleportTypeFrame" .. index, icon, "BackdropTemplate")
            icon.teleport_type_frame.tex = icon.teleport_type_frame:CreateTexture()

            -- 创建用于战斗显示的遮罩
            icon.teleport_type_frame.blocker = CreateFrame("Frame", nil, icon.teleport_type_frame)
            self:TeleportTypeFrame(icon.teleport_type_frame, teleport_type, index) -- Start blocking (popup starts hidden)

            -- 鼠标悬停事件
            icon:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.voidTeleportToolIcons[index]:GetAttribute("spell"))
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cFF00FF00鼠标左键|r传送", 0.9, 0.9, 0.9)
                GameTooltip:AddLine("|cFF00FF00鼠标右键|r其他传送", 0.9, 0.9, 0.9)
                GameTooltip:Show()
                s.bg:SetBackdropColor(0, 0, 0, 0.2)
                s.bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.3)
            end)

            -- 鼠标离开事件
            icon:SetScript("OnLeave", function(s)
                GameTooltip:Hide()
                s.bg:SetBackdropColor(0, 0, 0, 0.6)
                s.bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
            end)

            -- 鼠标右击事件
            icon:SetScript("OnMouseUp", function(s, button)
                if teleport_tool.button_frame[index] then
                    teleport_tool.button_frame = { false, false }
                    for _, value in ipairs(self.voidTeleportToolIcons) do
                        HideFrame(value.teleport_type_frame)
                    end
                else
                    if button == "RightButton" and s.teleport_type_frame then
                        teleport_tool.button_frame[index] = true
                        ShowFrame(s.teleport_type_frame)
                    end
                end
            end)
            self.voidTeleportToolIcons[index] = icon
        end
    end
end

-- 列表框体
function MzxToolFrame:TeleportTypeFrame(frame, spells, type_index)
    local len = #spells
    frame:SetSize(45, len * 40 + 6)
    frame:SetPoint("BOTTOM", 0, 45)
    SetInfoFrameStyle(frame)
    -- SetInfoTextureStyle(frame.tex)
    frame.blocker:SetAllPoints(frame)
    frame.blocker:SetFrameLevel(frame:GetFrameLevel() + 100) -- Above all buttons
    frame.blocker:EnableMouse(true)                          -- Start blocking (popup starts hidden)

    frame.icons = {}
    for index, spell in ipairs(spells) do
        -- icons[index] = frame:CreateTexture()
        -- AddIconBottom(icons[index], totem.icon, 34, 0, (index - 1) * 40 + 5)
        local icon = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        icon.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        -- 添加边框
        SetButtonFrameStyle(icon.bg, 43, 43, "BOTTOM", 0, (index - 1) * 44 + 1)
        AddLeftButton(icon, spell.icon, spell.spellID, 34, "BOTTOM", 0, (index - 1) * 44 + 5)

        -- 右键设置图标
        icon:SetScript("OnMouseUp", function(s, button)
            if button == "RightButton" then
                if InCombatLockdown() then
                    ShowSimpleAlert(
                        "|CFF8845ECM|r|CFFA037E9z|r|CFFA435E8x|r：战斗中无法设置！")
                else
                    self.voidTeleportToolIcons[type_index]:SetNormalTexture(spell.icon)
                    self.voidTeleportToolIcons[type_index]:SetAttribute("spell", spell.spellID)
                    -- 保存图腾设置
                    MzxToolClassicCharacterDB.teleport.default_btn[type_index] = {
                        icon = spell.icon,
                        spellID = spell.spellID,
                        name = spell.name
                    }
                    for index, value in ipairs(self.voidTeleportToolIcons) do
                        value.teleport_type_frame:SetAlpha(0)
                        HideFrame(value.teleport_type_frame)
                    end
                end
            end
            -- 关闭框体
            teleport_tool.button_frame = { false, false }
            for _, value in ipairs(self.voidTeleportToolIcons) do
                HideFrame(value.teleport_type_frame)
            end
        end)

        -- 鼠标悬停事件
        icon:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spell.spellID)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cFF00FF00鼠标左键|r传送", 0.9, 0.9, 0.9)
            GameTooltip:AddLine("|cFF00FF00鼠标右键|r设置为常用", 0.9, 0.9, 0.9)
            GameTooltip:Show()
            -- s.bg:SetBackdropColor(1, 0.8, 0.1, 0.8)
            s.bg:SetBackdropColor(0, 0, 0, 0.2)
            s.bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.3)
        end)

        icon:SetScript("OnLeave", function(s)
            GameTooltip:Hide()
            s.bg:SetBackdropColor(0, 0, 0, 0.6)
            s.bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
        end)
        -- icon:EnableMouse(false)
        frame.icons[index] = icon
    end

    -- frame:SetAlpha(0)
    -- frame:Show()

    if teleport_tool.button_frame[type_index] then
        frame:Show()
        frame:SetAlpha(1)
    else
        frame:Hide()
        frame:SetAlpha(0)
    end
end

function MzxToolFrame:Void_CreateTeleportTool()
    local teleport_types = nil
    while (true) do
        local t = GetCitys() -- 用 pcall 捕获错误
        if t then
            teleport_types = t
            break
        end
    end
    if #teleport_types < 1 then
        return
    end
    self:CreateTeleportToolFrame(teleport_types)
    MovableDisplay(self.voidTeleportTool)
    MovableFrameStop(self.voidTeleportTool, MzxToolClassicCharacterDB.point.teleport_tool, teleport_tool.up)
end

function MzxToolFrame:TeleportRegenDisabled()
    MzxDebug("传送进入战斗")
    for elem, container in pairs(self.voidTeleportToolIcons) do
        if not container.teleport_type_frame:IsShown() then
            container.teleport_type_frame:Show()
            container.teleport_type_frame:SetAlpha(0)
        end
        -- Ensure mouse is enabled on all buttons (may have been disabled from HidePopup)
        container.teleport_type_frame:EnableMouse(true)
        for _, btn in ipairs(container.teleport_type_frame.icons or {}) do
            btn:EnableMouse(true)
        end
        -- Toggle blocker based on popup visibility
        if container.teleport_type_frame.blocker then
            if not teleport_tool.button_frame[elem] then
                container.teleport_type_frame.blocker:EnableMouse(true)
            else
                container.teleport_type_frame.blocker:EnableMouse(false)
            end
        end
    end
end

function MzxToolFrame:TeleportRegenEnabled()
    MzxDebug("图腾工具离开战斗")
    for elem, container in pairs(self.voidTeleportToolIcons) do
        if not teleport_tool.button_frame[elem] then
            container.teleport_type_frame:EnableMouse(false)
            for _, btn in ipairs(container.teleport_type_frame.icons or {}) do
                btn:EnableMouse(false)
            end
            container.teleport_type_frame:Hide()
            if container.teleport_type_frame.blocker then
                container.teleport_type_frame.blocker:EnableMouse(true)
            end
        end
    end
end
