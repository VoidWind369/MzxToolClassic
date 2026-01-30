function WhiteTransparentFrame(self, infos)
    local bar_width = (infos.dot_size + infos.dot_spacing) * infos.max_stacks
    local bar_height = infos.dot_size + 10

    self:SetSize(bar_width + infos.dot_spacing + 12, bar_height + infos.dot_spacing)
    self:SetFrameStrata("HIGH")
    self:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    self:SetBackdropColor(0, 0, 0, 0.15)
    self:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
end

function WhiteTransparentDot(i, dot, infos)
    dot:SetSize(infos.dot_size, infos.dot_size)
    dot:SetPoint("LEFT", (i - 1) * (infos.dot_size + infos.dot_spacing) + (infos.dot_spacing / 2) + 6, 0)

    dot:SetAlpha(0.3)
end

function WhiteTransparentDotGlow(dotGlow, infos)
    dotGlow:SetSize(infos.dot_size, infos.dot_size)
    dotGlow:SetAlpha(0.2)
    dotGlow:SetPoint("CENTER")
    dotGlow:SetBlendMode("ADD")
    dotGlow:Hide()
    dotGlow:SetTexture(518448)
end

function WhiteTransparentDotTex(dotTex, infos)
    dotTex:SetSize(infos.dot_size, infos.dot_size)
    dotTex:SetPoint("CENTER")
    dotTex:SetTexture(518448)
    -- 初始状态
    dotTex:SetGradient("VERTICAL",
        CreateColor(0.5, 0.5, 0.5, 1),
        CreateColor(0.2, 0.2, 0.2, 1)
    )
end

--- # 框体通用属性
function SetInfoFrameStyle(frame)
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
function AddString(fontString, string, scale, x, y)
    fontString:SetPoint("LEFT", x or 13.5, y or 0)
    fontString:SetText(string)
    fontString:SetTextScale(scale or 1)
    fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(scale and scale * 1.5 or 1.5)
    fontString:SetJustifyH("LEFT")
end

--- # 显示数字通用属性
function AddNumber(fontString, number, scale, x, y)
    fontString:SetPoint("RIGHT", x or -13.5, y or 0)
    fontString:SetText(number)
    fontString:SetTextScale(scale or 1)
    fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(scale and scale * 1.5 or 1.5)
    fontString:SetJustifyH("RIGHT")
end

--- # 显示图片通用属性
function AddImage(texture, image, width, height, x, y)
    texture:SetTexture(image)
    texture:SetSize(width, height)
    texture:SetPoint("LEFT", x, y)
end

--- # 显示图标通用属性
function AddIcon(texture, image, size, x, y)
    AddImage(texture, image, size, size, x, y)
end
