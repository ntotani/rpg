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
    var returnAt : Date;
    var skills   : Array<Skill>;

    public function new(id:String, name:String, color:Color, plan:Plan, talent:Parameter, effort:Parameter, hp:Int, returnAt:Date, skills:Array<Skill>) {
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
        this.hp = hp;
        this.returnAt = returnAt;
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

    public function getParameter():Parameter {
        return {
            attack : calcParameter(this.talent.attack, this.effort.attack),
            block  : calcParameter(this.talent.block , this.effort.block) ,
            speed  : calcParameter(this.talent.speed , this.effort.speed) ,
            health : calcHealthParameter(this.talent.health, this.effort),
        }
    }

    public static function calcParameter(talent:Int, effort:Int):Int {
        return talent + Std.int(effort / 4);
    }

    public static function calcHealthParameter(talent:Int, effort:Parameter):Int {
        var sum:Int = Std.int((effort.attack + effort.block + effort.speed + effort.health) / 4);
        return Hero.calcParameter(talent, effort.health) + sum;
    }

}

enum HeroError {
    INVALID_TALENT;
    INVALID_EFFORT;
}
