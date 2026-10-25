-- ============================================================================
-- 模块：玩家属性面板 (PlayerInfo) —— 通用
-- ============================================================================
-- 职责：
--   1. 显示玩家主属性（力量/敏捷/耐力/智力/精神）与攻防属性（攻击强度/法术强度等）；
--   2. 显示七系抗性与移动速度；
--   3. 上下两个独立面板，支持拖动与双击居中。
--
-- 数据依赖：MzxCommonData.PlayerInfo（位于 module/Common/Data.lua）
-- UI 封装：MzxUIStyle（位于 commend/UIStyle.lua）
-- 数据持久化：MzxToolClassicCharacterDB.point.player_up / player_down
-- ============================================================================

local ui = MzxUIStyle      -- UI 封装层快捷引用
local dt = MzxCommonData.PlayerInfo   -- 数据层快捷引用

-- ----------------------------------------------------------------------------
-- 玩家信息获取（数据计算，不涉及 UI）
-- 返回：first_table, last_table
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_PlayerInfo()
    -- 主属性
    local strength = UnitStat("player", 1)  -- 力量
    local agility = UnitStat("player", 2)   -- 敏捷
    local stamina = UnitStat("player", 3)   -- 耐力
    local intellect = UnitStat("player", 4) -- 智力
    local spirit = UnitStat("player", 5)    -- 精神

    -------------------------------------------------------------------------
    -- 攻击强度
    local attackPowerBase, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = {
        name = "攻击强度",
        damage = attackPowerBase + posBuff + negBuff,    -- 攻击强度
        chance = GetCritChance(),                        -- 近战暴击
        rating = GetCombatRating(CR_HIT_MELEE),          -- 近战命中
        ratingBonus = GetCombatRatingBonus(CR_HIT_MELEE) -- 近战命中百分比
    }

    -- 法术强度
    local spellBonus = {
        name = "法术强度",
        damage = 9999,
        chance = 9999,
        rating = GetCombatRating(CR_HIT_SPELL),          -- 法术命中
        ratingBonus = GetCombatRatingBonus(CR_HIT_SPELL) -- 法术命中百分比
    }

    for school = 2, 7 do
        local damage = GetSpellBonusDamage(school) -- 法术强度
        local chance = GetSpellCritChance(school)  -- 法术暴击
        if damage < spellBonus.damage then
            spellBonus.damage = damage
        end
        if chance < spellBonus.chance then
            spellBonus.chance = chance
        end
    end

    -- 法术治疗
    local spellBonusHealing = {
        name = "治疗强度",
        damage = GetSpellBonusHealing(),
        chance = spellBonus.chance,
        rating = spellBonus.rating,
        ratingBonus = spellBonus.ratingBonus,
    }
    -------------------------------------------------------------------------
    local attribute = {
        name = "强度",
        damage = 0
    }
    for index, value in ipairs({ attackPower, spellBonus, spellBonusHealing }) do
        if value.damage > attribute.damage then
            attribute = value
        end
    end

    local haste = GetHaste()                        -- 急速

    local health = UnitHealth("player")             -- 生命值

    local _, physical = UnitResistance("player", 0) -- 护甲
    local _, holy = UnitResistance("player", 1)     -- 神圣
    local _, fire = UnitResistance("player", 2)     -- 火焰
    local _, nature = UnitResistance("player", 3)   -- 自然
    local _, frost = UnitResistance("player", 4)    -- 冰霜
    local _, shadow = UnitResistance("player", 5)   -- 暗影
    local _, arcane = UnitResistance("player", 6)   -- 奥数

    local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
    local speedPercent = (currentSpeed / 7) * 100 -- 7是基础奔跑速度

    local first_table = {
        { name = "|cFFC41E3A" .. attribute.name .. "|r", value = attribute.damage },
        { name = "|cFFC41E3A暴击几率|r", value = string.format(" %.2f%%", attribute.chance or 0) },
        { name = "|cFF3FC7EB命中等级|r", value = attribute.rating },
        { name = "|cFF3FC7EB命中几率|r", value = string.format(" %.2f%%", attribute.ratingBonus or 0) },
        { name = "|cFFCD7F32急速等级|r", value = string.format(" %.1f%%", haste or 0) },
        { name = "|cFFCD7F32移动速度|r", value = string.format(" %.1f%%", speedPercent or 0) },
    }

    local last_table = {
        { name = "|cFFFFFF66物理|r", value = physical },
        { name = "|cFFFFFF66神圣|r", value = holy },
        { name = "|cFFFF3300火焰|r", value = fire },
        { name = "|cFF00FF00自然|r", value = nature },
        { name = "|cFF00CCFF冰霜|r", value = frost },
        { name = "|cFF9933CC暗影|r", value = shadow },
        { name = "|cFFFF66FF奥数|r", value = arcane }
    }

    return first_table, last_table
end

-- ----------------------------------------------------------------------------
-- 创建上面板（主属性）
-- @param first first_table
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreatePlayerInfoFrame_UP(first)
    MzxToolClassicCharacterDB.point.player_up = MzxToolClassicCharacterDB.point.player_up or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }

    -- 主框体：统一面板样式
    self.voidPlayerInfo_UP = ui.CreatePanel(
        UIParent,
        dt.panel_w_up,
        #first * dt.row_h + dt.label_padding * 2,
        MzxToolClassicCharacterDB.point.player_up.p,
        MzxToolClassicCharacterDB.point.player_up.x,
        MzxToolClassicCharacterDB.point.player_up.y
    )

    self.voidPlayerInfoText_UP = {}
    for index, value in ipairs(first) do
        -- 从下往上排列，第一行在最底部
        local y = dt.label_padding + dt.row_h * (#first - index)

        local nameText = ui.CreateLabel(
            self.voidPlayerInfo_UP,
            value.name,
            ui.Font.tooltip,
            "LEFT", 6, y
        )
        local valueText = ui.CreateLabel(
            self.voidPlayerInfo_UP,
            value.value,
            ui.Font.tooltip,
            "RIGHT", -5, y
        )
        self.voidPlayerInfoText_UP[index] = { nameText, valueText }
    end
end

-- ----------------------------------------------------------------------------
-- 创建下面板（抗性属性）
-- @param last last_table
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreatePlayerInfoFrame_Down(last)
    MzxToolClassicCharacterDB.point.player_down = MzxToolClassicCharacterDB.point.player_down or {
        p = dt.down.p,
        x = dt.down.x,
        y = dt.down.y,
    }

    -- 主框体：统一面板样式
    self.voidPlayerInfo_DOWN = ui.CreatePanel(
        UIParent,
        dt.panel_w_down,
        #last * dt.row_h + dt.label_padding * 2,
        MzxToolClassicCharacterDB.point.player_down.p,
        MzxToolClassicCharacterDB.point.player_down.x,
        MzxToolClassicCharacterDB.point.player_down.y
    )

    self.voidPlayerInfoText_DOWN = {}
    for index, value in ipairs(last) do
        -- 从下往上排列，第一行在最底部
        local y = dt.label_padding + dt.row_h * (#last - index)

        local nameText = ui.CreateLabel(
            self.voidPlayerInfo_DOWN,
            value.name,
            ui.Font.tooltip,
            "LEFT", 6, y
        )
        local valueText = ui.CreateLabel(
            self.voidPlayerInfo_DOWN,
            value.value,
            ui.Font.tooltip,
            "RIGHT", -5, y
        )
        self.voidPlayerInfoText_DOWN[index] = { nameText, valueText }
    end
end

-- ----------------------------------------------------------------------------
-- 模块入口：创建玩家信息界面
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreatePlayerInfo()
    MzxToolClassicCharacterDB.point = MzxToolClassicCharacterDB.point or {}

    local first, last = MzxToolFrame:Void_PlayerInfo()
    self:Void_CreatePlayerInfoFrame_UP(first)
    self:Void_CreatePlayerInfoFrame_Down(last)

    MovableDisplay(self.voidPlayerInfo_UP)
    MovableDisplay(self.voidPlayerInfo_DOWN)

    MovableFrameStop(self.voidPlayerInfo_UP, MzxToolClassicCharacterDB.point.player_up, dt.up)
    MovableFrameStop(self.voidPlayerInfo_DOWN, MzxToolClassicCharacterDB.point.player_down, dt.down)
end

-- ----------------------------------------------------------------------------
-- 刷新玩家信息框体文本
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_UpdatePlayerInfo()
    if self.voidPlayerInfo_UP and self.voidPlayerInfo_DOWN then
        local first, last = MzxToolFrame:Void_PlayerInfo()
        for index, value in ipairs(first) do
            self.voidPlayerInfoText_UP[index][1]:SetText(value.name)
            self.voidPlayerInfoText_UP[index][2]:SetText(value.value)
        end
        for index, value in ipairs(last) do
            self.voidPlayerInfoText_DOWN[index][1]:SetText(value.name)
            self.voidPlayerInfoText_DOWN[index][2]:SetText(value.value)
        end
    end
end
