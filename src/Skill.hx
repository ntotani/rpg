class Skill {
    
    var id      : Int;
    var name    : String;
    var color   : Color;
    var target  : Target;
    // ↓ここをリスト化。。。？
    var power   : Int;
    var hitRate : Int;
    var effect  : Effect;
    
    public function new() {
        this.id = 0;
        this.name = '';
        this.color = Color.SUN;
        this.power = 100;
        this.hitRate = 100;
        this.target = Target.ENEMY;
        this.effect = Effect.ATTACK;
    }
    
    public function getEffect():Effect { return this.effect; }

}

enum Target {
    ENEMY;
    /*
    ENEMY_ALL;
    FRIEND;
    FRIEND_ALL;
    ALL;
    SELF;
    */
}

enum Effect {
    ATTACK;
}
