package rpg;

class Hero {

    public static var MAX_TALENT : Int = 16;
    public static var EFFORT_LIMIT : Int = 128;
    public static var EFFORT_SUM_LIMIT : Int = 256;

    var id       : String;
    var name     : String;
    var color    : Color;
    var plan     : Plan;
    var talent   : Parameter;
    var effort   : Parameter;
    var hp       : Int;
    var skills   : Array<Skill>;

    public function new(id:String, name:String, color:Color, plan:Plan, talent:Parameter, effort:Parameter, skills:Array<Skill>) {
        if (validateTalent(talent)) {
            throw HeroError.INVALID_TALENT;
        }
        if (validateEffort(effort)) {
            throw HeroError.INVALID_EFFORT;
        }
        this.id = id;
        this.name = name;
        this.color = color;
        this.plan = plan;
        this.talent = talent;
        this.effort = effort;
        this.hp = this.getParameter().health;
        this.skills = skills;
    }

    public static function validateTalent(talent:Parameter):Bool {
        return
            talent.attack < 1 || talent.attack > Hero.MAX_TALENT
            || talent.block < 1 || talent.block > Hero.MAX_TALENT
            || talent.speed < 1 || talent.speed > Hero.MAX_TALENT
            || talent.health < 1 || talent.health > Hero.MAX_TALENT;
    }

    public static function validateEffort(effort:Parameter):Bool {
        return
            effort.attack < 0 || effort.attack > Hero.EFFORT_LIMIT
            || effort.block < 0 || effort.block > Hero.EFFORT_LIMIT
            || effort.speed < 0 || effort.speed > Hero.EFFORT_LIMIT
            || effort.health < 0 || effort.health > Hero.EFFORT_LIMIT
            || (effort.attack + effort.block + effort.speed + effort.health) > Hero.EFFORT_SUM_LIMIT;
    }

    public function getId():String { return this.id; }
    public function getHp():Int { return this.hp; }
    public function setHp(hp:Int):Void { this.hp = hp; }
    public function getSkill(idx:Int):Skill { return this.skills[idx]; }
    public function getSkillNum() { return this.skills.length; }
    public function getEffort() { return this.effort; };
    public function getColor() { return this.color; }

    public function getParameter():Parameter {
        var level:Int = getLevel();
        return {
            attack : calcParameter(this.talent.attack, this.effort.attack, level),
            block  : calcParameter(this.talent.block , this.effort.block, level) ,
            speed  : calcParameter(this.talent.speed , this.effort.speed, level) ,
            health : calcHealthParameter(this.talent.health, this.effort.health, level),
        }
    }

    public function getLevel():Int {
        return calcLevel(this.effort);
    }

    public static function calcParameter(talent:Int, effort:Int, level:Int):Int {
        return Std.int((60 + talent + effort / 4) * level / 10);
    }

    public static function calcHealthParameter(talent:Int, effort:Int, level:Int):Int {
        return Hero.calcParameter(talent, effort, level) + level * 5;
    }

    public static function calcLevel(effort:Parameter):Int {
        var sum:Int = effort.attack + effort.block + effort.speed + effort.health;
        return Std.int(Math.sqrt(sum) * 9 / 16) + 1;
    }

    public function recoverAllHp():Void {
        this.hp = this.getParameter().health;
    }

    public static function generateTalent():Parameter {
        return {
            attack : (Rand.next() % MAX_TALENT) + 1,
            block  : (Rand.next() % MAX_TALENT) + 1,
            speed  : (Rand.next() % MAX_TALENT) + 1,
            health : (Rand.next() % MAX_TALENT) + 1,
        }
    }

    public function applyExp(effort:Parameter) {
        this.effort.attack += trimEffort(this.effort.attack, effort.attack);
        this.effort.block += trimEffort(this.effort.block, effort.block);
        this.effort.speed += trimEffort(this.effort.speed, effort.speed);
        this.effort.health += trimEffort(this.effort.health, effort.health);
    }

    function trimEffort(base:Int, gain:Int):Int {
        var ret = Std.int(Math.min(EFFORT_LIMIT - base, gain));
        var sum = effort.attack + effort.block + effort.speed + effort.health;
        return Std.int(Math.min(EFFORT_SUM_LIMIT - sum, ret));
    }

    public function calcExp():Parameter {
        var exp = {attack:0, block:0, speed:0, health:0};
        var val = this.getLevel();
        switch(this.color) {
            case FIRE:
            case WATER:
            case TREE:
                exp.attack = val;
            case EARTH:
                exp.block = val;
            case MOON:
            case GOLD:
                exp.speed = val;
            case SUN:
                exp.health = val;
        }
        return exp;
    }

}

enum HeroError {
    INVALID_TALENT;
    INVALID_EFFORT;
}
