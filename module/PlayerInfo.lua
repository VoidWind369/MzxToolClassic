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

    -- local first_table = {
    --     string.format("|cFFC41E3A力量 %d|r", strength),
    --     string.format("|cFFF48CBA敏捷 %d|r", agility),
    --     string.format("|cFFFFF468耐力 %d|r", stamina),
    --     string.format("|cFF3FC7EB智力 %d|r", intellect),
    --     string.format("|cFF33937F精神 %d|r", spirit),
    --     string.format("|cFFCD7F32护甲 %d|r", physical),
    -- }

    local first_table = {
        name = {
            "|cFFC41E3A" .. attribute.name .. "|r",
            "|cFFC41E3A暴击几率|r",
            "|cFF3FC7EB命中等级|r",
            "|cFF3FC7EB命中几率|r",
            "|cFFCD7F32急速等级|r",
            "|cFFCD7F32移动速度|r",
        },
        value = {
            attribute.damage,
            string.format(" %.2f%%", attribute.chance or 0),
            attribute.rating,
            string.format(" %.2f%%", attribute.ratingBonus or 0),
            string.format(" %.1f%%", haste or 0),
            string.format(" %.1f%%", speedPercent or 0),
        }
    }

    local last_table = {
        name = { "|cFFFFFF66神圣|r", "|cFFFF3300火焰|r", "|cFF00FF00自然|r", "|cFF00CCFF冰霜|r", "|cFF9933CC暗影|r", "|cFFFF66FF奥数|r" },
        value = { holy, fire, nature, frost, shadow, arcane },
    }
    local last = table.concat(last_table, "\n")

    local info = string.format("|cFFFFFF00生命 %d\n移速 %.2f%%|r", health, speedPercent)
    local sub_attribute = string.format("暴击 %d\n急速 %d\n精通 %d", crit, haste, mastery)

    return first_table, last_table, info, sub_attribute
end

--- # 创建主属性框体
function MzxToolFrame:Void_CreatePlayerInfoFrame_UP(first)
    MzxToolClassicCharacterDB.point.player_up = MzxToolClassicCharacterDB.point.player_up or {
        p = point.player_up.p,
        x = point.player_up.x,
        y = point.player_up.y
    }

    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(150, 115)
    self.voidPlayerInfo_UP:SetPoint(MzxToolClassicCharacterDB.point.player_up.p,
        MzxToolClassicCharacterDB.point.player_up.x,
        MzxToolClassicCharacterDB.point.player_up.y)
    SetInfoFrameStyle(self.voidPlayerInfo_UP)

    self.voidPlayerInfoText_UP = {
        self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    }

    AddStringLeft(self.voidPlayerInfoText_UP[1], table.concat(first.name, "\n"))
    AddStringRight(self.voidPlayerInfoText_UP[2], table.concat(first.value, "\n"))
end

--- # 创建副属性框体
function MzxToolFrame:Void_CreatePlayerInfoFrame_Down(info)
    MzxToolClassicCharacterDB.point.player_down = MzxToolClassicCharacterDB.point.player_down or {
        p = point.player_down.p,
        x = point.player_down.x,
        y = point.player_down.y
    }
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(90, 115)
    self.voidPlayerInfo_DOWN:SetPoint(MzxToolClassicCharacterDB.point.player_down.p,
        MzxToolClassicCharacterDB.point.player_down.x,
        MzxToolClassicCharacterDB.point.player_down.y)
    SetInfoFrameStyle(self.voidPlayerInfo_DOWN)

    self.voidPlayerInfoText_DOWN = {
        self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    }

    AddStringLeft(self.voidPlayerInfoText_DOWN[1], table.concat(info.name, "\n"))
    AddStringRight(self.voidPlayerInfoText_DOWN[2], table.concat(info.value, "\n"))
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
        local first, info = MzxToolFrame:Void_PlayerInfo()
        self.voidPlayerInfoText_UP[1]:SetText(table.concat(first.name, "\n"))
        self.voidPlayerInfoText_UP[2]:SetText(table.concat(first.value, "\n"))
        self.voidPlayerInfoText_DOWN[1]:SetText(table.concat(info.name, "\n"))
        self.voidPlayerInfoText_DOWN[2]:SetText(table.concat(info.value, "\n"))
    end
end
