// Some utility functions for mod I didn't feel like putting elsewhere

function T_PowerSkillForSignType(sign : ESignType) : ESkill
{
    var associatedSkill : ESkill;

    if (sign == ST_Aard)
        associatedSkill = S_Magic_s12;
    else if(sign == ST_Igni)
        associatedSkill = S_Magic_s07;
    else if(sign == ST_Yrden)
        associatedSkill = S_Magic_s16;
    else if(sign == ST_Quen)
        associatedSkill = S_Magic_s15;
    else if(sign == ST_Axii)
        associatedSkill = S_Magic_s18;
    else
        associatedSkill = S_SUndefined;
    return associatedSkill;
}

function T_DmgTypeForPowerSkill(skill : ESkill) : name
{
    if (skill == S_Magic_s12)
        return theGame.params.DAMAGE_NAME_FORCE;
    else if (skill == S_Magic_s07)
        return theGame.params.DAMAGE_NAME_FIRE;
    else if (skill == S_Magic_s16)
        return theGame.params.DAMAGE_NAME_SHOCK;
    else if (skill == S_Magic_s15)
        return theGame.params.DAMAGE_NAME_FORCE;
    else if (skill == S_Magic_s18)
        return theGame.params.DAMAGE_NAME_WILL;
    return '';
}

function T_AddMessage(message : string)
{
    theGame.witcherLog.AddMessage(message);
}

function T_LogMessage(message : string)
{
    LogChannel('TMod', message);
}

function T_StaminaCostToFocusCost(cost : float) : float
{
    return cost / thePlayer.GetStatMax(BCS_Stamina) * theGame.GetTModOptions().GetFocusPerMaxStamina();
}

enum T_EMutation
{
    TEM_Undefined,
    TEM_Tough,
    TEM_Quick,
    TEM_Huge,
    TEM_Resilient,
    TEM_TOTAL_COUNT
}

function T_EMutationNameToEnum(val : name) : T_EMutation
{
    switch (val) {
        case 'T_Tough':
            return TEM_Tough;
        case 'T_Quick':
            return TEM_Quick;
        case 'T_Huge':
            return TEM_Huge;
        case 'T_Resilient':
            return TEM_Resilient;
        default:
            return TEM_Undefined;
    }
}

function T_EMutationEnumToName(val : T_EMutation) : name
{
    switch (val) {
        case TEM_Tough:
            return 'T_Tough';
        case TEM_Quick:
            return 'T_Quick';
        case TEM_Huge:
            return 'T_Huge';
        case TEM_Resilient:
            return 'T_Resilient';
        default:
            return '';
    }
}

// Triangle enemy mutations
function T_GetMutatedPrefix(stats : CCharacterStats) : string
{
    var prefix : string;
    prefix = "";
    if (stats.HasAbility(T_EMutationEnumToName(TEM_Tough)))
        prefix += "Tough ";
    if (stats.HasAbility(T_EMutationEnumToName(TEM_Huge)))
        prefix += "Huge ";
    if (stats.HasAbility(T_EMutationEnumToName(TEM_Quick)))
        prefix += "Quick ";
    if (stats.HasAbility(T_EMutationEnumToName(TEM_Resilient)))
        prefix += "Resilient ";
    return prefix;
}

function T_IsPhysicalDamage(dmgType : name) : bool
{
    return ( dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || 
            dmgType == theGame.params.DAMAGE_NAME_SLASHING || 
            dmgType == theGame.params.DAMAGE_NAME_PIERCING || 
            dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING || 
            dmgType == theGame.params.DAMAGE_NAME_RENDING || 
            dmgType == theGame.params.DAMAGE_NAME_SILVER );
}
