
AddCSLuaFile()

SWEP.Author			= "RandomGuy"
SWEP.Instructions	= "Fires 5 Sinks with less than surgical precision"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 2

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Launch Shotgun"
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

local ShootSound = Sound("Weapon_Extinguisher.Double")

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:EmitSound( ShootSound )
	self:ShootEffects( self )
	if (!SERVER) then return end
	for i=1,5 do
		self:ShotgunChuck("models/props_c17/FurnitureSink001a.mdl")
	end


end

function SWEP:SecondaryAttack()

end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:ShotgunChuck( model_file )
	local ent = ents.Create ( "prop_physics" )
	if ( !IsValid(ent)) then return end
	ent:SetModel(model_file)

	ent:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 40))
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if ( !IsValid (phys)) then ent:Remove() return end

	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 200000
	velocity = velocity + ( VectorRand() * 20000 ) -- a random element
	--local velocity = Vector(30000,0,0)
	phys:ApplyForceCenter( velocity )

	timer.Simple ( 5, function() ent:Remove() end)
end
