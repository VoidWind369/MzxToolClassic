local buffs = {
    up = {
        p = "CENTER",
        x = 0,
        y = 180
    },
    totem_end_time = 0
}

function VoidFrame:GetGroupBuffs()
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destRaidFlags =
        CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_SUMMON" and sourceGUID == UnitGUID("player") then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand =
            select(12, CombatLogGetCurrentEventInfo())

        -- 更新时间
        buffs.totem_end_time = timestamp + 10.000
        print("|cFFFFFF00召唤", sourceName, subevent, spellId, spellName, amount, critical, "|r")
    end
end

function VoidFrame:CreateShamanBuffFrame()
    self.totemDuration = CreateFrame("Frame", "Totem", UIParent, "BackdropTemplate")
    self.totemDuration:SetSize(231, 36)
    self.totemDuration:SetPoint("CENTER", 0, 100)
    SetInfoFrameStyle(self.totemDuration)

    self.totemDurationText = self.totemDuration:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    AddStringRight(self.totemDurationText, FormatRemaining(), 1.2)
end

function VoidFrame:UpdateShamanBuff()
    self.totemDurationText:SetText(FormatRemaining())
end

function FormatRemaining()
    local remaining_time = buffs.totem_end_time - time()
    local est_color_str = string.format(remaining_time > 5 and "|cFFFFFF00%.0f|r" or "|cFFFF0000%.0f|r", remaining_time)
    return remaining_time > 0 and est_color_str or "|cFFC0C0C0Nil|r"
end
