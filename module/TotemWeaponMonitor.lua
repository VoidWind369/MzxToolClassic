local totemWeapon = {
    up = {
        p = "CENTER",
        x = 0,
        y = -270
    },

    Shaman_SpecId = 7,

    -- 法术ID                                                   -- 漩涡武器
    lightning_shield_id = { 324, 325, 905, 945, 8134, 10431, 10432, 25469, 25472 }, -- 闪电护盾
    water_shield_id = { 24398, 33736 },                                             -- 水之护盾
    focus_spell_id = 43339,                                                         -- 萨满专注

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

function VoidFrame:Void_CreateShield()
    VoidModClassicCharacterDB.point.totemWeapon = VoidModClassicCharacterDB.point.totemWeapon or totemWeapon.up
    VoidModClassicCharacterDB.point.totemWeapon.p = VoidModClassicCharacterDB.point.totemWeapon.p or totemWeapon.up.p
    VoidModClassicCharacterDB.point.totemWeapon.x = VoidModClassicCharacterDB.point.totemWeapon.x or totemWeapon.up.x
    VoidModClassicCharacterDB.point.totemWeapon.y = VoidModClassicCharacterDB.point.totemWeapon.y or totemWeapon.up.y

    -- 主框架
    self.dotFrame = CreateFrame("Frame", "TotemWeapon", UIParent, "BackdropTemplate")
    self.dotFrame:SetPoint(VoidModClassicCharacterDB.point.totemWeapon.p,
        VoidModClassicCharacterDB.point.totemWeapon.x,
        VoidModClassicCharacterDB.point.totemWeapon.y)
    WhiteTransparentFrame(self.dotFrame, totemWeapon)

    -- 创建10个小圆点
    self.totemWeaponDots = {}

    for i = 1, totemWeapon.max_stacks do
        local dot = CreateFrame("Frame", nil, self.dotFrame)
        WhiteTransparentDot(i, dot, totemWeapon)

        dot.glow = dot:CreateTexture(nil, "BACKGROUND")
        WhiteTransparentDotGlow(dot.glow, totemWeapon)

        dot.tex = dot:CreateTexture(nil, "OVERLAY")
        WhiteTransparentDotTex(dot.tex, totemWeapon)

        self.totemWeaponDots[i] = dot
    end

    MovableDisplay(self.dotFrame)
    MovableTotemWeaponDisplayStop()
end

-- 设定狂风怒号颜色
function UpdateDotFrameProgress(hasGaleWindsData)
    if hasGaleWindsData then
        VoidFrame.dotFrame:SetBackdropColor(0, 0.4, 1, 0.55)
        VoidFrame.dotFrame:SetBackdropBorderColor(0, 0.1, 0.4, 0.8)
    else
        VoidFrame.dotFrame:SetBackdropColor(0, 0, 0, 0.15)
        VoidFrame.dotFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
    end
end

-- 设定漩涡武器层数颜色
function UpdateDotProgress(stacks)
    local alpha = 1
    for i = 1, totemWeapon.max_stacks do
        local dot = VoidFrame.totemWeaponDots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            local topColor, bottomColor = GetGradientColorsSM(totemWeapon.shield_type, alpha)
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

function GetGradientColorsSM(shield_type, alpha)
    -- 饱满的金属渐变色
    if shield_type == 1 then
        -- 蓝色金属
        return CreateColor(0.8, 0.9, 1.0, alpha), CreateColor(0.2, 0.4, 0.9, alpha)
    else
        -- 红色金属
        return CreateColor(0.9, 0.0, 0.9, alpha), CreateColor(0.7, 0.0, 1.0, alpha)
    end
end

-- 增强萨buff监控进程
function VoidFrame:UpdateTotemWeaponStacks()
    -- 判断是否加载
    if not self.dotFrame then
        return
    end

    -- 萨满专注
    local focusData = C_UnitAuras.GetUnitAuraBySpellID("player", totemWeapon.focus_spell_id)

    -- 闪电护盾
    local lightning_shield = { 0, 0 }
    for _, spell_id in pairs(totemWeapon.lightning_shield_id) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            lightning_shield[1] = lightning_shield[1] + 1
            lightning_shield[2] = aura.applications or 0
        end
    end

    -- 水之护盾
    local water_shield = { 0, 0 }
    for _, spell_id in pairs(totemWeapon.water_shield_id) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            water_shield[1] = water_shield[1] + 1
            water_shield[2] = aura.applications or 0
        end
    end

    if lightning_shield[1] > 0 then
        totemWeapon.currentStacks = lightning_shield[2]
        totemWeapon.shield_type = 0
    elseif water_shield[1] > 0 then
        totemWeapon.currentStacks = water_shield[2]
        totemWeapon.shield_type = 1
    else
        totemWeapon.currentStacks = 0
        totemWeapon.lastStacks = 0
    end

    -- 更新小圆点进度
    UpdateDotProgress(totemWeapon.currentStacks)
    if focusData then
        UpdateDotFrameProgress(true)
    else
        UpdateDotFrameProgress(false)
    end
end

function MovableTotemWeaponDisplayStop()
    -- 拖动停止
    VoidFrame.dotFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModClassicCharacterDB.point.totemWeapon.p = p    -- 保存
        VoidModClassicCharacterDB.point.totemWeapon.x = xOfs -- 保存
        VoidModClassicCharacterDB.point.totemWeapon.y = yOfs -- 保存
    end)

    -- 双击居中
    VoidFrame.dotFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(totemWeapon.up.p, totemWeapon.up.x, totemWeapon.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModClassicCharacterDB.point.totemWeapon.p = p    -- 保存
            VoidModClassicCharacterDB.point.totemWeapon.x = xOfs -- 保存
            VoidModClassicCharacterDB.point.totemWeapon.y = yOfs -- 保存
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
        if totemWeapon.currentStacks == 0 then
            self.dotFrame:Hide()
        else
            self:UpdateDotProgress(totemWeapon.currentStacks)
        end
    end)
end
