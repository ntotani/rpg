package rpg.service;

import haxe.ds.IntMap;

class DungeonService {

    static var master = new IntMap<StoredDungeon>();

    public static function get(id:Int):Dungeon {
        var dungeon = master.get(id);
        return new Dungeon(dungeon.id, dungeon.area, dungeon.name, dungeon.desc, dungeon.depth, dungeon.preDepth, dungeon.postDepth, Lambda.array(Lambda.map(dungeon.lotteryTable, function(e) {
            return {
                enemies : Lambda.array(Lambda.map(e.enemies, fromStored)),
                rate    : e.rate,
            }
        })), dungeon.nameTable, Lambda.array(Lambda.map(dungeon.boss, fromStored)));
    }

    public static function set(id:Int, dungeon:StoredDungeon) {
        master.set(id, dungeon);
    }

    public static function commit(storage:Storage, now:Int, dungeon:Dungeon, depth:Int) {
        var progress = storage.getProgress();
        if (progress < dungeon.getId()) {
            throw DungeonError.INVALID_PROGRESS;
        }
        var team = Lambda.array(Lambda.filter(HeroService.getTeam(storage), function(e) {
            return e != null;
        }));
        for (hero in team) {
            var hp = HeroService.calcCurrentHp(hero, now);
            if (hp < 1) {
                throw DungeonError.INVALID_TEAM;
            }
            hero.setHp(hp);
        }
        var exp = Parameter.Parameters.zero();
        var clearDepth = 0;
        var result = dungeon.solveAuto(team, depth, function(engine) {
            if (!engine.isWin(0)) {
                return;
            }
            clearDepth++;
            var battleResult = engine.getResult();
            for (enemy in battleResult.teamBlue) {
                exp = Parameter.Parameters.sum(exp, enemy.calcExp());
            }
        });

        var storedResult = {
            dungeonId: dungeon.getId(),
            battles:Lambda.array(Lambda.map(result.battles, function(e) {
                return {
                    teamRed: Lambda.array(Lambda.map(e.teamRed, HeroService.toStored)),
                    teamBlue: Lambda.array(Lambda.map(e.teamBlue, HeroService.toStored)),
                    turns: e.turns,
                }
            })),
            join : result.join,
        }

        if (clearDepth >= Math.min(depth, dungeon.getDepth())) {
            for (hero in team) {
                if (hero.getHp() > 0) {
                    hero.applyExp(exp);
                }
            }
            if (clearDepth >= dungeon.getDepth()) {
                if (dungeon.getId() >= progress) {
                    storage.setProgress(dungeon.getId() + 1);
                    if (isAreaGoal(dungeon)) {
                        var bossTeam = result.battles[result.battles.length - 1].teamBlue;
                        var boss = bossTeam[0];
                        storedResult.join = boss.getId();
                        boss.setId(HeroService.generateId());
                        boss.recoverAllHp();
                        team.push(boss);
                    }
                } else {
                    // clear dungeon already cleared
                }
            }
        }
        for (hero in team) {
            hero.setReturnAt(now);
        }
        HeroService.update(storage, team);
        storage.setDungeonResult(now, storedResult);
    }

    public static function getLatestResult(storage:Storage):Dungeon.DungeonResult {
        var storedResult = storage.getLatestDungeonResult();
        return {
            dungeonId: storedResult.dungeonId,
            battles:Lambda.array(Lambda.map(storedResult.battles, function(e) {
                return {
                    teamRed: Lambda.array(Lambda.map(e.teamRed, HeroService.fromStored)),
                    teamBlue: Lambda.array(Lambda.map(e.teamBlue, HeroService.fromStored)),
                    turns: e.turns,
                }
            })),
            join: storedResult.join,
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

    public static function isAreaGoal(dungeon:Dungeon):Bool {
        for (e in master) {
            if (e.area == dungeon.getArea() && e.id > dungeon.getId()) {
                return false;
            }
        }
        return true;
    }

}

typedef StoredDungeonResult = {
    dungeonId: Int,
    battles : Array<StoredBattleResult>,
    join    : String,
}

typedef StoredBattleResult = {
    teamRed  : Array<HeroService.StoredHero>,
    teamBlue : Array<HeroService.StoredHero>,
    turns    : Array<rpg.battle.Result.Turn>,
}

typedef StoredDungeon = {
    id           : Int,
    area         : Int,
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

enum DungeonError {
    INVALID_PROGRESS;
    INVALID_TEAM;
}
