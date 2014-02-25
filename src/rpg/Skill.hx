package rpg;

typedef Skill = {
    id      : Int,
    name    : String,
    desc    : String,
    color   : Color,
    type    : SkillType,
    effect  : SkillEffect,
    target  : SkillTarget,
    power   : Int,
    hitRate : Int,
}

enum SkillTarget {
    ENEMY;
    /*
    ENEMY_ALL;
    FRIEND;
    FRIEND_ALL;
    ALL;
    SELF;
    */
}

enum SkillType {
    ATTACK;
    BLOCK;
    ENHANCE;
    JAM;
    HEAL;
}

enum SkillEffect {
    ATTACK;
}

class Skills {

    public static function targetValueOf(str:String):SkillTarget {
        return Type.createEnum(SkillTarget, str);
    }

    public static function typeValueOf(str:String):SkillType {
        return Type.createEnum(SkillType, str);
    }

    public static function effectValueOf(str:String):SkillEffect {
        return Type.createEnum(SkillEffect, str);
    }

}
