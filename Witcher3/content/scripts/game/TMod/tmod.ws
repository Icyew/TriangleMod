class TModOptions
{   
	
	// ---- Combat Begin ---- //

	public function GetHeavyAttackDamageMod() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackDmgMod' ) );
	}

	public function GetLightAttackComboBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'LightAttackComboBonus' ) );
	}

	public function GetHeavyAttackComboBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackComboBonus' ) );
	}

	public function GetLightAttackComboDecay() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'LightAttackComboDecay' ) );
	}

	public function GetHeavyAttackComboDecay() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackComboDecay' ) );
	}

	public function GetRendChargeBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'RendChargeBonus' ) );
	}

	// ---- Combat End ---- //

	// ---- Stamina Begin ---- //

	public function GetAltArmorStaminaMod() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'AltArmorStaminaMod');
	}

	public function SetActionStaminaCost(action : EStaminaActionType, out cost : SAbilityAttributeValue, optional abilityName : name, optional isPerSec : bool)
	{
		switch (action) {
			case ESAT_Dodge:
				cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseDodgeCost') );
			case ESAT_Roll:
				cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseRollCost') );
			case ESAT_LightAttack:
				cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseLightAttackCost') );
			case ESAT_HeavyAttack:
				cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseHeavyAttackCost') );
			case ESAT_Ability:
				if (SkillNameToEnum(abilityName) == S_Sword_s02 && !isPerSec) {
					cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseHeavyAttackCost') ) * 2; // for now, rend has 2x base stamina cost
				} else if (SkillNameToEnum(abilityName) == S_Sword_s01 && !isPerSec) { // Triangle TODO draining stamina for whirl might not be necessary, since drain per sec already active
					cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'BaseLightAttackCost') );
				}
				break;
			default:
				return;
		}
		cost.valueBase = 0;
	}

	public function GetArmorStaminaMod(armorType : EArmorType, armorSlot : EEquipmentSlots, action : EStaminaActionType, optional abilityName : name, optional isPerSec : bool) : float
	{
		var weight : float;
		var isBig, isAttack, isEvade : bool;

		if (armorType == EAT_Light)
			weight = 1;
		else if (armorType == EAT_Medium)
			weight = 2;
		else if (armorType == EAT_Heavy)
			weight = 3;
		else
			weight = 0;

		isBig = (armorSlot == EES_Armor || armorSlot == EES_Pants || false);
		isAttack = (action == ESAT_LightAttack || action == ESAT_HeavyAttack ||
			(action == ESAT_Ability && SkillNameToEnum(abilityName) == S_Sword_s02) ||
			(action == ESAT_Ability && SkillNameToEnum(abilityName) == S_Sword_s01) || false);
		isEvade = (action == ESAT_Dodge || action == ESAT_Roll || action == ESAT_Evade || action == ESAT_Jump || false);

		if (isBig && !isPerSec) {
			if (isAttack)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'ChestPantsAttackCost') ) * weight;
			if (isEvade)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'ChestPantsEvasionCost') ) * weight;
		} else if (!isPerSec) {
			if (isAttack)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsAttackCost') ) * weight;
			if (isEvade)
				return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsEvasionCost') ) * weight;
		}
		return 0;
	}

	// triangle TODO dead code for now
	public function GetArmorSpeedBonus(inventory : CInventoryComponent, action : EBufferActionType) : float
	{
		var speedBonus, speedPenalty, tempMod : float;
		var tempItem : SItemUniqueId;
		var armorEq, glovesEq, pantsEq, bootsEq : bool;

		if (action != EBAT_Dodge && action != EBAT_Roll) {
			return 1.0;
		}

		speedBonus = 1.0;
		speedPenalty = 1.0;
		if (inventory.GetItemEquippedOnSlot(EES_Armor, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'ChestEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		if (inventory.GetItemEquippedOnSlot(EES_Pants, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'PantsEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		if (inventory.GetItemEquippedOnSlot(EES_Gloves, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		if (inventory.GetItemEquippedOnSlot(EES_Boots, tempItem) && inventory.GetArmorType(tempItem) != EAT_Medium) {
			tempMod = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'GlovesBootsEvasionMod') ) / 100;
			if (inventory.GetArmorType(tempItem) == EAT_Heavy)
				speedPenalty += tempMod;
			else
				speedBonus += tempMod;
		}

		speedPenalty = 1 / speedPenalty;
		return speedBonus * speedPenalty;
	}

	public function GetStaminaRegenMult() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'StaminaRegenMult' ) );
	}

	public function GetStaminaRegenBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'StaminaRegenBonus' ) );
	}

	public function GetFocusPerMaxStamina() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'FocusPerMaxStamina' ) );
	}

	public function GetWeakDamageMod() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'WeakDamageMod' ) );
	}

	// ---- Stamina End --- //

	// ---- Signs Begin ---- //

	public function SetSignStaminaCost(abilityName : name, out cost : SAbilityAttributeValue, out delay : SAbilityAttributeValue, isPerSec : bool)
	{
		var skill : ESkill;
		skill = SkillNameToEnum(abilityName);
		if (!theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'UseCustomSignStaminaCosts' ))
			return;
		switch(skill) {
			case S_Magic_1:
			case S_Magic_2:
			case S_Magic_3:
			case S_Magic_4:
			case S_Magic_5:
				if (!isPerSec) {
					cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'BasicSignCost' ) );
					delay.valueBase = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'BasicSignDelay' ) );
				}
				return;
			case S_Magic_s01:
				cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'AltAardCost' ) );
				break;
			case S_Magic_s02:
				if (isPerSec)
					cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'AltIgniCost' ) );
				break;
			case S_Magic_s03:
				if (isPerSec)
					cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'AltYrdenCost' ) );
				break;
			case S_Magic_s04:
				if (isPerSec)
					cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'AltQuenCost' ) );
				break;
			case S_Magic_s05:
				if (isPerSec)
					cost.valueAdditive = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'AltAxiiCost' ) );
				break;
			default:
				return;
		}
		delay.valueBase = StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'AltSignDelay' ) );
		delay.valueMultiplicative = 1; // for firestream... annoying. O hope nothing else tries to change this
	}

	public function GetQuenStaminaRegenMult() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'QuenStaminaRegenMult' ) );
	}

	public function GetQuenDamageRatio() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'QuenDamageRatio' ) );
	}

	// ---- Signs End ---- //

	// ---- Leveling Begin ---- //
	public function AreLevelOptionsEnabled() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'AreLevelOptionsEnabled' );
	}

	public function IsUpscalingOn() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LinearUpscaling' );
	}

	public function IsDownscalingOn() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LinearDownscaling' );
	}

	public function DontScaleAnimals() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'DontScaleAnimals' );
	}

	public function GetUpscalingFactor() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'UpscalingFactor' ) );
	}

	public function GetDownscalingFactor() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'DownscalingFactor' ) );
	}
	
	public function GetFlatLevelBonus() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LevelBonus' ) );
	}

	public function GetLevelJitter() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LevelJitter' ) );
	}
	// ---- Leveling End ---- //

	// ---- Enemies Begin ---- //

	public function CanVitalityMutate() : bool
	{
		return !theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'MonstersOnly' );
	}

	public function GetEnemyMutationChance() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'EnemyMutationChance' ) ) / 100;
	}

	public function GetNumEnemyMutationRolls() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'NumEnemyMutationRolls' ) );
	}

	public function GetRandomEnemyMutations(out results : array < name >, optional forceAbilityName : name)
	{
		var mutations : array < T_EMutation >;
		var mutation : T_EMutation;
		var i : int;

		for (i = 1; i < (int)TEM_TOTAL_COUNT; i += 1) {
			if (theGame.GetDefinitionsManager().AbilityHasTag(T_EMutationEnumToName((T_EMutation)i), 'TEMutation'))
				mutations.PushBack((T_EMutation)i);
		}

		for (i = 0; i < GetNumEnemyMutationRolls(); i += 1) {
			if (RandF() < GetEnemyMutationChance()) {
				mutation = mutations[RandRange(mutations.Size())];
				results.PushBack(T_EMutationEnumToName(mutation));
				mutations.Remove(mutation);
				if (mutations.Size() == 0)
					return;
			}
		}
	}

	public function GetHugeScaleFactor() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'HugeScaleFactor' ) );
	}

	public function GetToughArmorPerLevel() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ToughArmorPerLevel' ) );
	}

	public function GetToughResistance() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ToughResistance' ) ) / 100;
	}

	public function GetQuickSpeedBonus() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'QuickSpeedBonus' ) ) / 100;
	}

	public function GetResilientRegenPerLevel() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ResilientRegenPerLevel' ) );
	}

	public function GetResilientDuration() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ResilientDuration' ) );
	}

	public function GetElectricCooldown() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ElectricCooldown' ) );
	}

	public function GetElectricDamageRatio() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ElectricDamageRatio' ) );
	}

	public function GetFlamingMaxDamageRatio() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'FlamingDamageRatio' ) ) / 100;
	}

	public function GetVampiricHealRatio() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'VampiricHealRatio' ) );
	}

	public function GetVenomousDuration() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'VenomousDuration' ) );
	}

	public function GetExplosiveDamageRatio() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ExplosiveDamageRatio' ) );
	}

	public function GetExplosiveRange() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ExplosiveRange' ) );
	}

	public function GetFlamingRange() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'FlamingRange' ) );
	}

	public function GetFreezingRange() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'FreezingRange' ) );
	}

	public function GetHypnoticRange() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'HypnoticRange' ) );
	}

	public function GetMinHypnoticDelay() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'HypnoticDelay' ) );
	}

	public function GetInspiredBonus() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'InspiredBonus' ) );
	}

	public function GetCripplingShotDurationPerLevel() : float
	{
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'CripplingShotDurationPerLevel' ) );
	}

	// ---- Enemies end ---- //
}