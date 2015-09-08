package thx;

import thx.bigint.*;

/**
Heavily based on code realized by Peter Olson:
https://github.com/peterolson/BigInteger.js
*/
@:forward(sign)
abstract BigInt(BigIntImpl) from BigIntImpl to BigIntImpl {
  public static var zero(default, null) : BigInt = Small.zero;
  public static var one(default, null) : BigInt = Small.one;
  public static var two(default, null) : BigInt = Small.two;
  public static var negativeOne(default, null) : BigInt = Small.negativeOne;

  @:from inline public static function fromInt(value : Int) : BigInt
    return Bigs.fromInt(value);

  @:from inline public static function fromFloat(value : Float) : BigInt
    return Bigs.fromFloat(value);

  public inline static function fromInt64(value : haxe.Int64) : BigInt
    return Bigs.fromInt64(value);

  @:from public inline static function fromString(value : String) : BigInt
    return Bigs.parseBase(value, 10);

  public inline static function fromStringWithBase(value : String, base : Int) : BigInt
    return Bigs.parseBase(value, base);

  public static function randomBetween(a : BigInt, b : BigInt) {
    var low  = a.min(b),
        high = a.max(b),
        range : BigIntImpl = high.subtract(low);
    return low.add(range.random());
  }

  inline public function isZero() : Bool
    return this.isZero();

  inline public function abs() : BigInt
    return this.abs();

  inline public function compare(that : BigInt) : Int
    return this.compare(that);

  inline public function compareAbs(that : BigInt) : Int
    return this.compareAbs(that);

  inline public function next() : BigInt
    return this.next();

  inline public function prev() : BigInt
    return this.prev();

  inline public function square() : BigInt
    return this.square();

  inline public function pow(exp : BigInt) : BigInt
    return this.pow(exp);

  inline public function isEven() : Bool
    return this.isEven();

  inline public function isOdd() : Bool
    return this.isOdd();

  inline public function isNegative() : Bool
    return this.sign;

  inline public function isPositive() : Bool
    return this.compare(zero) > 0;

  inline public function isUnit() : Bool
    return this.isUnit();

  public function isDivisibleBy(that : BigInt) {
    if(that.isZero())
      return false;
    if(that.isUnit())
      return true;
    if(that.equals(two))
      return isEven();
    return modulo(that).isZero();
  }

  public function isPrime() : Bool {
    var n = abs(),
        nPrev = n.prev();
    if(n.isUnit())
      return false;
    if(n.equals(2) || n.equals(3) || n.equals(5))
      return true;
    if(n.isEven() || n.isDivisibleBy(3) || n.isDivisibleBy(5))
      return false;
    if(n.less(25))
      return true;
    var a = [2, 3, 5, 7, 11, 13, 17, 19],
        b = nPrev,
        d, t, i, x;
    while(b.isEven())
      b = b.divide(2);
    for(i in 0...a.length) {
      x = (a[i] : BigInt).modPow(b, n);
      if(x.equals(one) || x.equals(nPrev))
        continue;
      t = true;
      d = b;
      while(t && d.less(nPrev)) {
        x = x.square().modulo(n);
        if(x.equals(nPrev))
          t = false;
        d = d.multiply(2);
      }
      if(t)
        return false;
    }
    return false;
  }

  public function modPow(exp : BigInt, mod : BigInt) : BigInt {
    if (mod.isZero())
      throw new Error("Cannot take modPow with modulus 0");

    var r : BigIntImpl = Small.one,
        base = modulo(mod);

    if (base.isZero())
      return Small.zero;

    while(exp.isPositive()) {
      if (exp.isOdd())
        r = r.multiply(base).modulo(mod);
      exp = exp.divide(Small.two);
      base = base.square().modulo(mod);
    }
    return r;
  }

  inline public function max(that : BigInt) : BigInt
    return greater(that) ? this : that;

  inline public function min(that : BigInt) : BigInt
    return less(that) ? this : that;

  public function gcd(that : BigInt) : BigInt {
    var a = abs(),
        b = that.abs();
    if(a.equals(b) || a.isZero())
      return b;
    if(b.isZero())
      return a;
    if(a.isEven()) {
      if(b.isOdd()) {
        return a.divide(Small.two).gcd(b);
      }
      return a.divide(Small.two).gcd(b.divide(Small.two)).multiply(Small.two);
    }
    if(b.isEven()) {
      return a.gcd(b.divide(Small.two));
    }
    if(a.greater(b)) {
      return a.subtract(b).divide(Small.two).gcd(b);
    }
    return b.subtract(a).divide(Small.two).gcd(a);
  }

  public function lcm(that : BigInt) : BigInt {
    var a = abs(),
        b = that.abs();
    return a.multiply(b).divide(a.gcd(b));
  }

  @:op(A>B) public function greater(that : BigInt) : Bool
    return this.compare(that) > 0;

  @:op(A>=B) public function greaterEqual(that : BigInt) : Bool
    return this.compare(that) >= 0;

  @:op(A<B) public function less(that : BigInt) : Bool
    return this.compare(that) < 0;

  @:op(A<=B) public function lessEqual(that : BigInt) : Bool
    return this.compare(that) <= 0;

  @:op(A==B) @:commutative
  public function equals(that : BigInt) : Bool
    return this.compare(that) == 0;

  @:op(A!=B) @:commutative
  public function notEquals(that : BigInt) : Bool
    return this.compare(that) != 0;

  @:op(A+B) @:commutative
  inline public function add(that : BigInt) : BigInt
    return this.add(that);

  @:op(A-B)
  inline public function subtract(that : BigInt) : BigInt
    return this.subtract(that);

  @:op(++A)
  inline public function preIncrement() : BigInt
    return this = add(Small.one);

  @:op(A++)
  inline public function postIncrement() : BigInt {
    var v = this;
    this = add(Small.one);
    return v;
  }

  @:op(--A)
  inline public function preDecrement() : BigInt
    return this = subtract(Small.one);

  @:op(A--)
  inline public function postDecrement() : BigInt {
    var v = this;
    this = subtract(Small.one);
    return v;
  }

  @:op(-A)
  inline public function negate() : BigInt
    return this.negate();

  @:op(A*B) @:commutative
  inline public function multiply(that : BigInt) : BigInt
    return this.multiply(that);

  @:op(A/B)
  inline public function divide(that : BigInt) : BigInt
    return this.divide(that);

  @:op(A%B)
  inline public function modulo(that : BigInt) : BigInt
    return this.modulo(that);

  @:op(A << B)
  inline public function shiftLeft(that : Int) : BigInt
    return this.shiftLeft(that);

  @:op(A >> B)
  inline public function shiftRight(that : Int) : BigInt
    return this.shiftRight(that);

  @:op(~A)
  inline public function not() : BigInt
    return this.not();

  @:op(A & B)
  inline public function and(that : BigInt) : BigInt
    return this.and(that);

  @:op(A | B)
  inline public function or(that : BigInt) : BigInt
    return this.or(that);

  @:op(A ^ B)
  inline public function xor(that : BigInt) : BigInt
    return this.xor(that);

  inline public function divMod(that : BigInt) : { quotient : BigInt, remainder : BigInt }
    return this.divMod(that);

  @:to inline public function toInt() : Int
    return this.toInt();

  @:to inline public function toFloat() : Float
    return this.toFloat();

  inline public function toInt64() : haxe.Int64
    return Bigs.toInt64(this);

  @:to inline public function toString() : String
    return this.toString();

  inline public function toStringWithBase(base : Int) : String
    return this.toStringWithBase(base);
}
