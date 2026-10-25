-- ============================================================================
-- 模块：萨满图腾舞辅助 (TotemDance)
-- ============================================================================
-- 职责：
--   1. 通过 COMBAT_LOG_EVENT_UNFILTERED 监控玩家放置风怒图腾；
--   2. 启动 10 秒倒计时，图标在普通/激活状态间切换；
--   3. 提供图标悬停提示，说明图腾舞用途。
--
-- 数据依赖：MzxShamanData.TotemDance（位于 module/Shaman/Data/ShamanData.lua）
-- 事件依赖：COMBAT_LOG_EVENT_UNFILTERED（仅在萨满且图腾舞开启时注册，见 MzxTool.lua）
-- 数据持久化：MzxToolClassicCharacterDB.point.totem_dance
-- ============================================================================

local dt = MzxShamanData.TotemDance   -- 数据层快捷引用

local totem_dance = {
    totem_end_time = 0,
    remaining_time = 0,
}

-- ----------------------------------------------------------------------------
-- 战斗日志回调：监控玩家召唤风怒图腾，刷新结束时间
-- ----------------------------------------------------------------------------
function MzxToolFrame:GetGroupBuffs()
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags, spellId = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_SUMMON" and sourceGUID == UnitGUID("player") then
        if tContains(dt.windfury_totem_spell_ids, spellId) then
            totem_dance.totem_end_time = GetTime() + dt.end_time_offset
        end
    end
end

-- ----------------------------------------------------------------------------
-- 创建图腾舞主框体
-- @param dance_time 初始剩余时间文本
-- ----------------------------------------------------------------------------
function MzxToolFrame:CreateTotemDanceFrame(dance_time)
    MzxToolClassicCharacterDB.point.totem_dance = MzxToolClassicCharacterDB.point.totem_dance or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }

    self.voidTotemDance = CreateFrame("Frame", "TotemDance", UIParent, "BackdropTemplate")
    self.voidTotemDance:SetSize(dt.panel_w, dt.panel_h)
    self.voidTotemDance:SetPoint(MzxToolClassicCharacterDB.point.totem_dance.p,
        MzxToolClassicCharacterDB.point.totem_dance.x,
        MzxToolClassicCharacterDB.point.totem_dance.y)
    SetInfoFrameStyle(self.voidTotemDance)

    self.voidTotemDanceIcon = self.voidTotemDance:CreateTexture()
    self.voidTotemDanceText = {
        self.voidTotemDance:CreateFontString(nil, "OVERLAY", dt.Font.tooltip),
        self.voidTotemDance:CreateFontString(nil, "OVERLAY", dt.Font.tooltip),
    }
    AddIconLeft(self.voidTotemDanceIcon, dt.icon_normal, dt.icon_size, dt.icon_x, dt.icon_y)
    AddStringLeft(self.voidTotemDanceText[1], dt.text.title, dt.text1_scale, dt.text1_x)
    AddStringRight(self.voidTotemDanceText[2], dance_time, dt.text2_scale)

    GetTotemDanceGameTooltip()
end

-- ----------------------------------------------------------------------------
-- 模块入口：创建图腾舞界面
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateTotemDance()
    self:CreateTotemDanceFrame(FormatRemaining())
    MovableDisplay(self.voidTotemDance)
    MovableTotemDanceFrameStop()
end

-- ----------------------------------------------------------------------------
-- 刷新图腾舞显示（图标与倒计时文本）
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_UpdateTotemDance()
    if self.voidTotemDance then
        if totem_dance.remaining_time > 2 then
            MzxToolFrame.voidTotemDanceIcon:SetTexture(dt.icon_active)
        else
            MzxToolFrame.voidTotemDanceIcon:SetTexture(dt.icon_normal)
        end
        self.voidTotemDanceText[2]:SetText(FormatRemaining())
    end
end

-- ----------------------------------------------------------------------------
-- 计算并格式化剩余时间字符串
-- 返回：带颜色代码的时间文本，或 "--"
-- ----------------------------------------------------------------------------
function FormatRemaining()
    totem_dance.remaining_time = totem_dance.totem_end_time - GetTime()
    local est_color_str = string.format(totem_dance.remaining_time > 2 and "|cFFFFFF00%.1f|r" or "|cFFFF0000%.1f|r",
        totem_dance.remaining_time)
    return totem_dance.remaining_time > 0 and est_color_str or "|cFFC0C0C0--|r"
end

-- ----------------------------------------------------------------------------
-- 图标悬停提示
-- ----------------------------------------------------------------------------
function GetTotemDanceGameTooltip()
    MzxToolFrame.voidTotemDanceIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(dt.text.title)
        GameTooltip:AddLine(dt.text.desc1, 1, 0.9, 0)
        GameTooltip:AddLine(dt.text.desc2, 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    MzxToolFrame.voidTotemDanceIcon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- ----------------------------------------------------------------------------
-- 框体拖动停止与双击居中
-- ----------------------------------------------------------------------------
function MovableTotemDanceFrameStop()
    -- 拖动停止：保存位置
    MzxToolFrame.voidTotemDance:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        MzxToolClassicCharacterDB.point.totem_dance.p = p
        MzxToolClassicCharacterDB.point.totem_dance.x = xOfs
        MzxToolClassicCharacterDB.point.totem_dance.y = yOfs
    end)

    -- 双击居中
    MzxToolFrame.voidTotemDance:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(dt.up.p, dt.up.x, dt.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            MzxToolClassicCharacterDB.point.totem_dance.p = p
            MzxToolClassicCharacterDB.point.totem_dance.x = xOfs
            MzxToolClassicCharacterDB.point.totem_dance.y = yOfs
            self.doubleClick = false
        end
    end)
end
