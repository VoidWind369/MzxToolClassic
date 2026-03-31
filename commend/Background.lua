function WhiteTransparentFrame(self, infos)
    local bar_width = (infos.dot_size + infos.dot_spacing) * infos.max_stacks
    local bar_height = infos.dot_size + 10

    self:SetSize(bar_width + infos.dot_spacing + 12, bar_height + infos.dot_spacing)
    self:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    self:SetBackdropColor(0, 0, 0, 0.3)
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
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.3)
    frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
end

--- # 框体通用属性
function SetInfoTextureStyle(texture)
    texture:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
    texture:SetAlpha(0.3)
end

--- # 按钮通用属性
function SetButtonFrameStyle(frame, width, height, point, x, y)
    frame:SetSize(width, height)
    frame:SetPoint(point, x, y)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        -- insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(0.8, 0, 0.7, 0.8)
    frame:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
end

--- # 显示数字通用属性
function AddString(fontString, string, scale, point, x, y)
    fontString:SetPoint(point, x, y)
    fontString:SetText(string)
    fontString:SetTextScale(scale)
    fontString:SetShadowColor(0, 0, 0, 0.5)
    fontString:SetSpacing(scale and scale * 1.5 or 1.5)
    fontString:SetJustifyH(point)
end

--- # 显示文字通用属性
function AddStringLeft(fontString, string, scale, x, y)
    AddString(fontString, string, scale or 1, "LEFT", x or 13.5, y or 0)
end

--- # 显示数字通用属性
function AddStringCenter(fontString, string, scale, x, y)
    AddString(fontString, string, scale or 1, "CENTER", x or 0, y or 0)
end

--- # 显示数字通用属性
function AddStringRight(fontString, string, scale, x, y)
    AddString(fontString, string, scale or 1, "RIGHT", x or -13.5, y or 0)
end

--- # 显示图片通用属性
function AddImage(point, texture, image, width, height, x, y)
    texture:SetTexture(image)
    texture:SetSize(width, height)
    texture:SetPoint(point, x, y)
end

--- # 显示图标通用属性
function AddIconLeft(texture, image, size, x, y)
    AddImage("LEFT", texture, image, size, size, x, y)
end

--- # 显示图标通用属性
function AddIconCenter(texture, image, size, x, y)
    AddImage("CENTER", texture, image, size, size, x, y)
end

--- # 显示图标通用属性
function AddIconBottom(texture, image, size, x, y)
    AddImage("BOTTOM", texture, image, size, size, x, y)
end

--- # 面板按钮通用属性
function AddButton(button_frame, spell, width, height, point, x, y)
    button_frame:SetSize(width, height)
    button_frame:SetPoint(point, x, y)
    button_frame:SetAttribute("type", "spell")
    button_frame:SetAttribute("spell", spell) -- 设置要施放的技能名
    button_frame:RegisterForClicks("AnyUp", "AnyDown")
end

--- # 技能按钮通用属性
function AddLeftButton(button_frame, icon, spell, size, point, x, y)
    button_frame:SetNormalTexture(icon)
    button_frame:SetSize(size, size)
    button_frame:SetPoint(point, x, y)
    button_frame:SetAttribute("type1", "spell")
    button_frame:SetAttribute("spell", spell) -- 设置要施放的技能名
    button_frame:RegisterForClicks("AnyUp", "AnyDown")
end

function MinutesOrSeconds(seconds)
    if seconds > 60000 then
        return string.format("%.0fm", seconds / 60000)
    elseif seconds < 10000 then
        return string.format("%.1fs", seconds / 1000)
    else
        return string.format("%.0fs", seconds / 1000)
    end
end

function MzxDebug(...)
    if VoidModClassicCharacterDB.status.Debug then
        print(...)
    end
end
