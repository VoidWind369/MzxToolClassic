local totem = {
    up = {
        p = "CENTER",
        x = 0.0,
        y = 0
    },
}

function VoidFrame.GetTotemInfo()
    local str_table = {}
    local color = { "|cFFFF4500", "|cFF8B4513", "|cFF1E90FF", "|cFF40E0D0" }
    for index = 1, 4 do
        local haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(index)
        local name = (haveTotem and totemName) and totemName or "(没插)"
        local est_dur = (haveTotem and totemName) and startTime + duration - GetTime() or 0
        table.insert(str_table, color[index] .. name .. "|r  " .. string.format("%.1f", est_dur))
    end
    return table.concat(str_table, "\n")
end

--- # 创建图腾框体
function VoidFrame:Void_CreateTotemInfoDisplay(str)
    VoidModClassicCharacterDB.point.totem = VoidModClassicCharacterDB.point.totem or totem.up
    VoidModClassicCharacterDB.point.totem.p = VoidModClassicCharacterDB.point.totem.p or totem.up.p
    VoidModClassicCharacterDB.point.totem.x = VoidModClassicCharacterDB.point.totem.x or totem.up.x
    VoidModClassicCharacterDB.point.totem.y = VoidModClassicCharacterDB.point.totem.y or totem.up.y
    self.voidTotemInfo = CreateFrame("Frame", "Totem", UIParent, "BackdropTemplate")
    self.voidTotemInfo:SetSize(165, 90)
    self.voidTotemInfo:SetPoint(VoidModClassicCharacterDB.point.totem.p,
        VoidModClassicCharacterDB.point.totem.x,
        VoidModClassicCharacterDB.point.totem.y)
    SetPlayerInfoFrameStyle(self.voidTotemInfo)

    self.voidTotemInfoText = self.voidTotemInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")

    AddString(self.voidTotemInfoText, str)
end

--- # 创建武器熟练度信息框体
function VoidFrame:Void_CreateTotemInfo()
    local info = VoidFrame:GetTotemInfo()
    self:Void_CreateTotemInfoDisplay(info)

    MovableDisplay(self.voidTotemInfo)

    MovableTotemDisplayStop()
end

--- # 刷新武器熟练度信息框体
function VoidFrame:Void_UpdateTotemInfoDisplay()
    local info = VoidFrame:GetTotemInfo()
    if self.voidTotemInfoText then
        self.voidTotemInfoText:SetText(info)
    end
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
