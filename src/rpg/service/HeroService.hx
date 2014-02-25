package rpg.service;

import haxe.ds.StringMap;

class HeroService {

    public static var HERO_PER_TEAM = 4;
    public static var MSEC_PER_RECOVER = 60000;

    public static function createInit():Hero {
        var id = generateId();
        var talent = {attack:7, block:7, speed:16, health:7};
        var effort = Parameter.Parameters.ZERO;
        var skill = SkillService.get(1);
        return new Hero(id, 'ハルヒロ', Color.FIRE, Plan.MONKEY, talent, effort, [skill], 0);
    }

    public static function getAll(storage:Storage):StringMap<Hero> {
        var storedHeros = storage.getHeros();
        if (storedHeros.length == 0) {
            var hero = createInit();
            storedHeros = [toStored(hero)];
            storage.setHeros(storedHeros);
        }
        var heros = new StringMap<Hero>();
        for (stored in storedHeros) {
            heros.set(stored.id, fromStored(stored));
        }
        return heros;
    }

    public static function getTeam(storage:Storage):Array<Hero> {
        var heros = getAll(storage);
        var team = storage.getTeam();
        if (team.length < 1) {
            team = Lambda.array(Lambda.map(heros, function(e) {
                return e.getId();
            }));
        }
        return Lambda.array(Lambda.mapi([0...HERO_PER_TEAM], function(i, e) {
            if (team.length <= i) {
                return null;
            }
            return heros.get(team[i]);
        }));
    }

    public static function update(storage:Storage, heros:Array<Hero>) {
        var heroMap = new StringMap<Hero>();
        for (hero in heros) {
            heroMap.set(hero.getId(), hero);
        }
        var all = Lambda.array(Lambda.map(storage.getHeros(), function(e) {
            if (heroMap.exists(e.id)) {
                return toStored(heroMap.get(e.id));
            }
            return e;
        }));
        storage.setHeros(all);
    }

    public static function toStored(hero:Hero):StoredHero {
        return {
            id       : hero.getId(),
            name     : hero.getName(),
            color    : Std.string(hero.getColor()),
            plan     : Std.string(hero.getPlan()),
            talent   : hero.getTalent(),
            effort   : hero.getEffort(),
            hp       : hero.getHp(),
            skills   : Lambda.array(Lambda.map(hero.getSkills(), function(e) {
                return e.id;
            })),
            returnAt : hero.getReturnAt(),
        }
    }
    
    public static function fromStored(stored:StoredHero):Hero {
        var hero = new Hero(stored.id, stored.name, Color.Colors.valueOf(stored.color), Plan.Plans.valueOf(stored.plan), stored.talent, stored.effort, Lambda.array(Lambda.map(stored.skills, function(e) { return SkillService.get(e); })), 0);
        hero.setHp(stored.hp);
        return hero;
    }
    
    public static function generateId():String {
        return Std.string(Rand.next());
    }

    public static function calcCurrentHp(hero:Hero, now:Int):Int {
        var hp = hero.getHp() + (now - hero.getReturnAt()) / MSEC_PER_RECOVER;
        return Std.int(Math.min(hp, hero.getParameter().health));
    }

}

typedef StoredHero = {
    id       : String,
    name     : String,
    color    : String,
    plan     : String,
    talent   : Parameter,
    effort   : Parameter,
    hp       : Int,
    skills   : Array<Int>,
    returnAt : Int,
}
