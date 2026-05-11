function VoidFrame:MessageStart(text, playerName, languageName, channelName)
    print(channelName .. "|cFA500FF0" .. playerName .. "|r say: " .. text)
    if text == "123" then
        C_PartyInfo.InviteUnit(playerName)
    elseif text == "团队" then
        C_PartyInfo.ConfirmConvertToRaid()
    elseif text == "小队" then
        C_PartyInfo.ConvertToParty()
    elseif string.find(text, "倒数") then
        local num_str = string.gsub(text, "倒数", "")
        local num = tonumber(strtrim(num_str)) or 10
        print("|cFFFF0000开始倒计时|r", num, "|cFFFF0000秒|r")
        C_PartyInfo.DoCountdown(num)
    elseif text == "属性" then
        SendChatMessage(self:Void_PlayerInfo(), "WHISPER", nil, playerName)
    end
end

function VoidFrame:PartyStart(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
    AcceptGroup()
    StaticPopup_Hide("PARTY_INVITE")
    print("被|cFA500FF0" .. name .. "|r邀请进组")
end