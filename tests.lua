local bigint = require 'bigint'

local function test(bits)
  bigint.scale(bits)

  local function assert_eq(a , b)
    if a ~= b then --luacov:disable
      error('assertion failed: ' .. tostring(a) .. ' ~= ' .. tostring(b), 2)
    end --luacov:enable
  end

  do --utils
    assert(bigint(-2):iszero() == false)
    assert(bigint(-1):iszero() == false)
    assert(bigint(0):iszero() == true)
    assert(bigint(1):iszero() == false)
    assert(bigint(2):iszero() == false)

    assert(bigint(-2):isone() == false)
    assert(bigint(-1):isone() == false)
    assert(bigint(0):isone() == false)
    assert(bigint(1):isone() == true)
    assert(bigint(2):isone() == false)

    assert(bigint(-1):isminusone() == true)
    assert(bigint(-2):isminusone() == false)
    assert(bigint(1):isminusone() == false)
    assert(bigint(0):isminusone() == false)
    assert(bigint(2):isminusone() == false)

    assert(bigint(-1):isneg() == true)
    assert(bigint(-2):isneg() == true)
    assert(bigint(0):isneg() == false)
    assert(bigint(1):isneg() == false)
    assert(bigint(2):isneg() == false)

    assert(bigint(-1):ispos() == false)
    assert(bigint(-2):ispos() == false)
    assert(bigint(0):ispos() == false)
    assert(bigint(1):ispos() == true)
    assert(bigint(2):ispos() == true)
  end

  do -- number conversion
    local function test_num2num(x)
      assert_eq(bigint(x):tonumber(), x)
      assert_eq(bigint.new(x):tonumber(), x)
      assert_eq(bigint.from(x):tonumber(), x)
      assert_eq(bigint.fromuinteger(x):tonumber(), x)
      assert_eq(bigint.new(bigint(x)):tonumber(), x)
      assert_eq(bigint.from(bigint(x)):tonumber(), x)
      assert_eq(bigint.new(tostring(x)):tonumber(), x)
      assert_eq(bigint.from(tostring(x)):tonumber(), x)
      assert_eq(bigint.tonumber(x), x)
      assert_eq(bigint.tonumber(bigint(x)), x)
      assert_eq(bigint.tointeger(x), x)
      assert_eq(bigint.tointeger(x * 1.0), x)
      assert_eq(bigint.tointeger(bigint(x)), x)
      assert_eq(bigint.zero():_assign(x):tonumber(), x)
    end
    local function test_num2hex(x)
      assert_eq(bigint(x):tobase(16), ('%x'):format(x))
    end
    local function test_num2dec(x)
      assert_eq(tostring(bigint(x)), ('%d'):format(x))
    end
    local function test_num2oct(x)
      assert_eq(bigint(x):tobase(8), ('%o'):format(x))
    end
    local function test_str2num(x)
      assert_eq(bigint.frombase(tostring(x)):tonumber(), x)
    end
    local function test_ops(x)
      test_num2num(x)
      test_num2num(-x)
      test_num2hex(x)
      test_num2oct(x)
      if bits == 64 then
        test_num2hex(-x)
        test_num2oct(-x)
      end
      test_num2dec(x)
      test_num2dec(-x)
      test_str2num(x)
      test_str2num(-x)
    end
    assert_eq(bigint.fromnumber(1.1):tonumber(), 1)
    assert_eq(bigint.fromnumber(-1.1):tonumber(), -1)
    test_ops(0)
    test_ops(1)
    test_ops(0xfffffffffe)
    test_ops(0xffffffff)
    test_ops(0xffffffff)
    test_ops(0x123456789abc)
    test_ops(0xf505c2)
    test_ops(0x9f735a)
    test_ops(0xcf7810)
    test_ops(0xbbc55f)
  end

  do -- add/sub/mul/band/bor/bxor/eq/lt/le
    local function test_add(x, y)
      assert_eq((bigint(x) + bigint(y)):tonumber(), x + y)
    end
    local function test_sub(x, y)
      assert_eq((bigint(x) - bigint(y)):tonumber(), x - y)
    end
    local function test_mul(x, y)
      assert_eq((bigint(x) * bigint(y)):tonumber(), x * y)
    end
    local function test_band(x, y)
      assert_eq((bigint(x) & bigint(y)):tonumber(), x & y)
    end
    local function test_bor(x, y)
      assert_eq((bigint(x) | bigint(y)):tonumber(), x | y)
    end
    local function test_bxor(x, y)
      assert_eq((bigint(x) ~ bigint(y)):tonumber(), x ~ y)
    end
    local function test_eq(x, y)
      assert_eq(bigint(x) == bigint(y), x == y)
    end
    local function test_le(x, y)
      assert_eq(bigint(x) <= bigint(y), x <= y)
    end
    local function test_lt(x, y)
      assert_eq(bigint(x) < bigint(y), x < y)
    end
    local function test_ops2(x, y)
      test_add(x, y)
      test_sub(x, y) test_sub(y, x)
      test_mul(x, y) test_mul(y, x)
      test_band(x, y)
      test_bor(x, y)
      test_bxor(x, y)
      test_eq(x, y) test_eq(y, x) test_eq(x, x) test_eq(y, y)
      test_lt(x, y) test_lt(y, x) test_lt(x, x) test_lt(y, y)
      test_le(x, y) test_le(y, x) test_le(x, x) test_le(y, y)
    end
    local function test_ops(x, y)
      test_ops2(x, y)
      test_ops2(-x, y)
      test_ops2(-x, -y)
      test_ops2(x, -y)
    end
    test_ops(0, 0)
    test_ops(1, 1)
    test_ops(1, 2)
    test_ops(80, 20)
    test_ops(18, 22)
    test_ops(12, 8)
    test_ops(100080, 20)
    test_ops(18, 559022)
    test_ops(2000000000, 2000000000)
    test_ops(0x00ffff, 1)
    test_ops(0x00ffff00, 0x00000100)
    test_ops(1000001, 1000000)
    test_ops(42, 0)
    test_ops(101, 100)
    test_ops(242, 42)
    test_ops(1042, 0)
    test_ops(101010101, 101010100)
    test_ops(0x010000, 1)
    test_ops(0xf505c2, 0x0fffe0)
    test_ops(0x9f735a, 0x65ffb5)
    test_ops(0xcf7810, 0x04ff34)
    test_ops(0xbbc55f, 0x4eff76)
    test_ops(0x100000, 1)
    test_ops(0x010000, 1)
    test_ops(0xb5beb4, 0x01ffc4)
    test_ops(0x707655, 0x50ffa8)
    test_ops(0xf0a990, 0x1cffd1)
    test_ops(0x010203, 0x1020)
    test_ops(42, 0)
    test_ops(42, 1)
    test_ops(42, 2)
    test_ops(42, 10)
    test_ops(42, 100)
    test_ops(420, 1000)
    test_ops(200, 8)
    test_ops(2, 256)
    test_ops(500, 2)
    test_ops(500000, 2)
    test_ops(500, 500)
    test_ops(1000000000, 2)
    test_ops(2, 1000000000)
    test_ops(1000000000, 4)
    test_ops(0xfffffffe, 0xffffffff)
    test_ops(0xffffffff, 0xffffffff)
    test_ops(0xffffffff, 0x10000)
    test_ops(0xffffffff, 0x1000)
    test_ops(0xffffffff, 0x100)
    test_ops(0xffffffff, 1)
    test_ops(1000000, 1000)
    test_ops(1000000, 10000)
    test_ops(1000000, 100000)
    test_ops(1000000, 1000000)
    test_ops(1000000, 10000000)
    test_ops(0xffffffff, 0x005500aa)
    test_ops(7, 3)
    test_ops(0xffffffff, 0)
    test_ops(0, 0xffffffff)
    test_ops(0xffffffff, 0xffffffff)
    test_ops(0xffffffff, 0)
    test_ops(0, 0xffffffff)
    test_ops(0x00000000, 0xffffffff)
    test_ops(0x55555555, 0xaaaaaaaa)
    test_ops(0xffffffff, 0xffffffff)
    test_ops(4, 3)
  end

  do --shl/shr
    local function test_shl(x, y)
      assert_eq((bigint(x) << y):tonumber(), x << y)
    end
    local function test_shr(x, y)
      assert_eq((bigint(x) >> y):tonumber(), x >> y)
    end
    local function test_ops(x, y)
      test_shl(x, y) test_shl(x, -y)
      test_shr(x, y) test_shr(x, -y)
    end
    test_ops(0, 0)
    test_ops(1, 0)
    test_ops(1, 1)
    test_ops(1, 2)
    test_ops(1, 3)
    test_ops(1, 4)
    test_ops(1, 5)
    test_ops(1, 6)
    test_ops(1, 7)
    test_ops(1, 8)
    test_ops(1, 9)
    test_ops(1, 10)
    test_ops(1, 11)
    test_ops(1, 12)
    test_ops(1, 13)
    test_ops(1, 14)
    test_ops(1, 15)
    test_ops(1, 16)
    test_ops(1, 17)
    test_ops(1, 18)
    test_ops(1, 19)
    test_ops(1, 20)
    test_ops(1, 64)
    test_ops(1, 100)
    test_ops(0xdd, 0x18)
    test_ops(0x68, 0x02)
    test_ops(0xf6, 1)
    test_ops(0x1a, 1)
    test_ops(0xb0, 1)
    test_ops(0xba, 1)
    test_ops(0x10, 3)
    test_ops(0xe8, 4)
    test_ops(0x37, 4)
    test_ops(0xa0, 7)
    test_ops(0xa0, 100)
    test_ops(      1,  0)
    test_ops(      2,  1)
    test_ops(      4,  2)
    test_ops(      8,  3)
    test_ops(     16,  4)
    test_ops(     32,  5)
    test_ops(     64,  6)
    test_ops(    128,  7)
    test_ops(    256,  8)
    test_ops(    512,  9)
    test_ops(   1024, 10)
    test_ops(   2048, 11)
    test_ops(   4096, 12)
    test_ops(   8192, 13)
    test_ops(  16384, 14)
    test_ops(  32768, 15)
    test_ops(  65536, 16)
    test_ops( 131072, 17)
    test_ops( 262144, 18)
    test_ops( 524288, 19)
    test_ops(1048576, 20)
    test_ops(1048576, 100)
  end

  do -- pow
    local function test_pow(x, y)
      assert_eq((bigint(x) ^ y):tonumber(), math.floor(x ^ y))
      assert_eq((bigint(x) ^ bigint(y)):tonumber(), math.floor(x ^ y))
    end
    local function test_ops(x, y)
      test_pow(x, y)
      test_pow(-x, y)
    end
    test_ops(0, 0)
    test_ops(0, 1)
    test_ops(0, 2)
    test_ops(0, 15)
    test_ops(1, 0)
    test_ops(1, 1)
    test_ops(1, 2)
    test_ops(1, 15)
    test_ops(2, 0)
    test_ops(2, 1)
    test_ops(2, 2)
    test_ops(2, 15)
    test_ops(7, 4)
    test_ops(7, 11)
  end

  do --bnot/unm
    local function test_bnot(x)
      assert_eq((~bigint(x)):tonumber(), ~x)
      assert_eq((~ ~bigint(x)):tonumber(), x)
    end
    local function test_unm(x)
      assert_eq((-bigint(x)):tonumber(), -x)
      assert_eq((- -bigint(x)):tonumber(), x)
    end
    local function test_inc(x)
      assert_eq(bigint(x):inc():tonumber(), x + 1)
    end
    local function test_dec(x)
      assert_eq(bigint(x):dec():tonumber(), x - 1)
    end
    local function test_ops(x)
      test_bnot(x) test_bnot(-x)
      test_unm(x) test_unm(-x)
      test_inc(x) test_inc(-x)
      test_dec(x) test_dec(-x)
    end
    test_ops(0)
    test_ops(1)
    test_ops(2)
    test_ops(15)
    test_ops(16)
    test_ops(17)
    test_ops(0xffffffff)
    test_ops(0xfffffffe)
    test_ops(0xf505c2)
    test_ops(0x9f735a)
    test_ops(0xcf7810)
    test_ops(0xbbc55f)
  end

  do -- idiv/mod
    local function test_udiv(x, y)
      assert_eq(bigint.udiv(x, y):tonumber(), x // y)
    end
    local function test_idiv(x, y)
      assert_eq((bigint(x) // bigint(y)):tonumber(), x // y)
    end
    local function test_umod(x, y)
      assert_eq(bigint.umod(x, y):tonumber(), x % y)
    end
    local function test_mod(x, y)
      assert_eq((bigint(x) % bigint(y)):tonumber(), x % y)
    end
    local function test_udivmod(x, y)
      local quot, rem = bigint.udivmod(x, y)
      assert_eq(quot:tonumber(), x // y)
      assert_eq(rem:tonumber(), x % y)
    end
    local function test_idivmod(x, y)
      local quot, rem = bigint.idivmod(x, y)
      assert_eq(quot:tonumber(), x // y)
      assert_eq(rem:tonumber(), x % y)
    end
    local function test_ops(x, y)
      test_udiv(x, y)
      test_idiv(x, y)
      test_idiv(x, -y)
      test_idiv(-x, -y)
      test_idiv(-x, y)
      test_umod(x, y)
      test_mod(x, y)
      test_mod(x, -y)
      test_mod(-x, y)
      test_mod(-x, -y)
      test_udivmod(x, y)
      test_idivmod(x, y)
    end
    test_ops(0xffffffff, 0xffffffff)
    test_ops(0xffffffff, 0x10000)
    test_ops(0xffffffff, 0x1000)
    test_ops(0xffffffff, 0x100)
    test_ops(1000000, 1000)
    test_ops(1000000, 10000)
    test_ops(1000000, 100000)
    test_ops(1000000, 1000000)
    test_ops(1000000, 10000000)
    test_ops(8, 3)
    test_ops(28, 7)
    test_ops(27, 7)
    test_ops(26, 7)
    test_ops(25, 7)
    test_ops(24, 7)
    test_ops(23, 7)
    test_ops(22, 7)
    test_ops(21, 7)
    test_ops(20, 7)
    test_ops(0, 12)
    test_ops(1, 16)
    test_ops(10, 1)
    test_ops(1024, 1000)
    test_ops(12345678, 16384)
    test_ops(0xffffff, 1234)
    test_ops(0xffffffff, 1)
    test_ops(0xffffffff, 0xef)
    test_ops(0xffffffff, 0x10000)
    test_ops(0xb36627, 0x0dff95)
    test_ops(0xe5a18e, 0x09ff82)
    test_ops(0x45edd0, 0x04ff1a)
    test_ops(0xe7a344, 0x71ffe8)
    test_ops(0xa3a9a1, 0x2ff44)
    test_ops(0xc128b2, 0x60ff61)
    test_ops(0xdc2254, 0x517fea)
    test_ops(0x769c99, 0x2cffda)
    test_ops(0xc19076, 0x31ffd4)
  end
end

test(64, 4)
test(64, 8)
test(64, 16)
test(64)
test(128)
test(256)
