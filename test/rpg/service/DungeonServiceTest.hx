package rpg.service;

import massive.munit.Assert;

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

}
