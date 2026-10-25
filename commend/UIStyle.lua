-- ============================================================================
-- 模块：统一 UI 样式与封装层 (UIStyle)
-- ============================================================================
-- 职责：
--   1. 定义插件全局 UI 主题（颜色、间距、字体、边框），保证所有模块风格统一；
--   2. 提供封装的 UI 创建函数（面板、按钮、图标按钮、标签、弹出列表等），
--      各模块只调用本层，不得直接操作原始 CreateFrame/SetBackdrop/CreateFontString；
--   3. 统一悬停/点击反馈，避免各模块各自写一套颜色和间距。
--
-- 约定：
--   1. 所有尺寸、颜色、字体均从本表读取，模块内不得硬编码魔法数字；
--   2. 所有创建函数返回的框体均已挂载统一样式，可直接使用；
--   3. 本文件必须在所有 module/* 之前加载（见 TOC）。
-- ============================================================================

local UIStyle = {}

-- ----------------------------------------------------------------------------
-- 主题颜色（RGBA，分量 0~1）
-- ----------------------------------------------------------------------------
UIStyle.Color = {
    panel_bg       = { 0, 0, 0, 0.35 },   -- 面板默认背景
    panel_border   = { 0.2, 0.2, 0.2, 0.6 }, -- 面板默认边框
    btn_bg         = { 0, 0, 0, 0.6 },    -- 按钮背景
    btn_border     = { 0.1, 0.1, 0.1, 1 }, -- 按钮边框
    btn_hover_bg   = { 0, 0, 0, 0.2 },    -- 按钮悬停背景
    btn_hover_border = { 0.1, 0.1, 0.1, 0.3 }, -- 按钮悬停边框
    blocker        = { 0, 0, 0, 0.5 },    -- 遮罩背景
    text_title     = { 1, 1, 1, 1 },      -- 标题文字
    text_normal    = { 0.9, 0.9, 0.9, 1 },-- 普通文字
    text_sub       = { 0.7, 0.7, 0.7, 1 },-- 次要文字
    text_success   = { 0, 1, 0, 1 },      -- 成功/正常
    text_warn      = { 1, 1, 0, 1 },      -- 警告
    text_error     = { 1, 0, 0, 1 },      -- 错误
}

-- ----------------------------------------------------------------------------
-- 间距与尺寸（统一所有模块的布局度量，禁止各模块自定义不同间距）
-- ----------------------------------------------------------------------------
UIStyle.Space = {
    panel_padding  = 12,   -- 面板内边距
    panel_edge     = 8,    -- 面板外边距
    btn_size       = 36,   -- 主图标按钮尺寸
    btn_bg_size    = 46,   -- 主按钮背景框尺寸
    popup_w        = 45,   -- 弹出列表宽度
    popup_row_h    = 40,   -- 弹出列表每行高度
    popup_row_spacing = 44,-- 弹出列表行间距
    popup_btn_size = 34,   -- 弹出按钮图标尺寸
    popup_btn_bg   = 43,   -- 弹出按钮背景框尺寸
    icon_size      = 34,   -- 通用图标尺寸
    label_h        = 18,   -- 单行标签高度
    gap            = 8,    -- 元素间通用间隙
}

-- ----------------------------------------------------------------------------
-- 字体
-- ----------------------------------------------------------------------------
UIStyle.Font = {
    title  = "GameFontNormalHuge",
    normal = "GameFontNormal",
    small  = "GameFontNormalSmall",
    tooltip = "GameTooltipText",
}

-- ----------------------------------------------------------------------------
-- 纹理
-- ----------------------------------------------------------------------------
UIStyle.Texture = {
    bg      = "Interface/Tooltips/UI-Tooltip-Background",
    border  = "Interface/Tooltips/UI-Tooltip-Border",
    default_icon = 136232,
}

-- ----------------------------------------------------------------------------
-- 内部：应用统一面板背景与边框
-- ----------------------------------------------------------------------------
local function ApplyPanelBackdrop(frame, no_border)
    frame:SetBackdrop({
        bgFile = UIStyle.Texture.bg,
        edgeFile = no_border and nil or UIStyle.Texture.border,
        edgeSize = no_border and 0 or 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    frame:SetBackdropColor(unpack(UIStyle.Color.panel_bg))
    if not no_border then
        frame:SetBackdropBorderColor(unpack(UIStyle.Color.panel_border))
    end
end

-- ----------------------------------------------------------------------------
-- 内部：应用统一按钮背景与边框
-- ----------------------------------------------------------------------------
local function ApplyButtonBackdrop(frame, hover)
    frame:SetBackdrop({
        bgFile = UIStyle.Texture.bg,
        edgeFile = UIStyle.Texture.border,
        edgeSize = 8,
    })
    if hover then
        frame:SetBackdropColor(unpack(UIStyle.Color.btn_hover_bg))
        frame:SetBackdropBorderColor(unpack(UIStyle.Color.btn_hover_border))
    else
        frame:SetBackdropColor(unpack(UIStyle.Color.btn_bg))
        frame:SetBackdropBorderColor(unpack(UIStyle.Color.btn_border))
    end
end

-- ----------------------------------------------------------------------------
-- 创建统一样式的面板
-- @param parent  父框架
-- @param w       宽度
-- @param h       高度
-- @param point   锚点
-- @param x       X 偏移
-- @param y       Y 偏移
-- @param no_border 是否无边框
-- 返回：创建的框架
-- ----------------------------------------------------------------------------
function UIStyle.CreatePanel(parent, w, h, point, x, y, no_border)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(w, h)
    frame:SetPoint(point, x, y)
    ApplyPanelBackdrop(frame, no_border)
    return frame
end

-- ----------------------------------------------------------------------------
-- 创建统一样式的图标按钮（技能/图腾/传送按钮）
-- @param parent  父框架
-- @param icon    图标 ID 或路径
-- @param spellID 法术 ID（用于 SecureActionButtonTemplate 绑定）
-- @param size    图标显示尺寸
-- @param point   锚点
-- @param x       X 偏移
-- @param y       Y 偏移
-- @param onClick 右键点击回调 (function(button))
-- 返回：创建的按钮框架（已包含 bg 背景框）
-- ----------------------------------------------------------------------------
function UIStyle.CreateIconButton(parent, icon, spellID, size, point, x, y, onClick)
    local btn = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    btn:SetSize(size, size)
    btn:SetPoint(point, x, y)
    btn:SetAttribute("type1", "spell")
    btn:SetAttribute("spell", spellID)
    btn:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp", "RightButtonDown")
    btn:SetNormalTexture(icon or UIStyle.Texture.default_icon)

    local bg = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    bg:SetSize(size + 10, size + 10)
    bg:SetPoint("CENTER", btn, "CENTER", 0, 0)
    ApplyButtonBackdrop(bg, false)
    btn.bg = bg

    -- 统一悬停效果
    btn:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:Show()
        ApplyButtonBackdrop(bg, true)
    end)
    btn:SetScript("OnLeave", function(s)
        GameTooltip:Hide()
        ApplyButtonBackdrop(bg, false)
    end)

    if onClick then
        btn:SetScript("OnMouseUp", function(s, button)
            onClick(s, button)
        end)
    end

    return btn
end

-- ----------------------------------------------------------------------------
-- 创建统一样式的文本标签
-- @param parent  父框架
-- @param text    显示文本
-- @param font    字体常量（UIStyle.Font.xxx）
-- @param point   锚点
-- @param x       X 偏移
-- @param y       Y 偏移
-- @param color   颜色表（可选，默认 text_normal）
-- 返回：创建的 FontString
-- ----------------------------------------------------------------------------
function UIStyle.CreateLabel(parent, text, font, point, x, y, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or UIStyle.Font.normal)
    fs:SetPoint(point, x, y)
    fs:SetText(text)
    local c = color or UIStyle.Color.text_normal
    fs:SetTextColor(unpack(c))
    fs:SetShadowColor(0, 0, 0, 0.5)
    fs:SetShadowOffset(1, -1)
    return fs
end

-- ----------------------------------------------------------------------------
-- 创建统一样式的弹出列表框体（右键主按钮后展开）
-- @param parent      父框架
-- @param items       列表项表，每项 { icon, spellID, name }
-- @param row_count   行数
-- @param onItemClick 点击列表项回调 (function(item, button))
-- 返回：创建的弹出框架（含 blocker 遮罩）
-- ----------------------------------------------------------------------------
function UIStyle.CreatePopupList(parent, items, row_count, onItemClick)
    local dt = UIStyle.Space
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(dt.popup_w, row_count * dt.popup_row_h + 6)
    frame:SetPoint("BOTTOM", 0, 45)
    ApplyPanelBackdrop(frame, false)

    -- 遮罩：默认阻挡点击，弹出时放行
    local blocker = CreateFrame("Frame", nil, frame)
    blocker:SetAllPoints(frame)
    blocker:SetFrameLevel(frame:GetFrameLevel() + 100)
    blocker:EnableMouse(true)
    frame.blocker = blocker

    frame.icons = {}
    for index, item in ipairs(items) do
        local btn = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        btn:SetSize(dt.popup_btn_size, dt.popup_btn_size)
        btn:SetPoint("BOTTOM", 0, (index - 1) * dt.popup_row_spacing + 5)
        btn:SetAttribute("type1", "spell")
        btn:SetAttribute("spell", item.spellID)
        btn:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp", "RightButtonDown")
        btn:SetNormalTexture(item.icon or UIStyle.Texture.default_icon)

        local bg = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        bg:SetSize(dt.popup_btn_bg, dt.popup_btn_bg)
        bg:SetPoint("CENTER", btn, "CENTER", 0, 0)
        ApplyButtonBackdrop(bg, false)
        btn.bg = bg

        btn:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(item.spellID)
            GameTooltip:Show()
            ApplyButtonBackdrop(bg, true)
        end)
        btn:SetScript("OnLeave", function(s)
            GameTooltip:Hide()
            ApplyButtonBackdrop(bg, false)
        end)
        btn:SetScript("OnMouseUp", function(s, button)
            if onItemClick then
                onItemClick(item, s, button)
            end
        end)

        frame.icons[index] = btn
    end

    frame:Hide()
    frame:SetAlpha(0)
    return frame
end

-- ----------------------------------------------------------------------------
-- 显示/隐藏弹出列表（统一处理 alpha 与遮罩）
-- @param frame   弹出框架
-- @param show    true 显示，false 隐藏
-- ----------------------------------------------------------------------------
function UIStyle.TogglePopup(frame, show)
    if show then
        frame:Show()
        frame:SetAlpha(1)
        if frame.blocker then
            frame.blocker:EnableMouse(false)
        end
    else
        frame:Hide()
        frame:SetAlpha(0)
        if frame.blocker then
            frame.blocker:EnableMouse(true)
        end
    end
end

-- ----------------------------------------------------------------------------
-- 统一屏幕提示（大字淡出 + UIErrorsFrame）
-- @param text 提示文本
-- ----------------------------------------------------------------------------
function UIStyle.ShowAlert(text)
    UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0.0, 1.0)

    if not UIStyle.alertText then
        UIStyle.alertText = UIParent:CreateFontString(nil, "OVERLAY", UIStyle.Font.title)
        UIStyle.alertText:SetPoint("CENTER", 0, 100)
        UIStyle.alertText:SetTextColor(unpack(UIStyle.Color.text_error))
        UIStyle.alertText:SetShadowColor(0, 0, 0, 1)
        UIStyle.alertText:SetShadowOffset(2, -2)
    end

    UIStyle.alertText:SetText(text)
    UIStyle.alertText:SetAlpha(1)
    UIStyle.alertText.fadeInfo = {}
    UIStyle.alertText.fadeInfo.mode = "OUT"
    UIStyle.alertText.fadeInfo.timeToFade = 3
    UIStyle.alertText.fadeInfo.startAlpha = 1
    UIStyle.alertText.fadeInfo.endAlpha = 0
    UIFrameFade(UIStyle.alertText, UIStyle.alertText.fadeInfo)
end

-- ----------------------------------------------------------------------------
-- 对外暴露（全局）
-- ============================================================================
MzxUIStyle = UIStyle
