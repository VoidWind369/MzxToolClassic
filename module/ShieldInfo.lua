local shield = {
    up = {
        p = "CENTER",
        x = 0,
        y = -270
    },

    Shaman_SpecId = 7,

    -- 法术ID
    lightning_shield_id = { 324, 325, 905, 945, 8134, 10431, 10432, 25469, 25472 }, -- 闪电护盾
    water_shield_id = { 24398, 33736 },                                             -- 水之护盾
    earth_shield_id = { 947, 32593, 32594 },                                        -- 大地之盾
    focus_spell_id = 43339,                                                         -- 萨满专注

    now_shield_id = nil,                                                            -- 当前护盾

    -- 显示设置
    max_stacks = 3,
    dot_size = 36,   -- 每个小圆点的大小
    dot_spacing = 1, -- 圆点间距
    position_x = 0,
    position_y = -260,

    shield_type = 0,
    currentStacks = 0,
    lastStacks = 0,
}

--- # 获取武器临时附魔信息
function VoidFrame:GetWeaponEnchantInfo()
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID, hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID =
        GetWeaponEnchantInfo()

    local main_color_str = hasMainHandEnchant and
        string.format("%s%s|r", mainHandExpiration > 10000 and "|cFFFFFF00" or "|cFFFF0000",
            MinutesOrSeconds(mainHandExpiration)) or
        "|cFFC0C0C0Nil|r"
    local off_color_str = hasOffHandEnchant and
        string.format("%s%s|r", offHandExpiration > 10000 and "|cFFFFFF00" or "|cFFFF0000",
            MinutesOrSeconds(offHandExpiration)) or
        "|cFFC0C0C0Nil|r"
    local ranged_color_str = hasRangedEnchant and
        string.format("%s%s|r", rangedExpiration > 10000 and "|cFFFFFF00" or "|cFFFF0000",
            MinutesOrSeconds(rangedExpiration)) or
        "|cFFC0C0C0Nil|r"

    return {
        main = {
            expiration = main_color_str,
        },
        off = {
            expiration = off_color_str,
        },
        ranged = {
            expiration = ranged_color_str,
        }
    }
end

--- # 创建护盾检测框体
function VoidFrame:Void_CreateShieldInfo()
    VoidModClassicCharacterDB.point.shield = VoidModClassicCharacterDB.point.shield or {
        p = shield.up.p,
        x = shield.up.x,
        y = shield.up.y
    }

    -- 主框架
    self.dotFrame = CreateFrame("Frame", "TotemWeapon", UIParent, "BackdropTemplate")
    self.dotFrame:SetPoint(VoidModClassicCharacterDB.point.shield.p,
        VoidModClassicCharacterDB.point.shield.x,
        VoidModClassicCharacterDB.point.shield.y)
    WhiteTransparentFrame(self.dotFrame, shield)

    -- 创建10个小圆点
    self.shieldDots = {}

    for i = 1, shield.max_stacks do
        local dot = CreateFrame("Frame", nil, self.dotFrame)
        WhiteTransparentDot(i, dot, shield)

        dot.glow = dot:CreateTexture(nil, "BACKGROUND")
        WhiteTransparentDotGlow(dot.glow, shield)

        dot.tex = dot:CreateTexture(nil, "OVERLAY")
        WhiteTransparentDotTex(dot.tex, shield)

        self.shieldDots[i] = dot
    end

    self:Void_CreateWeaponEnchantInfoFrame(self:GetWeaponEnchantInfo())

    GetShieldGameTooltip()
    MovableDisplay(self.dotFrame)
    MovableShieldInfoFrameStop()
end

function VoidFrame:Void_CreateWeaponEnchantInfoFrame(hand_table)
    self.dotFrame.weaponEnchantMain = CreateFrame("Frame", "WeaponEnchantMain", self.dotFrame, "BackdropTemplate")
    self.dotFrame.weaponEnchantMain:SetSize(50, shield.dot_size + shield.dot_spacing + 10)
    self.dotFrame.weaponEnchantMain:SetPoint("CENTER", -90, 0)
    SetInfoFrameStyle(self.dotFrame.weaponEnchantMain)

    self.dotFrame.weaponEnchantMainText = self.dotFrame.weaponEnchantMain:CreateFontString(nil, "OVERLAY",
        "GameTooltipText")
    AddStringCenter(self.dotFrame.weaponEnchantMainText, hand_table.main.expiration)

    self.dotFrame.weaponEnchantOff = CreateFrame("Frame", "WeaponEnchantOff", self.dotFrame, "BackdropTemplate")
    self.dotFrame.weaponEnchantOff:SetSize(50, shield.dot_size + shield.dot_spacing + 10)
    self.dotFrame.weaponEnchantOff:SetPoint("CENTER", 90, 0)
    SetInfoFrameStyle(self.dotFrame.weaponEnchantOff)

    self.dotFrame.weaponEnchantOffText = self.dotFrame.weaponEnchantOff:CreateFontString(nil, "OVERLAY",
        "GameTooltipText")
    AddStringCenter(self.dotFrame.weaponEnchantOffText, hand_table.off.expiration)
end

-- 设定萨满专注颜色
function UpdateDotFrameProgress(hasGaleWindsData)
    if hasGaleWindsData then
        VoidFrame.dotFrame:SetBackdropColor(0, 0.4, 1, 0.55)
        VoidFrame.dotFrame:SetBackdropBorderColor(0, 0.1, 0.4, 0.8)
    else
        VoidFrame.dotFrame:SetBackdropColor(0, 0, 0, 0.15)
        VoidFrame.dotFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
    end
end

-- 设定护盾层数颜色
function UpdateDotProgress(stacks)
    local alpha = 1
    for i = 1, shield.max_stacks do
        local dot = VoidFrame.shieldDots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            local topColor, bottomColor = GetGradientColorsSM(shield.shield_type, alpha)
            dot.tex:SetGradient("VERTICAL", topColor, bottomColor)

            -- 发光效果
            dot.glow:SetGradient("VERTICAL", topColor, bottomColor)
            dot.glow:Show()
            dot:SetAlpha(1)
        else
            -- 未激活的小圆点 - 深灰色渐变
            dot.tex:SetGradient("VERTICAL",
                CreateColor(0.5, 0.5, 0.5, alpha),
                CreateColor(0.2, 0.2, 0.2, alpha)
            )
            dot.glow:Hide()
            dot:SetAlpha(0.3)
        end
    end
end

--- # 刷新武器临时附魔信息
function VoidFrame:UpdateWeaponEnchant()
    local hand = self:GetWeaponEnchantInfo()
    if self.dotFrame then
        self.dotFrame.weaponEnchantMainText:SetText(hand.main.expiration)
        self.dotFrame.weaponEnchantOffText:SetText(hand.off.expiration)
    end
end

function GetGradientColorsSM(shield_type, alpha)
    -- 饱满的金属渐变色
    if shield_type == 1 then
        -- 蓝色金属
        return CreateColor(0.8, 0.9, 1.0, alpha), CreateColor(0.2, 0.4, 0.9, alpha)
    elseif shield_type == 2 then
        -- 黄色金属
        return CreateColor(0.9, 1.0, 0.0, alpha), CreateColor(0.5, 1.0, 0.0, alpha)
    else
        -- 红色金属
        return CreateColor(0.9, 0.0, 0.9, alpha), CreateColor(0.7, 0.0, 1.0, alpha)
    end
end

-- 增强萨buff监控进程
function VoidFrame:UpdateShieldInfo()
    -- 判断是否加载
    if not self.dotFrame then
        return
    end

    -- 萨满专注
    local focusData = C_UnitAuras.GetUnitAuraBySpellID("player", shield.focus_spell_id)

    -- 闪电护盾
    local lightning_shield = { 0, 0 }
    for _, spell_id in pairs(shield.lightning_shield_id) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            lightning_shield[1] = lightning_shield[1] + 1
            lightning_shield[2] = aura.applications or 0
            shield.now_shield_id = spell_id
        end
    end

    -- 水之护盾
    local water_shield = { 0, 0 }
    for _, spell_id in pairs(shield.water_shield_id) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            water_shield[1] = water_shield[1] + 1
            water_shield[2] = aura.applications or 0
            shield.now_shield_id = spell_id
        end
    end

    -- 大地之盾
    local earth_shield = { 0, 0 }
    for _, spell_id in pairs(shield.earth_shield_id) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            earth_shield[1] = earth_shield[1] + 1
            earth_shield[2] = aura.applications or 0
            shield.now_shield_id = spell_id
        end
    end

    if lightning_shield[1] > 0 then
        shield.currentStacks = lightning_shield[2]
        shield.shield_type = 0
    elseif water_shield[1] > 0 then
        shield.currentStacks = water_shield[2]
        shield.shield_type = 1
    elseif earth_shield[1] > 0 then
        shield.currentStacks = earth_shield[2]
        shield.shield_type = 2
    else
        shield.currentStacks = 0
        shield.lastStacks = 0
        shield.now_shield_id = nil
    end

    -- 更新小圆点进度
    UpdateDotProgress(shield.currentStacks)
    if focusData then
        UpdateDotFrameProgress(true)
    else
        UpdateDotFrameProgress(false)
    end
end

function GetShieldGameTooltip()
    -- 鼠标悬停事件
    VoidFrame.shieldDots[2]:SetScript("OnEnter", function(self)
        if shield.now_shield_id then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(shield.now_shield_id)
            GameTooltip:Show()
        end
    end)

    VoidFrame.shieldDots[2]:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function MovableShieldInfoFrameStop()
    -- 拖动停止
    VoidFrame.dotFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModClassicCharacterDB.point.shield.p = p    -- 保存
        VoidModClassicCharacterDB.point.shield.x = xOfs -- 保存
        VoidModClassicCharacterDB.point.shield.y = yOfs -- 保存
    end)

    -- 双击居中
    VoidFrame.dotFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(shield.up.p, shield.up.x, shield.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModClassicCharacterDB.point.shield.p = p    -- 保存
            VoidModClassicCharacterDB.point.shield.x = xOfs -- 保存
            VoidModClassicCharacterDB.point.shield.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end

function VoidFrame:TestDisplay()
    -- 测试显示不同层数
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试小圆点进度...|r")

    -- 循环测试不同层数
    local testIndex = 1
    C_Timer.NewTicker(0.3, function()
        self:UpdateDotProgress(testIndex)
        self.dotFrame:Show()
        testIndex = testIndex + 1
        if testIndex > 10 then
            testIndex = 1
        end
    end, 10) -- 测试10秒

    C_Timer.After(10.5, function()
        if shield.currentStacks == 0 then
            self.dotFrame:Hide()
        else
            self:UpdateDotProgress(shield.currentStacks)
        end
    end)
end
