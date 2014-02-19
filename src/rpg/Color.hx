package rpg;

enum Color {
    SUN;
    MOON;
    FIRE;
    WATER;
    TREE;
    GOLD;
    EARTH;
}

class Colors {

    public static function rate(from:Color, to:Color):Float {
        return switch(from) {
            case FIRE:
                switch(to) {
                    case TREE, GOLD: 2.0;
                    case FIRE, WATER, EARTH: 0.5;
                    default: 1.0;
                }
            case WATER:
                switch(to) {
                    case FIRE, MOON: 2.0;
                    case WATER, TREE, EARTH: 0.5;
                    default: 1.0;
                }
            case TREE:
                switch(to) {
                    case WATER, SUN: 2.0;
                    case TREE, FIRE, EARTH: 0.5;
                    default: 1.0;
                }
            default: 1.0;
        }
    }

    public static function valueOf(str:String):Color {
        return Type.createEnum(Color, str);
    }

}
