package rpg;

import massive.munit.Assert;

class HeroTest {

    @Test
    public function testTalent():Void {
        var zero = {attack:0, block:0, speed:0, health:0};
        var one = {attack:1, block:1, speed:1, health:1};
        var minTalent = one;
        var maxTalent = {attack:Hero.MAX_TALENT, block:1, speed:1, health:1};
        var underTalent = {attack:-1, block:1, speed:1, health:1};
        var overTalent = {attack:Hero.MAX_TALENT + 1, block:1, speed:1, health:1};
        createHero(minTalent, zero);
        createHero(maxTalent, zero);
        try {
            createHero(underTalent, zero);
            Assert.fail('should throw exception');
        } catch(e:Hero.HeroError) {
            Assert.areEqual(Hero.HeroError.INVALID_TALENT, e);
            return;
        }
        try {
            createHero(overTalent, zero);
            Assert.fail('should throw exception');
        } catch(e:Hero.HeroError) {
            Assert.areEqual(Hero.HeroError.INVALID_TALENT, e);
            return;
        }
    }

    @Test
    public function testEffort():Void {
        var zero = {attack:0, block:0, speed:0, health:0};
        var one = {attack:1, block:1, speed:1, health:1};
        var minEffort = zero;
        var maxEffort = {attack:Hero.EFFORT_LIMIT, block:Hero.EFFORT_LIMIT, speed:0, health:0};
        var underEffort = {attack:-1, block:0, speed:0, health:0};
        var overEffort = {attack:Hero.EFFORT_LIMIT + 1, block:0, speed:0, health:0};
        var overSumEffort = {attack:Hero.EFFORT_LIMIT, block:Hero.EFFORT_LIMIT, speed:1, health:0};
        createHero(one, minEffort);
        createHero(one, maxEffort);
        try {
            createHero(one, underEffort);
            Assert.fail('should throw exception');
        } catch(e:Hero.HeroError) {
            Assert.areEqual(Hero.HeroError.INVALID_EFFORT, e);
            return;
        }
        try {
            createHero(one, overEffort);
            Assert.fail('should throw exception');
        } catch(e:Hero.HeroError) {
            Assert.areEqual(Hero.HeroError.INVALID_EFFORT, e);
            return;
        }
        try {
            createHero(one, overSumEffort);
            Assert.fail('should throw exception');
        } catch(e:Hero.HeroError) {
            Assert.areEqual(Hero.HeroError.INVALID_EFFORT, e);
            return;
        }
    }

    @Test
    public function testCalcLevel():Void {
        var maxEffort = {attack:Hero.EFFORT_LIMIT, block:Hero.EFFORT_LIMIT, speed:0, health:0};
        var level:Int = Hero.calcLevel(maxEffort);
        Assert.areEqual(10, level);
    }

    @Test
    public function testCalcParameter():Void {
        var hight:Int = Hero.calcParameter(Hero.MAX_TALENT, 0, 1);
        var low:Int = Hero.calcParameter(1, 0, 1);
        Assert.isTrue(hight > low);
    }

    @Test
    public function testCalcHealthParameter():Void {
        var hight:Int = Hero.calcHealthParameter(1, Hero.EFFORT_LIMIT, 1);
        var low:Int = Hero.calcHealthParameter(1, 0, 1);
        Assert.isTrue(hight > low);
    }

    @Test
    public function testGetParameterZero():Void {
        var hero:Hero = createMinHero();
        var actual:Parameter = hero.getParameter();
        Assert.isTrue(actual.attack > 0);
    }

    @Test
    public function testGetParameterMax():Void {
        var maxHero:Hero = createMaxHero();
        var maxPrm:Parameter = maxHero.getParameter();
        var zeroHero:Hero = createMinHero();
        var zeroPrm:Parameter = zeroHero.getParameter();
        Assert.isTrue(maxPrm.attack > zeroPrm.attack);
    }

    @Test
    public function testGenerateTalen() {
        Rand.startDebug([0, 1, 15, 16]);
        var talent = Hero.generateTalent();
        Assert.areEqual(1, talent.attack);
        Assert.areEqual(2, talent.block);
        Assert.areEqual(16, talent.speed);
        Assert.areEqual(1, talent.health);
        Rand.endDebug();
    }

    @Test
    public function testApplyEffort() {
        var hero = createMinHero();
        hero.applyExp({attack:1, block:0, speed:0, health:0});
        Assert.areEqual(1, hero.getEffort().attack);
        hero.applyExp({attack:1000, block:0, speed:0, health:0});
        Assert.areEqual(Hero.EFFORT_LIMIT, hero.getEffort().attack);
        hero.applyExp({attack:0, block:1000, speed:0, health:0});
        Assert.areEqual(Hero.EFFORT_LIMIT, hero.getEffort().block);
        hero.applyExp({attack:0, block:0, speed:1, health:0});
        Assert.areEqual(0, hero.getEffort().speed);
    }

    @Test
    public function testCalcExp() {
        var hero = createMinHero();
        var expected = {attack:0, block:0, speed:0, health:1};
        Assert.areEqual(Std.string(expected), Std.string(hero.calcExp()));
    }

    public static function createMinHero():Hero {
        var paramZero = {attack:0, block:0, speed:0, health:0};
        var paramMin = {attack:1, block:1, speed:1, health:1};
        return createHero(paramMin, paramZero);
    }

    public static function createMaxHero():Hero {
        var paramZero = {attack:0, block:0, speed:0, health:0};
        var paramMax = {
            attack:Hero.MAX_TALENT,
            block:Hero.MAX_TALENT,
            speed:Hero.MAX_TALENT,
            health:Hero.MAX_TALENT,
        };
        return createHero(paramMax, paramZero);
    }

    static var heroId:Int = 0;

    public static function createHero(talent:Parameter, effort:Parameter):Hero {
        var id:String = Std.string(heroId++);
        var skills:Array<Skill> = [createSkill()];
        return new Hero(id, id, Color.SUN, Plan.MONKEY, talent, effort, skills, 0);
    }
    
    public static function createSkill():Skill {
        return {
            id:1,
            name:'',
            desc:'',
            color:Color.SUN,
            type:Skill.SkillType.ATTACK,
            target:Skill.SkillTarget.ENEMY,
            effect:Skill.SkillEffect.ATTACK,
            power:40,
            hitRate:100
        };
    }

}
