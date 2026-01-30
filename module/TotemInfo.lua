local totem = {
    up = {
        p = "CENTER",
        x = 0,
        y = -190
    },
}

function VoidFrame.GetTotemInfo()
    local totem_info = {}
    local color = { { "|cFFFF4500", "(火焰图腾)" }, { "|cFF8B4513", "(大地图腾)" }, { "|cFF1E90FF", "(水之图腾)" }, { "|cFF40E0D0", "(空气图腾)" } }
    for index, value in ipairs(color) do
        local haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(index)
        local icon_num = icon or 136232
        local name = (haveTotem and totemName) and totemName or value[2]
        local est_num = startTime + duration - GetTime()
        local est_color_str = string.format(est_num > 10 and "|cFFFFFF00%.1f|r" or "|cFFFF0000%.1f|r", est_num)
        local est_dur = (haveTotem and totemName) and est_color_str or "|cFFC0C0C0Nil|r"

        totem_info[index] = {
            icon = icon_num,
            name = value[1] .. name .. "|r",
            dur = est_dur,
        }
    end
    return totem_info
end

--- # 创建图腾框体
function VoidFrame:Void_CreateTotemInfoDisplay(totem_info)
    VoidModClassicCharacterDB.point.totem = VoidModClassicCharacterDB.point.totem or totem.up
    VoidModClassicCharacterDB.point.totem.p = VoidModClassicCharacterDB.point.totem.p or totem.up.p
    VoidModClassicCharacterDB.point.totem.x = VoidModClassicCharacterDB.point.totem.x or totem.up.x
    VoidModClassicCharacterDB.point.totem.y = VoidModClassicCharacterDB.point.totem.y or totem.up.y
    self.voidTotemInfo = CreateFrame("Frame", "Totem", UIParent, "BackdropTemplate")
    self.voidTotemInfo:SetSize(220, #totem_info * 26 + 10)
    self.voidTotemInfo:SetPoint(VoidModClassicCharacterDB.point.totem.p,
        VoidModClassicCharacterDB.point.totem.x,
        VoidModClassicCharacterDB.point.totem.y)
    SetInfoFrameStyle(self.voidTotemInfo)

    self.voidTotemInfoIcon = {}
    self.voidTotemInfoNameText = {}
    self.voidTotemInfoDurText = {}
    for index, value in ipairs(totem_info) do
        self.voidTotemInfoIcon[index] = self.voidTotemInfo:CreateTexture()
        self.voidTotemInfoNameText[index] = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        self.voidTotemInfoDurText[index] = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")

        local y = 36 - (index - 1) * 24
        AddIcon(self.voidTotemInfoIcon[index], value.icon, 17, 13.5, y - 1)
        AddString(self.voidTotemInfoNameText[index], value.name, 1.2, 35, y)
        AddNumber(self.voidTotemInfoDurText[index], value.dur, 1.2, -10, y)
    end
end

--- # 创建武器熟练度信息框体
function VoidFrame:Void_CreateTotemInfo()
    self:Void_CreateTotemInfoDisplay(VoidFrame:GetTotemInfo())

    MovableDisplay(self.voidTotemInfo)
    self:RecycleTotem()

    MovableTotemDisplayStop()
end

--- # 刷新武器熟练度信息框体
function VoidFrame:Void_UpdateTotemInfoDisplay()
    -- 判断是否启用
    if self.voidTotemInfo then
        local info = VoidFrame:GetTotemInfo()
        for index, value in ipairs(info) do
            self.voidTotemInfoIcon[index]:SetTexture(value.icon)
            self.voidTotemInfoNameText[index]:SetText(value.name)
            self.voidTotemInfoDurText[index]:SetText(value.dur)
        end
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
