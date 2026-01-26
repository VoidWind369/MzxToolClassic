function MovableDisplay(frame)
    -- 启用拖动
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    -- 拖动开始
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
        self.isMoving = true
    end)

    -- 双击检测
    local lastClickTime = 0
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            local currentTime = GetTime()
            if currentTime - lastClickTime < 0.3 then -- 300ms内
                self.doubleClick = true
            else
                self.doubleClick = false
            end
            lastClickTime = currentTime
        end
    end)

    return frame
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
function AddString(fontString, string, scale, x)
    fontString:SetPoint("LEFT", x or 13.5, 0)
    fontString:SetText(string)
    fontString:SetTextScale(scale or 1)
    fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(scale and scale * 1.5 or 1.5)
    fontString:SetJustifyH("LEFT")
end

--- # 显示数字通用属性
function AddNumber(fontString, number, scale, x)
    fontString:SetPoint("RIGHT", x or -13.5, 0)
    fontString:SetText(number)
    fontString:SetTextScale(scale or 1)
    fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(scale and scale * 1.5 or 1.5)
    fontString:SetJustifyH("RIGHT")
end
