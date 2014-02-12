import battle.*;
import battle.Result;

class Dungeon {

    var name : String;
    var depth : Int;
    // env (weather, ground...)

    public function new() {
        this.name = '';
        this.depth = 1;
    }

    public function solveAuto(heros:Array<Hero>):Result {
        var result:Result = {
            exp: {attack:0, block:0, speed:0, health:0},
            battles: [],
            depth:0,
        };
        var id2hero:Map<String, Hero> = new Map<String, Hero>();
        for (e in heros) { id2hero.set(e.getId(), e); }
        for (i in 0...depth) {
            var enemies:Array<Hero> = this.spawnEnemies();
            var engine:Engine = new Engine(heros, enemies);
            var friendAgent:MonkeyAI = new MonkeyAI(engine, 0);
            var enemyAgent:MonkeyAI = new MonkeyAI(engine, 1);
            while (!engine.isFinish()) {
                engine.execute(friendAgent);
                engine.execute(enemyAgent);
            }
            for (e in engine.getHeros()) {
                var id:String = e.getHero().getId();
                if (id2hero.exists(id)) {
                    id2hero.get(id).setHp(e.getHp());
                }
            }
            // check
            result.battles.push(engine.getResult());
        }
        return result;
    }
    
    public function spawnEnemies():Array<Hero> {
        var zero:Parameter = {attack:0, block:0, speed:0, health:0};
        return [Hero.create('hoge', zero, zero)];
    }

}

typedef Result = {
    exp:Parameter,
    battles:Array<BattleResult>,
    depth:Int,
}

class MonkeyAI implements Engine.Request {

    var engine:Engine;
    var friendTeam:Int;

    public function new(engine:Engine, friendTeam:Int) {
        this.engine = engine;
        this.friendTeam = friendTeam;
    }

    public function getCommands():Iterable<Engine.Command> {
        var friends:List<HeroState> = this.engine.getFriends(this.friendTeam);
        var enemies:List<HeroState> = this.engine.getEnemies(this.friendTeam);
        return Lambda.map(friends, function(friend) {
            var target:Int = Lambda.fold(enemies, function(e, p) {
                return e.getHp() > 0 ? e.getId() : p;
            }, 0);
            return {actor:friend.getId(), target:target, skill:0};
        });
    }

    public function callback(turn:Turn, finish:Bool):Void {
    }

}
