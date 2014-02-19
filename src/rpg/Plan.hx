package rpg;

enum Plan {
    MONKEY;
}

class Plans {
    public static function valueOf(str:String):Plan {
        return Type.createEnum(Plan, str);
    }
}
