AddCSLuaFile()

SWEP.Author			= "RandomGuy"
SWEP.Instructions	= "Shoots Harpoons like tf2 or something idk"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType			= "rpg"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.8

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Explosive Harpoon Launcher"
SWEP.Slot				= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ExplosionRange = 146
SWEP.KickHeight = 55

local ShootSound = Sound("Weapon_RPG.NPC_Single")

function SWEP:PrimaryAttack()

	--debugoverlay.Line(Vector(self.Owner:GetPos()), Vector(145.609970, -14.031034, -11391.538086), 10000, Color(255,0,0), true)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:EmitSound( ShootSound )
	self:ShootEffects( self )
	if (!SERVER) then return end

	local ent = ents.Create ( "prop_physics" )
	if ( !IsValid(ent)) then return end
	ent:SetModel("models/props_junk/harpoon002a.mdl")
	ent:SetCollisionGroup(11)
	ent:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 50))
	ent:SetAngles( self.Owner:EyeAngles() )

	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if ( !IsValid (phys)) then ent:Remove() return end

	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 500000
	--local velocity = Vector(30000,0,0)
	phys:EnableGravity(false)
	phys:ApplyForceCenter( velocity )


	ent:AddCallback("PhysicsCollide", function(collider, colData)

		--PrintTable(colData)

		local lineData = {}
		lineData.start = colData.HitPos


		for k, v in pairs(player.GetAll()) do

			lineData.endpos = v:GetPos()+Vector(0,0,self.KickHeight)
			local collisiondistance = lineData.start:DistToSqr(lineData.endpos)
			if collisiondistance < (self.ExplosionRange)^2 then
				local sqrtdst = math.sqrt(collisiondistance)
				local r,g,b
				r = 255
				g = (self.ExplosionRange-self.KickHeight + sqrtdst)
				b = (self.ExplosionRange-self.KickHeight + sqrtdst)
				debugoverlay.Line(lineData.start, lineData.endpos, 2, Color(r,g,b), true)
				--collider:SetVelocity(sqrtdst)

				local kickAmount = lineData.endpos-lineData.start
				--print(kickAmount)
				local kickMult = 2 + (2)*(self.ExplosionRange/sqrtdst)
				kickAmount:Mul(kickMult)
				print("k"..kickMult)
				timer.Simple(0, function()
					v:SetVelocity(kickAmount)
				end)


			end
		end



		local entExplode = ents.Create( "env_explosion" )
		entExplode:SetPos( lineData.start )
		entExplode:SetOwner( ent:GetOwner() )
		entExplode:SetPhysicsAttacker( ent )
		entExplode:Spawn()
		entExplode:SetKeyValue( "iMagnitude", "30" )
		entExplode:SetKeyValue( "iRadiusOverride", self.ExplosionRange )
		entExplode:Fire( "Explode", 0, 0 )
		timer.Simple(0, function() ent:Remove() end)

		--util.BlastDamage( ent, ent:GetOwner(), lineData.start, self.ExplosionRange, 90 )

	end)


end

function SWEP:SecondaryAttack()

end

function SWEP:ShouldDropOnDie()
	return false
end
