AddCSLuaFile()
if SERVER then
  util.AddNetworkString("Bat Primary Hit")
else

  SWEP.PrintName="Homerun Bat"
  SWEP.Author="Gamefreak"
  SWEP.Instructions = "Left click to hit a home run!\nYou will run 25% faster with it in your Hands."
  SWEP.Slot=0

  SWEP.Spawnable			= true
  SWEP.AdminSpawnable		= true

  SWEP.ViewModelFlip=false


  sound.Add{
    name="Bat.Swing",
    channel=CHAN_STATIC,
    volume=1,
    level=40,
    pitch=100,
    sound="weapons/iceaxe/iceaxe_swing1.wav"
  }

  sound.Add{
    name="Bat.Sound",
    channel=CHAN_STATIC,
    volume=1,
    level=65,
    pitch=100,
    sound="nessbat/gamefreak/bat_sound.wav"
  }

  sound.Add{
    name="Bat.HomeRun",
    channel=CHAN_STATIC,
    volume=1,
    level=120,
    pitch=100,
    sound="nessbat/gamefreak/homerun.wav"
  }

end


SWEP.ViewModel=Model("models/weapons/gamefreak/v_nessbat.mdl")
SWEP.WorldModel=Model("models/weapons/gamefreak/w_nessbat.mdl")

SWEP.HoldType="melee"


SWEP.Primary.Damage=0
SWEP.Primary.Delay=.7
SWEP.Primary.ClipSize=2
SWEP.Primary.DefaultClip=2
SWEP.Primary.Automatic=true
SWEP.Primary.Ammo="none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DeployDelay=0.9
SWEP.Range=100
SWEP.VelocityBoostAmount=500
SWEP.DeploySpeed = 25


function SWEP:Deploy()
  self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
  self:SetNextPrimaryFire(CurTime()+self.DeployDelay)
  return self.BaseClass.Deploy(self)
end


function SWEP:PrimaryAttack()
  local ply,wep=self.Owner,self.Weapon
  wep:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
  if !IsValid(ply) or wep:Clip1()<=0 then return end

  ply:SetAnimation(PLAYER_ATTACK1)
  wep:SendWeaponAnim(ACT_VM_MISSCENTER)
  wep:EmitSound("Bat.Swing")

  local av,spos,tr=ply:GetAimVector(),ply:GetShootPos()
  local epos=spos+av*self.Range
  local kmins = Vector(1,1,1) * 7
  local kmaxs = Vector(1,1,1) * 7

  self.Owner:LagCompensation( true )

  local tr = util.TraceHull({start=spos, endpos=epos, filter=ply, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

  -- Hull might hit environment stuff that line does not hit
  if not IsValid(tr.Entity) then
    tr = util.TraceLine({start=spos, endpos=epos, filter=ply, mask=MASK_SHOT_HULL})
  end

  self.Owner:LagCompensation( false )

  local ent=tr.Entity

  if !tr.Hit or !(tr.HitWorld or IsValid(ent)) then return end

  if ent:GetClass()=="prop_ragdoll" then
    ply:FireBullets{Src=spos,Dir=av,Tracer=0,Damage=0}
  end

  if CLIENT then return end

  net.Start("Bat Primary Hit")
  net.WriteTable(tr)
  net.WriteEntity(ply)
  net.WriteEntity(wep)
  net.Broadcast()

  local isply=ent:IsPlayer()

  if isply then

    wep:SetNextPrimaryFire(CurTime()+wep.Primary.Delay*4)

    if ent:GetMoveType()==MOVETYPE_LADDER then ent:SetMoveType(MOVETYPE_WALK) end

    local boost=wep.VelocityBoostAmount
    ent:SetVelocity(ply:GetVelocity()+Vector(av.x/2,av.y/2,math.max(1,av.z+.35))*math.Rand(boost*.8,boost*1.2)*2)
    ent.was_pushed = {att=self.Owner, t=CurTime(), wep=self:GetClass()}
  elseif ent:GetClass()=="prop_physics" then
    local phys=ent:GetPhysicsObject()
    if IsValid(phys) then
      local boost=wep.VelocityBoostAmount
      phys:ApplyForceOffset(ply:GetVelocity()+Vector(av.x,av.y,math.max(1,av.z+.35))*math.Rand(boost*4,boost*8),tr.HitPos)
    end
  end

  do
    local dmg=DamageInfo()
    dmg:SetDamage(isply and self.Primary.Damage or self.Primary.Damage*.5)
    dmg:SetAttacker(ply)
    dmg:SetInflictor(wep)
    dmg:SetDamageForce(av*2000)
    dmg:SetDamagePosition(ply:GetPos())
    dmg:SetDamageType(DMG_CLUB)
    ent:DispatchTraceAttack(dmg,tr)
  end


end

function SWEP:SecondaryAttack()

end

if CLIENT then
  net.Receive("Bat Primary Hit",function()
      local tr,ply,wep=net.ReadTable(),net.ReadEntity(),net.ReadEntity()
      local ent=tr.Entity

      local edata=EffectData()
      edata:SetStart(tr.StartPos)
      edata:SetOrigin(tr.HitPos)
      edata:SetNormal(tr.Normal)
      edata:SetSurfaceProp(tr.SurfaceProps)
      edata:SetHitBox(tr.HitBox)
      edata:SetEntity(ent)

      local isply=ent:IsPlayer()

      if isply or ent:GetClass()=="prop_ragdoll" then
        if isply then
          wep:EmitSound("Bat.Sound")
          timer.Simple(.48,function()
              if IsValid(ent) and IsValid(wep) then
                if ent:Alive() then
                  wep:EmitSound("Bat.HomeRun")
                end
              end
            end)
        end
        util.Effect("BloodImpact", edata)
      else
        util.Effect("Impact",edata)
      end
    end)
end
