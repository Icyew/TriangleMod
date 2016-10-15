// ---- Combat Begin ---- //

function TOpts_HeavyAttackDamageMod() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackDmgMod' ) );
}

function TOpts_LightAttackComboBonus() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'LightAttackComboBonus' ) );
}

function TOpts_HeavyAttackComboBonus() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackComboBonus' ) );
}

function TOpts_LightAttackComboDecay() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'LightAttackComboDecay' ) );
}

function TOpts_HeavyAttackComboDecay() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'HeavyAttackComboDecay' ) );
}

function TOpts_RendChargeBonus() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'RendChargeBonus' ) );
}

function TOpts_ResolveDamagePerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'ResolveDamagePerLevel' ) ) / 100;
}

function TOpts_ResolveDuration() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'ResolveDuration' ) );
}

function TOpts_ParryCooldown() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'ParryCooldown' ) );
}

function TOpts_MaxParries() : int
{
	return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionCombat', 'MaxParries' ) );
}

// ---- Combat End ---- //

// ---- Alchemy Begin ---- //

function TOpts_BonusToxicity() : int
{
	return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'BonusToxicity' ) );
}

function TOpts_EndurePainDamageRatioPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'EndurePainDamageRatioPerLevel' ) ) / 100;
}

function TOpts_EndurePainDuration() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'EndurePainDuration' ) );
}

function TOpts_AcquiredToleranceDiscount() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'AcquiredToleranceDiscount' ) );
}

function TOpts_AcquiredToleranceDurationPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'AcquiredToleranceDurationPerLevel' ) );
}

function TOpts_DelayedRecoverySlowFactorPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'DelayedRecoverySlowFactorPerLevel' ) );
}

function TOpts_AltTawnyOwlDuration() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'AltTawnyOwlDuration' ) );
}

function TOpts_AltTawnyOwlBase() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'AltTawnyOwlBase' ) );
}

function TOpts_DefaultToxicityDrainTime() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'DefaultToxicityDrainTime' ) );
}

function TOpts_FastMetabolismDrainFactorPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'FastMetabolismDrainFactorPerLevel' ) );
}

function TOpts_AdaptationDiscountPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'AdaptationDiscountPerLevel' ) ) / 100;
}

function TOpts_AdaptationMaxDiscount() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'AdaptationMaxDiscount' ) ) / 100;
}

function TOpts_FixativeMaxBonusPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'FixativeMaxBonusPerLevel' ) ) / 100;
}

function TOpts_FixativeMultBonus() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionAlchemy', 'FixativeMultBonus' ) );
}

// ---- Stamina Begin ---- //

function TOpts_AltArmorStaminaMod() : bool
{
	return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'AltArmorStaminaMod');
}

function TOpts_SetActionStaminaCost(action : EStaminaActionType, out cost : SAbilityAttributeValue, optional abilityName : name, optional isPerSec : bool)
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

function TOpts_ArmorStaminaMod(armorType : EArmorType, armorSlot : EEquipmentSlots, action : EStaminaActionType, optional abilityName : name, optional isPerSec : bool) : float
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
function TOpts_ArmorSpeedBonus(inventory : CInventoryComponent, action : EBufferActionType) : float
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

function TOpts_StaminaRegenMult() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'StaminaRegenMult' ) );
}

function TOpts_StaminaRegenBonus() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'StaminaRegenBonus' ) );
}

function TOpts_FocusPerMaxStamina() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'FocusPerMaxStamina' ) );
}

function TOpts_WeakDamageMod() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionStamina', 'WeakDamageMod' ) );
}

// ---- Stamina End --- //

// ---- Signs Begin ---- //

function TOpts_SetSignStaminaCost(abilityName : name, out cost : SAbilityAttributeValue, out delay : SAbilityAttributeValue, isPerSec : bool)
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
				delay.valueMultiplicative = 1;
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

function TOpts_QuenStaminaRegenMult() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'QuenStaminaRegenMult' ) );
}

function TOpts_QuenDamageRatio() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionSigns', 'QuenDamageRatio' ) );
}

// ---- Signs End ---- //

// ---- Leveling Begin ---- //
function TOpts_AreLevelOptionsEnabled() : bool
{
	return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'AreLevelOptionsEnabled' );
}

function TOpts_IsUpscalingOn() : bool
{
	return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LinearUpscaling' );
}

function TOpts_IsDownscalingOn() : bool
{
	return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LinearDownscaling' );
}

function TOpts_DontScaleAnimals() : bool
{
	return theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'DontScaleAnimals' );
}

function TOpts_UpscalingFactor() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'UpscalingFactor' ) );
}

function TOpts_DownscalingFactor() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'DownscalingFactor' ) );
}

function TOpts_FlatLevelBonus() : int
{
	return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LevelBonus' ) );
}

function TOpts_LevelJitter() : int
{
	return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionScaling', 'LevelJitter' ) );
}
// ---- Leveling End ---- //

// ---- Enemies Begin ---- //

function TOpts_CanVitalityMutate() : bool
{
	return !theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'MonstersOnly' );
}

function TOpts_EnemyMutationChance() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'EnemyMutationChance' ) ) / 100;
}

function TOpts_NumEnemyMutationRolls() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'NumEnemyMutationRolls' ) );
}

function TOpts_RandomEnemyMutations(out results : array < name >, optional forceAbilityName : name)
{
	var mutations : array < TEMutation >;
	var mutation : TEMutation;
	var i : int;

	for (i = 1; i < (int)TEM_TOTAL_COUNT; i += 1) {
		if (theGame.GetDefinitionsManager().AbilityHasTag(TUtil_TEMutationEnumToName((TEMutation)i), 'TEMutation'))
			mutations.PushBack((TEMutation)i);
	}

	for (i = 0; i < TOpts_NumEnemyMutationRolls(); i += 1) {
		if (RandF() < TOpts_EnemyMutationChance()) {
			mutation = mutations[RandRange(mutations.Size())];
			results.PushBack(TUtil_TEMutationEnumToName(mutation));
			mutations.Remove(mutation);
			if (mutations.Size() == 0)
				return;
		}
	}
}

function TOpts_HugeScaleFactor() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'HugeScaleFactor' ) );
}

function TOpts_ToughArmorPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ToughArmorPerLevel' ) );
}

function TOpts_ToughResistance() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ToughResistance' ) ) / 100;
}

function TOpts_QuickSpeedBonus() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'QuickSpeedBonus' ) ) / 100;
}

function TOpts_ResilientRegenPerLevel() : int
{
	return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ResilientRegenPerLevel' ) );
}

function TOpts_ResilientDuration() : int
{
	return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ResilientDuration' ) );
}

function TOpts_ElectricCooldown() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ElectricCooldown' ) );
}

function TOpts_ElectricDamageRatio() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ElectricDamageRatio' ) );
}

function TOpts_FlamingMaxDamageRatio() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'FlamingDamageRatio' ) ) / 100;
}

function TOpts_VampiricHealRatio() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'VampiricHealRatio' ) );
}

function TOpts_VenomousDuration() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'VenomousDuration' ) );
}

function TOpts_ExplosiveBaseDamage() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ExplosiveBaseDamage' ) );
}

function TOpts_ExplosiveRange() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ExplosiveRange' ) );
}

function TOpts_ExplosiveDelay() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'ExplosiveDelay' ) );
}

function TOpts_FlamingRange() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'FlamingRange' ) );
}

function TOpts_FreezingRange() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'FreezingRange' ) );
}

function TOpts_HypnoticRange() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'HypnoticRange' ) );
}

function TOpts_MinHypnoticDelay() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'HypnoticDelay' ) );
}

function TOpts_InspiredBonus() : int
{
	return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'InspiredBonus' ) );
}

function TOpts_CripplingShotDurationPerLevel() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionEnemies', 'CripplingShotDurationPerLevel' ) );
}

// ---- Enemies end ---- //

// ---- Misc start ---- //

function TOpts_RuneEffectMultiplier() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionMisc', 'RuneEffectMultiplier' ) );
}

function TOpts_GlyphEffectMultiplier() : float
{
	return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('TModOptionMisc', 'GlyphEffectMultiplier' ) );
}

// ---- Misc end ---- //
