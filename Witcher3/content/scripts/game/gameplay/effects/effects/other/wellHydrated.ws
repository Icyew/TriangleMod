/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_WellHydrated extends W3RegenEffect
{
	private var level : int;

	default effectType = EET_WellHydrated;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer && thePlayer == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{		
			iconPath = theGame.effectMgr.GetPathForEffectIconTypeName('icon_effect_Dumplings');
		}
	}

	//modSigns: same as well fed
	event OnPerk15Unequipped()
	{
		SetTimeLeft( initialDuration );
		duration = initialDuration;
	}
	
	//modSigns: same as well fed
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var min, max : SAbilityAttributeValue;
		
		super.CalculateDuration(setInitialDuration);
		
		if( isOnPlayer && GetWitcherPlayer() )
		{	
			
			if( GetWitcherPlayer().CanUseSkill( S_Perk_15 ) )
			{
				min = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration', false, false );
				duration = min.valueAdditive;
			}
			if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
				duration *= 1 + min.valueMultiplicative;
			}
		}
	}
	
	//modSigns: same as well fed
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var eff : W3Effect_WellFed;
		var dm : CDefinitionsManagerAccessor;
		var thisLevel, otherLevel : int;
		var min, max : SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		eff = (W3Effect_WellFed)e;
		dm.GetAbilityAttributeValue(abilityName, 'level', min, max);
		thisLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		dm.GetAbilityAttributeValue(eff.abilityName, 'level', min, max);
		otherLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		
		if(otherLevel >= thisLevel)
			return EI_Cumulate;		
		else
			return EI_Deny;
	}
	
	//modSigns: remove
	/*public function CacheSettings()
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName, customAbilityName : name;
		var type : EEffectType;		
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			EffectNameToType(tmpName, type, customAbilityName);
			if(effectType == type)
			{
				if(!dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', level))
					level = 0;
					
				break;
			}
		}
	}*/
}