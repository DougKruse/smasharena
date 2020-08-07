AddCSLuaFile()

SWEP.Author			= "RandomGuy"
SWEP.Instructions	= "Charge A precise bolt of energy that will knock the target flying"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_physcannon.mdl"
SWEP.WorldModel			= "models/weapons/w_physics.mdl"
SWEP.HoldType			= "ar2"

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.Delay1 = 0.01
SWEP.Primary.Delay2 = 1.5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Sniper Laser"
SWEP.Slot				= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true

local ShootSound1 = Sound("Weapon_AR2.Special1")
local ShootSound2 = Sound("AlyxEMP.Discharge")

function SWEP:PrimaryAttack()
  self:StopIdle()
  if self.Weapon:Clip1() >= 100 then

    hook.Add("PlayerButtonUp", "ready_for_fire" .. self:EntIndex(), function(ply, button)
      if ( !IsValid(self)) then return end
      if ply == self.Owner and button == 107 then
        self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay2 )
        self:EmitSound( ShootSound2)
        self.Weapon:SetClip1(0)
        self.Owner:MuzzleFlash()

        local effectdata = EffectData()
        effectdata:SetOrigin( self.Owner:EyePos() + (self.Owner:GetAimVector()*15))
        util.Effect ( "TeslaZap", effectdata)

        self.Weapon:SendWeaponAnim(	181)

        local bullet = {}
        bullet.Src = self.Owner:GetShootPos()
        bullet.Dir = self.Owner:GetAimVector()
        bullet.Spread = Vector(0,0,0)
        bullet.Tracer = 1
        bullet.HullSize = 10
        bullet.Force = 10000
        bullet.Damage = 10
        bullet.TracerName = "laser_gun_tracer_02"
        self.Owner:FireBullets( bullet )

        self:Tracer()
        self.Owner:ViewPunch( Angle( -15, 0, 0 ) )




        local ply,wep=self.Owner,self.Weapon
        local av,spos,tr=ply:GetAimVector(),ply:GetShootPos()
        local epos=spos+av*10000000
        local kmins = Vector(1,1,1) * 7
        local kmaxs = Vector(1,1,1) * 7

        local tr = util.TraceHull({start=spos, endpos=epos, filter=ply, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

        -- Hull might hit environment stuff that line does not hit
        if not IsValid(tr.Entity) then
          tr = util.TraceLine({start=spos, endpos=epos, filter=ply, mask=MASK_SHOT_HULL})
        end

        local ent=tr.Entity
        local isply=ent:IsPlayer()

        if !tr.Hit or !(tr.HitWorld or IsValid(ent)) then return end

        if isply then
          if ent:GetMoveType()==MOVETYPE_LADDER then ent:SetMoveType(MOVETYPE_WALK) end

          ent:SetVelocity(self.Owner:GetAimVector()*100000)
          --ent.was_pushed = {att=self.Owner, t=CurTime(), self.Weapon=self:GetClass()}
          do
            local dmg=DamageInfo()
            dmg:SetDamage(0)
            dmg:SetAttacker(ply)
            dmg:SetInflictor(self.Weapon)
            dmg:SetDamageForce(av*2000)
            dmg:SetDamagePosition(ply:GetPos())
            dmg:SetDamageType(DMG_ENERGYBEAM)
            ent:DispatchTraceAttack(dmg,tr)
          end

        end
      end
      hook.Remove("PlayerButtonUp", "ready_for_fire" .. self:EntIndex())
    end)

  else
    hook.Remove("PlayerButtonUp", "ready_for_fire" .. self:EntIndex())
    hook.Remove("PlayerButtonUp", "charging" .. self:EntIndex())

    self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay1 )
    self.Weapon:SetClip1(self.Weapon:Clip1() + 1)
    self:EmitSound( ShootSound1)
    hook.Add("PlayerButtonUp", "charging" .. self:EntIndex(), function(ply, button)
      if ( !IsValid(self)) then return end
      if ply == self.Owner and button == 107 then
        self:Idle()
      end

    end)

  end

end


function SWEP:SecondaryAttack()

end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:Deploy()
  self:Idle()
  return true
end

function SWEP:Holster()
	self:StopIdle()
  hook.Remove("PlayerButtonUp", "ready_for_fire" .. self:EntIndex())
  hook.Remove("PlayerButtonUp", "charging" .. self:EntIndex())
  self.Weapon:SetClip1(0)
  return true
end

function SWEP:Idle()
  if ( CLIENT || !IsValid( self.Owner ) ) then return end
  timer.Create( "weapon_idle" .. self:EntIndex(), 0.05 , 0, function()
    if ( !IsValid( self ) ) then return end
    if self.Weapon:Clip1() > 2 then self.Weapon:SetClip1(self.Weapon:Clip1() - 3)
    else
      self.Weapon:SetClip1(0)
    end
  end )
end

function SWEP:StopIdle()
  timer.Destroy( "weapon_idle" .. self:EntIndex() )
end

function SWEP:DoImpactEffect( tr, nDamageType )

	if ( tr.HitSky ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "cball_explode", effectdata )
end

function SWEP:Tracer()
			local tr = self.Owner:GetEyeTrace()

			local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetStart( self.Owner:GetShootPos() )
			effectdata:SetAttachment( 1 )
			effectdata:SetEntity( self.Weapon )
			util.Effect( "laser_gun_tracer_02", effectdata, true, true )
end

function SWEP:FirinMaLazor(ply, button, self)

end
