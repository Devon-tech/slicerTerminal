SWEP.Author = "Devon"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Devons Hacking Tool"

SWEP.ViewModel = "models/weapons/c_toolgun.mdl" -- Gets the model path
SWEP.WorldModel = "models/weapons/w_toolgun.mdl" -- Gets the model path 

SWEP.Spawnable = true
SWEP.SetHoldType = "pistol"
SWEP.UseHands = true

SWEP.DrawAmmo = false

SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.ShouldDropOnDie = false

-- Disables attacking with the weapon
function SWEP:CanPrimaryAttack()
    return false
end