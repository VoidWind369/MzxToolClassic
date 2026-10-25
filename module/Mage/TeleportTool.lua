-- ============================================================================
-- 模块：法师传送门工具 (TeleportTool)
-- ============================================================================
-- 职责：
--   1. 扫描玩家法术书，按类型（传送/传送门）分类收录已学会的城市法术；
--   2. 创建主图标栏（传送、传送门，每类一个可快捷释放的按钮）；
--   3. 右键点击主图标弹出该类型全部城市列表，可释放或设置为常用；
--   4. 战斗状态下自动显示/隐藏传送框体（PLAYER_REGEN_DISABLED/ENABLED）。
--
-- 数据依赖：MzxMageData.TeleportTool（位于 module/Mage/Data.lua）
-- 运行时状态：teleport_state.button_frame[类型索引] 记录该类型弹出列表是否展开
-- 数据持久化：MzxToolClassicCharacterDB.teleport.default_btn[类型索引]
-- ============================================================================

-- 运行时状态（不持久化，仅在当前会话有效）
local teleport_state = {
    button_frame = { false, false },
}

-- 颜色与字体数据层快捷引用（顶层，不属于 TeleportTool 子表）
local dt_color = MzxMageData.Color
local dt_font  = MzxMageData.Font

-- ----------------------------------------------------------------------------
-- API 封装：扫描法术书，按类型返回已学会的传送/传送门法术表
-- 返回：teleport_types[1]=传送系列表, teleport_types[2]=传送门系列表
--       每个列表项为 SpellArgs 表
-- ----------------------------------------------------------------------------
function GetCitys()
    local teleport_types = {}
    local citys = MzxMageData.TeleportTool.citys

    local spells = {}
    for slot = 1, 500 do
        local spellType, id = GetSpellBookItemInfo(slot, "spell")
        if not id then
            MzxDebug("加载", slot - 1, "法术")
            break
        end
        local name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(slot, "spell")
        subtext = C_Spell.GetSpellSubtext(spellID)

        -- 加载到 spells（法师传送/传送门无重复等级，不需要最高级过滤）
        spells[name] = SpellArgs(name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon)
    end

    -- 按类型归类：1=传送, 2=传送门
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

-- ----------------------------------------------------------------------------
-- 创建传送门收纳主面板
-- @param teleport_types GetCitys() 返回的两类型法术表
-- ----------------------------------------------------------------------------
function MzxToolFrame:CreateTeleportToolFrame(teleport_types)
    local dt = MzxMageData.TeleportTool   -- 数据层快捷引用

    -- 初始化位置数据
    MzxToolClassicCharacterDB.point.teleport_tool = MzxToolClassicCharacterDB.point.teleport_tool or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }
    local point = MzxToolClassicCharacterDB.point.teleport_tool

    -- 初始化保存的传送按钮设置
    MzxToolClassicCharacterDB.teleport.default_btn = MzxToolClassicCharacterDB.teleport.default_btn or {}

    -- 创建主框体
    local col_count = #teleport_types
    self.voidTeleportTool = CreateFrame("Frame", "TeleportTool", UIParent, "BackdropTemplate")
    self.voidTeleportTool:SetSize(col_count * dt.panel_w_per_col + dt.panel_padding, dt.panel_h)
    self.voidTeleportTool:SetPoint(point.p, point.x, point.y)
    SetInfoFrameStyle(self.voidTeleportTool)

    self.voidTeleportToolIcons = {}
    for index, teleport_type in ipairs(teleport_types) do
        if #teleport_type > 0 then
            -- 读取该类型已保存的常用传送设置，无则取该类型第一个法术作为默认
            local db = MzxToolClassicCharacterDB.teleport.default_btn[index] or {
                icon = teleport_type[1].icon,
                spellID = teleport_type[1].spellID,
                name = teleport_type[1].name,
            }

            -- 创建主图标按钮（安全动作按钮，可直接绑定法术释放）
            local icon = CreateFrame("Button", nil, self.voidTeleportTool, "SecureActionButtonTemplate")
            icon.bg = CreateFrame("Frame", nil, self.voidTeleportTool, "BackdropTemplate")
            SetButtonFrameStyle(icon.bg, dt.btn_bg_size, dt.btn_bg_size, "LEFT", index * dt.col_spacing - 38, 0)

            -- 加载图标与法术绑定
            AddLeftButton(icon, db.icon, db.spellID, dt.btn_size, "LEFT", index * dt.col_spacing - 33, 0)
            MzxDebug("加载传送技能", db.spellID, db.name)

            -- 创建每类型传送的弹出框体
            icon.teleport_type_frame = CreateFrame("Frame", "TeleportTypeFrame" .. index, icon, "BackdropTemplate")
            icon.teleport_type_frame.tex = icon.teleport_type_frame:CreateTexture()

            -- 创建战斗显示遮罩（默认阻挡点击，弹出时放行）
            icon.teleport_type_frame.blocker = CreateFrame("Frame", nil, icon.teleport_type_frame)
            self:TeleportTypeFrame(icon.teleport_type_frame, teleport_type, index) -- 初始化弹出列表（popup 起始隐藏）

            -- ================= 鼠标事件：主图标 =================

            -- 悬停：显示法术提示，高亮背景
            icon:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.voidTeleportToolIcons[index]:GetAttribute("spell"))
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(dt.text.left_click, 0.9, 0.9, 0.9)
                GameTooltip:AddLine(dt.text.right_click_popup, 0.9, 0.9, 0.9)
                GameTooltip:Show()
                s.bg:SetBackdropColor(unpack(dt_color.bg_hover))
                s.bg:SetBackdropBorderColor(unpack(dt_color.border_hover))
            end)

            -- 离开：隐藏提示，恢复背景
            icon:SetScript("OnLeave", function(s)
                GameTooltip:Hide()
                s.bg:SetBackdropColor(unpack(dt_color.bg_default))
                s.bg:SetBackdropBorderColor(unpack(dt_color.border_default))
            end)

            -- 右键：打开该类型传送弹出列表；左键：直接释放常用传送（由 SecureActionButtonTemplate 处理）
            icon:SetScript("OnMouseUp", function(s, button)
                if teleport_state.button_frame[index] then
                    -- 已弹出：关闭全部弹出框
                    teleport_state.button_frame = { false, false }
                    for _, value in ipairs(self.voidTeleportToolIcons) do
                        HideFrame(value.teleport_type_frame)
                    end
                else
                    if button == "RightButton" and s.teleport_type_frame then
                        teleport_state.button_frame[index] = true
                        ShowFrame(s.teleport_type_frame)
                    end
                end
            end)

            self.voidTeleportToolIcons[index] = icon
        end
    end
end

-- ----------------------------------------------------------------------------
-- 创建传送/传送门弹出列表框体（右键主图标后展开）
-- @param frame        弹出框体
-- @param spells       该类型下的传送法术表
-- @param type_index   类型索引（1=传送, 2=传送门）
-- ----------------------------------------------------------------------------
function MzxToolFrame:TeleportTypeFrame(frame, spells, type_index)
    local dt = MzxMageData.TeleportTool
    local len = #spells

    frame:SetSize(dt.popup_w, len * dt.popup_row_h + 6)
    frame:SetPoint("BOTTOM", 0, 45)
    SetInfoFrameStyle(frame)
    frame.blocker:SetAllPoints(frame)
    frame.blocker:SetFrameLevel(frame:GetFrameLevel() + 100) -- 位于所有按钮之上，阻挡点击
    frame.blocker:EnableMouse(true)                           -- 起始状态：阻挡，popup 隐藏

    frame.icons = {}
    for index, spell in ipairs(spells) do
        -- 创建类型内单个传送按钮
        local icon = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        icon.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        SetButtonFrameStyle(icon.bg, dt.popup_btn_bg, dt.popup_btn_bg, "BOTTOM", 0, (index - 1) * dt.popup_row_spacing + 1)
        AddLeftButton(icon, spell.icon, spell.spellID, dt.popup_btn_size, "BOTTOM", 0, (index - 1) * dt.popup_row_spacing + 5)

        -- 右键：设置为该类型常用传送，并保存到角色数据
        icon:SetScript("OnMouseUp", function(s, button)
            if InCombatLockdown() then
                ShowSimpleAlert(dt.text.combat_block)
            else
                if button == "RightButton" then
                    -- 更新主图标图标与绑定法术
                    self.voidTeleportToolIcons[type_index]:SetNormalTexture(spell.icon)
                    self.voidTeleportToolIcons[type_index]:SetAttribute("spell", spell.spellID)
                    -- 持久化保存
                    MzxToolClassicCharacterDB.teleport.default_btn[type_index] = {
                        icon = spell.icon,
                        spellID = spell.spellID,
                        name = spell.name,
                    }
                    -- 关闭全部弹出框
                    for index2, value in ipairs(self.voidTeleportToolIcons) do
                        value.teleport_type_frame:SetAlpha(0)
                        HideFrame(value.teleport_type_frame)
                    end
                end
                -- 无论左右键，点击后均关闭弹出框并重置按钮状态
                teleport_state.button_frame = { false, false }
                for _, value in ipairs(self.voidTeleportToolIcons) do
                    HideFrame(value.teleport_type_frame)
                end
            end
        end)

        -- 悬停：显示法术提示，高亮背景
        icon:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spell.spellID)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(dt.text.left_click, 0.9, 0.9, 0.9)
            GameTooltip:AddLine(dt.text.right_click_set, 0.9, 0.9, 0.9)
            GameTooltip:Show()
            s.bg:SetBackdropColor(unpack(dt_color.bg_hover))
            s.bg:SetBackdropBorderColor(unpack(dt_color.border_hover))
        end)

        -- 离开：隐藏提示，恢复背景
        icon:SetScript("OnLeave", function(s)
            GameTooltip:Hide()
            s.bg:SetBackdropColor(unpack(dt_color.bg_default))
            s.bg:SetBackdropBorderColor(unpack(dt_color.border_default))
        end)

        frame.icons[index] = icon
    end

    -- 按运行时展开状态控制初始显示/隐藏
    if teleport_state.button_frame[type_index] then
        frame:Show()
        frame:SetAlpha(1)
    else
        frame:Hide()
        frame:SetAlpha(0)
    end
end

-- ----------------------------------------------------------------------------
-- 进入战斗：显示所有传送框体并启用鼠标
-- ----------------------------------------------------------------------------
function MzxToolFrame:TeleportRegenDisabled()
    MzxDebug("传送进入战斗")
    if not self.voidTeleportToolIcons then
        return
    end
    for elem, container in pairs(self.voidTeleportToolIcons) do
        if not container.teleport_type_frame:IsShown() then
            container.teleport_type_frame:Show()
            container.teleport_type_frame:SetAlpha(0)
        end
        container.teleport_type_frame:EnableMouse(true)
        for _, btn in ipairs(container.teleport_type_frame.icons or {}) do
            btn:EnableMouse(true)
        end
        if container.teleport_type_frame.blocker then
            if not teleport_state.button_frame[elem] then
                container.teleport_type_frame.blocker:EnableMouse(true)
            else
                container.teleport_type_frame.blocker:EnableMouse(false)
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- 离开战斗：隐藏未展开的传送框体并禁用鼠标
-- ----------------------------------------------------------------------------
function MzxToolFrame:TeleportRegenEnabled()
    MzxDebug("传送工具离开战斗")
    if not self.voidTeleportToolIcons then
        return
    end
    for elem, container in pairs(self.voidTeleportToolIcons) do
        if not teleport_state.button_frame[elem] then
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

-- ----------------------------------------------------------------------------
-- 模块入口：创建传送工具界面（仅在 PLAYER_LOGIN 且 TeleportTool 开启时调用）
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateTeleportTool()
    local teleport_types = GetCitys()
    if #teleport_types < 1 then
        return
    end
    self:CreateTeleportToolFrame(teleport_types)
    MovableDisplay(self.voidTeleportTool)
    MovableFrameStop(self.voidTeleportTool, MzxToolClassicCharacterDB.point.teleport_tool, MzxMageData.TeleportTool.up)
end
