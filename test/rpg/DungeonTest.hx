package rpg;

import massive.munit.Assert;

class DungeonTest {

    @Test
    public function testSpawnEnemies():Void {
        var dungeon = createDungeon();
        var enemies = dungeon.spawnEnemies();
        Assert.isTrue(enemies[0].getHp() > 0);
    }

    @Test
    public function testSolveAuto():Void {
        var dungeon = createDungeon();
        var hero:Hero = HeroTest.createMaxHero();
        var result:Dungeon.DungeonResult = dungeon.solveAuto([hero]);
        Assert.isTrue(hero.getHp() < hero.getParameter().health);
    }

    function createDungeon():Dungeon {
        var zero:Parameter = {attack:0, block:0, speed:0, health:0};
        var s:Array<Skill> = [HeroTest.createSkill()];
        var enemies:Array<Dungeon.DungeonEnemy> = [
            {color:Color.SUN, plan:Plan.MONKEY, effort:zero, skills:s}
        ];
        var lot:Dungeon.DungeonLot = {
            enemies:enemies,
            rate:100,
        };
        return new Dungeon(1, [lot], enemies);
    }

}
