/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct SAxiiEffects
{
	editable var castEffect		: name;
	editable var throwEffect	: name;
}

statemachine class W3AxiiEntity extends W3SignEntity
{
	editable var effects		: array< SAxiiEffects >;	
	editable var projTemplate	: CEntityTemplate;
	editable var distance		: float;	
	editable var projSpeed		: float;
	
	default skillEnum = S_Magic_5;
	
	protected var targets		: array<CActor>;
	protected var orientationTarget : CActor;
	
	public function GetSignType() : ESignType
	{
		return ST_Axii;
	}
	
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{	
		var ownerActor : CActor;
		var prevSign : W3SignEntity;
		
		ownerActor = inOwner.GetActor();
		
		if( (CPlayer)ownerActor )
		{
			prevSign = GetWitcherPlayer().GetSignEntity(ST_Axii);
			if(prevSign)
				prevSign.OnSignAborted(true);
		}
		
		ownerActor.SetBehaviorVariable( 'bStopSign', 0.f );
		/*if ( inOwner.CanUseSkill(S_Magic_s17) && inOwner.GetSkillLevel(S_Magic_s17) > 1)
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 1.f );
		else*/ //modSigns: remove as it breaks Puppet
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 0.f );
		
		return super.Init( inOwner, prevInstance, skipCastingAnimation );
	}
		
	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'axii_ready' )
		{
			PlayEffect( effects[fireMode].throwEffect );
		}
		else if ( eventName == 'horse_cast_begin' )
		{
			OnHorseStarted();
		}
		else
		{
			return super.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		var i : int;
		
		SelectTargets();
		
		for(i=0; i<targets.Size(); i+=1)
		{
			AddMagic17Effect(targets[i]);
		}
		
		Attach(true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
			
		PlayEffect( effects[fireMode].castEffect );
		
		if ( owner.ChangeAspect( this, S_Magic_s05 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AxiiChanneled' );
		}
		else
		{
			GotoState( 'AxiiCast' );
		}		
	}
	
	
	function OnHorseStarted()
	{
		Attach(true);
		PlayEffect( effects[fireMode].castEffect );
	}
	
	
	private final function IsTargetValid(actor : CActor, isAdditionalTarget : bool) : bool
	{
		var npc : CNewNPC;
		var horse : W3HorseComponent;
		var attitude : EAIAttitude;
		
		if(!actor)
			return false;
			
		if(!actor.IsAlive())
			return false;
		
				
		attitude = GetAttitudeBetween(owner.GetActor(), actor);
		
		
		if(isAdditionalTarget && attitude != AIA_Hostile)
			return false;
		
		npc = (CNewNPC)actor;
		
	
		if(attitude == AIA_Friendly)
		{
			
			if(npc.GetNPCType() == ENGT_Quest && !actor.HasTag(theGame.params.TAG_AXIIABLE_LOWER_CASE) && !actor.HasTag(theGame.params.TAG_AXIIABLE))
				return false;
		}
					
		
		if(npc)
		{
			horse = npc.GetHorseComponent();				
			if(horse && !horse.IsDismounted())	
			{
				if(horse.GetCurrentUser() != owner.GetActor())	
					return false;
			}
		}
		
		return true;
	}
	
	private function SelectTargets()
	{
		var projCount, i, j : int;
		var actors, finalActors : array<CActor>;
		var ownerPos : Vector;
		var ownerActor : CActor;
		var actor : CActor;
		
		if(owner.CanUseSkill(S_Magic_s19))
			projCount = 2;
		else
			projCount = 1;
		
		targets.Clear();
		actor = (CActor)thePlayer.slideTarget;	
		
		if(actor && IsTargetValid(actor, false))
		{
			targets.PushBack(actor);
			//theGame.witcherLog.AddMessage("Primary target"); //modSigns: debug
			projCount -= 1;
			
			if(projCount == 0)
				return;
		}
		
		ownerActor = owner.GetActor();
		ownerPos = ownerActor.GetWorldPosition();
		
		
		actors = ownerActor.GetNPCsAndPlayersInCone(15, VecHeading(ownerActor.GetHeadingVector()), 120, 20, , FLAG_OnlyAliveActors + FLAG_TestLineOfSight);
					
		
		for(i=actors.Size()-1; i>=0; i-=1)
		{
			
			if(ownerActor == actors[i] || actor == actors[i] || !IsTargetValid(actors[i], true))
				actors.Erase(i);
		}
		
		
		if(actors.Size() > 0)
			finalActors.PushBack(actors[0]);
					
		for(i=1; i<actors.Size(); i+=1)
		{
			for(j=0; j<finalActors.Size(); j+=1)
			{
				if(VecDistance(ownerPos, actors[i].GetWorldPosition()) < VecDistance(ownerPos, finalActors[j].GetWorldPosition()))
				{
					finalActors.Insert(j, actors[i]);
					break;
				}
			}
			
			
			if(j == finalActors.Size())
				finalActors.PushBack(actors[i]);
		}
		
		
		if(finalActors.Size() > 0)
		{
			for(i=0; i<projCount; i+=1)
			{
				if(finalActors[i])
				{
					targets.PushBack(finalActors[i]);
					//theGame.witcherLog.AddMessage("Secondary target"); //modSigns: debug
				}
				else
					break;	
			}
		}
	}
	
	protected function ProcessThrow()
	{
		var proj : W3AxiiProjectile;
		var i : int;				
		var spawnPos : Vector;
		var spawnRot : EulerAngles;		
		
		
		
				
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		
		
		StopEffect( effects[fireMode].castEffect );
		PlayEffect('axii_sign_push');
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			proj = (W3AxiiProjectile)theGame.CreateEntity( projTemplate, spawnPos, spawnRot );
			proj.PreloadEffect( proj.projData.flyEffect );
			proj.ExtInit( owner, skillEnum, this );			
			proj.PlayEffect(proj.projData.flyEffect );				
			proj.ShootProjectileAtNode(0, projSpeed, targets[i]);
		}		
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var buff : EEffectInteract;
		var conf : W3ConfuseEffect;
		var i : int;
		var duration, durationAnimal, axiiPower, currentDuration : SAbilityAttributeValue; //modSigns: new vars
		var casterActor : CActor;
		var dur, durAnimals : float;
		var params, staggerParams : SCustomEffectParams;
		var npcTarget : CNewNPC;
		var jobTreeType : EJobTreeType;
		var sp, pts, prc, chance, durationBonus, durationPenalty : float; //modSigns: new vars
		
		casterActor = owner.GetActor();		
		ProcessThrow();
		StopEffect(effects[fireMode].throwEffect);
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		
		
		RemoveMagic17Effect(orientationTarget);
				
		if(IsAlternateCast())
		{
			thePlayer.LockToTarget( false );
			thePlayer.EnableManualCameraControl( true, 'AxiiEntity' );
		}
		
		if (targets.Size() > 0 )
		{
			duration = thePlayer.GetSkillAttributeValue(skillEnum, 'duration', false, true);
			if(IsAlternateCast())
				duration += thePlayer.GetSkillAttributeValue(S_Magic_s05, 'duration_bonus_after1', false, true) * (thePlayer.GetSkillLevel(S_Magic_s05) - 1);
			durationAnimal = thePlayer.GetSkillAttributeValue(skillEnum, 'duration_animals', false, true);
			
			duration.valueMultiplicative = 1.0f;
			durationAnimal.valueMultiplicative = 1.0f;
			
			if(owner.CanUseSkill(S_Magic_s19) && targets.Size() > 1) //modSigns: no penalty for single target
			{
				duration -= owner.GetSkillAttributeValue(S_Magic_s19, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s19));
				durationAnimal -= owner.GetSkillAttributeValue(S_Magic_s19, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s19));
			}
			
			//modSigns: duration bonus from Axii power
			axiiPower = casterActor.GetTotalSignSpellPower(skillEnum);
			durationBonus = PowerStatToPowerBonus(axiiPower.valueMultiplicative);
			//modSigns: duration bonus from power skill
			if(owner.CanUseSkill(S_Magic_s18))
				durationBonus += CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s18, 'axii_duration_bonus', false, false)) * owner.GetSkillLevel(S_Magic_s18);
			
			//dur = CalculateAttributeValue(duration);
			//durAnimals = CalculateAttributeValue(durationAnimal);
			
			params.creator = casterActor;
			params.sourceName = "axii_" + skillEnum;			
			params.customPowerStatValue = casterActor.GetTotalSignSpellPower(skillEnum);
			params.isSignEffect = true;
			
			
			for(i=0; i<targets.Size(); i+=1)
			{
				npcTarget = (CNewNPC)targets[i];
				
				//modSigns: keep SAbilityAttributeValue
				if( targets[i].IsAnimal() || npcTarget.IsHorse() )
				{
					currentDuration = durationAnimal;
				}
				else
				{
					currentDuration = duration;
				}
				
				//modSigns: target point resistance reduces effect duration (percent resistance reduction is calculated in baseEffect)
				//apply chance is only affected by percent resistance
				if( owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Hostile )
				{
					targets[i].GetResistValue(CDS_WillRes, pts, prc);
					durationPenalty = pts/100;
					chance = ClampF(1 - prc, 0.0, 1.0);
				}
				else
				{
					durationPenalty = 0;
					chance = 1;
				}

				currentDuration.valueBase *= MaxF(0, 1 + durationBonus - durationPenalty);
				
				params.duration = CalculateAttributeValue(currentDuration);
				
				jobTreeType = npcTarget.GetCurrentJTType();	
					
				if( jobTreeType == EJTT_InfantInHand )
				{
					params.effectType = EET_AxiiGuardMe;
					chance = 1;
				}
				else if( IsAlternateCast() && owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly )
				{
					params.effectType = EET_Confusion;
					chance = 1;
				}
				else
				{
					params.effectType = actionBuffs[0].effectType;
				}
				
				RemoveMagic17Effect(targets[i]);
				
				//modSigns
				if( params.duration > 0 && chance > 0 && RandF() < chance )
				{
					buff = targets[i].AddEffectCustom(params);
				}
				else
					buff = EI_Deny;
					
				if( buff == EI_Pass || buff == EI_Override || buff == EI_Cumulate )
				{
					targets[i].OnAxiied( casterActor );
					
					/*if(owner.CanUseSkill(S_Magic_s18))
					{
						conf = (W3ConfuseEffect)(targets[i].GetBuff(params.effectType, "axii_" + skillEnum));
						conf.SetDrainStaminaOnExit();
					}*/ //modSigns: early design leftover code - Demotivate ability - removing
				}
				else
				{
					if(owner.CanUseSkill(S_Magic_s17) && owner.GetSkillLevel(S_Magic_s17) == 3)
					{
						params.duration = 0.5; //modSigns
						staggerParams = params;
						staggerParams.effectType = EET_Stagger;
						targets[i].AddEffectCustom(staggerParams);
					}
					else
					{
						owner.GetActor().SetBehaviorVariable( 'axiiResisted', 1.f );
					}
				}
			}
		}
		
		casterActor.OnSignCastPerformed(ST_Axii, fireMode);
		
		super.OnEnded();
	}
	
	event OnSignAborted( optional force : bool )
	{
		HAXX_AXII_ABORTED();
		super.OnSignAborted(force);
	}
	
	
	public function HAXX_AXII_ABORTED()
	{
		var i : int;
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		RemoveMagic17Effect(orientationTarget);
	}
	
	
	public function OnDisplayTargetChange(newTarget : CActor)
	{
		var buffParams : SCustomEffectParams;
	
		
		if(!owner.CanUseSkill(S_Magic_s17) || owner.GetSkillLevel(S_Magic_s17) == 0)
			return;
	 
		if(newTarget == orientationTarget)
			return;
			
		RemoveMagic17Effect(orientationTarget);
		orientationTarget = newTarget;
		//theGame.witcherLog.AddMessage("New target"); //modSigns: debug
		AddMagic17Effect(orientationTarget);			
	}
	
	private function AddMagic17Effect(target : CActor)
	{
		var buffParams : SCustomEffectParams;
		
		if(!target || owner.GetActor() != GetWitcherPlayer() || !GetWitcherPlayer().CanUseSkill(S_Magic_s17))
			return;
		
		buffParams.effectType = EET_SlowdownAxii;
		buffParams.creator = this;
		buffParams.sourceName = "axii_immobilize";
		buffParams.duration = 10;
		buffParams.effectValue.valueAdditive = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s17, 'axii_slowdown_prc', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s17); //modSigns: new mechanic
		buffParams.isSignEffect = true;
		
		target.AddEffectCustom(buffParams);
	}
	
	private function RemoveMagic17Effect(target : CActor)
	{
		if(target)
			target.RemoveBuff(EET_SlowdownAxii, true, "axii_immobilize");
	}
}

state AxiiCast in W3AxiiEntity extends NormalCast
{
	event OnEnded(optional isEnd : bool)
	{
		var player			: CR4Player;
		
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
			
		player = caster.GetPlayer();
		
		if( player )
		{
			parent.ManagePlayerStamina();
			parent.ManageGryphonSetBonusBuff();
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			
			caster.GetActor().SetBehaviorVariable( 'bStopSign', 1.f );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		
		super.OnSignAborted(force);
	}
}

state AxiiChanneled in W3AxiiEntity extends Channeling
{
	event OnEnded(optional isEnd : bool)
	{
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
		caster.OnDelayOrientationChange();
	}

	event OnProcessSignEvent( eventName : name )
	{
		if( eventName == 'axii_alternate_ready' )
		{
			
			
		}
		else
		{
			return parent.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
			ChannelAxii();			
	}
		
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );

		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
	
		super.OnSignAborted( force );
	}
	
	entry function ChannelAxii()
	{	
		while( Update(theTimer.timeDelta) ) //modSigns
		{
			Sleep(theTimer.timeDelta); //modSigns
		}
	}
}

