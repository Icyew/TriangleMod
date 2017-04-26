/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_THeavyCombo extends W3Effect_TAttackCombo
{
	default effectType = EET_THeavyCombo;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		duration = TOpts_MaxComboDuration();
		decayTime = TOpts_HeavyAttackComboDecay();
		maxCombo = TOpts_HeavyAttackMaxCombo();
		super.OnEffectAdded(customParams);
	}
}
