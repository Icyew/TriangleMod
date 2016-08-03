/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_TResolve extends CBaseGameplayEffect
{
	default effectType = EET_TResolve;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		if (!target.HasAbility('TResolveDamageBonus')) {
			target.AddAbilityMultiple('TResolveDamageBonus', FloorF(effectValue.valueMultiplicative * 100));
		}

		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		target.RemoveAbilityAll('TResolveDamageBonus');
		super.OnEffectRemoved();
	}

	protected function OnPaused()
	{
		target.RemoveAbilityAll('TResolveDamageBonus');
		super.OnPaused();
	}

	protected function OnResumed()
	{
		if (!target.HasAbility('TResolveDamageBonus')) {
			target.AddAbilityMultiple('TResolveDamageBonus', FloorF(effectValue.valueMultiplicative * 100));
		}
		super.OnResumed();
	}
}
