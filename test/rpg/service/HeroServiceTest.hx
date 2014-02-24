package rpg.service;

import massive.munit.Assert;
import haxe.ds.StringMap;

class HeroServiceTest {

    @BeforeClass
    public function beforeClass() {
        SkillService.set(1, HeroTest.createSkill());
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
        Assert.areEqual(0, hero.getEffort().attack);
    }

    @Test
    public function testGetAll():Void {
        var storage = new StorageImpl();
        var heros = HeroService.getAll(storage);
        var storedHeros = storage.get(HeroService.HEROS_KEY);
        for (hero in heros) {
            Assert.areEqual(0, hero.getEffort().attack);
            var stored = storedHeros.get(hero.getId());
            Assert.areEqual(0, stored.effort.attack);
        }
    }

    @Test
    public function testGetAllExist():Void {
        var hero = HeroTest.createMaxHero();
        var storedHeros = new StringMap<HeroService.StoredHero>();
        storedHeros.set(hero.getId(), HeroService.toStored(hero));
        var storage = new StorageImpl();
        storage.set(HeroService.HEROS_KEY, storedHeros);
        var heros = HeroService.getAll(storage);
        for (actual in heros) {
            Assert.areEqual(hero.getId(), actual.getId());
        }
    }

}

class StorageImpl implements Storage {

    var storage:StringMap<Dynamic>;

    public function new() {
        storage = new StringMap<Dynamic>();
    }

    public function get(key:String):Dynamic {
        return storage.get(key);
    }

    public function set(key:String, value:Dynamic) {
        storage.set(key, value);
    }

}
