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

--- # 拖动停止
--- * frame: 拖动停止的框架
--- * database: 框架的位置数据
function MovableFrameStop(frame, database, default_point)
    -- 拖动停止
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        database.p = p    -- 保存
        database.x = xOfs -- 保存
        database.y = yOfs -- 保存
    end)

    -- 双击居中
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(default_point.p, default_point.x, default_point.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            database.p = p    -- 保存
            database.x = xOfs -- 保存
            database.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end
