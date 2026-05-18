local skill_line = {
    names = { "匕首", "单手斧", "单手锤", "单手剑", "双手斧", "双手锤", "双手剑", "长柄武器", "徒手战斗", "法杖", "防御", "弩" },
    up = {
        p = "BOTTOMRIGHT",
        x = -430,
        y = 30
    },
    wight = 160
}

function VoidFrame.GetSkillLineInfo()
    local name_table = {}
    local rank_table = {}
    for i = 1, GetNumSkillLines() do
        local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription =
            GetSkillLineInfo(i)
        for index, value in ipairs(skill_line.names) do
            if value == skillName then
                table.insert(name_table, string.format("|cFFFFCC00%s|r", skillName))
                table.insert(rank_table, string.format("%d/%d", skillRank, skillMaxRank))
            end
        end
    end
    return name_table, rank_table
end

--- # 创建武器熟练度框体
function VoidFrame:Void_CreateSkillLineInfoFrame(name_table, rank_table)
    VoidModClassicCharacterDB.point.skill_line = VoidModClassicCharacterDB.point.skill_line or {
        p = skill_line.up.p,
        x = skill_line.up.x,
        y = skill_line.up.y
    }

    self.voidSkillLineInfo = CreateFrame("Frame", "SkillLine", UIParent, "BackdropTemplate")
    self.voidSkillLineInfo:SetSize(skill_line.wight, #name_table * 18 + 10)
    self.voidSkillLineInfo:SetPoint(VoidModClassicCharacterDB.point.skill_line.p,
        VoidModClassicCharacterDB.point.skill_line.x,
        VoidModClassicCharacterDB.point.skill_line.y)
    SetInfoFrameStyle(self.voidSkillLineInfo)

    self.voidSkillLineInfoText = {
        self.voidSkillLineInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        self.voidSkillLineInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    }

    AddStringLeft(self.voidSkillLineInfoText[1], table.concat(name_table, "\n"))
    AddStringRight(self.voidSkillLineInfoText[2], table.concat(rank_table, "\n"))
end

--- # 创建武器熟练度信息框体
function VoidFrame:Void_CreateSkillLineInfo()
    self:Void_CreateSkillLineInfoFrame(VoidFrame:GetSkillLineInfo())

    MovableDisplay(self.voidSkillLineInfo)

    MovableSkillLineFrameStop()
end

--- # 刷新武器熟练度信息框体
function VoidFrame:Void_UpdateSkillLineInfo()
    if self.voidSkillLineInfo then
        local name_table, rank_table = VoidFrame:GetSkillLineInfo()
        self.voidSkillLineInfo:SetSize(skill_line.wight, #name_table * 18 + 10)
        if self.voidSkillLineInfoText then
            self.voidSkillLineInfoText[1]:SetText(table.concat(name_table, "\n"))
            self.voidSkillLineInfoText[2]:SetText(table.concat(rank_table, "\n"))
        end
    end
end

function MovableSkillLineFrameStop()
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
