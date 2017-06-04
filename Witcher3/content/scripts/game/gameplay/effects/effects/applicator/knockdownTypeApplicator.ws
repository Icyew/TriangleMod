/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_KnockdownTypeApplicator extends W3ApplicatorEffect
{
	private saved var customEffectValue : SAbilityAttributeValue;		
	private saved var customDuration : float;							
	private saved var customAbilityName : name;							

	default effectType = EET_KnockdownTypeApplicator;
	default isNegative = true;
	default isPositive = false;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var aardPower	: float;
		var tags : array<name>;
		var i : int;
		var possibleTypes : array<EEffectType>; //modSigns
		var probs : array<float>; //modSigns
		var roll : float; //modSigns
		var appliedType : EEffectType;
		var null, sp, abl : SAbilityAttributeValue; //modSigns
		var resPts, resPrc, rawSP, effectPower, bonusChance : float; //modSigns // Triangle aard
		var npc : CNewNPC;
		var params : SCustomEffectParams;
		var witcher : W3PlayerWitcher; //modSigns
		
		if(isOnPlayer)
		{
			thePlayer.OnRangedForceHolster( true, true, false );
		}
		/*
		//first determine the type of effect to apply - let's calculate
		if(effectValue.valueMultiplicative + effectValue.valueAdditive > 0)		//if effect value set
			aardPower = effectValue.valueMultiplicative * ( 1 - resistance ) / (1 + effectValue.valueAdditive/100);
		else
			aardPower = creatorPowerStat.valueMultiplicative * ( 1 - resistance ) / (1 + creatorPowerStat.valueAdditive/100);
		*/
		//modSigns
		if(effectValue.valueMultiplicative + effectValue.valueAdditive > 0)		//if effect value set
			sp = effectValue;
		else
			sp = creatorPowerStat;
		//target.GetResistValue(resistStat, resPts, resPrc); // get both pts and prc
		// rawSP = PowerStatToPowerBonus(sp.valueMultiplicative); // modSigns // Triangle aard
		//move Petri philtre effect here -> removed
		/*if(isSignEffect && GetCreator() == GetWitcherPlayer() && GetWitcherPlayer().GetPotionBuffLevel(EET_PetriPhiltre) == 3)
		{
			rawSP += 0.5;
		}*/
		// Triangle aard
		// Use custom curves for aard spell power
		rawSP = sp.valueMultiplicative - 1;
		if(isSignEffect)
			aardPower = MaxF(0, rawSP - resistancePts/100) * (1 - resistance);
		else
			aardPower = MaxF(0.1, 0.5 + rawSP - resistancePts/100) * (1 - resistance);
		// Triangle end
		//combat log
		//theGame.witcherLog.AddCombatMessage("Sign power: " + FloatToString(sp.valueMultiplicative), thePlayer, NULL);
		//theGame.witcherLog.AddCombatMessage("Knockdown applicator: aard power = " + FloatToString(aardPower), thePlayer, NULL);
		
		//for shielded enemy
		/*npc = (CNewNPC)target;
		if(npc && npc.HasShieldedAbility() )
		{
			if ( npc.IsShielded(GetCreator()) )
			{
				if ( aardPower >= 1.2 )//when aard is most powerfull
					appliedType = EET_LongStagger;
				else
					appliedType = EET_Stagger;
			}
			else
			{
				if ( aardPower >= 1.2 )//when aard is most powerfull
					appliedType = EET_Knockdown;
				if ( aardPower >= 1.0 )
					appliedType = EET_LongStagger;
				else
					appliedType = EET_Stagger;
			}
		}
		else if ( target.HasAbility( 'mon_type_huge' ) )
		{
			if ( aardPower >= 1.2 )
				appliedType = EET_LongStagger;
			else
				appliedType = EET_Stagger;
		}
		else if ( target.HasAbility( 'WeakToAard' ) )
		{
			appliedType = EET_Knockdown;
		}
		else if( aardPower >= 1.2 )
		{
			appliedType = EET_HeavyKnockdown;
		}
		else if( aardPower >= 0.95 )
		{
			appliedType = EET_Knockdown;
		}
		else if( aardPower >= 0.75 )
		{
			appliedType = EET_LongStagger;
		}
		else
		{
			appliedType = EET_Stagger;
		}
		*/
		
		//modSigns: reworked
		appliedType = EET_Knockdown;
		if( !target.HasAbility( 'WeakToAard' ) )
		{
			npc = (CNewNPC)target;
			// Triangle aard Reworked probability curves for aard
			if( !(npc && npc.IsShielded(GetCreator())) && !target.HasAbility( 'mon_type_huge' ) )
			{
				bonusChance = 1;
				if (GetCreator() == GetWitcherPlayer() && GetWitcherPlayer().CanUseSkill(S_Magic_s12))
					bonusChance += TUtil_ValueForLevel(S_Magic_s12, TOpts_AardPowerBonus()); // this is a multiplier
				possibleTypes.PushBack( EET_Stagger );				probs.PushBack(            TUtil_ChanceForStagger(aardPower) );
				possibleTypes.PushBack( EET_LongStagger );			probs.PushBack( probs[0] + TUtil_ChanceForLongStagger(aardPower) );
				possibleTypes.PushBack( EET_Knockdown );		probs.PushBack( probs[1] + TUtil_ChanceForKnockdown(aardPower, bonusChance) );
				possibleTypes.PushBack( EET_HeavyKnockdown );	probs.PushBack( probs[2] + TUtil_ChanceForHeavyKnockdown(aardPower, bonusChance) );
				witcher = (W3PlayerWitcher)GetCreator();
			} else {
				possibleTypes.PushBack( EET_Stagger );				probs.PushBack(            TUtil_ChanceForStagger(aardPower, true) );
				possibleTypes.PushBack( EET_LongStagger );			probs.PushBack( probs[0] + TUtil_ChanceForLongStagger(aardPower, true) );
			}
			// Triangle end
			roll = RandF() * probs[probs.Size() - 1];
			// Triangle aard logging stuff that I may need later
			// for( i = 0; i < possibleTypes.Size(); i += 1 )
			// {
			// 	if (i > 0)
			// 		TUtil_LogMessage(probs[i] - probs[i-1]);
			// 	else
			// 		TUtil_LogMessage(probs[i]);
			// }
			// TUtil_LogMessage("rawSP: " + rawSP + " aardPower: " + aardPower + " pntRes: " + resistancePts + " percRes: " + resistance + " roll: " + roll);
			// Triangle end
			for( i = 0; i < possibleTypes.Size(); i += 1 )
			{
				if( roll < probs[i] )
				{
					appliedType = possibleTypes[i];
					break;
				}
			}
		}
		
		appliedType = ModifyHitSeverityBuff(target, appliedType);
		
		
		params.effectType = appliedType;
		params.creator = GetCreator();
		params.sourceName = sourceName;
		params.isSignEffect = isSignEffect;
		params.customPowerStatValue = creatorPowerStat;
		params.customAbilityName = customAbilityName;
		params.duration = customDuration;
		params.effectValue = customEffectValue;	
		
		target.AddEffectCustom(params);
		
		
		
		isActive = true;
		duration = 0;
	}
			
	public function Init(params : SEffectInitInfo)
	{
		customDuration = params.duration;
		customEffectValue = params.customEffectValue;
		customAbilityName = params.customAbilityName;
		
		super.Init(params);
	}
}