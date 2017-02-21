/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3AardProjectile extends W3SignProjectile
{
	protected var staminaDrainPerc : float;
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var projectileVictim : CProjectileTrajectory;
		
		projectileVictim = (CProjectileTrajectory)collidingComponent.GetEntity();
		
		if( projectileVictim )
		{
			projectileVictim.OnAardHit( this );
		}
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var dmgVal : float;
		var sp : SAbilityAttributeValue;
		var isMutation6 : bool;
		var victimNPC : CNewNPC;
	
		
		if ( hitEntities.FindFirst( collider ) != -1 )
		{
			return;
		}
		
		
		hitEntities.PushBack( collider );
	
		super.ProcessCollision( collider, pos, normal );
		
		victimNPC = (CNewNPC) collider;
		
		
		if( IsRequiredAttitudeBetween(victimNPC, caster, true ) )
		{
			isMutation6 = ( ( W3PlayerWitcher )owner.GetPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation6 ) );
			if( isMutation6 )
			{
				action.SetBuffSourceName( "Mutation6" );
			}		
			else if ( owner.CanUseSkill(S_Magic_s06) )		
			{			
				
				dmgVal = GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
			//modSigns: moved here as this should happen before damage action is processed
			if( victimNPC.IsAlive() && GetStaminaDrainPerc() > 0.f )
			{
				victimNPC.DrainStamina(ESAT_FixedValue, GetStaminaDrainPerc() * victimNPC.GetStatMax(BCS_Stamina) + 1, 1);
				//modSigns: debug
				//theGame.witcherLog.AddMessage("Stamina drained = " + victimNPC.GetStat(BCS_Stamina));
			}
		}
		else
		{
			isMutation6 = false;
		}
		
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		action.SetProcessBuffsIfNoDamage(true);
		
		
		if ( !owner.IsPlayer() )
		{
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
		}
		
		
		
		
		
		
		theGame.damageMgr.ProcessAction( action );
		
		collider.OnAardHit( this );
		
		
		if( isMutation6 && victimNPC && victimNPC.IsAlive() )
		{
			ProcessMutation6( victimNPC );
		}
	}
	
	private final function ProcessMutation6( victimNPC : CNewNPC )
	{
		var result : EEffectInteract;
		var mutationAction : W3DamageAction;
		var min, max : SAbilityAttributeValue;
		var dmgVal : float;
		var instaKill, hasKnockdown/*, applySlowdown*/ : bool;
		var freezingChance, pts, prc : float; //modSigns
				
		//modSigns: change how the whole thing works, to make it less OP and match the description
		
		hasKnockdown = victimNPC.HasBuff( EET_Knockdown ) || victimNPC.HasBuff( EET_HeavyKnockdown ) || victimNPC.GetIsRecoveringFromKnockdown();
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );
		
		//modSigns: check resistances
		((CActor)victimNPC).GetResistValue(CDS_FrostRes, pts, prc);
		freezingChance = min.valueMultiplicative * ClampF(1 - prc, 0, 1);
		
		//Check whether or not to apply freezing
		result = EI_Deny;
		if( RandF() < freezingChance && !victimNPC.IsImmuneToInstantKill() )
		{
			result = victimNPC.AddEffectDefault( EET_Frozen, this, "Mutation 6", true );
		}
		//Check for instant kill
		instaKill = false;
		if( EffectInteractionSuccessfull( result ) && hasKnockdown )
		{
			mutationAction = new W3DamageAction in theGame.damageMgr;
			mutationAction.Initialize( action.attacker, victimNPC, this, "Mutation 6", EHRT_None, CPS_Undefined, false, false, true, false );
			mutationAction.SetInstantKill();
			mutationAction.SetForceExplosionDismemberment();
			mutationAction.SetIgnoreInstantKillCooldown();
			theGame.damageMgr.ProcessAction( mutationAction );
			delete mutationAction;
			instaKill = true;
		}
		//If no other effect was applied, add force damage
		if( !instaKill && !victimNPC.HasBuff( EET_Frozen ) )
		{			
			if ( owner.CanUseSkill(S_Magic_s06) )
			{
				dmgVal = GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
			
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
			dmgVal = CalculateAttributeValue( min );
			action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			
			action.ClearEffects();
			action.SetProcessBuffsIfNoDamage( false );
			action.SetForceExplosionDismemberment();
			action.SetIgnoreInstantKillCooldown();
			action.SetBuffSourceName( "Mutation 6" );
			theGame.damageMgr.ProcessAction( action );
		}
	}
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnAardHit( this );
	}
	
	public final function GetStaminaDrainPerc() : float
	{
		return staminaDrainPerc;
	}
	
	public final function SetStaminaDrainPerc(p : float)
	{
		staminaDrainPerc = p;
	}
}



class W3AxiiProjectile extends W3SignProjectile
{
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		DestroyAfter( 3.f );
		
		collider.OnAxiiHit( this );	
		
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return false;
	}
}

class W3IgniProjectile extends W3SignProjectile
{
	private var channelCollided : bool;
	private var dt : float;	
	private var isUsed : bool;
	
	default channelCollided = false;
	default isUsed = false;
	
	public function SetDT(d : float)
	{
		dt = d;
	}

	public function IsUsed() : bool
	{
		return isUsed;
	}

	public function SetIsUsed( used : bool )
	{
		isUsed = used;
	}

	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var rot, rotImp : EulerAngles;
		var v, posF, pos2, n : Vector;
		var igniEntity : W3IgniEntity;
		var ent, colEnt : CEntity;
		var template : CEntityTemplate;
		var f : float;
		var test : bool;
		var postEffect : CGameplayFXSurfacePost;
		
		channelCollided = true;
		
		
		igniEntity = (W3IgniEntity)signEntity;
		
		if(signEntity.IsAlternateCast())
		{			
			
			test = (!collidingComponent && hitCollisionsGroups.Contains( 'Terrain' ) ) || (collidingComponent && !((CActor)collidingComponent.GetEntity()));
			
			colEnt = collidingComponent.GetEntity();
			if( (W3BoltProjectile)colEnt || (W3SignEntity)colEnt || (W3SignProjectile)colEnt )
				test = false;
			
			if(test)
			{
				f = theGame.GetEngineTimeAsSeconds();
				
				if(f - igniEntity.lastFxSpawnTime >= 1)
				{
					igniEntity.lastFxSpawnTime = f;
					
					template = (CEntityTemplate)LoadResource( "igni_object_fx" );
					
					
					rot.Pitch	= AcosF( VecDot( Vector( 0, 0, 0 ), normal ) );
					rot.Yaw		= this.GetHeading();
					rot.Roll	= 0.0f;
					
					
					posF = pos + VecNormalize(pos - signEntity.GetWorldPosition());
					if(theGame.GetWorld().StaticTrace(pos, posF, pos2, n, igniEntity.projectileCollision))
					{					
						ent = theGame.CreateEntity(template, pos2, rot );
						ent.AddTimer('TimerStopVisualFX', 5, , , , true);
						
						postEffect = theGame.GetSurfacePostFX();
						postEffect.AddSurfacePostFXGroup( pos2, 0.5f, 8.0f, 10.0f, 0.3f, 1 );
					}
				}				
			}
			
			
			if ( !hitCollisionsGroups.Contains( 'Water' ) )
			{
				
				v = GetWorldPosition() - signEntity.GetWorldPosition();
				rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
				
				igniEntity.ShowChannelingCollisionFx(GetWorldPosition(), rot, -v);
			}
		}
		
		return super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var currentReductionFactor, maxReductionFactor, reductionFactor : int; //modSigns
		var signPower, channelDmg, armorRedAttr : SAbilityAttributeValue; //modSigns
		var burnChance : float;					// chance to apply burn effect (NPC only)
		var maxArmorReduction : float;			// by how much the armor can be reduced
		var applyNbr : int;						// how many times base armor reduction has to be applied
		var i : int;
		var npc : CNewNPC;
		var armorRedAblName : name;
		var currentReduction, perHitReduction, armorRedVal, pts, prc : float; //modSigns
		var actorVictim : CActor;
		var ownerActor : CActor;
		var dmg : float;
		var performBurningTest : bool;
		var igniEntity : W3IgniEntity;
		var postEffect : CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		
		postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
		
		// this condition prevents from hitting actor twice by the same projectile
		if ( hitEntities.Contains( collider ) )
		{
			return;
		}
		hitEntities.PushBack( collider );		
		
		super.ProcessCollision( collider, pos, normal );	
			
		ownerActor = owner.GetActor();
		actorVictim = ( CActor ) action.victim;
		npc = (CNewNPC)collider;
		signPower = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());
		
		//modSigns: Igni Power damage
		if(owner.CanUseSkill(S_Magic_s07) && !igniEntity.hitEntities.Contains( collider ) && !signEntity.IsAlternateCast())
		{
			dmg = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s07, 'fire_damage_bonus', false, false)) * owner.GetSkillLevel(S_Magic_s07);
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
				
		//igni burning
		if(signEntity.IsAlternateCast())
		{
			igniEntity = (W3IgniEntity)signEntity;
			performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
			
			// if target was already hit then skip initial damage, also skip the hit particle
			// this condition prevents from hitting actor twice by the the whole igni entity
			if( igniEntity.hitEntities.Contains( collider ) )
			{
				channelCollided = true;
				action.SetHitEffect('');
				action.SetHitEffect('', true );
				action.SetHitEffect('', false, true);
				action.SetHitEffect('', true, true);
				action.ClearDamage();
				
				//add channeling damage
				channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, false);
				//modSigns: scale damage with skill level and sign power
				channelDmg += owner.GetSkillAttributeValue(signSkill, 'channeling_damage_after_1', false, false) * (owner.GetSkillLevel(S_Magic_s02) - 1);
				dmg = channelDmg.valueAdditive + channelDmg.valueMultiplicative * actorVictim.GetMaxHealth();
				//modSigns: Igni Power damage
				if(owner.CanUseSkill(S_Magic_s07))
				{
					dmg += CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s07, 'channeling_damage_bonus', false, false)) * owner.GetSkillLevel(S_Magic_s07);
				}
				//modSigns: since DoT damage is no longer scaled with sign power, do manual scaling for Firestream
				dmg *= signPower.valueMultiplicative;
				dmg *= dt;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
				action.SetIsDoTDamage(dt);
				
				//combat log
				//theGame.witcherLog.AddCombatMessage("Igni channeling: dt = " + FloatToString(dt) + "; dmg = " + FloatToString(dmg), ownerActor, actorVictim);
				
				if(!collider)	//if no target (just showing impact fx) then exit
					return;
			}
			else
			{
				igniEntity.hitEntities.PushBack( collider );
			}
			
			if(!performBurningTest)
			{
				action.ClearEffects();
			}
		}
		
		//if npc is shielded do not take any dmg
		if ( npc && npc.IsShielded( ownerActor ) )
		{
			collider.OnIgniHit( this );	
			return;
		}
		
		// Claculate sign spellpower, taking target resistances into consideration
		//signPower = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());

		// a piece of custom code for calculating burning effect
		if ( !owner.IsPlayer() )
		{
			//NPCs
			burnChance = signPower.valueMultiplicative;
			if ( RandF() < burnChance )
			{
				action.AddEffectInfo(EET_Burning);
			}
			
			dmg = CalculateAttributeValue(signPower);
			if ( dmg <= 0 )
			{
				dmg = 20;
			}			
			action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
		
		if(signEntity.IsAlternateCast())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else		
		{
			action.SetHitEffect('igni_cone_hit', false, false);
			action.SetHitEffect('igni_cone_hit', true, false);
			action.SetHitReactionType(EHRT_Igni, false);
		}
		
		theGame.damageMgr.ProcessAction( action );	
		
		// Melt armor
		if ( owner.CanUseSkill(S_Magic_s08) && (CActor)collider)
		{	
			//modSigns
			((CActor)collider).GetResistValue(CDS_FireRes, pts, prc);
			if(prc < 1) // don't have fire immunity
			{
				//reduction per ability
				//armorRedAttr = owner.GetSkillAttributeValue(S_Magic_s08, 'armor', false, false);
				//armorRedVal = AbsF(armorRedAttr.valueMultiplicative);
				armorRedAttr = owner.GetSkillAttributeValue(S_Magic_s08, 'armor_reduction_bonus', false, false);
				armorRedVal = CalculateAttributeValue(armorRedAttr);
				//max allowed reduction
				maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s08);
				//max allowed reduction factor (num stacked abilities)
				maxReductionFactor = RoundMath(maxArmorReduction / armorRedVal);
				//sign power dependent reduction factor per hit
				reductionFactor = Max(1, RoundMath((1 + 100 * PowerStatToPowerBonus(signPower.valueMultiplicative)) * (1 - prc)));
				if(signEntity.IsAlternateCast())
				{
					reductionFactor = Max(1, RoundMath(reductionFactor * dt));
				}
				//armor reduction per hit
				perHitReduction = armorRedVal * reductionFactor;
				//combat log
				/*
				theGame.witcherLog.AddCombatMessage("Target resist pts: " + FloatToString(pts), thePlayer, NULL);
				theGame.witcherLog.AddCombatMessage("Target resist prc: " + FloatToString(prc), thePlayer, NULL);
				theGame.witcherLog.AddCombatMessage("armorRedVal: " + FloatToString(armorRedVal), thePlayer, NULL);
				theGame.witcherLog.AddCombatMessage("maxArmorReduction: " + FloatToString(maxArmorReduction), thePlayer, NULL);
				theGame.witcherLog.AddCombatMessage("maxReductionFactor: " + IntToString(maxReductionFactor), thePlayer, NULL);
				theGame.witcherLog.AddCombatMessage("signPower: " + FloatToString(signPower.valueMultiplicative), thePlayer, NULL);
				theGame.witcherLog.AddCombatMessage("reductionFactor: " + IntToString(reductionFactor), thePlayer, NULL);
				theGame.witcherLog.AddCombatMessage("perHitReduction: " + FloatToString(perHitReduction), thePlayer, NULL);
				*/
				//ability name (magic_s8 - Melt Armor)
				armorRedAblName = SkillEnumToName(S_Magic_s08);
				//current reduction factor (num stacked abilities)
				currentReductionFactor = ((CActor)collider).GetAbilityCount(armorRedAblName);
				//current reduction value
				currentReduction = currentReductionFactor * armorRedVal;
				//combat log
				//theGame.witcherLog.AddCombatMessage("currentReductionFactor: " + IntToString(currentReductionFactor), thePlayer, NULL);
				//theGame.witcherLog.AddCombatMessage("currentReduction: " + FloatToString(currentReduction), thePlayer, NULL);
				//limit armor reduction to max reduction allowed by ability * level
				if(currentReductionFactor + reductionFactor < maxReductionFactor)
					applyNbr = reductionFactor;
				else
					applyNbr = maxReductionFactor - currentReductionFactor;
				//combat log
				//theGame.witcherLog.AddCombatMessage("applyNbr: " + IntToString(applyNbr), thePlayer, NULL);
				//add abilities
				for ( i = 0; i < applyNbr; i += 1 )
					action.victim.AddAbility(armorRedAblName, true);
			}
		}	
		collider.OnIgniHit( this );		
	}	

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnIgniHit( this );
	}

	
	event OnRangeReached()
	{
		var v : Vector;
		var rot : EulerAngles;
				
		
		if(!channelCollided)
		{			
			
			v = GetWorldPosition() - signEntity.GetWorldPosition();
			rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
			((W3IgniEntity)signEntity).ShowChannelingRangeFx(GetWorldPosition(), rot);
		}
		
		isUsed = false;
		
		super.OnRangeReached();
	}
	
	public function IsProjectileFromChannelMode() : bool
	{
		return signSkill == S_Magic_s02;
	}
}