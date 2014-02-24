package rpg.service;

import haxe.ds.StringMap;

class HeroService {

    public static var HEROS_KEY = 'hero_all';

    public static function createInit():Hero {
        var id = generateId();
        var talent = {attack:7, block:7, speed:16, health:7};
        var effort = Parameter.Parameters.ZERO;
        var skill = SkillService.get(1);
        return new Hero(id, 'ハルヒロ', Color.FIRE, Plan.MONKEY, talent, effort, [skill], 0);
    }

    public static function getAll(storage:Storage):StringMap<Hero> {
        var storedHeros:StringMap<StoredHero> = storage.get(HEROS_KEY);
        if (storedHeros == null) {
            var hero = createInit();
            storedHeros = new StringMap<StoredHero>();
            storedHeros.set(hero.getId(), toStored(hero));
            storage.set(HEROS_KEY, storedHeros);
        }
        var heros = new StringMap<Hero>();
        for (stored in storedHeros) {
            heros.set(stored.id, fromStored(stored));
        }
        return heros;
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
