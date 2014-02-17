package rpg;

typedef Skill = {
    id      : Int,
    name    : String,
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
