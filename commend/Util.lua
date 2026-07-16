--- # Api打包
function SpellArgs(name, subtext, icon, castTime, minRange, maxRange, spellID, originalIcon)
    return {
        name = name,
        subtext = subtext,
        icon = icon,
        castTime = castTime,
        minRange = minRange,
        maxRange = maxRange,
        spellID = spellID,
        originalIcon = originalIcon
    }
end

function ShowFrame(frame)
    if not InCombatLockdown() then
        frame:Show()
        frame:EnableMouse(true)
        for _, btn in ipairs(frame.icons or {}) do
            btn:EnableMouse(true)
        end
    end
    frame:SetAlpha(1)
    if frame.blocker then
        frame.blocker:EnableMouse(false) -- 允许点击穿透到按钮
    end
end

function HideFrame(frame)
    if InCombatLockdown() then
        frame:SetAlpha(0)
        if frame.blocker then
            frame.blocker:EnableMouse(true) -- 阻止隐藏弹出窗口的点击
        end
    else
        frame:EnableMouse(false)
        for _, btn in ipairs(frame.icons or {}) do
            btn:EnableMouse(false)
        end
        frame:Hide()
        if frame.blocker then
            frame.blocker:EnableMouse(true)
        end
    end
end
