package rpg;

import rpg.battle.*;
import rpg.battle.Result;

class Dungeon {

    var id           : Int;
    var area         : Int;
    var name         : String;
    var desc         : String;
    var depth        : Int;
    var preDepth     : String;
    var postDepth    : String;
    var lotteryTable : Array<DungeonLot>;
    var nameTable    : Array<String>;
    var boss         : Array<DungeonEnemy>;

    public function new(id, area, name, desc, depth, preDepth, postDepth, lotteryTable, nameTable, boss) {
        this.id = id;
        this.area = area;
        this.name = name;
        this.desc = desc;
        this.depth = depth;
        this.preDepth = preDepth;
        this.postDepth = postDepth;
        this.lotteryTable = lotteryTable;
        this.nameTable = nameTable;
        this.boss = boss;
    }

    public function getId():Int { return id; }
    public function getArea():Int { return area; }
    public function getDepth():Int { return depth; }

    public function solveAuto(heros:Array<Hero>, targetDepth:Int, ?onBattle:Engine->Void):DungeonResult {
        var result:DungeonResult = {
            battles: [],
            join:'',
        };
        var id2hero = new Map<String, Hero>();
        for (e in heros) { id2hero.set(e.getId(), e); }
        for (i in 0...depth) {
            var enemies = this.toHeros((i + 1) == depth ? this.boss : this.spawnEnemies(), i + 1);
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
            if (onBattle != null) { onBattle(engine); }
            result.battles.push(engine.getResult());
            if (!engine.isWin(0) || result.battles.length >= targetDepth) {
                break;
            }
        }
        return result;
    }

    public function spawnEnemies():Array<DungeonEnemy> {
        var rateSum = Lambda.fold(this.lotteryTable, function(e, p) {
            return p + e.rate;
        }, 0);
        var pivot = Rand.next() % rateSum;
        for (lot in this.lotteryTable) {
            if (lot.rate > pivot) {
                return lot.enemies;
            }
        }
        throw 'invalid table';
    }

    public function toHeros(enemies:Array<DungeonEnemy>, depth:Int):Array<Hero> {
        return Lambda.array(Lambda.mapi(enemies, function(i, e) {
            var name = e.name == '_RAND_' ? this.nameTable[Rand.next() % this.nameTable.length] : e.name;
            return new Hero('enemy_${depth}_${i}', name, e.color, e.plan, Hero.generateTalent(), e.effort, e.skills, 0);
        }));
    }

}

typedef DungeonResult = {
    battles:Array<BattleResult>,
    join:String,
}

typedef DungeonEnemy = {
    name   : String,
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
