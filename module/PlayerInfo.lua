local point = {
    up = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 130.0
    },
    down = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 10.0
    }
}

--- # 玩家信息获取
function VoidFrame:Void_PlayerInfo()
    -- 主属性
    local strength = UnitStat("player", 1) -- 力量
    local agility = UnitStat("player", 2) -- 敏捷
    local stamina = UnitStat("player", 3) -- 耐力
    local intellect = UnitStat("player", 4) -- 智力
    local spirit = UnitStat("player", 5) -- 精神

    local health = UnitHealth("player") -- 生命值

    local _, physical = UnitResistance("player", 0) -- 护甲
    local _, holy = UnitResistance("player", 1) -- 神圣
    local _, fire = UnitResistance("player", 2) -- 火焰
    local _, nature = UnitResistance("player", 3) -- 自然
    local _, frost = UnitResistance("player", 4) -- 冰霜
    local _, shadow = UnitResistance("player", 5) -- 暗影
    local _, arcane = UnitResistance("player", 6) -- 奥数

    local baseSpeed, currentSpeed, playerSpeedMod = GetUnitSpeed("player")
    local speedPercent = (currentSpeed / 7) * 100  -- 7是基础奔跑速度
    --local power = UnitPower("player", Enum.PowerType.Mana)

    -- 副属性
    local crit = GetCritChance() -- 暴击
    local haste = GetHaste() -- 急速
    local mastery = GetMasteryEffect() -- 精通

    local first_table = {
        string.format("|cFFC41E3A力量 %d|r", strength),
        string.format("|cFFF48CBA敏捷 %d|r", agility),
        string.format("|cFFFFF468耐力 %d|r", stamina),
        string.format("|cFF3FC7EB智力 %d|r", intellect),
        string.format("|cFF33937F精神 %d|r", spirit),
        string.format("|cFFCD7F32护甲 %d|r", physical),
    }

    local first = table.concat(first_table, "\n")

    local last_table = {
        string.format("|cFFFFFF66神圣 %d|r", holy),
        string.format("|cFFFF3300火焰 %d|r", fire),
        string.format("|cFF00FF00自然 %d|r", nature),
        string.format("|cFF00CCFF冰霜 %d|r", frost),
        string.format("|cFF9933CC暗影 %d|r", shadow),
        string.format("|cFFFF66FF奥数 %d|r", arcane),
    }
    local last = table.concat(last_table, "\n")

    local info = string.format("|cFFFFFF00生命 %d\n移速 %.2f%%|r", health, speedPercent)
    local sub_attribute = string.format("暴击 %d\n急速 %d\n精通 %d", crit, haste, mastery)

    return first, last, info, sub_attribute
end

--- # 框体通用属性
function SetPlayerInfoFrameStyle(frame)
    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.15)
    frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
end

--- # 显示文字通用属性
function AddString(fontString, string)
    fontString:SetPoint("LEFT", 13.5, 0)
    fontString:SetText(string)
    fontString:SetTextScale(1)
    fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(1.5)
    fontString:SetJustifyH("LEFT")
end

--- # 创建主属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_UP(first)
    VoidModClassicCharacterDB.point.up = VoidModClassicCharacterDB.point.up or point.up
    VoidModClassicCharacterDB.point.up.p = VoidModClassicCharacterDB.point.up.p or point.up.p
    VoidModClassicCharacterDB.point.up.x = VoidModClassicCharacterDB.point.up.x or point.up.x
    VoidModClassicCharacterDB.point.up.y = VoidModClassicCharacterDB.point.up.y or point.up.y
    print("p", VoidModClassicCharacterDB.point.up.p)
    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(100, 115)
    self.voidPlayerInfo_UP:SetPoint(VoidModClassicCharacterDB.point.up.p, VoidModClassicCharacterDB.point.up.x, VoidModClassicCharacterDB.point.up.y)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_UP)

    self.voidPlayerInfoText_UP = self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText")

    AddString(self.voidPlayerInfoText_UP, first)
end

--- # 创建副属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_Down(info)
    VoidModClassicCharacterDB.point.down = VoidModClassicCharacterDB.point.down or point.down
    VoidModClassicCharacterDB.point.down.p = VoidModClassicCharacterDB.point.down.p or point.down.p
    VoidModClassicCharacterDB.point.down.x = VoidModClassicCharacterDB.point.down.x or point.down.x
    VoidModClassicCharacterDB.point.down.y = VoidModClassicCharacterDB.point.down.y or point.down.y
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(100, 115)
    self.voidPlayerInfo_DOWN:SetPoint(VoidModClassicCharacterDB.point.down.p, VoidModClassicCharacterDB.point.down.x, VoidModClassicCharacterDB.point.down.y)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_DOWN)

    self.voidPlayerInfoText_DOWN = self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText")

    AddString(self.voidPlayerInfoText_DOWN, info)
end

--- # 创建玩家信息框体
function VoidFrame:Void_CreatePlayerInfoDisplay()
    VoidModClassicCharacterDB.point = VoidModClassicCharacterDB.point or point

    local first, info = VoidFrame:Void_PlayerInfo()
    self:Void_CreatePlayerInfoDisplay_UP(first)
    self:Void_CreatePlayerInfoDisplay_Down(info)

    MovableDisplay(self.voidPlayerInfo_UP)
    MovableDisplay(self.voidPlayerInfo_DOWN)

    MovableDisplayStop()
end

--- # 刷新玩家信息框体
function VoidFrame:Void_UpdatePlayerInfoDisplay()
    local first, info = VoidFrame:Void_PlayerInfo()
    self.voidPlayerInfoText_UP:SetText(first)
    self.voidPlayerInfoText_DOWN:SetText(info)
end

function MovableDisplayStop()
    -- 拖动停止
    VoidFrame.voidPlayerInfo_UP:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModClassicCharacterDB.point.up.p = p -- 保存
        VoidModClassicCharacterDB.point.up.x = xOfs -- 保存
        VoidModClassicCharacterDB.point.up.y = yOfs -- 保存
    end)
    VoidFrame.voidPlayerInfo_DOWN:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModClassicCharacterDB.point.down.p = p -- 保存
        VoidModClassicCharacterDB.point.down.x = xOfs -- 保存
        VoidModClassicCharacterDB.point.down.y = yOfs -- 保存
    end)

    -- 双击居中
    VoidFrame.voidPlayerInfo_UP:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(point.up.p, point.up.x, point.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModClassicCharacterDB.point.up.p = p -- 保存
            VoidModClassicCharacterDB.point.up.x = xOfs -- 保存
            VoidModClassicCharacterDB.point.up.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)

    VoidFrame.voidPlayerInfo_DOWN:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(point.down.p, point.down.x, point.down.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModClassicCharacterDB.point.down.p = p -- 保存
            VoidModClassicCharacterDB.point.down.x = xOfs -- 保存
            VoidModClassicCharacterDB.point.down.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end
