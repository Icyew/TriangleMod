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
