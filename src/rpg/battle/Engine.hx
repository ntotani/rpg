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
            var turn:Turn = [];
            for (id in this.solveOrder(this.requests)) {
                var event:Action = this.action(commands.get(id));
                turn.push(event);
            }
            this.result.turns.push(turn);
            for (e in this.requests) {
                e.callback(turn, this.isFinish());
            }
            this.requests = [];
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
                result.effect = this.calcDamage(actor, target);
                target.damage(result.effect);
            default:
        }
        return result;
    }

    public function calcDamage(actor:BattleHero, target:BattleHero):Int {
        var attack:Int = actor.getHero().getParameter().attack;
        var block:Int = target.getHero().getParameter().block;
        return Std.int(Math.max(1, attack - block));
    }
    
    public function isFinish():Bool {
        var redHp:Int = 0;
        var blueHp:Int = 0;
        for (e in this.heros) {
            if (e.getTeam() == 0) {
                redHp += e.getHp();
            } else {
                blueHp += e.getHp();
            }
        }
        return redHp <= 0 || blueHp <= 0;
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
