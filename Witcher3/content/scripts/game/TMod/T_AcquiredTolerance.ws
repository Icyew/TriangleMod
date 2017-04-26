/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



// Triangle acquired tolerance
class W3Effect_TAcquiredTolerance extends W3Effect_TMutableDuration
{
	default effectType = EET_TAcquiredTolerance;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
}
