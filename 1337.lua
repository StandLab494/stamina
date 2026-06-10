while task.wait() do 
    local Sprinting = game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting 
    local stamina = require(Sprinting) 
    stamina.MaxStamina = 100 
    stamina.StaminaGain = 1000 
    stamina.StaminaLoss = 0 
    stamina.SprintSpeed = 28 
    stamina.StaminaLossDisabled = true 
end
