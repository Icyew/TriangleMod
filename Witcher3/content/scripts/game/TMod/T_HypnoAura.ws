/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






class W3THypnoAuraCustomParams extends W3BuffCustomParams
{
	var range : float;
	var hypnoDuration : float;
}

class W3THypnoAura extends W3Effect_Aura
{
	default effectType = EET_THypnoAura;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3THypnoAuraCustomParams;
		var i : int;

		super.OnEffectAdded(customParams);

		params = (W3THypnoAuraCustomParams)customParams;
		if (params) {
			if (params.range > 0) {
				range = params.range;
			}
			if (params.hypnoDuration > 0) {
				for (i = 0; i < spawns.Size(); i += 1) {
					if (spawns[i].spawnType == EET_Hypnotized) {
						spawns[i].spawnCustomParams.duration = params.hypnoDuration;
					}
				}
			}
		}
	}
}
