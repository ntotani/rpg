package rpg.service;

import haxe.ds.IntMap;

class DungeonService {

    static var master = new IntMap<StoredDungeon>();

    public static function get(id:Int):Dungeon {
        var dungeon = master.get(id);
        return new Dungeon(dungeon.name, dungeon.desc, dungeon.depth, dungeon.preDepth, dungeon.postDepth, Lambda.array(Lambda.map(dungeon.lotteryTable, function(e) {
            return {
                enemies : Lambda.array(Lambda.map(e.enemies, fromStored)),
                rate    : e.rate,
            }
        })), dungeon.nameTable, Lambda.array(Lambda.map(dungeon.boss, fromStored)));
    }

    public static function set(id:Int, dungeon:StoredDungeon) {
        master.set(id, dungeon);
    }

    public static function commit(dungeonStorage:DungeonStorage, heroStorage:HeroService.HeroStorage, now:Int, dungeon:Dungeon, depth:Int) {
        var team = HeroService.getTeam(heroStorage);
        for (hero in team) {
            hero.setHp(HeroService.calcCurrentHp(hero, now));
        }
        var exp = Parameter.Parameters.ZERO;
        var result = dungeon.solveAuto(team, depth, function(engine) {
            if (!engine.isWin(0)) {
                return;
            }
            var battleResult = engine.getResult();
            for (enemy in battleResult.teamBlue) {
                exp = Parameter.Parameters.sum(exp, enemy.calcExp());
            }
        });
        for (hero in team) {
            if (hero.getHp() > 0) {
                hero.applyExp(exp);
            }
        }
        HeroService.update(heroStorage, team);
        var storedResult = {
            battles:Lambda.array(Lambda.map(result.battles, function(e) {
                return {
                    teamRed: Lambda.array(Lambda.map(e.teamRed, HeroService.toStored)),
                    teamBlue: Lambda.array(Lambda.map(e.teamBlue, HeroService.toStored)),
                    turns: e.turns,
                }
            })),
        }
        dungeonStorage.setResult(now, storedResult);
    }

    public static function getLatestResult(storage:DungeonStorage):Dungeon.DungeonResult {
        var storedResult = storage.getLatest();
        return {
            battles:Lambda.array(Lambda.map(storedResult.battles, function(e) {
                return {
                    teamRed: Lambda.array(Lambda.map(e.teamRed, HeroService.fromStored)),
                    teamBlue: Lambda.array(Lambda.map(e.teamBlue, HeroService.fromStored)),
                    turns: e.turns,
                }
            })),
        };
    }

    static function fromStored(stored:StoredEnemy):Dungeon.DungeonEnemy {
        return {
            name   : stored.name,
            color  : Color.Colors.valueOf(stored.color),
            plan   : Plan.Plans.valueOf(stored.plan),
            effort : stored.effort,
            skills : Lambda.array(Lambda.map(stored.skills, function(e) {
                return SkillService.get(e);
            })),
        }
    }

}

interface DungeonStorage {
    function setResult(now:Int, result:StoredDungeonResult):Void;
    function getLatest():StoredDungeonResult;
}

typedef StoredDungeonResult = {
    battles : Array<StoredBattleResult>,
}

typedef StoredBattleResult = {
    teamRed  : Array<HeroService.StoredHero>,
    teamBlue : Array<HeroService.StoredHero>,
    turns    : Array<rpg.battle.Result.Turn>,
}

typedef StoredDungeon = {
    name         : String,
    desc         : String,
    depth        : Int,
    preDepth     : String,
    postDepth    : String,
    lotteryTable : Array<StoredLot>,
    nameTable    : Array<String>,
    boss         : Array<StoredEnemy>,
}

typedef StoredLot = {
    enemies : Array<StoredEnemy>,
    rate    : Int,
}

typedef StoredEnemy = {
    name   : String,
    color  : String,
    plan   : String,
    effort : Parameter,
    skills : Array<Int>,
}
