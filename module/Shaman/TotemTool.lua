-- ============================================================================
-- 模块：萨满图腾收纳工具 (TotemTool)
-- ============================================================================
-- 职责：
--   1. 扫描玩家法术书，按系（土/火/水/风）分类收录已学会的图腾法术；
--   2. 创建主图标栏（4 系，每系一个可快捷释放的按钮）；
--   3. 右键点击主图标弹出该系全部图腾列表，可释放或设置为常用；
--   4. 战斗状态下自动显示/隐藏图腾框体（PLAYER_REGEN_DISABLED/ENABLED）。
--
-- 数据依赖：MzxShamanData.TotemTool（位于 module/Shaman/Data.lua）
-- UI 封装：MzxUIStyle（位于 commend/UIStyle.lua）
-- 数据持久化：MzxToolClassicCharacterDB.totem.default_btn[系索引]
-- ============================================================================

local ui = MzxUIStyle    -- UI 封装层快捷引用
local dt = MzxShamanData.TotemTool   -- 数据层快捷引用

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

    local totem_map = dt.totem_map

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
    -- 初始化位置数据
    MzxToolClassicCharacterDB.point.totem_tool = MzxToolClassicCharacterDB.point.totem_tool or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }
    local point = MzxToolClassicCharacterDB.point.totem_tool

    -- 初始化保存的图腾按钮设置
    MzxToolClassicCharacterDB.totem.default_btn = MzxToolClassicCharacterDB.totem.default_btn or {}

    -- 创建主框体（统一面板样式）
    local col_count = #totems
    self.voidTotemTool = ui.CreatePanel(
        UIParent,
        col_count * dt.panel_w_per_col + dt.panel_padding,
        dt.panel_h,
        point.p, point.x, point.y
    )

    self.voidTotemToolIcons = {}
    for index, totem in ipairs(totems) do
        if #totem > 0 then
            -- 读取该系已保存的常用图腾设置，无则取该系第一个法术作为默认
            local db = MzxToolClassicCharacterDB.totem.default_btn[index] or {
                icon = totem[1].icon,
                spellID = totem[1].spellID,
                name = totem[1].name,
            }

            -- 创建主图标按钮（统一样式，含悬停效果）
            local icon = ui.CreateIconButton(
                self.voidTotemTool,
                db.icon,
                db.spellID,
                dt.btn_size,
                "LEFT", index * dt.col_spacing - 33, 0,
                function(s, button)
                    -- 左键：由 SecureActionButtonTemplate 施放法术
                    -- 右键：打开该系图腾弹出列表
                    if button == "RightButton" then
                        if totem_state.button_frame[index] then
                            -- 已弹出：关闭全部弹出框
                            totem_state.button_frame = { false, false, false, false }
                            for _, value in ipairs(self.voidTotemToolIcons) do
                                ui.TogglePopup(value.totem_frame, false)
                            end
                        else
                            totem_state.button_frame[index] = true
                            ui.TogglePopup(icon.totem_frame, true)
                        end
                    end
                end
            )

            -- 创建每系图腾的弹出列表（统一样式）
            local popup = ui.CreatePopupList(
                icon,
                totem,
                #totem,
                function(item, s, button)
                    if InCombatLockdown() then
                        ui.ShowAlert(dt.text.combat_block)
                    else
                        if button == "RightButton" then
                            -- 设置为该系常用图腾
                            icon:SetNormalTexture(item.icon)
                            icon:SetAttribute("spell", item.spellID)
                            MzxToolClassicCharacterDB.totem.default_btn[index] = {
                                icon = item.icon,
                                spellID = item.spellID,
                                name = item.name,
                            }
                        end
                    end
                    -- 无论左右键，点击后均关闭弹出框并重置状态
                    totem_state.button_frame = { false, false, false, false }
                    for _, value in ipairs(self.voidTotemToolIcons) do
                        ui.TogglePopup(value.totem_frame, false)
                    end
                end
            )

            icon.totem_frame = popup
            self.voidTotemToolIcons[index] = icon
        end
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
    MovableFrameStop(self.voidTotemTool, MzxToolClassicCharacterDB.point.totem_tool, dt.up)
end
