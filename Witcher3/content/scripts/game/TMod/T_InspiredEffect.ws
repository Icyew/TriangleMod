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
		if (!target.HasAbility(T_EMutationEnumToName(TEM_Inspired))) {
			target.AddAbilityMultiple(T_EMutationEnumToName(TEM_Inspired), theGame.GetTModOptions().GetInspiredBonus());
		}

		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		target.RemoveAbilityAll(T_EMutationEnumToName(TEM_Inspired));
		super.OnEffectRemoved();
	}

	protected function OnPaused()
	{
		target.RemoveAbilityAll(T_EMutationEnumToName(TEM_Inspired));
		super.OnPaused();
	}

	protected function OnResumed()
	{
		if (!target.HasAbility(T_EMutationEnumToName(TEM_Inspired))) {
			target.AddAbilityMultiple(T_EMutationEnumToName(TEM_Inspired), theGame.GetTModOptions().GetInspiredBonus());
		}
		super.OnResumed();
	}
}
