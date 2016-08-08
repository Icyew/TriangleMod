/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_TIgnorePain extends W3DamageOverTimeEffect
{
	default effectType = EET_TIgnorePain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;

	event OnUpdate(dt : float)
	{
		var dmg, maxVit, maxEss : float;
		var i : int;
		
		maxVit = target.GetStatMax( BCS_Vitality);
		maxEss = target.GetStatMax( BCS_Essence);
		
		for(i=0; i<damages.Size(); i+=1)
		{
			dmg = CalculateDamage(i, maxVit, maxEss, dt);
			// Dont kill target. Note that this gets weird with multiple damage types
			if ((damages[i].hitsVitality && dmg < target.GetStat(BCS_Vitality)) || (damages[i].hitsEssence && dmg < target.GetStat(BCS_Essence))) {
				super.OnUpdate(dt);
				break;
			}
		}
	}

}