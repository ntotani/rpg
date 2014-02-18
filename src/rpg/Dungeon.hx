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
            battles: [],
        };
        var id2hero = new Map<String, Hero>();
        for (e in heros) { id2hero.set(e.getId(), e); }
        for (i in 0...depth) {
            var enemies = this.spawnEnemies();
            var engine = new Engine(heros, enemies);
            var friendAgent = new MonkeyAI(engine, 0);
            var enemyAgent = new MonkeyAI(engine, 1);
            while (!engine.isFinish()) {
                engine.execute(friendAgent);
                engine.execute(enemyAgent);
            }
            for (e in engine.getHeros()) {
                var id = e.getHero().getId();
                if (id2hero.exists(id)) {
                    id2hero.get(id).setHp(e.getHp());
                }
            }
            result.battles.push(engine.getResult());
            if (!engine.isWin(0)) {
                break;
            }
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
    battles:Array<BattleResult>,
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
        var friends = Lambda.filter(this.engine.getFriends(this.friendTeam), function(e) { return e.alive(); });
        var enemies = Lambda.array(Lambda.filter(this.engine.getEnemies(this.friendTeam), function(e) { return e.alive(); }));
        return Lambda.map(friends, function(friend) {
            return {
                actor:friend.getId(),
               target:enemies[Rand.next() % enemies.length].getId(),
               skill:Rand.next() % friend.getHero().getSkillNum(),
            };
        });
    }

    public function callback(turn:Turn, finish:Bool):Void {
    }

}
