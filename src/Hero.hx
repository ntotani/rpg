import Color;
import Plan;
import Parameter;
import Skill;

@:expose('Hero')
class Hero {

    public static var MAX_TALENT : Int = 15;

    var id       : String;
    var name     : String;
    var color    : Color;
    var plan     : Plan;
    var talent   : Parameter;
    var effort   : Parameter;
    var hp       : Int;
    var returnAt : Date;
    var skills   : Array<Skill>;

    function new(id:String) {
        this.id = id;
        this.name = '';
        this.color = Color.SUN;
        this.plan = Plan.MONKEY;
        this.talent = {attack:0, block:0, speed:0, health:0};
        this.effort = {attack:0, block:0, speed:0, health:0};
        this.hp = 100;
        this.returnAt = Date.now();
        this.skills = [new Skill()];
    }

    public static function create(id:String, talent:Parameter, effort:Parameter):Hero {
        var hero:Hero = new Hero(id);
        hero.talent = talent;
        hero.effort = effort;
        return hero;
    }
    
    /*
    public static function create(json:String):Hero {
    }
    public static function spawn(rnd:Random):Hero {
    }
    */
    
    public function getId():String { return this.id; }
    public function getHp():Int { return this.hp; }
    public function setHp(hp:Int):Void { this.hp = hp; }
    public function getSkill(idx:Int):Skill { return this.skills[idx]; }
    
    public static function calcParameter(talent:Int, effort:Int):Int {
        return Std.int(Math.max(1, talent + effort / 4));
    }
    
    public function getParameter():Parameter {
        return {
            attack : Hero.calcParameter(this.talent.attack, this.effort.attack),
            block  : Hero.calcParameter(this.talent.block , this.effort.block) ,
            speed  : Hero.calcParameter(this.talent.speed , this.effort.speed) ,
            health : Hero.calcParameter(this.talent.health, this.effort.health),
        }
    }

}
