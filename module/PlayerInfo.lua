local point = {
    player_up = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 130.0
    },
    player_down = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 10.0
    }
}

--- # 玩家信息获取
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
    --local power = UnitPower("player", Enum.PowerType.Mana)

    local first_table = {
        { name = "|cFFC41E3A" .. attribute.name .. "|r", value = attribute.damage },
        { name = "|cFFC41E3A暴击几率|r", value = string.format(" %.2f%%", attribute.chance or 0) },
        { name = "|cFF3FC7EB命中等级|r", value = attribute.rating },
        { name = "|cFF3FC7EB命中几率|r", value = string.format(" %.2f%%", attribute.ratingBonus or 0) },
        { name = "|cFFCD7F32急速等级|r", value = string.format(" %.1f%%", haste or 0) },
        { name = "|cFFCD7F32移动速度|r", value = string.format(" %.1f%%", speedPercent or 0) },
    }

    -- local first_table = {
    --     name = {
    --         "|cFFC41E3A" .. attribute.name .. "|r",
    --         "|cFFC41E3A暴击几率|r",
    --         "|cFF3FC7EB命中等级|r",
    --         "|cFF3FC7EB命中几率|r",
    --         "|cFFCD7F32急速等级|r",
    --         "|cFFCD7F32移动速度|r",
    --     },
    --     value = {
    --         attribute.damage,
    --         string.format(" %.2f%%", attribute.chance or 0),
    --         attribute.rating,
    --         string.format(" %.2f%%", attribute.ratingBonus or 0),
    --         string.format(" %.1f%%", haste or 0),
    --         string.format(" %.1f%%", speedPercent or 0),
    --     }
    -- }

    local last_table = {
        { name = "|cFFFFFF66物理|r", value = physical },
        { name = "|cFFFFFF66神圣|r", value = holy },
        { name = "|cFFFF3300火焰|r", value = fire },
        { name = "|cFF00FF00自然|r", value = nature },
        { name = "|cFF00CCFF冰霜|r", value = frost },
        { name = "|cFF9933CC暗影|r", value = shadow },
        { name = "|cFFFF66FF奥数|r", value = arcane }
    }

    -- local last_table = {
    --     name = { "|cFFFFFF66物理|r", "|cFFFFFF66神圣|r", "|cFFFF3300火焰|r", "|cFF00FF00自然|r", "|cFF00CCFF冰霜|r", "|cFF9933CC暗影|r", "|cFFFF66FF奥数|r" },
    --     value = { physical, holy, fire, nature, frost, shadow, arcane },
    -- }

    return first_table, last_table
end

--- # 创建主属性框体
function MzxToolFrame:Void_CreatePlayerInfoFrame_UP(first)
    MzxToolClassicCharacterDB.point.player_up = MzxToolClassicCharacterDB.point.player_up or {
        p = point.player_up.p,
        x = point.player_up.x,
        y = point.player_up.y
    }

    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(140, #first * 20 + 10)
    self.voidPlayerInfo_UP:SetPoint(MzxToolClassicCharacterDB.point.player_up.p,
        MzxToolClassicCharacterDB.point.player_up.x,
        MzxToolClassicCharacterDB.point.player_up.y)
    SetInfoFrameStyle(self.voidPlayerInfo_UP, true)

    -- self.voidPlayerInfoText_UP = {
    --     self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    --     self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    -- }

    -- for _, value in ipairs(first.name) do
    --     AddStringLeft(self.voidPlayerInfoText_UP[1], value)
    -- end
    -- for _, value in ipairs(first.value) do
    --     AddStringRight(self.voidPlayerInfoText_UP[2], value)
    -- end

    self.voidPlayerInfoText_UP = {}
    for index, value in ipairs(first) do
        self.voidPlayerInfoText_UP[index] = {
            self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
            self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        }
        AddStringLeft(self.voidPlayerInfoText_UP[index][1], value.name, nil, 6, (1 - index) * 20 + (#first - 1) * 10)
        AddStringRight(self.voidPlayerInfoText_UP[index][2], value.value, nil, -5, (1 - index) * 20 + (#first - 1) * 10)
    end
end

--- # 创建副属性框体
function MzxToolFrame:Void_CreatePlayerInfoFrame_Down(last)
    MzxToolClassicCharacterDB.point.player_down = MzxToolClassicCharacterDB.point.player_down or {
        p = point.player_down.p,
        x = point.player_down.x,
        y = point.player_down.y
    }
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(90, #last * 20 + 10)
    self.voidPlayerInfo_DOWN:SetPoint(MzxToolClassicCharacterDB.point.player_down.p,
        MzxToolClassicCharacterDB.point.player_down.x,
        MzxToolClassicCharacterDB.point.player_down.y)
    SetInfoFrameStyle(self.voidPlayerInfo_DOWN, true)

    -- self.voidPlayerInfoText_DOWN = {
    --     self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    --     self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    -- }

    -- for _, value in ipairs(last.name) do
    --     AddStringLeft(self.voidPlayerInfoText_DOWN[1], value)
    -- end
    -- for _, value in ipairs(last.value) do
    --     AddStringRight(self.voidPlayerInfoText_DOWN[2], value)
    -- end

    self.voidPlayerInfoText_DOWN = {}
    for index, value in ipairs(last) do
        self.voidPlayerInfoText_DOWN[index] = {
            self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
            self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        }
        AddStringLeft(self.voidPlayerInfoText_DOWN[index][1], value.name, nil, 6, (1 - index) * 20 + (#last - 1) * 10)
        AddStringRight(self.voidPlayerInfoText_DOWN[index][2], value.value, nil, -5, (1 - index) * 20 + (#last - 1) * 10)
    end
end

--- # 创建玩家信息框体
function MzxToolFrame:Void_CreatePlayerInfo()
    MzxToolClassicCharacterDB.point = MzxToolClassicCharacterDB.point or point

    local first, info = MzxToolFrame:Void_PlayerInfo()
    self:Void_CreatePlayerInfoFrame_UP(first)
    self:Void_CreatePlayerInfoFrame_Down(info)

    MovableDisplay(self.voidPlayerInfo_UP)
    MovableDisplay(self.voidPlayerInfo_DOWN)

    MovableFrameStop(self.voidPlayerInfo_UP, MzxToolClassicCharacterDB.point.player_up, point.player_up)
    MovableFrameStop(self.voidPlayerInfo_DOWN, MzxToolClassicCharacterDB.point.player_down, point.player_down)
end

--- # 刷新玩家信息框体
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
        -- self.voidPlayerInfoText_UP[1]:SetText(table.concat(first.name, "\n"))
        -- self.voidPlayerInfoText_UP[2]:SetText(table.concat(first.value, "\n"))
        -- self.voidPlayerInfoText_DOWN[1]:SetText(table.concat(last.name, "\n"))
        -- self.voidPlayerInfoText_DOWN[2]:SetText(table.concat(last.value, "\n"))
    end
end
