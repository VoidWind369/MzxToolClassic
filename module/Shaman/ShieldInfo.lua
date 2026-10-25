-- ============================================================================
-- 模块：萨满元素护盾监控 (ShieldInfo)
-- ============================================================================
-- 职责：
--   1. 监控玩家身上的闪电护盾、水之护盾、大地护盾层数，以小圆点显示；
--   2. 监控萨满专注、元素集中 buff，改变主框体边框颜色；
--   3. 显示主手/副手/远程武器临时附魔剩余时间。
--
-- 数据依赖：MzxShamanData.ShieldInfo（位于 module/Shaman/Data/ShamanData.lua）
-- 事件依赖：UNIT_AURA（已在 MzxTool.lua 中合并为 0.1s 定时器处理）
-- 数据持久化：MzxToolClassicCharacterDB.point.shield
-- ============================================================================

local shield_data = MzxShamanData.ShieldInfo   -- 数据层快捷引用
local shield_font = MzxShamanData.Font         -- 字体数据层快捷引用

-- 运行时状态（不持久化，仅在当前会话有效）
local shield_state = {
    now_shield_id = nil,   -- 当前生效的护盾法术 ID
    currentStacks = 0,     -- 当前护盾层数
    lastStacks = 0,        -- 上一帧层数（用于变化检测）
    shield_type = 0,       -- 0=无/闪电, 1=水, 2=大地
}

-- ----------------------------------------------------------------------------
-- 获取武器临时附魔信息（主手/副手/远程）
-- 返回：{ main={expiration}, off={expiration}, ranged={expiration} }
-- ----------------------------------------------------------------------------
function MzxToolFrame:GetWeaponEnchant()
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID,
        hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID,
        hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID =
        GetWeaponEnchantInfo()

    local main_color_str = hasMainHandEnchant and
        string.format("%s%s|r", mainHandExpiration > 10000 and "|cFFFFFF00" or "|cFFFF0000",
            MinutesOrSeconds(mainHandExpiration)) or
        "|cFFC0C0C0主手|r"
    local off_color_str = hasOffHandEnchant and
        string.format("%s%s|r", offHandExpiration > 10000 and "|cFFFFFF00" or "|cFFFF0000",
            MinutesOrSeconds(offHandExpiration)) or
        "|cFFC0C0C0副手|r"
    local ranged_color_str = hasRangedEnchant and
        string.format("%s%s|r", rangedExpiration > 10000 and "|cFFFFFF00" or "|cFFFF0000",
            MinutesOrSeconds(rangedExpiration)) or
        "|cFFC0C0C0弓箭|r"

    return {
        main = { expiration = main_color_str },
        off  = { expiration = off_color_str },
        ranged = { expiration = ranged_color_str },
    }
end

-- ----------------------------------------------------------------------------
-- 创建护盾检测主框体与小圆点
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateShieldInfo()
    MzxToolClassicCharacterDB.point.shield = MzxToolClassicCharacterDB.point.shield or {
        p = shield_data.up.p,
        x = shield_data.up.x,
        y = shield_data.up.y,
    }

    -- 主框架
    self.dotFrame = CreateFrame("Frame", "TotemWeapon", UIParent, "BackdropTemplate")
    self.dotFrame:SetPoint(MzxToolClassicCharacterDB.point.shield.p,
        MzxToolClassicCharacterDB.point.shield.x,
        MzxToolClassicCharacterDB.point.shield.y)
    WhiteTransparentFrame(self.dotFrame, shield_data)

    -- 创建小圆点（层数指示）
    self.shieldDots = {}
    for i = 1, shield_data.max_stacks do
        local dot = CreateFrame("Frame", nil, self.dotFrame)
        WhiteTransparentDot(i, dot, shield_data)

        dot.tex = dot:CreateTexture(nil, "OVERLAY")
        WhiteTransparentDotTex(dot.tex, shield_data)

        self.shieldDots[i] = dot
    end

    self:Void_CreateWeaponEnchantInfoFrame(self:GetWeaponEnchant())

    GetShieldGameTooltip()
    MovableDisplay(self.dotFrame)
    MovableShieldInfoFrameStop()
end

-- ----------------------------------------------------------------------------
-- 创建武器附魔剩余时间子框体
-- @param hand_table GetWeaponEnchant() 返回的表
-- ----------------------------------------------------------------------------
function MzxToolFrame:Void_CreateWeaponEnchantInfoFrame(hand_table)
    self.dotFrame.weaponEnchantMain = CreateFrame("Frame", "WeaponEnchantMain", self.dotFrame, "BackdropTemplate")
    self.dotFrame.weaponEnchantMain:SetSize(50, shield_data.dot_size + shield_data.dot_spacing + 10)
    self.dotFrame.weaponEnchantMain:SetPoint("CENTER", -90, 0)
    SetInfoFrameStyle(self.dotFrame.weaponEnchantMain)

    self.dotFrame.weaponEnchantMainText = self.dotFrame.weaponEnchantMain:CreateFontString(nil, "OVERLAY",
        shield_font.tooltip)
    AddStringCenter(self.dotFrame.weaponEnchantMainText, hand_table.main.expiration)

    self.dotFrame.weaponEnchantOff = CreateFrame("Frame", "WeaponEnchantOff", self.dotFrame, "BackdropTemplate")
    self.dotFrame.weaponEnchantOff:SetSize(50, shield_data.dot_size + shield_data.dot_spacing + 10)
    self.dotFrame.weaponEnchantOff:SetPoint("CENTER", 90, 0)
    SetInfoFrameStyle(self.dotFrame.weaponEnchantOff)

    self.dotFrame.weaponEnchantOffText = self.dotFrame.weaponEnchantOff:CreateFontString(nil, "OVERLAY",
        shield_font.tooltip)
    AddStringCenter(self.dotFrame.weaponEnchantOffText, hand_table.off.expiration)
end

-- ----------------------------------------------------------------------------
-- 设定萨满专注/元素集中颜色（主框体边框）
-- @param hasGaleWindsData 0=无, 1=专注, 2=元素集中, 3=两者皆有
-- ----------------------------------------------------------------------------
function UpdateDotFrameProgress(hasGaleWindsData)
    if hasGaleWindsData == 1 then -- 蓝（专注）
        MzxToolFrame.dotFrame:SetBackdropColor(0, 0.4, 1, 0.55)
        MzxToolFrame.dotFrame:SetBackdropBorderColor(0, 0.1, 0.4, 0.8)
    elseif hasGaleWindsData == 2 then -- 红（元素集中）
        MzxToolFrame.dotFrame:SetBackdropColor(1, 0, 0, 0.55)
        MzxToolFrame.dotFrame:SetBackdropBorderColor(0.4, 0, 0.1, 0.8)
    elseif hasGaleWindsData == 3 then -- 紫（两者皆有）
        MzxToolFrame.dotFrame:SetBackdropColor(1, 0, 1, 0.55)
        MzxToolFrame.dotFrame:SetBackdropBorderColor(0.4, 0, 0.4, 0.8)
    else -- 无
        MzxToolFrame.dotFrame:SetBackdropColor(0, 0, 0, 0.15)
        MzxToolFrame.dotFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
    end
end

-- ----------------------------------------------------------------------------
-- 设定护盾层数颜色（小圆点渐变）
-- @param stacks 当前层数
-- ----------------------------------------------------------------------------
function UpdateDotProgress(stacks)
    local alpha = 1
    for i = 1, shield_data.max_stacks do
        local dot = MzxToolFrame.shieldDots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            local topColor, bottomColor = GetGradientColorsSM(shield_state.shield_type, alpha)
            dot.tex:SetGradient("VERTICAL", topColor, bottomColor)
            dot:SetAlpha(1)
        else
            -- 未激活的小圆点 - 深灰色渐变
            dot.tex:SetGradient("VERTICAL",
                CreateColor(0.5, 0.5, 0.5, alpha),
                CreateColor(0.2, 0.2, 0.2, alpha)
            )
            dot:SetAlpha(0.3)
        end
    end
end

-- ----------------------------------------------------------------------------
-- 刷新武器临时附魔信息文本
-- ----------------------------------------------------------------------------
function MzxToolFrame:UpdateWeaponEnchant()
    if not self.dotFrame then
        return
    end
    local hand = self:GetWeaponEnchant()
    self.dotFrame.weaponEnchantMainText:SetText(hand.main.expiration)
    self.dotFrame.weaponEnchantOffText:SetText(hand.off.expiration)
end

-- ----------------------------------------------------------------------------
-- 获取渐变色（按护盾类型）
-- @param shield_type 0=闪电/无, 1=水, 2=大地
-- @param alpha 透明度
-- 返回：topColor, bottomColor (CreateColor 对象)
-- ----------------------------------------------------------------------------
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
        return CreateColor(0.9, 0.0, 0.0, alpha), CreateColor(0.7, 0.0, 1.0, alpha)
    end
end

-- ----------------------------------------------------------------------------
-- 增强萨buff监控主刷新：护盾层数 + 专注/元素集中状态
-- ----------------------------------------------------------------------------
function MzxToolFrame:UpdateShieldInfo()
    -- 判断是否加载
    if not self.dotFrame then
        return
    end

    -- 萨满专注
    local focusData = C_UnitAuras.GetUnitAuraBySpellID("player", shield_data.focus_spell_id)
    -- 元素集中
    local elementalFocusData = C_UnitAuras.GetUnitAuraBySpellID("player", shield_data.elemental_focus_id)

    -- 闪电护盾
    local lightning_shield = { 0, 0 }
    for _, spell_id in pairs(shield_data.lightning_shield_ids) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            lightning_shield[1] = lightning_shield[1] + 1
            lightning_shield[2] = aura.applications or 0
            shield_state.now_shield_id = spell_id
        end
    end

    -- 水之护盾
    local water_shield = { 0, 0 }
    for _, spell_id in pairs(shield_data.water_shield_ids) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            water_shield[1] = water_shield[1] + 1
            water_shield[2] = aura.applications or 0
            shield_state.now_shield_id = spell_id
        end
    end

    -- 大地之盾
    local earth_shield = { 0, 0 }
    for _, spell_id in pairs(shield_data.earth_shield_ids) do
        local aura = C_UnitAuras.GetUnitAuraBySpellID("player", spell_id)
        if aura then
            earth_shield[1] = earth_shield[1] + 1
            earth_shield[2] = aura.applications or 0
            shield_state.now_shield_id = spell_id
        end
    end

    -- 确定当前生效护盾与层数
    if lightning_shield[1] > 0 then
        shield_state.currentStacks = lightning_shield[2]
        shield_state.shield_type = 0
    elseif water_shield[1] > 0 then
        shield_state.currentStacks = water_shield[2]
        shield_state.shield_type = 1
    elseif earth_shield[1] > 0 then
        shield_state.currentStacks = earth_shield[2]
        shield_state.shield_type = 2
    else
        shield_state.currentStacks = 0
        shield_state.lastStacks = 0
        shield_state.now_shield_id = nil
    end

    -- 更新小圆点进度
    UpdateDotProgress(shield_state.currentStacks)
    if focusData and not elementalFocusData then
        UpdateDotFrameProgress(1)
    elseif elementalFocusData and not focusData then
        UpdateDotFrameProgress(2)
    elseif focusData and elementalFocusData then
        UpdateDotFrameProgress(3)
    else
        UpdateDotFrameProgress(0)
    end
end

-- ----------------------------------------------------------------------------
-- 护盾图标悬停法术提示
-- ----------------------------------------------------------------------------
function GetShieldGameTooltip()
    MzxToolFrame.shieldDots[2]:SetScript("OnEnter", function(self)
        if shield_state.now_shield_id then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(shield_state.now_shield_id)
            GameTooltip:Show()
        end
    end)

    MzxToolFrame.shieldDots[2]:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- ----------------------------------------------------------------------------
-- 框体拖动停止与双击居中
-- ----------------------------------------------------------------------------
function MovableShieldInfoFrameStop()
    -- 拖动停止：保存位置
    MzxToolFrame.dotFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        MzxToolClassicCharacterDB.point.shield.p = p
        MzxToolClassicCharacterDB.point.shield.x = xOfs
        MzxToolClassicCharacterDB.point.shield.y = yOfs
    end)

    -- 双击居中
    MzxToolFrame.dotFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(shield_data.up.p, shield_data.up.x, shield_data.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            MzxToolClassicCharacterDB.point.shield.p = p
            MzxToolClassicCharacterDB.point.shield.x = xOfs
            MzxToolClassicCharacterDB.point.shield.y = yOfs
            self.doubleClick = false
        end
    end)
end

-- ----------------------------------------------------------------------------
-- 测试显示不同层数（调试用）
-- ----------------------------------------------------------------------------
function MzxToolFrame:TestDisplay()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试小圆点进度...|r")

    local testIndex = 1
    C_Timer.NewTicker(0.3, function()
        self:UpdateDotProgress(testIndex)
        self.dotFrame:Show()
        testIndex = testIndex + 1
        if testIndex > 10 then
            testIndex = 1
        end
    end, 10) -- 测试 10 秒

    C_Timer.After(10.5, function()
        if shield_state.currentStacks == 0 then
            self.dotFrame:Hide()
        else
            self:UpdateDotProgress(shield_state.currentStacks)
        end
    end)
end
