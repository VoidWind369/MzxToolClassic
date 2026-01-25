local skill_line = {
    names = { "匕首", "单手斧", "单手锤", "单手剑", "双手斧", "双手锤", "双手剑", "长柄武器", "徒手战斗", "法杖", "防御" },
    up = {
        p = "CENTER",
        x = 0.0,
        y = 0.0
    },
}

function VoidFrame.GetSkillLineInfo()
    local str_table = {
        "|cFFFFCC00"
    }
    for i = 1, GetNumSkillLines() do
        local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription =
            GetSkillLineInfo(i)
        for index, value in ipairs(skill_line.names) do
            if value == skillName then
                table.insert(str_table, string.format("%s %d/%d", skillName, skillRank, skillMaxRank))
            end
        end
    end
    table.insert(str_table, "|r")
    return table.concat(str_table, "\n")
end

--- # 创建武器熟练度框体
function VoidFrame:Void_CreateSkillLineInfoDisplay(str)
    VoidModClassicCharacterDB.point.skill_line = VoidModClassicCharacterDB.point.skill_line or skill_line.up
    VoidModClassicCharacterDB.point.skill_line.p = VoidModClassicCharacterDB.point.skill_line.p or skill_line.up.p
    VoidModClassicCharacterDB.point.skill_line.x = VoidModClassicCharacterDB.point.skill_line.x or skill_line.up.x
    VoidModClassicCharacterDB.point.skill_line.y = VoidModClassicCharacterDB.point.skill_line.y or skill_line.up.y
    print("p", VoidModClassicCharacterDB.point.up.p)
    self.voidSkillLineInfo = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidSkillLineInfo:SetSize(145, 155)
    self.voidSkillLineInfo:SetPoint(VoidModClassicCharacterDB.point.skill_line.p,
        VoidModClassicCharacterDB.point.skill_line.x,
        VoidModClassicCharacterDB.point.skill_line.y)
    SetPlayerInfoFrameStyle(self.voidSkillLineInfo)

    self.voidSkillLineInfoText = self.voidSkillLineInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")

    AddString(self.voidSkillLineInfoText, str)
end

--- # 创建武器熟练度信息框体
function VoidFrame:Void_CreateSkillLineInfo()
    local info = VoidFrame:GetSkillLineInfo()
    self:Void_CreateSkillLineInfoDisplay(info)

    MovableDisplay(self.voidSkillLineInfo)

    MovableSkillLineDisplayStop()
end

--- # 刷新武器熟练度信息框体
function VoidFrame:Void_UpdateSkillLineInfoDisplay()
    local info = VoidFrame:GetSkillLineInfo()
    if self.voidSkillLineInfoText then
        self.voidSkillLineInfoText:SetText(info)
    end
end

function MovableSkillLineDisplayStop()
    -- 拖动停止
    VoidFrame.voidSkillLineInfo:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModClassicCharacterDB.point.skill_line.p = p    -- 保存
        VoidModClassicCharacterDB.point.skill_line.x = xOfs -- 保存
        VoidModClassicCharacterDB.point.skill_line.y = yOfs -- 保存
    end)

    -- 双击居中
    VoidFrame.voidSkillLineInfo:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(skill_line.up.p, skill_line.up.x, skill_line.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModClassicCharacterDB.point.skill_line.p = p    -- 保存
            VoidModClassicCharacterDB.point.skill_line.x = xOfs -- 保存
            VoidModClassicCharacterDB.point.skill_line.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end
