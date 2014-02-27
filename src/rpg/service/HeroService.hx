package rpg.service;

import haxe.ds.StringMap;

class HeroService {

    public static var HERO_PER_TEAM = 4;
    public static var MSEC_PER_RECOVER = 60000;

    public static function createInit():Array<Hero> {
        var names = ['ファイア案件', 'レッドオーシャン', '氷河期', 'ブルー'];
        var colors = [Color.FIRE, Color.FIRE, Color.WATER, Color.WATER];
        var skills = [1, 1, 2, 2];
        var heros = [];
        for (i in 0...HERO_PER_TEAM) {
            var id = generateId();
            var talent = Hero.generateTalent();
            var effort = Parameter.Parameters.zero();
            var skill = SkillService.get(skills[i]);
            heros.push(new Hero(id, names[i], colors[i], Plan.MONKEY, talent, effort, [skill], 0));
        }
        return heros;
    }

    public static function getAll(storage:Storage):StringMap<Hero> {
        var storedHeros = storage.getHeros();
        if (storedHeros.length == 0) {
            var inits = Lambda.map(createInit(), toStored);
            storedHeros = Lambda.array(inits);
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
        var storedTeam = storage.getTeam();
        if (storedTeam.length < 1) {
            storedTeam = Lambda.array(Lambda.map(heros, function(e) {
                return e.getId();
            }));
        }
        var team = [];
        for (i in 0...HERO_PER_TEAM) {
            if (storedTeam.length <= i) {
                team.push(null);
            } else {
                team.push(heros.get(storedTeam[i]));
            }
        }
        return team;
    }

    public static function update(storage:Storage, heros:Array<Hero>) {
        var heroMap = new StringMap<StoredHero>();
        for (hero in storage.getHeros()) {
            heroMap.set(hero.id, hero);
        }
        for (hero in heros) {
            heroMap.set(hero.getId(), toStored(hero));
        }
        storage.setHeros(Lambda.array(heroMap));
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
        var hero = new Hero(stored.id, stored.name, Color.Colors.valueOf(stored.color), Plan.Plans.valueOf(stored.plan), stored.talent, stored.effort, Lambda.array(Lambda.map(stored.skills, function(e) { return SkillService.get(e); })), stored.returnAt);
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
