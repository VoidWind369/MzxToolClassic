-- ============================================================================
-- 模块：萨满图腾收纳工具 (TotemTool)
-- ============================================================================
-- 职责：
--   1. 扫描玩家法术书，按系（土/火/水/风）分类收录已学会的图腾法术；
--   2. 创建主图标栏（4 系，每系一个可快捷释放的按钮）；
--   3. 右键点击主图标弹出该系全部图腾列表，可释放或设置为常用；
--   4. 战斗状态下自动显示/隐藏图腾框体（PLAYER_REGEN_DISABLED/ENABLED）。
--
-- 数据依赖：MzxShamanData.TotemTool（位于 module/Shaman/Data/ShamanData.lua）
-- 运行时状态：totem_state.button_frame[系索引] 记录该系弹出列表是否展开
-- 数据持久化：MzxToolClassicCharacterDB.totem.default_btn[系索引]
-- ============================================================================

-- 运行时状态（不持久化，仅在当前会话有效）
local totem_state = {
    button_frame = { false, false, false, false },
}

-- ----------------------------------------------------------------------------
-- API 封装：扫描法术书，按系返回已学会的图腾法术表
-- 返回：totems[1]=土系列表, totems[2]=火系列表, totems[3]=水系列表, totems[4]=气系列表
--       每个列表项为 TotemArgs 表；系内按法术等级降序排列（最高级在前）
-- ----------------------------------------------------------------------------
function GetTotems()
    local totems = {}

    -- 从数据层读取四系图腾法术名映射，避免硬编码散落在 UI 逻辑中
    local totem_map = MzxShamanData.TotemTool.totem_map

    local spells = {}
    for slot = 1, 500 do
        local spellType, id = GetSpellBookItemInfo(slot, "spell")
        if not id then
            MzxDebug("加载", slot - 1, "法术")
            break
        end
        local name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(slot, "spell")
        subtext = C_Spell.GetSpellSubtext(spellID)

        -- 同名法术保留最高等级
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

    -- 按系归类
    for key, spell in pairs(spells) do
        for index, value in ipairs(totem_map.earth) do
            if spell.name == value then
                totems[1] = totems[1] or {}
                table.insert(totems[1], spell)
            end
        end
        for index, value in ipairs(totem_map.fire) do
            if spell.name == value then
                totems[2] = totems[2] or {}
                table.insert(totems[2], spell)
            end
        end
        for index, value in ipairs(totem_map.water) do
            if spell.name == value then
                totems[3] = totems[3] or {}
                table.insert(totems[3], spell)
            end
        end
        for index, value in ipairs(totem_map.air) do
            if spell.name == value then
                totems[4] = totems[4] or {}
                table.insert(totems[4], spell)
            end
        end
    end

    return totems
end

-- ----------------------------------------------------------------------------
-- API 打包：构建图腾参数表
-- ----------------------------------------------------------------------------
function TotemArgs(name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon)
    return {
        name        = name,
        subtext     = subtext,
        icon        = icon,
        castTime    = castTime,
        minRange    = minRange,
        maxRange    = maxRange,
        spellID     = spellID,
        originalIcon = originalIcon,
    }
end

-- ----------------------------------------------------------------------------
-- 创建图腾收纳主面板
-- @param totems GetTotems() 返回的四系法术表
-- ----------------------------------------------------------------------------
function MzxToolFrame:CreateTotemToolFrame(totems)
    local dt = MzxShamanData.TotemTool   -- 数据层快捷引用

    -- 初始化位置数据
    MzxToolClassicCharacterDB.point.totem_tool = MzxToolClassicCharacterDB.point.totem_tool or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }
    local point = MzxToolClassicCharacterDB.point.totem_tool

    -- 初始化保存的图腾按钮设置
    MzxToolClassicCharacterDB.totem.default_btn = MzxToolClassicCharacterDB.totem.default_btn or {}

    -- 创建主框体
    local col_count = #totems
    self.voidTotemTool = CreateFrame("Frame", "TotemTool", UIParent, "BackdropTemplate")
    self.voidTotemTool:SetSize(col_count * dt.panel_w_per_col + dt.panel_padding, dt.panel_h)
    self.voidTotemTool:SetPoint(point.p, point.x, point.y)
    SetInfoFrameStyle(self.voidTotemTool)

    self.voidTotemToolIcons = {}
    for index, totem in ipairs(totems) do
        if #totem > 0 then
            -- 读取该系已保存的常用图腾设置，无则取该系第一个法术作为默认
            local db = MzxToolClassicCharacterDB.totem.default_btn[index] or {
                icon = totem[1].icon,
                spellID = totem[1].spellID,
                name = totem[1].name,
            }

            -- 创建主图标按钮（安全动作按钮，可直接绑定法术释放）
            local icon = CreateFrame("Button", nil, self.voidTotemTool, "SecureActionButtonTemplate")
            icon.bg = CreateFrame("Frame", nil, self.voidTotemTool, "BackdropTemplate")
            SetButtonFrameStyle(icon.bg, dt.btn_bg_size, dt.btn_bg_size, "LEFT", index * dt.col_spacing - 38, 0)

            -- 加载图标与法术绑定
            AddLeftButton(icon, db.icon, db.spellID, dt.btn_size, "LEFT", index * dt.col_spacing - 33, 0)
            MzxDebug("加载图腾", db.spellID, db.name)

            -- 创建每系图腾的弹出框体
            icon.totem_frame = CreateFrame("Frame", "TotemFrame" .. index, icon, "BackdropTemplate")
            icon.totem_frame.tex = icon.totem_frame:CreateTexture()

            -- 创建战斗显示遮罩（默认阻挡点击，弹出时放行）
            icon.totem_frame.blocker = CreateFrame("Frame", nil, icon.totem_frame)
            self:TotemFrame(icon.totem_frame, totem, index) -- 初始化弹出列表（popup 起始隐藏）

            -- ================= 鼠标事件：主图标 =================

            -- 悬停：显示法术提示，高亮背景
            icon:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.voidTotemToolIcons[index]:GetAttribute("spell"))
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(dt.text.left_click, 0.9, 0.9, 0.9)
                GameTooltip:AddLine(dt.text.right_click_popup, 0.9, 0.9, 0.9)
                GameTooltip:Show()
                s.bg:SetBackdropColor(unpack(dt.Color.bg_hover))
                s.bg:SetBackdropBorderColor(unpack(dt.Color.border_hover))
            end)

            -- 离开：隐藏提示，恢复背景
            icon:SetScript("OnLeave", function(s)
                GameTooltip:Hide()
                s.bg:SetBackdropColor(unpack(dt.Color.bg_default))
                s.bg:SetBackdropBorderColor(unpack(dt.Color.border_default))
            end)

            -- 右键：打开该系图腾弹出列表；左键：直接释放常用图腾（由 SecureActionButtonTemplate 处理）
            icon:SetScript("OnMouseUp", function(s, button)
                if totem_state.button_frame[index] then
                    -- 已弹出：关闭全部弹出框
                    totem_state.button_frame = { false, false, false, false }
                    for _, value in ipairs(self.voidTotemToolIcons) do
                        HideFrame(value.totem_frame)
                    end
                else
                    if button == "RightButton" and s.totem_frame then
                        totem_state.button_frame[index] = true
                        ShowFrame(s.totem_frame)
                    end
                end
            end)

            self.voidTotemToolIcons[index] = icon
        end
    end
end

-- ----------------------------------------------------------------------------
-- 创建四系图腾弹出列表框体（右键主图标后展开）
-- @param frame        弹出框体
-- @param totem_spells 该系下的图腾法术表
-- @param type_index   系索引（1=土,2=火,3=水,4=气）
-- ----------------------------------------------------------------------------
function MzxToolFrame:TotemFrame(frame, totem_spells, type_index)
    local dt = MzxShamanData.TotemTool
    local len = #totem_spells

    frame:SetSize(dt.popup_w, len * dt.popup_row_h + 6)
    frame:SetPoint("BOTTOM", 0, 45)
    SetInfoFrameStyle(frame)
    frame.blocker:SetAllPoints(frame)
    frame.blocker:SetFrameLevel(frame:GetFrameLevel() + 100) -- 位于所有按钮之上，阻挡点击
    frame.blocker:EnableMouse(true)                           -- 起始状态：阻挡，popup 隐藏

    frame.icons = {}
    for index, totem in ipairs(totem_spells) do
        -- 创建系内单个图腾按钮
        local icon = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        icon.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        SetButtonFrameStyle(icon.bg, dt.popup_btn_bg, dt.popup_btn_bg, "BOTTOM", 0, (index - 1) * dt.popup_row_spacing + 1)
        AddLeftButton(icon, totem.icon, totem.spellID, dt.popup_btn_size, "BOTTOM", 0, (index - 1) * dt.popup_row_spacing + 5)

        -- 右键：设置为该系常用图腾，并保存到角色数据
        icon:SetScript("OnMouseUp", function(s, button)
            if InCombatLockdown() then
                ShowSimpleAlert(dt.text.combat_block)
            else
                if button == "RightButton" then
                    -- 更新主图标图标与绑定法术
                    self.voidTotemToolIcons[type_index]:SetNormalTexture(totem.icon)
                    self.voidTotemToolIcons[type_index]:SetAttribute("spell", totem.spellID)
                    -- 持久化保存
                    MzxToolClassicCharacterDB.totem.default_btn[type_index] = {
                        icon = totem.icon,
                        spellID = totem.spellID,
                        name = totem.name,
                    }
                    -- 关闭全部弹出框
                    for index2, value in ipairs(self.voidTotemToolIcons) do
                        value.totem_frame:SetAlpha(0)
                        HideFrame(value.totem_frame)
                    end
                end
                -- 无论左右键，点击后均关闭弹出框并重置按钮状态
                totem_state.button_frame = { false, false, false, false }
                for _, value in ipairs(self.voidTotemToolIcons) do
                    HideFrame(value.totem_frame)
                end
            end
        end)

        -- 悬停：显示法术提示，高亮背景
        icon:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(totem.spellID)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(dt.text.left_click, 0.9, 0.9, 0.9)
            GameTooltip:AddLine(dt.text.right_click_set, 0.9, 0.9, 0.9)
            GameTooltip:Show()
            s.bg:SetBackdropColor(unpack(dt.Color.bg_hover))
            s.bg:SetBackdropBorderColor(unpack(dt.Color.border_hover))
        end)

        -- 离开：隐藏提示，恢复背景
        icon:SetScript("OnLeave", function(s)
            GameTooltip:Hide()
            s.bg:SetBackdropColor(unpack(dt.Color.bg_default))
            s.bg:SetBackdropBorderColor(unpack(dt.Color.border_default))
        end)

        frame.icons[index] = icon
    end

    -- 按运行时展开状态控制初始显示/隐藏
    if totem_state.button_frame[type_index] then
        frame:Show()
        frame:SetAlpha(1)
    else
        frame:Hide()
        frame:SetAlpha(0)
    end
end

-- ----------------------------------------------------------------------------
-- 进入战斗：显示所有图腾框体并启用鼠标
-- ----------------------------------------------------------------------------
function MzxToolFrame:TotemRegenDisabled()
    MzxDebug("图腾工具进入战斗")
    if not self.voidTotemToolIcons then
        return
    end
    for elem, container in pairs(self.voidTotemToolIcons) do
        if not container.totem_frame:IsShown() then
            container.totem_frame:Show()
            container.totem_frame:SetAlpha(0)
        end
        container.totem_frame:EnableMouse(true)
        for _, btn in ipairs(container.totem_frame.icons or {}) do
            btn:EnableMouse(true)
        end
        if container.totem_frame.blocker then
            if not totem_state.button_frame[elem] then
                container.totem_frame.blocker:EnableMouse(true)
            else
                container.totem_frame.blocker:EnableMouse(false)
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- 离开战斗：隐藏未展开的图腾框体并禁用鼠标
-- ----------------------------------------------------------------------------
function MzxToolFrame:TotemRegenEnabled()
    MzxDebug("图腾工具离开战斗")
    if not self.voidTotemToolIcons then
        return
    end
    for elem, container in pairs(self.voidTotemToolIcons) do
        if not totem_state.button_frame[elem] then
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

-- ----------------------------------------------------------------------------
-- 模块入口：创建图腾工具界面（仅在 PLAYER_LOGIN 且 TotemTool 开启时调用）
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateTotemTool()
    local totems = GetTotems()
    if #totems < 1 then
        return
    end
    self:CreateTotemToolFrame(totems)
    MovableDisplay(self.voidTotemTool)
    MovableFrameStop(self.voidTotemTool, MzxToolClassicCharacterDB.point.totem_tool, MzxShamanData.TotemTool.up)
end
