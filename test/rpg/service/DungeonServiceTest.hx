package rpg.service;

import massive.munit.Assert;
import haxe.ds.IntMap;

class DungeonServiceTest {

    @BeforeClass
    public function beforeClass() {
        SkillService.set(1, HeroTest.createSkill());
        SkillService.set(2, HeroTest.createSkill());
        var enemy = {
            name   : '',
            color  : 'SUN',
            plan   : 'MONKEY',
            effort : Parameter.Parameters.zero(),
            skills : [1],
        }
        DungeonService.set(1, {
            id           : 1,
            area         : 1,
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
        DungeonService.set(2, {
            id           : 2,
            area         : 1,
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
    public function testIsAreaGoal():Void {
        var dungeon1 = DungeonService.get(1);
        var dungeon2 = DungeonService.get(2);
        Assert.isFalse(DungeonService.isAreaGoal(dungeon1));
        Assert.isTrue(DungeonService.isAreaGoal(dungeon2));
    }

    @Test
    public function testCommit():Void {
        var storage = new StorageImpl();
        var now = 60;
        var dungeon = DungeonService.get(1);
        DungeonService.commit(storage, now, dungeon, 1);
        var heros = HeroService.getAll(storage);
        Assert.areEqual(4, Lambda.array(heros).length);
        for (hero in heros) {
            Assert.isTrue(hero.getHp() <= hero.getParameter().health);
            Assert.areEqual(now, hero.getReturnAt());
        }
        var result = DungeonService.getLatestResult(storage);
        for (hero in result.battles[0].teamRed) {
            Assert.areEqual(hero.getParameter().health, hero.getHp());
        }
    }

    @Test
    public function testCommitJoinBoss():Void {
        Rand.startDebug([0]);
        var storage = new StorageImpl();
        storage.setProgress(2);
        var hero = HeroTest.createMaxHero();
        hero.applyExp({attack:100, block:0, speed:100, health:100});
        storage.setHeros([HeroService.toStored(hero)]);
        var dungeon = DungeonService.get(2);
        DungeonService.commit(storage, 0, dungeon, 2);
        Rand.endDebug();
        var heros = HeroService.getAll(storage);
        Assert.areEqual(2, Lambda.array(heros).length);
    }

    @Test
    public function testCommitInvalidProgress():Void {
        Rand.startDebug([0]);
        var storage = new StorageImpl();
        var dungeon = DungeonService.get(2);
        var flag = false;
        try {
            DungeonService.commit(storage, 0, dungeon, 1);
        } catch(e:DungeonService.DungeonError) {
            Assert.areEqual(DungeonService.DungeonError.INVALID_PROGRESS, e);
            flag = true;
        }
        Assert.isTrue(flag);
        Rand.endDebug();
    }

    @Test
    public function testCommitInvalidTeam():Void {
        Rand.startDebug([0]);
        var storage = new StorageImpl();
        var hero = HeroTest.createMaxHero();
        hero.setHp(0);
        storage.setHeros([HeroService.toStored(hero)]);
        var dungeon = DungeonService.get(1);
        var flag = false;
        try {
            DungeonService.commit(storage, 0, dungeon, 1);
        } catch(e:DungeonService.DungeonError) {
            Assert.areEqual(DungeonService.DungeonError.INVALID_TEAM, e);
            flag = true;
        }
        Assert.isTrue(flag);
        Rand.endDebug();
    }

}
