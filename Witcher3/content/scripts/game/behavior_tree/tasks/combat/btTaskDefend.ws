/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskDefend extends IBehTreeTask
{
	public var useCustomHits : bool;
	public var listenToParryEvents : bool;
	public var completeTaskOnIsDefending : bool;
	public var minimumDuration	: float;
	public var playParrySound	: bool;
	
	
	private var m_activationTime : float;
	
	/*function IsAvailable() : bool //modSigns: check for stamina - removed
	{
		var npc : CNewNPC = GetNPC();
		var counterStaminaCost : float;

		counterStaminaCost = CalculateAttributeValue(npc.GetAttributeValue( 'counter_stamina_cost' ));
		
		//theGame.witcherLog.AddMessage("CBTTaskDefend: IsAvailable"); //modSigns: debug
		//theGame.witcherLog.AddMessage("Stamina: " + npc.GetStat( BCS_Stamina )); //modSigns: debug
		//theGame.witcherLog.AddMessage("counterStaminaCost: " + counterStaminaCost); //modSigns: debug
		
		if( npc.GetStat( BCS_Stamina ) >= counterStaminaCost )
			return true;
		return false;
	}*/
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetGuarded(true);
		npc.SetParryEnabled( true );
		if ( useCustomHits )
		{
			npc.customHits = true;
			npc.SetCanPlayHitAnim( true );
		}
		
		m_activationTime = GetLocalTime();
		
		return BTNS_Active;
		
		//modSigns: skip defensive pose and force counter
		//removed - can't do this as it breaks last breath ability (probably something else)
		/*npc.ResetHitCounter(0, 0);
		npc.DisableHitAnimFor(2.0);
		npc.SetIsInHitAnim(false);
		return BTNS_Completed;*/
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetGuarded(false);
		npc.SetParryEnabled( false );
		if ( useCustomHits )
		{
			npc.customHits = false;
		}
		
		//modSigns: prevent player from interrupting a following counter attack
		npc.SetIsInHitAnim(false);
		npc.DisableHitAnimFor(2.0);
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 					: CNewNPC = GetNPC();
		var data 					: CDamageData;
		var l_currentDuration		: float;
		
		if ( eventName == 'BeingHit' )
		{
			data = (CDamageData) GetEventParamBaseDamage();
			
			if( (CBaseGameplayEffect) data.causer )
				return true;
			
			if( playParrySound )			
				npc.SoundEvent( "cmb_play_parry" );
				
			//((CActor)(data.attacker)).AddEffectDefault( EET_Stagger, npc, "ParryStagger" ); //modSigns
				
			if ( data.customHitReactionRequested )
			{
				npc.RaiseEvent('CustomHit');
				SetHitReactionDirection();
				//return true;
			}
			
			//modSigns: complete on hit
			Complete(true);
			return true;
		}
		else if ( listenToParryEvents && ( eventName == 'ParryPerform' || eventName == 'ParryStagger' ) && npc.CanPlayHitAnim() )
		{
			npc.RaiseEvent('CustomHit');
			SetHitReactionDirection();
			return true;
		}
		else if ( eventName == 'IsDefending' )
		{
			SetEventRetvalInt(1);
			
			l_currentDuration = GetLocalTime() - m_activationTime;
			
			if ( completeTaskOnIsDefending && l_currentDuration > minimumDuration )
				Complete(true);
			return true;
		}
		return false;
	}
	
	private function SetHitReactionDirection()
	{
		
		var victimToAttackerAngle 	: float;
		var npc 					: CNewNPC = GetNPC();
		var target					: CActor = GetCombatTarget();
		
		victimToAttackerAngle = NodeToNodeAngleDistance( target, npc );
		
		if( AbsF(victimToAttackerAngle) <= 90 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionDirection',(int)EHRD_Forward);
		}
		else if( AbsF(victimToAttackerAngle) > 90 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionDirection',(int)EHRD_Back);
		}
		
		if( victimToAttackerAngle > 45 && victimToAttackerAngle < 135 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_Right);
		}
		else if( victimToAttackerAngle < -45 && victimToAttackerAngle > -135 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_Left);
		}
		else
		{
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_None);
		}
	}
}

class CBTTaskDefendDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDefend';

	editable var useCustomHits 				: bool;
	editable var listenToParryEvents 		: bool;
	editable var completeTaskOnIsDefending 	: bool;
	editable var minimumDuration			: float;
	editable var playParrySound				: bool;
	
	default useCustomHits = false;
	default listenToParryEvents = true;
	default completeTaskOnIsDefending = false;
	default playParrySound = true;
	
	hint completeTaskOnIsDefending = "IsDefending event is sent on Geralt's attack if this task is active geralt will play AttackReflect";
	hint minimumDuration = "The task won't complete on 'IsDefending' before this duration";
}
