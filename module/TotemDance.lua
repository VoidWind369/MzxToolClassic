local totem_dance = {
    up = {
        p = "CENTER",
        x = 0,
        y = -90
    },
    windfury_totem_spell_id = { 8512, 10613, 10614, 25585, 25587 },
    flametongue_totem_sprll_id = { 8227, 8249, 10526, 16387, 25557 },
    totem_end_time = 0
}

function VoidFrame:GetGroupBuffs()
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destRaidFlags =
        CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_SUMMON" and sourceGUID == UnitGUID("player") then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand =
            select(12, CombatLogGetCurrentEventInfo())

        if tContains(totem_dance.windfury_totem_spell_id, spellId) then
            -- 更新时间
            totem_dance.totem_end_time = GetTime() + 10.000
            print("|cFFFFFF00召唤", sourceName, subevent, spellId, spellName, amount, critical, "|r")
        end
        -- 更新时间
    end
end

function VoidFrame:CreateTotemDanceFrame(dance_time)
    VoidModClassicCharacterDB.point.totem_dance = VoidModClassicCharacterDB.point.totem_dance or {
        p = totem_dance.up.p,
        x = totem_dance.up.x,
        y = totem_dance.up.y,
    }
    self.voidTotemDance = CreateFrame("Frame", "TotemDance", UIParent, "BackdropTemplate")
    self.voidTotemDance:SetSize(231, 50)
    self.voidTotemDance:SetPoint(VoidModClassicCharacterDB.point.totem_dance.p,
        VoidModClassicCharacterDB.point.totem_dance.x,
        VoidModClassicCharacterDB.point.totem_dance.y)
    SetInfoFrameStyle(self.voidTotemDance)

    self.totemDurationText = {
        self.voidTotemDance:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        self.voidTotemDance:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    }
    AddStringLeft(self.totemDurationText[1], "|cFFFF1493图腾舞|r", 1.6)
    AddStringRight(self.totemDurationText[2], dance_time, 1.6)
end

function VoidFrame:Void_CreateTotemDance()
    self:CreateTotemDanceFrame(FormatRemaining())
    MovableDisplay(self.voidTotemDance)
    MovableTotemDanceFrameStop()
end

function VoidFrame:Void_UpdateTotemDance()
    if self.voidTotemDance then
        self.totemDurationText[2]:SetText(FormatRemaining())
    end
end

function FormatRemaining()
    local remaining_time = totem_dance.totem_end_time - GetTime()
    local est_color_str = string.format(remaining_time > 5 and "|cFFFFFF00%.1f|r" or "|cFFFF0000%.1f|r", remaining_time)
    return remaining_time > 0 and est_color_str or "|cFFC0C0C0None|r"
end

function MovableTotemDanceFrameStop()
    -- 拖动停止
    VoidFrame.voidTotemDance:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModClassicCharacterDB.point.totem_dance.p = p    -- 保存
        VoidModClassicCharacterDB.point.totem_dance.x = xOfs -- 保存
        VoidModClassicCharacterDB.point.totem_dance.y = yOfs -- 保存
    end)

    -- 双击居中
    VoidFrame.voidTotemDance:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(totem_dance.up.p, totem_dance.up.x, totem_dance.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModClassicCharacterDB.point.totem_dance.p = p    -- 保存
            VoidModClassicCharacterDB.point.totem_dance.x = xOfs -- 保存
            VoidModClassicCharacterDB.point.totem_dance.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end
