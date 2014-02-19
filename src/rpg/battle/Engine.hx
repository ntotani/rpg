package rpg.battle;

import haxe.ds.IntMap;
import rpg.battle.Result;

class Engine {

    var heros : IntMap<BattleHero>;
    var requests : Array<Request>;
    var result : BattleResult;

    public function new(teamRed:Array<Hero>, teamBlue:Array<Hero>) {
        this.heros = new IntMap<BattleHero>();
        this.requests = [];
        var id:Int = 0;
        var team:Int = 0;
        for (hero in teamRed) {
            this.heros.set(id, new BattleHero(id, team, hero)); 
            id++;
        }
        team++;
        for (hero in teamBlue) {
            this.heros.set(id, new BattleHero(id, team, hero));
            id++;
        }
        this.result = {
            teamRed: Util.copy(teamRed),
            teamBlue: Util.copy(teamBlue),
            turns:[],
        };
    }

    public function getHero(id:Int):BattleHero {
        return this.heros.get(id);
    }
    
    public function getHeros():Iterator<BattleHero> {
        return this.heros.iterator();
    }
    
    public function getFriends(team:Int):List<BattleHero> {
        return Lambda.filter(this.heros, function(e:BattleHero) {
            return e.getTeam() == team;
        });
    }
    
    public function getEnemies(team:Int):List<BattleHero> {
        return Lambda.filter(this.heros, function(e:BattleHero) {
            return e.getTeam() != team;
        });
    }

    public function getResult():BattleResult {
        return this.result;
    }

    public function execute(req:Request) {
        this.requests.push(req);
        if (this.requests.length == 2) {
            var commands:IntMap<Command> = new IntMap<Command>();
            for (req in this.requests) {
                for (cmd in req.getCommands()) {
                    commands.set(cmd.actor, cmd);
                }
            }
            var events:Array<Action> = [];
            var turn:Turn = this.applyNewTurn();
            for (id in this.solveOrder(this.requests)) {
                var event:Action = this.action(commands.get(id));
                this.applyAction(event);
            }
            var requests:Array<Request> = this.requests;
            this.requests = [];
            for (e in requests) {
                e.callback(turn, this.isFinish());
            }
        }
    }

    public function solveOrder(requests:Array<Request>):Array<Int> {
        var allHeros:Array<BattleHero> = [];
        for (e in this.heros) { allHeros.push(e); }
        allHeros.sort(function(a, b) {
            var aSpeed:Int = a.getHero().getParameter().speed;
            var bSpeed:Int = b.getHero().getParameter().speed;
            return bSpeed - aSpeed;
        });
        var order:Array<Int> = [];
        for (e in allHeros) { order.push(e.getId()); }
        return order;
    }

    public function action(cmd:Command):Action {
        var actor:BattleHero = this.heros.get(cmd.actor);
        var target:BattleHero = this.heros.get(cmd.target);
        var skill:Skill = actor.getHero().getSkill(cmd.skill);
        var result:Action = {
            actor:cmd.actor,
            target:cmd.target,
            skill:cmd.skill,
            effect:0,
        };
        switch(skill.type) {
            case ATTACK:
                result.effect = actor.alive() && target.alive() && actor.getTeam() != target.getTeam() ? calcDamage(actor, target, skill) : 0;
            default:
        }
        return result;
    }

    public function applyNewTurn():Turn {
        var turn:Turn = [];
        this.result.turns.push(turn);
        return turn;
    }

    public function applyAction(act:Action):Void {
        var actor:BattleHero = this.heros.get(act.actor);
        var target:BattleHero = this.heros.get(act.target);
        var skill:Skill = actor.getHero().getSkill(act.skill);
        switch(skill.type) {
            case ATTACK:
                target.damage(act.effect);
            default:
        }
        var turn:Turn = this.result.turns[this.result.turns.length - 1];
        turn.push(act);
    }

    public static function calcDamage(actor:BattleHero, target:BattleHero, skill:Skill):Int {
        var attack = actor.getHero().getParameter().attack;
        var block = target.getHero().getParameter().block;
        var damage = skill.power * attack / block;
        damage *= actor.getHero().getLevel() / 10;
        damage *= (85 + Rand.next() % 16) / 100;
        damage *= Color.Colors.rate(skill.color, target.getHero().getColor());
        return Std.int(damage) + 1;
    }
    
    public function isFinish():Bool {
        return isWin(0) || isWin(1);
    }
    
    public function isWin(team):Bool {
        return Lambda.fold(this.heros, function(e, p) {
            if (e.getTeam() == team) {
                return p;
            }
            return p + e.getHp();
        }, 0) <= 0;
    }

}

interface Request {
    function getCommands():Iterable<Command>;
    function callback(turn:Turn, finish:Bool):Void;
}

typedef Command = {
    actor  : Int,
    target : Int,
    skill  : Int,
}
