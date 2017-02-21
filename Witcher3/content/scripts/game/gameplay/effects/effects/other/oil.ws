/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Oil extends CBaseGameplayEffect
{
	private saved var currCount : int;			
	private saved var maxCount : int;			
	private saved var sword : SItemUniqueId;	
	private saved var oilAbility : name;		
	private saved var oilItemName : name;		
	private saved var queueTimer : int;
	
	default effectType = EET_Oil;
	default isPositive = true;
	default dontAddAbilityOnTarget = true;
	default queueTimer = 0;
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var oilParams : W3OilBuffParams;
		
		
		oilParams = (W3OilBuffParams)customParams;
		if(oilParams)
		{
			iconPath = oilParams.iconPath;
			effectNameLocalisationKey = oilParams.localizedName;
			effectDescriptionLocalisationKey = oilParams.localizedDescription;
			currCount = oilParams.currCount;
			maxCount = oilParams.maxCount;
			sword = oilParams.sword;
			oilAbility = oilParams.oilAbilityName;
			oilItemName = oilParams.oilItemName;
		}
		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		
		if( ShouldProcessTutorial( 'TutorialAlchemyRefill' ) && FactsQuerySum( "q001_nightmare_ended" ) > 0 && target == GetWitcherPlayer() )
		{
			FactsAdd( 'tut_alch_refill', 1 );
		}
		
		
		target.GetInventory().RemoveItemCraftedAbility( sword, oilAbility );
		
		Show( false );
		
		super.OnEffectRemoved();
	}
	
	event OnEffectAddedPost()
	{
		var swordEquipped : bool;
		var swordEntity : CWitcherSword;
		
		
		target.GetInventory().AddItemCraftedAbility( sword, oilAbility );
				
		swordEquipped = GetWitcherPlayer().IsItemEquipped( sword );
		if(swordEquipped)
		{
			
			target.AddAbility( oilAbility );
			
			
			swordEntity = (CWitcherSword) target.GetInventory().GetItemEntityUnsafe( sword );
			swordEntity.ApplyOil( oilAbility );
		}
		
		UpdateOilsQueue();
	}
	
	protected function Show( visible : bool )
	{
		var swordEntity : CWitcherSword;
		
		if( visible )
		{
			if( !GetWitcherPlayer().IsItemHeld( sword ) )
			{
				return;
			}
		}
		
		showOnHUD = visible;
		
		
		swordEntity = (CWitcherSword) target.GetInventory().GetItemEntityUnsafe( sword );		
		if( visible )
		{
			swordEntity.ApplyOil( oilAbility );
		}
		else
		{
			swordEntity.RemoveOil( oilAbility );
		}	
	}
	
	protected function OnResumed()
	{
		if( currCount > 0 )
		{
			Show( true );			
		}
	}
	
	protected function OnPaused()
	{
		Show( false );
	}
	
	public final function Reapply( newMax : int )
	{
		maxCount = newMax;
		currCount = newMax;
		
		queueTimer = 0;
		UpdateOilsQueue();
		
		
		if( !IsPaused( '' ) )
		{
			Show( true );
		}
	}
	
	private final function UpdateOilsQueue()
	{
		var otherOils : array< W3Effect_Oil >;
		var i : int;
		
		otherOils = target.GetInventory().GetOilsAppliedOnItem( sword );
		otherOils.Remove( this );
		
		for( i=0; i<otherOils.Size(); i+=1 )
		{
			otherOils[i].IncreaseQueueTimer();
		}
	}
	
	public final function IncreaseQueueTimer()
	{
		queueTimer += 1;
	}
	
	public final function GetQueueTimer() : int
	{
		return queueTimer;
	}
	
	protected function CumulateWith( effect : CBaseGameplayEffect )
	{
		var oldCount : int;
		
		oldCount = currCount;
		
		super.CumulateWith( effect );
		
		if( oldCount <= 0 && currCount > 0 && !IsPaused( '' ) && !showOnHUD )
		{
			Show( true );
		}
	}
	
	public final function ReduceAmmo()
	{
		if( currCount == 1 )
		{
			Show( false );
		}
		
		currCount = Max( 0, currCount - 1 );
	}
	
	public final function GetAmmoMaxCount() : int
	{
		return maxCount;
	}

	public final function GetAmmoCurrentCount() : int
	{
		return currCount;
	}

	public final function GetAmmoPercentage() : float
	{
		return ((float)(currCount)) / ((float)(maxCount)); //modSigns
	}
	
	public final function GetSwordItemId() : SItemUniqueId
	{
		return sword;
	}
	
	public final function GetOilItemName() : name
	{
		return oilItemName;
	}
	
	public final function GetOilAbilityName() : name
	{
		return oilAbility;
	}
	
	public final function GetMonsterCategory() : EMonsterCategory
	{
		var i : int;
		var mcType : EMonsterCategory;
		var attributes : array< name >;
	
		theGame.GetDefinitionsManager().GetAbilityAttributes( oilAbility, attributes );
		
		for( i=0; i<attributes.Size(); i+=1 )
		{
			mcType = MonsterAttackPowerBonusToCategory( attributes[ i ] );
			if( mcType != MC_NotSet )
			{
				return mcType;
			}
		}
			
		return MC_NotSet;
	}
	
	//modSigns
	public final function GetAttackPowerBonus( monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
	{
		var attrVal, min, max : SAbilityAttributeValue;
		
		if( GetMonsterCategory() != monsterCategory || GetAmmoCurrentCount() < 1 )
			return attrVal;
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( oilAbility, MonsterCategoryToAttackPowerBonus( monsterCategory ), min, max );
		attrVal = GetAttributeRandomizedValue(min, max);
		//theGame.witcherLog.AddCombatMessage("Ability: " + oilAbility, thePlayer, NULL);
		//theGame.witcherLog.AddCombatMessage("Attribute: " + MonsterCategoryToAttackPowerBonus( monsterCategory ), thePlayer, NULL);
		//theGame.witcherLog.AddCombatMessage("Value: " + attrVal.valueMultiplicative, thePlayer, NULL);
		attrVal.valueBase *= GetAmmoPercentage();
		attrVal.valueAdditive *= GetAmmoPercentage();
		attrVal.valueMultiplicative *= GetAmmoPercentage();
		//theGame.witcherLog.AddCombatMessage("Value modified: " + attrVal.valueMultiplicative, thePlayer, NULL);
		return attrVal;
	}

	//modSigns
	public final function GetResistReductionBonus( monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
	{
		var attrVal, min, max : SAbilityAttributeValue;
		
		if( GetMonsterCategory() != monsterCategory || GetAmmoCurrentCount() < 1 )
			return attrVal;
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( oilAbility, MonsterCategoryToResistReduction( monsterCategory ), min, max );
		attrVal = GetAttributeRandomizedValue(min, max);
		//theGame.witcherLog.AddCombatMessage("Ability: " + oilAbility, thePlayer, NULL);
		//theGame.witcherLog.AddCombatMessage("Attribute: " + MonsterCategoryToResistReduction( monsterCategory ), thePlayer, NULL);
		//theGame.witcherLog.AddCombatMessage("Value: " + CalculateAttributeValue( attrVal ), thePlayer, NULL);
		attrVal.valueBase *= GetAmmoPercentage();
		attrVal.valueAdditive *= GetAmmoPercentage();
		attrVal.valueMultiplicative *= GetAmmoPercentage();
		//theGame.witcherLog.AddCombatMessage("Value modified: " + CalculateAttributeValue( attrVal ), thePlayer, NULL);
		return attrVal;
	}
	
	//modSigns
	public final function GetCriticalChanceBonus( monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
	{
		var attrVal, min, max : SAbilityAttributeValue;
		
		if( GetAmmoCurrentCount() < 1 )
			return attrVal;
		if( GetMonsterCategory() == monsterCategory )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( oilAbility, MonsterCategoryToCriticalChanceBonus( monsterCategory ), min, max );
			attrVal = GetAttributeRandomizedValue(min, max);
			//theGame.witcherLog.AddCombatMessage("Ability: " + oilAbility, thePlayer, NULL);
			//theGame.witcherLog.AddCombatMessage("Attribute: " + MonsterCategoryToCriticalChanceBonus( monsterCategory ), thePlayer, NULL);
			//theGame.witcherLog.AddCombatMessage("Value: " + CalculateAttributeValue( attrVal ), thePlayer, NULL);
			attrVal.valueBase *= GetAmmoPercentage();
			attrVal.valueAdditive *= GetAmmoPercentage();
			attrVal.valueMultiplicative *= GetAmmoPercentage();
		}
		if( GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ) )
			attrVal.valueAdditive += 0.05;
		//theGame.witcherLog.AddCombatMessage("Value modified: " + CalculateAttributeValue( attrVal ), thePlayer, NULL);
		return attrVal;
	}
	
	//modSigns
	public final function GetCriticalDamageBonus( monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
	{
		var attrVal, min, max : SAbilityAttributeValue;
		
		if( GetAmmoCurrentCount() < 1 )
			return attrVal;
		if( GetMonsterCategory() == monsterCategory )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( oilAbility, MonsterCategoryToCriticalDamageBonus( monsterCategory ), min, max );
			attrVal = GetAttributeRandomizedValue(min, max);
			//theGame.witcherLog.AddCombatMessage("Ability: " + oilAbility, thePlayer, NULL);
			//theGame.witcherLog.AddCombatMessage("Attribute: " + MonsterCategoryToCriticalDamageBonus( monsterCategory ), thePlayer, NULL);
			//theGame.witcherLog.AddCombatMessage("Value: " + CalculateAttributeValue( attrVal ), thePlayer, NULL);
			attrVal.valueBase *= GetAmmoPercentage();
			attrVal.valueAdditive *= GetAmmoPercentage();
			attrVal.valueMultiplicative *= GetAmmoPercentage();
		}
		if( GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ) )
			attrVal.valueAdditive += 0.10;
		//theGame.witcherLog.AddCombatMessage("Value modified: " + CalculateAttributeValue( attrVal ), thePlayer, NULL);
		return attrVal;
	}
	
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var otherLevel, selfLevel : int;
		var oilTypeSelf, oilTypeOther : string;
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		var otherBuff : W3Effect_Oil;
	
		otherBuff = ( W3Effect_Oil ) e;		
		oilTypeSelf = StrLeft( oilItemName, StrLen( oilItemName ) - 2 );
		oilTypeOther = StrLeft( otherBuff.oilItemName, StrLen( otherBuff.oilItemName ) - 2 );
		
		if(oilTypeSelf != oilTypeOther)
		{
			return EI_Pass;
		}
		
		
		dm = theGame.GetDefinitionsManager();
		dm.GetItemAttributeValueNoRandom( oilItemName, true, 'level', min, max );
		selfLevel = RoundMath( CalculateAttributeValue( min ) );
		
		dm.GetItemAttributeValueNoRandom( otherBuff.oilItemName, true, 'level', min, max );
		otherLevel = RoundMath( CalculateAttributeValue( min ) );
		
		if( otherLevel >= selfLevel)
		{
			return EI_Override;
		}

		return EI_Deny;
	}
}

class W3OilBuffParams extends W3BuffCustomParams
{
	var iconPath : string;
	var localizedName : string;
	var localizedDescription : string;
	var currCount : int;
	var maxCount : int;
	var sword : SItemUniqueId;
	var oilAbilityName : name;
	var oilItemName : name;
}