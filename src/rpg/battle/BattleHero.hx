package rpg.battle;

class BattleHero {

    var id : Int;
    var team: Int;
    var hero : Hero;
    var hp : Int;
    var correction : Parameter;

    public function new(id:Int, team:Int, hero:Hero) {
        this.id = id;
        this.team = team;
        this.hero = hero;
        this.hp = hero.getHp();
        this.correction = {attack:0, block:0, speed:0, health:0};
    }

    public function getId():Int { return this.id; }
    public function getTeam():Int { return this.team; }
    public function getHero():Hero { return this.hero; }
    public function getHp():Int { return this.hp; }

    public function damage(value:Int):Void {
        this.hp -= value;
        this.hp = if(this.hp < 0) 0 else this.hp;
    }

}
