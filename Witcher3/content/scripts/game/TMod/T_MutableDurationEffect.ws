/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



// Triangle acquired tolerance
class W3Effect_TMutableDuration extends CBaseGameplayEffect
{
	public function AddTimeLeft(time : float, optional capDuration : bool)
	{
		timeLeft += time;
		if (capDuration && timeLeft > duration) {
			timeLeft = duration;
		} else {
			duration = MaxF(duration, timeLeft);
		}
	}
}
