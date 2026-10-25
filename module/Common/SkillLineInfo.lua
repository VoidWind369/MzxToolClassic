local skill_line = {
    names = { "匕首", "单手斧", "单手锤", "单手剑", "双手斧", "双手锤", "双手剑", "长柄武器", "徒手战斗", "法杖", "防御", "弩", "魔杖" },
    up = {
        p = "BOTTOMRIGHT",
        x = -430,
        y = 30
    },
    wight = 160
}

function MzxToolFrame.GetSkillLineInfo()
    local slill_table = {}
    local num = 0
    for i = 1, GetNumSkillLines() do
        local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription =
            GetSkillLineInfo(i)
        for _, value in ipairs(skill_line.names) do
            if value == skillName then
                num = num + 1
                slill_table[num] = {
                    name = string.format("|cFFFFCC00%s|r", skillName),
                    rank = string.format("%d/%d", skillRank, skillMaxRank)
                }
            end
        end
    end
    return slill_table
end

--- # 创建武器熟练度框体
function MzxToolFrame:Void_CreateSkillLineInfoFrame(skill_table, rank_table)
    MzxToolClassicCharacterDB.point.skill_line = MzxToolClassicCharacterDB.point.skill_line or {
        p = skill_line.up.p,
        x = skill_line.up.x,
        y = skill_line.up.y
    }

    self.voidSkillLineInfo = CreateFrame("Frame", "SkillLine", UIParent, "BackdropTemplate")
    self.voidSkillLineInfo:SetSize(skill_line.wight, #skill_table * 20 + 10)
    self.voidSkillLineInfo:SetPoint(MzxToolClassicCharacterDB.point.skill_line.p,
        MzxToolClassicCharacterDB.point.skill_line.x,
        MzxToolClassicCharacterDB.point.skill_line.y)
    SetInfoFrameStyle(self.voidSkillLineInfo, true)

    self.voidSkillLineInfoText = {}
    for index, value in ipairs(skill_table) do
        self.voidSkillLineInfoText[index] = {
            self.voidSkillLineInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
            self.voidSkillLineInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        }
        AddStringLeft(self.voidSkillLineInfoText[index][1], value.name, nil, 6,
            (1 - index) * 20 + (#skill_table - 1) * 10)
        AddStringRight(self.voidSkillLineInfoText[index][2], value.rank, nil, -5,
            (1 - index) * 20 + (#skill_table - 1) * 10)
    end
end

--- # 创建武器熟练度信息框体
function MzxToolFrame:Void_CreateSkillLineInfo()
    self:Void_CreateSkillLineInfoFrame(MzxToolFrame:GetSkillLineInfo())

    MovableDisplay(self.voidSkillLineInfo)
    MovableFrameStop(self.voidSkillLineInfo, MzxToolClassicCharacterDB.point.skill_line, skill_line.up)
end

--- # 刷新武器熟练度信息框体
function MzxToolFrame:Void_UpdateSkillLineInfo()
    if self.voidSkillLineInfo then
        local skill_table = MzxToolFrame:GetSkillLineInfo()
        self.voidSkillLineInfo:SetSize(skill_line.wight, #skill_table * 20 + 10)
        if self.voidSkillLineInfoText then
            for index, value in ipairs(skill_table) do
                self.voidSkillLineInfoText[index][1]:SetText(value.name)
                self.voidSkillLineInfoText[index][2]:SetText(value.rank)
            end
        end
    end
end
