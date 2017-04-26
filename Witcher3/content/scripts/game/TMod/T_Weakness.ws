/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



// Triangle protective coating, spell sword, alt stamina, enemy mutations
class W3Effect_TWeakness extends CBaseGameplayEffect
{
	default effectType = EET_TWeakness;
	default isNegative = true;
	protected var weaknessModifier : float;
	protected var npcTarget : CNewNPC;
	protected var prefix : string; default prefix = "Weakened";



	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		npcTarget = (CNewNPC)target;
		if (effectValue.valueMultiplicative < 0 || effectValue.valueMultiplicative > 1) {
			TUtil_LogMessage("WARNING: weakness effectValue.valueMultiplicative is not between 0 and 1");
		}
		if (npcTarget) {
			npcTarget.AddPrefix(prefix, sourceName);
		}
		super.OnEffectAdded(customParams);
	}

	public function WeakMod() : float
	{
		return 1 - effectValue.valueMultiplicative;
	}

	event OnEffectRemoved()
	{
		if (npcTarget) {
			npcTarget.RemovePrefix(sourceName, prefix);
		}
		super.OnEffectRemoved();
	}

	protected function OnPaused()
	{
		if (npcTarget) {
			npcTarget.RemovePrefix(sourceName, prefix);
		}
		super.OnPaused();
	}

	protected function OnResumed()
	{
		if (npcTarget) {
			npcTarget.AddPrefix(prefix, sourceName);
		}
		super.OnResumed();
	}
}
