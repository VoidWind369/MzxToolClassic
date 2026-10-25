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
-- UI 封装：MzxUIStyle（位于 commend/UIStyle.lua）
-- 数据持久化：MzxToolClassicCharacterDB.teleport.default_btn[类型索引]
-- ============================================================================

local ui = MzxUIStyle       -- UI 封装层快捷引用
local dt = MzxMageData.TeleportTool   -- 数据层快捷引用

-- 运行时状态（不持久化，仅在当前会话有效）
local teleport_state = {
    button_frame = { false, false },
}

-- ----------------------------------------------------------------------------
-- API 封装：扫描法术书，按类型返回已学会的传送/传送门法术表
-- 返回：teleport_types[1]=传送系列表, teleport_types[2]=传送门系列表
--       每个列表项为 SpellArgs 表
-- ----------------------------------------------------------------------------
function GetCitys()
    local teleport_types = {}
    local citys = dt.citys

    local spells = {}
    for slot = 1, 500 do
        local spellType, id = GetSpellBookItemInfo(slot, "spell")
        if not id then
            MzxDebug("加载", slot - 1, "法术")
            break
        end
        local name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(slot, "spell")
        subtext = C_Spell.GetSpellSubtext(spellID)

        -- 法师传送/传送门无重复等级，不需要最高级过滤
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
-- 创建传送门收纳主面板（统一样式）
-- @param teleport_types GetCitys() 返回的两类型法术表
-- ----------------------------------------------------------------------------
function MzxToolFrame:CreateTeleportToolFrame(teleport_types)
    -- 初始化位置数据
    MzxToolClassicCharacterDB.point.teleport_tool = MzxToolClassicCharacterDB.point.teleport_tool or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }
    local point = MzxToolClassicCharacterDB.point.teleport_tool

    -- 初始化保存的传送按钮设置
    MzxToolClassicCharacterDB.teleport.default_btn = MzxToolClassicCharacterDB.teleport.default_btn or {}

    -- 创建主框体（统一面板样式）
    local col_count = #teleport_types
    self.voidTeleportTool = ui.CreatePanel(
        UIParent,
        col_count * dt.panel_w_per_col + dt.panel_padding,
        dt.panel_h,
        point.p, point.x, point.y
    )

    self.voidTeleportToolIcons = {}
    for index, teleport_type in ipairs(teleport_types) do
        if #teleport_type > 0 then
            -- 读取该类型已保存的常用传送设置，无则取该类型第一个法术作为默认
            local db = MzxToolClassicCharacterDB.teleport.default_btn[index] or {
                icon = teleport_type[1].icon,
                spellID = teleport_type[1].spellID,
                name = teleport_type[1].name,
            }

            -- 创建主图标按钮（统一样式，含悬停效果）
            local icon = ui.CreateIconButton(
                self.voidTeleportTool,
                db.icon,
                db.spellID,
                dt.btn_size,
                "LEFT", index * dt.col_spacing - 33, 0,
                function(s, button)
                    -- 左键：由 SecureActionButtonTemplate 施放法术
                    -- 右键：打开该类型传送弹出列表
                    if button == "RightButton" then
                        if teleport_state.button_frame[index] then
                            -- 已弹出：关闭全部弹出框
                            teleport_state.button_frame = { false, false }
                            for _, value in ipairs(self.voidTeleportToolIcons) do
                                ui.TogglePopup(value.teleport_type_frame, false)
                            end
                        else
                            teleport_state.button_frame[index] = true
                            ui.TogglePopup(icon.teleport_type_frame, true)
                        end
                    end
                end
            )

            -- 创建每类型传送的弹出列表（统一样式）
            local popup = ui.CreatePopupList(
                icon,
                teleport_type,
                #teleport_type,
                function(item, s, button)
                    if InCombatLockdown() then
                        ui.ShowAlert(dt.text.combat_block)
                    else
                        if button == "RightButton" then
                            -- 设置为该类型常用传送
                            icon:SetNormalTexture(item.icon)
                            icon:SetAttribute("spell", item.spellID)
                            MzxToolClassicCharacterDB.teleport.default_btn[index] = {
                                icon = item.icon,
                                spellID = item.spellID,
                                name = item.name,
                            }
                        end
                    end
                    -- 无论左右键，点击后均关闭弹出框并重置状态
                    teleport_state.button_frame = { false, false }
                    for _, value in ipairs(self.voidTeleportToolIcons) do
                        ui.TogglePopup(value.teleport_type_frame, false)
                    end
                end
            )

            icon.teleport_type_frame = popup
            self.voidTeleportToolIcons[index] = icon
        end
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
    MovableFrameStop(self.voidTeleportTool, MzxToolClassicCharacterDB.point.teleport_tool, dt.up)
end

-- ----------------------------------------------------------------------------
-- Todo：刷新传送工具（预留）
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_UpdateTeleportTool()
    local teleport_types = GetCitys()
    if #teleport_types < 1 then
        return
    end
end
