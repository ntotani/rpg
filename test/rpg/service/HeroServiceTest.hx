package rpg.service;

import massive.munit.Assert;
import haxe.ds.StringMap;

class HeroServiceTest {

    @BeforeClass
    public function beforeClass() {
        Rand.endDebug();
        SkillService.set(1, HeroTest.createSkill());
        SkillService.set(2, HeroTest.createSkill());
    }

    @Test
    public function testStored():Void {
        var hero = HeroTest.createMaxHero();
        var stored = HeroService.toStored(hero);
        Assert.areEqual(stored.color, 'SUN');
        Assert.areEqual(stored.plan, 'MONKEY');
        Assert.areEqual(1, stored.skills[0]);
        var parseHero = HeroService.fromStored(stored);
        Assert.areEqual(Color.SUN, parseHero.getColor());
        Assert.areEqual(Plan.MONKEY, parseHero.getPlan());
        Assert.areEqual(1, parseHero.getSkill(0).id);
    }

    @Test
    public function testCreateInit():Void {
        var hero = HeroService.createInit();
        Assert.areEqual(4, hero.length);
        Assert.areEqual(0, hero[0].getEffort().attack);
    }

    @Test
    public function testGetAll():Void {
        var storage = new StorageImpl();
        var heros = HeroService.getAll(storage);
        Assert.areEqual(4, Lambda.array(heros).length);
        var storedHeros = storage.getHeros();
        for (stored in storedHeros) {
            var hero = heros.get(stored.id);
            Assert.areEqual(0, hero.getEffort().attack);
            Assert.areEqual(0, stored.effort.attack);
        }
    }

    @Test
    public function testGetAllExist():Void {
        var hero = HeroTest.createMaxHero();
        var storage = new StorageImpl();
        storage.setHeros([HeroService.toStored(hero)]);
        var heros = HeroService.getAll(storage);
        for (actual in heros) {
            Assert.areEqual(hero.getId(), actual.getId());
        }
    }

    @Test
    public function testGetTeam():Void {
        var storage = new StorageImpl();
        var team = HeroService.getTeam(storage);
        Assert.areEqual(4, team.length);
        Assert.isNotNull(team[0]);
    }

    @Test
    public function testGetTeamExist():Void {
        var hero = HeroTest.createMaxHero();
        var storage = new StorageImpl();
        storage.setHeros([HeroService.toStored(hero)]);
        storage.setTeam([hero.getId()]);
        var team = HeroService.getTeam(storage);
        Assert.areEqual(4, team.length);
        Assert.areEqual(hero.getId(), team[0].getId());
        Assert.isNull(team[1]);
    }

    @Test
    public function testCalcCurrentHp():Void {
        var hero = HeroTest.createMaxHero();
        hero.setHp(0);
        var sec = DateTools.seconds(HeroService.MSEC_PER_RECOVER / 1000);
        var hp = HeroService.calcCurrentHp(hero, Std.int(sec));
        Assert.areEqual(1, hp);
    }

    @Test
    public function testUpdate():Void {
        var hero = HeroTest.createMinHero();
        var storage = new StorageImpl();
        storage.setHeros([HeroService.toStored(hero)]);
        hero.applyExp(Parameter.Parameters.one());
        HeroService.update(storage, [hero]);
        var heros = HeroService.getAll(storage);
        for (actual in heros) {
            Assert.areEqual(1, actual.getEffort().attack);
        }
    }

    @Test
    public function testUpdateAdd():Void {
        var hero = HeroTest.createMinHero();
        var addHero = HeroTest.createMinHero();
        var storage = new StorageImpl();
        storage.setHeros([HeroService.toStored(hero)]);
        HeroService.update(storage, [hero, addHero]);
        var heros = HeroService.getAll(storage);
        Assert.areEqual(2, Lambda.array(heros).length);
    }

}
