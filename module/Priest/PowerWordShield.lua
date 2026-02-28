function VoidFrame:GetPowerWordShield()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(600)

    local name =  UnitBuff("player", 1)
    local value =  select(16, UnitBuff("player", 1))
    print(name, value)
    if aura then
        print(aura.name, aura.maxCharges)
        for i, point in pairs(aura.points) do
            print(i, point)
        end
    else
        print("no")
    end
end
