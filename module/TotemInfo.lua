local totem = {
    up = {
        p = "CENTER",
        x = 0.0,
        y = 0
    },
}

function VoidFrame.GetTotemInfo()
    local icon_table = {}
    local name_table = {}
    local dur_table = {}
    local color = { { "|cFFFF4500", "(火焰图腾)" }, { "|cFF8B4513", "(大地图腾)" }, { "|cFF1E90FF", "(水之图腾)" }, { "|cFF40E0D0", "(空气图腾)" } }
    for index, value in ipairs(color) do
        local haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(index)
        local icon_num = icon or 136232
        local name = (haveTotem and totemName) and totemName or value[2]
        local est_dur = (haveTotem and totemName) and string.format("|cFFFFFF00%.1f|r", startTime + duration - GetTime()) or
            "|cFFC0C0C0Nil|r"
        -- print("icon:", icon)
        table.insert(icon_table, icon_num)
        table.insert(name_table, value[1] .. name .. "|r")
        table.insert(dur_table, est_dur)
    end
    return table.concat(name_table, "\n"), table.concat(dur_table, "\n"), icon_table, table.concat(icon_table, "\n")
end

--- # 创建图腾框体
function VoidFrame:Void_CreateTotemInfoDisplay(name, dur, icon, icon_text)
    VoidModClassicCharacterDB.point.totem = VoidModClassicCharacterDB.point.totem or totem.up
    VoidModClassicCharacterDB.point.totem.p = VoidModClassicCharacterDB.point.totem.p or totem.up.p
    VoidModClassicCharacterDB.point.totem.x = VoidModClassicCharacterDB.point.totem.x or totem.up.x
    VoidModClassicCharacterDB.point.totem.y = VoidModClassicCharacterDB.point.totem.y or totem.up.y
    self.voidTotemInfo = CreateFrame("Frame", "Totem", UIParent, "BackdropTemplate")
    self.voidTotemInfo:SetSize(220, 100)
    self.voidTotemInfo:SetPoint(VoidModClassicCharacterDB.point.totem.p,
        VoidModClassicCharacterDB.point.totem.x,
        VoidModClassicCharacterDB.point.totem.y)
    SetInfoFrameStyle(self.voidTotemInfo)

    self.voidTotemInfoNameText = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    self.voidTotemInfoDurText = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    self.voidTotemInfoIconText = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")

    self.voidTotemInfoIcon = {}
    for index, value in ipairs(icon) do
        self.voidTotemInfoIcon[index] = self.voidTotemInfo:CreateTexture()
        self.voidTotemInfoIcon[index]:SetTexture(value)
        self.voidTotemInfoIcon[index]:SetSize(15, 15)
        self.voidTotemInfoIcon[index]:SetPoint("LEFT", self.voidTotemInfo, "LEFT", 13.5, 27 - (index - 1) * 19.2)
    end

    AddString(self.voidTotemInfoNameText, name, 1.2, 35)
    AddNumber(self.voidTotemInfoDurText, dur, 1.2)
    -- AddString(self.voidTotemInfoIconText, icon_text, 1.2, 190)

    -- 不是增强初始隐藏
    local _, _, classId = UnitClass("player")
    if classId ~= 7 then
        self.voidTotemInfo:Hide()
    end
end

--- # 创建武器熟练度信息框体
function VoidFrame:Void_CreateTotemInfo()
    -- local name, dur = VoidFrame:GetTotemInfo()
    self:Void_CreateTotemInfoDisplay(VoidFrame:GetTotemInfo())

    MovableDisplay(self.voidTotemInfo)

    MovableTotemDisplayStop()
end

--- # 刷新武器熟练度信息框体
function VoidFrame:Void_UpdateTotemInfoDisplay()
    local name, dur, icon, icon_text = VoidFrame:GetTotemInfo()
    for index, value in ipairs(icon) do
        self.voidTotemInfoIcon[index]:SetTexture(value)
    end
    if self.voidTotemInfoNameText then
        self.voidTotemInfoNameText:SetText(name)
        self.voidTotemInfoDurText:SetText(dur)
        -- self.voidTotemInfoIconText:SetText(icon_text)
    end
end

function VoidFrame:RecycleTotem()
    VoidFrame.voidTotemInfo.secureBtn = CreateFrame("Button", "RecycleTotemBtn", self.voidTotemInfo,
        "SecureActionButtonTemplate")
    self.voidTotemInfo.secureBtn:SetSize(110, 100)
    -- self.voidTotemInfo.secureBtn:SetNormalTexture(136233)
    self.voidTotemInfo.secureBtn:SetPoint("RIGHT", self.voidTotemInfo, "RIGHT", 0, 0)
    self.voidTotemInfo.secureBtn:SetAttribute("type1", "spell")
    self.voidTotemInfo.secureBtn:SetAttribute("spell", "图腾召唤") -- 设置要施放的技能名
    self.voidTotemInfo.secureBtn:RegisterForClicks("AnyUp", "AnyDown")
    -- VoidFrame.voidTotemInfo.secureBtn:SetAttribute("type", "macro")
    -- VoidFrame.voidTotemInfo.secureBtn:SetAttribute("macrotext", "/cast 图腾召唤") -- text for macro on left click
end

function MovableTotemDisplayStop()
    -- 拖动停止
    VoidFrame.voidTotemInfo:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModClassicCharacterDB.point.totem.p = p    -- 保存
        VoidModClassicCharacterDB.point.totem.x = xOfs -- 保存
        VoidModClassicCharacterDB.point.totem.y = yOfs -- 保存
    end)

    -- 双击居中
    VoidFrame.voidTotemInfo:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(totem.up.p, totem.up.x, totem.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModClassicCharacterDB.point.totem.p = p    -- 保存
            VoidModClassicCharacterDB.point.totem.x = xOfs -- 保存
            VoidModClassicCharacterDB.point.totem.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end
