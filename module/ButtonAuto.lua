function SimulateButtonClick(buttonName)
    local button = _G[buttonName]
    if button then
        button:Click()
    else
        print("按钮 " .. buttonName .. " 未找到")
    end
end