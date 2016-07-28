/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






class W3TInspiringAura extends W3Effect_Aura
{
	default effectType = EET_TInspiringAura;
	
	protected function ApplySpawnsOn( entityGE : CGameplayEntity)
	{
		if ((CActor)entityGE && entityGE != target && entityGE != thePlayer) {
			super.ApplySpawnsOn( entityGE );
		}
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
}
