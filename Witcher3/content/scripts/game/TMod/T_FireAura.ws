/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






class W3TFireAuraCustomParams extends W3BuffCustomParams
{
	var range : float;
	var burningDuration : float;
}

class W3TFireAura extends W3Effect_Aura
{
	default effectType = EET_TFireAura;
	
	protected function ApplySpawnsOn( entityGE : CGameplayEntity)
	{
		
		if( (CActor)entityGE )
			super.ApplySpawnsOn( entityGE );
		else
			entityGE.OnFireHit( GetCreator() );
	}

	event OnUpdate(dt : float)
	{
		if (!target.IsEffectActive('critical_burning'))
			target.PlayEffect('critical_burning');
		super.OnUpdate(dt);
	}

	protected function OnResumed()
	{
		if (!target.IsEffectActive('critical_burning'))
			target.PlayEffect('critical_burning');
		super.OnResumed();
	}

	protected function OnPaused()
	{
		if (target.IsEffectActive('critical_burning'))
			target.StopEffect('critical_burning');
		super.OnPaused();
	}

	event OnEffectRemoved()
	{
		if (target.IsEffectActive('critical_burning'))
			target.StopEffect('critical_burning');
		super.OnEffectRemoved();
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3TFireAuraCustomParams;
		var i : int;

		super.OnEffectAdded(customParams);

		target.PlayEffect('critical_burning');

		params = (W3TFireAuraCustomParams)customParams;
		if (params) {
			if (params.range > 0) {
				range = params.range;
			}
			if (params.burningDuration > 0) {
				for (i = 0; i < spawns.Size(); i += 1) {
					if (spawns[i].spawnType == EET_Burning) {
						spawns[i].spawnCustomParams.duration = params.burningDuration;
					}
				}
			}
		}
	}
}
