package rpg;

import rpg.battle.*;
import rpg.battle.Result;

class Dungeon {

    var depth        : Int;
    var lotteryTable : Array<DungeonLot>;
    var boss         : Array<DungeonEnemy>;

    public function new(depth, lotteryTable, boss) {
        this.depth = depth;
        this.lotteryTable = lotteryTable;
        this.boss = boss;
    }

    public function solveAuto(heros:Array<Hero>):DungeonResult {
        var result:DungeonResult = {
            exp: {attack:0, block:0, speed:0, health:0},
            battles: [],
            depth:0,
        };
        var id2hero = new Map<String, Hero>();
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
        var rateSum = Lambda.fold(this.lotteryTable, function(e, p) {
            return p + e.rate;
        }, 0);
        var pivot = Rand.next() % rateSum;
        for (lot in this.lotteryTable) {
            if (lot.rate > pivot) {
                return Lambda.array(Lambda.mapi(lot.enemies, function(i, e) {
                    return new Hero('enemy' + i, e.color, e.plan, Hero.generateTalent(), e.effort, e.skills);
                }));
            }
        }
        throw 'invalid table';
    }

}

typedef DungeonResult = {
    exp:Parameter,
    battles:Array<BattleResult>,
    depth:Int,
}

typedef DungeonEnemy = {
    color  : Color,
    plan   : Plan,
    effort : Parameter,
    skills : Array<Skill>,
}

typedef DungeonLot = {
    enemies : Array<DungeonEnemy>,
    rate    : Int,
}

class MonkeyAI implements Engine.Request {

    var engine:Engine;
    var friendTeam:Int;

    public function new(engine:Engine, friendTeam:Int) {
        this.engine = engine;
        this.friendTeam = friendTeam;
    }

    public function getCommands():Iterable<Engine.Command> {
        var friends:List<BattleHero> = this.engine.getFriends(this.friendTeam);
        var enemies:List<BattleHero> = this.engine.getEnemies(this.friendTeam);
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
