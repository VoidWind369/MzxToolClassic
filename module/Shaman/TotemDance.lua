local totem_dance = {
    up = {
        p = "CENTER",
        x = 0,
        y = -90
    },
    windfury_totem_spell_id = { 8512, 10613, 10614, 25585, 25587 },
    flametongue_totem_sprll_id = { 8227, 8249, 10526, 16387, 25557 },
    totem_end_time = 0,
    remaining_time = 0
}

function MzxToolFrame:GetGroupBuffs()
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destRaidFlags =
        CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_SUMMON" and sourceGUID == UnitGUID("player") then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand =
            select(12, CombatLogGetCurrentEventInfo())

        if tContains(totem_dance.windfury_totem_spell_id, spellId) then
            -- 更新时间
            totem_dance.totem_end_time = GetTime() + 10.000
        end
        -- 更新时间
    end
end

function MzxToolFrame:CreateTotemDanceFrame(dance_time)
    MzxToolClassicCharacterDB.point.totem_dance = MzxToolClassicCharacterDB.point.totem_dance or {
        p = totem_dance.up.p,
        x = totem_dance.up.x,
        y = totem_dance.up.y,
    }
    self.voidTotemDance = CreateFrame("Frame", "TotemDance", UIParent, "BackdropTemplate")
    self.voidTotemDance:SetSize(231, 50)
    self.voidTotemDance:SetPoint(MzxToolClassicCharacterDB.point.totem_dance.p,
        MzxToolClassicCharacterDB.point.totem_dance.x,
        MzxToolClassicCharacterDB.point.totem_dance.y)
    SetInfoFrameStyle(self.voidTotemDance)

    self.voidTotemDanceIcon = self.voidTotemDance:CreateTexture()
    self.voidTotemDanceText = {
        self.voidTotemDance:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        self.voidTotemDance:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    }
    AddIconLeft(self.voidTotemDanceIcon, 136114, 26, 13.5, -1.2)
    AddStringLeft(self.voidTotemDanceText[1], "|cFFFF1493图腾舞|r", 1.6, 45)
    AddStringRight(self.voidTotemDanceText[2], dance_time, 1.6)

    GetTotemDanceGameTooltip()
end

function MzxToolFrame:Void_CreateTotemDance()
    self:CreateTotemDanceFrame(FormatRemaining())
    MovableDisplay(self.voidTotemDance)
    MovableTotemDanceFrameStop()
end

function MzxToolFrame:Void_UpdateTotemDance()
    if self.voidTotemDance then
        if totem_dance.remaining_time > 2 then
            MzxToolFrame.voidTotemDanceIcon:SetTexture(136046)
        else
            MzxToolFrame.voidTotemDanceIcon:SetTexture(136114)
        end
        self.voidTotemDanceText[2]:SetText(FormatRemaining())
    end
end

function FormatRemaining()
    totem_dance.remaining_time = totem_dance.totem_end_time - GetTime()
    local est_color_str = string.format(totem_dance.remaining_time > 2 and "|cFFFFFF00%.1f|r" or "|cFFFF0000%.1f|r",
        totem_dance.remaining_time)
    return totem_dance.remaining_time > 0 and est_color_str or "|cFFC0C0C0--|r"
end

function GetTotemDanceGameTooltip()
    -- 鼠标悬停事件
    MzxToolFrame.voidTotemDanceIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("|cFFFF1493图腾舞|r")
        GameTooltip:AddLine("用于高端萨满玩家同时保持风怒图腾与风之优雅", 1, 0.9, 0) -- RGB白色
        GameTooltip:AddLine("作用：风怒图腾召唤后的第一次主手附魔倒计时", 0.8, 0.8, 0.8) -- 浅灰色
        GameTooltip:Show()
    end)

    MzxToolFrame.voidTotemDanceIcon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function MovableTotemDanceFrameStop()
    -- 拖动停止
    MzxToolFrame.voidTotemDance:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        MzxToolClassicCharacterDB.point.totem_dance.p = p    -- 保存
        MzxToolClassicCharacterDB.point.totem_dance.x = xOfs -- 保存
        MzxToolClassicCharacterDB.point.totem_dance.y = yOfs -- 保存
    end)

    -- 双击居中
    MzxToolFrame.voidTotemDance:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(totem_dance.up.p, totem_dance.up.x, totem_dance.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            MzxToolClassicCharacterDB.point.totem_dance.p = p    -- 保存
            MzxToolClassicCharacterDB.point.totem_dance.x = xOfs -- 保存
            MzxToolClassicCharacterDB.point.totem_dance.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end
