/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



// Triangle spell sword
class W3Effect_TWeakness extends CBaseGameplayEffect
{
	default effectType = EET_TWeakness;
	default isNegative = true;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		target.isWeak = true;
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		target.isWeak = false;
		super.OnEffectRemoved();
	}

	protected function OnPaused()
	{
		target.isWeak = false;
		super.OnPaused();
	}

	protected function OnResumed()
	{
		target.isWeak = true;
		super.OnResumed();
	}
}
