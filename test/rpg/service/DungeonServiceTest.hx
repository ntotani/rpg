package rpg.service;

import massive.munit.Assert;
import haxe.ds.IntMap;

class DungeonServiceTest {

    @BeforeClass
    public function beforeClass() {
        SkillService.set(1, HeroTest.createSkill());
        var enemy = {
            name   : '',
            color  : 'SUN',
            plan   : 'MONKEY',
            effort : Parameter.Parameters.ZERO,
            skills : [1],
        }
        DungeonService.set(1, {
            name         : '',
            desc         : '',
            depth        : 2,
            preDepth     : '',
            postDepth    : '',
            lotteryTable : [
                {enemies:[enemy], rate:100}
            ],
            nameTable    : [''],
            boss         : [enemy],
        });
    }

    @Test
    public function testGet():Void {
        var dungeon = DungeonService.get(1);
        Assert.isNotNull(dungeon);
    }

    @Test
    public function testCommit():Void {
        Rand.startDebug([0]);
        var storage = new StorageImpl();
        var now = 0;
        var dungeon = DungeonService.get(1);
        var depth = 1;
        DungeonService.commit(storage, now, dungeon, depth);
        var heros = HeroService.getAll(storage);
        for (hero in heros) {
            Assert.isTrue(0 < hero.getEffort().health);
            Assert.isTrue(hero.getHp() < hero.getParameter().health);
        }
        var result = DungeonService.getLatestResult(storage);
        for (hero in result.battles[0].teamRed) {
            Assert.areEqual(hero.getParameter().health, hero.getHp());
        }
        Rand.endDebug();
    }

}
