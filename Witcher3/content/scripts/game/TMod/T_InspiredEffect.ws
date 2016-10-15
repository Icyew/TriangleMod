/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_TInspired extends CBaseGameplayEffect
{
	default effectType = EET_TInspired;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		if (!target.HasAbility(TUtil_TEMutationEnumToName(TEM_Inspired))) {
			target.AddAbilityMultiple(TUtil_TEMutationEnumToName(TEM_Inspired), TOpts_InspiredBonus());
		}

		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		target.RemoveAbilityAll(TUtil_TEMutationEnumToName(TEM_Inspired));
		super.OnEffectRemoved();
	}

	protected function OnPaused()
	{
		target.RemoveAbilityAll(TUtil_TEMutationEnumToName(TEM_Inspired));
		super.OnPaused();
	}

	protected function OnResumed()
	{
		if (!target.HasAbility(TUtil_TEMutationEnumToName(TEM_Inspired))) {
			target.AddAbilityMultiple(TUtil_TEMutationEnumToName(TEM_Inspired), TOpts_InspiredBonus());
		}
		super.OnResumed();
	}
}
