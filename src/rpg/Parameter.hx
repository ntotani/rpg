package rpg;

typedef Parameter = {
    attack : Int,
    block  : Int,
    speed  : Int,
    health : Int,
}

class Parameters {

    public static var ZERO = {attack:0, block:0, speed:0, health:0};
    public static var ONE = {attack:1, block:1, speed:1, health:1};

    public static function sum(a:Parameter, b:Parameter):Parameter {
        return {
            attack: a.attack + b.attack,
            block: a.block + b.block,
            speed: a.speed + b.speed,
            health: a.health + b.health,
        }
    }

}
