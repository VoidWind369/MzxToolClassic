function InitDatabase()
    VoidModClassicDB = VoidModClassicDB or {}
    VoidModClassicCharacterDB = VoidModClassicCharacterDB or {
        status = {},
        point = {}
    }
    VoidModClassicCharacterDB.status = VoidModClassicCharacterDB.status or {
        PlayerInfo = true,
        SkillLine = true,
        ShieldInfo = true,
        TotemInfo = true
    }
end
