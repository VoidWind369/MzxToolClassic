-- ============================================================================
-- 模块：萨满图腾信息监控 (TotemInfo)
-- ============================================================================
-- 职责：
--   1. 显示四系图腾（火焰/大地/水之/空气）的当前名称、剩余时间、图标；
--   2. 图腾剩余时间按阈值着色（>10 秒黄色，<=10 秒红色，未放置灰色）；
--   3. 提供“图腾召唤”安全动作按钮，附带法术提示悬停。
--
-- 数据依赖：MzxShamanData.TotemInfo（位于 module/Shaman/Data/ShamanData.lua）
-- 数据持久化：MzxToolClassicCharacterDB.point.totem
-- ============================================================================

local dt     = MzxShamanData.TotemInfo   -- 数据层快捷引用
local dt_font = MzxShamanData.Font       -- 字体数据层快捷引用

-- ----------------------------------------------------------------------------
-- 获取全部四系图腾当前状态
-- 返回：totem_info[1..4]，每项 { icon, name, dur, spell_id }
-- ----------------------------------------------------------------------------
function MzxToolFrame.GetTotemInfo()
    local totem_info = {}
    for index = 1, 4 do
        local haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(index)
        local icon_num = icon or MzxShamanData.Texture.default_icon or 136232
        local name = (haveTotem and totemName) and totemName or dt.color[index][2]
        local est_num = startTime + duration - GetTime()
        local est_color_str = string.format(est_num > 10 and "|cFFFFFF00%.1f|r" or "|cFFFF0000%.1f|r", est_num)
        local est_dur = (haveTotem and totemName) and est_color_str or dt.placeholder

        totem_info[index] = {
            icon   = icon_num,
            name   = dt.color[index][1] .. name .. "|r",
            dur    = est_dur,
            spell_id = spellID,
        }
    end
    return totem_info
end

-- ----------------------------------------------------------------------------
-- 获取全部四系图腾剩余时间（轻量版，仅用于计时刷新）
-- 返回：totem_info[1..4]，每项 { dur }
-- ----------------------------------------------------------------------------
function MzxToolFrame.GetTotemTimeLeft()
    local totem_info = {}
    for index = 1, 4 do
        local seconds = GetTotemTimeLeft(index)
        local est_color_str = string.format(seconds > 10 and "|cFFFFFF00%.1f|r" or "|cFFFF0000%.1f|r", seconds)
        local est_dur = seconds > 0 and est_color_str or "|cFFC0C0C0--|r"
        totem_info[index] = { dur = est_dur }
    end
    return totem_info
end

-- ----------------------------------------------------------------------------
-- 创建图腾信息主框体
-- @param totem_info GetTotemInfo() 返回的表
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateTotemInfoFrame(totem_info)
    MzxToolClassicCharacterDB.point.totem = MzxToolClassicCharacterDB.point.totem or {
        p = dt.up.p,
        x = dt.up.x,
        y = dt.up.y,
    }

    self.voidTotemInfo = CreateFrame("Frame", "Totem", UIParent, "BackdropTemplate")
    self.voidTotemInfo:SetSize(dt.panel_w, #totem_info * dt.row_h + 10)
    self.voidTotemInfo:SetPoint(MzxToolClassicCharacterDB.point.totem.p,
        MzxToolClassicCharacterDB.point.totem.x,
        MzxToolClassicCharacterDB.point.totem.y)
    SetInfoFrameStyle(self.voidTotemInfo)

    self.voidTotemInfoIcon = {}
    self.voidTotemInfoNameText = {}
    self.voidTotemInfoDurText = {}
    for index, value in ipairs(totem_info) do
        self.voidTotemInfoIcon[index] = self.voidTotemInfo:CreateTexture()
        self.voidTotemInfoNameText[index] = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", dt_font.tooltip)
        self.voidTotemInfoDurText[index] = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", dt_font.tooltip)

        local y = 36 - (index - 1) * 24
        AddIconLeft(self.voidTotemInfoIcon[index], value.icon, dt.icon_w, dt.icon_x, y - 1)
        AddStringLeft(self.voidTotemInfoNameText[index], value.name, dt.name_scale, dt.name_x, y)
        AddStringRight(self.voidTotemInfoDurText[index], value.dur, dt.name_scale, dt.dur_x, y)
    end
    GetTotemGameTooltip()
end

-- ----------------------------------------------------------------------------
-- 模块入口：创建图腾信息界面
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateTotemInfo()
    self:Void_CreateTotemInfoFrame(MzxToolFrame:GetTotemInfo())

    MovableDisplay(self.voidTotemInfo)
    self:RecycleTotem()

    MovableTotemFrameStop()
end

-- ----------------------------------------------------------------------------
-- 刷新图腾信息框体（图标、名称、剩余时间）
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_UpdateTotemInfo()
    if self.voidTotemInfo then
        local info = MzxToolFrame:GetTotemInfo()
        for index, value in ipairs(info) do
            self.voidTotemInfoIcon[index]:SetTexture(value.icon)
            self.voidTotemInfoNameText[index]:SetText(value.name)
            self.voidTotemInfoDurText[index]:SetText(value.dur)
        end
    end
end

-- ----------------------------------------------------------------------------
-- 刷新图腾剩余时间文本
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_UpdateTotemTimeLeft()
    if self.voidTotemInfo then
        local info = MzxToolFrame:GetTotemTimeLeft()
        for index, value in ipairs(info) do
            self.voidTotemInfoDurText[index]:SetText(value.dur)
        end
    end
end

-- ----------------------------------------------------------------------------
-- 创建“图腾召唤”安全动作按钮
-- ----------------------------------------------------------------------------
function MzxToolFrame:RecycleTotem()
    MzxToolFrame.voidTotemInfo.secureBtn = CreateFrame("Button", "RecycleTotemBtn", self.voidTotemInfo,
        "SecureActionButtonTemplate")
    self.voidTotemInfo.secureBtn:SetSize(110, 100)
    self.voidTotemInfo.secureBtn:SetPoint("RIGHT", self.voidTotemInfo, "RIGHT", 0, 0)
    self.voidTotemInfo.secureBtn:SetAttribute("type1", "spell")
    self.voidTotemInfo.secureBtn:SetAttribute("spell", "图腾召唤")
    self.voidTotemInfo.secureBtn:RegisterForClicks("AnyUp", "AnyDown")
    -- 鼠标悬停事件
    self.voidTotemInfo.secureBtn:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(36936)
        GameTooltip:AddLine("|cFF00FF00鼠标左键|r释放|cFFFFFF66图腾召唤|r", 0.9, 0.9, 0.9)
        GameTooltip:Show()
    end)
    self.voidTotemInfo.secureBtn:SetScript("OnLeave", function(s)
        GameTooltip:Hide()
    end)
end

-- ----------------------------------------------------------------------------
-- 为图标绑定鼠标悬停法术提示
-- ----------------------------------------------------------------------------
function GetTotemGameTooltip()
    for index, value in ipairs(MzxToolFrame.voidTotemInfoIcon) do
        value:SetScript("OnEnter", function(self)
            local haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(index)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spellID)
            GameTooltip:Show()
        end)

        value:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
end

-- ----------------------------------------------------------------------------
-- 框体拖动停止与双击居中
-- ----------------------------------------------------------------------------
function MovableTotemFrameStop()
    -- 拖动停止：保存位置
    MzxToolFrame.voidTotemInfo:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        MzxToolClassicCharacterDB.point.totem.p = p
        MzxToolClassicCharacterDB.point.totem.x = xOfs
        MzxToolClassicCharacterDB.point.totem.y = yOfs
    end)

    -- 双击居中
    MzxToolFrame.voidTotemInfo:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(dt.up.p, dt.up.x, dt.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            MzxToolClassicCharacterDB.point.totem.p = p
            MzxToolClassicCharacterDB.point.totem.x = xOfs
            MzxToolClassicCharacterDB.point.totem.y = yOfs
            self.doubleClick = false
        end
    end)
end
