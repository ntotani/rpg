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

/*
interface HeroStorage {
    function getAll():Array<StoredHero>;
    function setAll(heros:Array<StoredHero>):Void;
    function getTeam():Array<String>;
    function setTeam(team:Array<String>):Void;
}
*/

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
