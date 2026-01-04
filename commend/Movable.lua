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
            if currentTime - lastClickTime < 0.3 then  -- 300ms内
                self.doubleClick = true
            else
                self.doubleClick = false
            end
            lastClickTime = currentTime
        end
    end)

    return frame
end