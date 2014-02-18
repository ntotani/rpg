package rpg;

class Rand {

    static var gen:IRand = new RandImpl();

    public static function next():Int {
        return gen.next();
    }

    public static function startDebug(nums):Void {
        gen = new RandDebug(nums);
    }

    public static function endDebug():Void {
        gen = new RandImpl();
    }

}

private interface IRand {
    function next():Int;
}

private class RandImpl implements IRand {
    /**
     * (a Mersenne prime M31) modulus constant = 2^31 - 1 = 0x7ffffffe
     */
    private inline static var MPM = 2147483647.0;

    public function new() {}

    public function next():Int {
        return Math.floor(Math.random() * MPM);
    }
}

private class RandDebug implements IRand {

    private var nums:Array<Int>;
    private var currentIdx:Int;
    
    public function new(nums) {
        this.nums = nums;
        this.currentIdx = 0;
    }

    public function next():Int {
        var ret = this.nums[this.currentIdx];
        currentIdx = (this.currentIdx + 1) % this.nums.length;
        return ret;
    }

}
