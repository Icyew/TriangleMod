/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






class W3TFreezingAuraCustomParams extends W3BuffCustomParams
{
	var range : float;
	var freezingDuration : float;
}

class W3TFreezingAura extends W3Effect_Aura
{
	default effectType = EET_TFreezingAura;
	
	protected function ApplySpawnsOn( entityGE : CGameplayEntity)
	{
		
		if( (CActor)entityGE )
			super.ApplySpawnsOn( entityGE );
		else
			entityGE.OnFrostHit( GetCreator() );
	}

	event OnUpdate(dt : float)
	{
		if (!target.IsEffectActive('critical_frozen'))
			target.PlayEffect('critical_frozen');
		super.OnUpdate(dt);
	}

	protected function OnResumed()
	{
		if (!target.IsEffectActive('critical_frozen'))
			target.PlayEffect('critical_frozen');
		super.OnResumed();
	}

	protected function OnPaused()
	{
		if (target.IsEffectActive('critical_frozen'))
			target.StopEffect('critical_frozen');
		super.OnPaused();
	}

	event OnEffectRemoved()
	{
		if (target.IsEffectActive('critical_frozen'))
			target.StopEffect('critical_frozen');
		super.OnEffectRemoved();
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3TFreezingAuraCustomParams;
		var i : int;

		super.OnEffectAdded(customParams);

		target.PlayEffect('critical_frozen');

		params = (W3TFreezingAuraCustomParams)customParams;
		if (params) {
			if (params.range > 0) {
				range = params.range;
			}
			if (params.freezingDuration > 0) {
				for (i = 0; i < spawns.Size(); i += 1) {
					if (spawns[i].spawnType == EET_SlowdownFrost) {
						spawns[i].spawnCustomParams.duration = params.freezingDuration;
					}
				}
			}
		}
	}
}
