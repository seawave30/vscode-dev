#!/bin/csh
# ====================================================
# 학습 예제 05: 수학 알고리즘 - 피보나치 & 소수 판별
# 반복문을 활용한 수학적 문제 해결
# ====================================================

echo "=== 피보나치 수열 (첫 15개) ==="

set a = 0
set b = 1
set count = 15
set i = 1

echo -n "수열: $a $b "
while ($i < $count - 1)
    @ c = $a + $b
    echo -n "$c "
    set a = $b
    set b = $c
    @ i++
end
echo ""

echo ""
echo "=== 소수(Prime) 판별 ==="

# 2~30 범위에서 소수 찾기
set primes = ()
set n = 2
while ($n <= 30)
    set is_prime = 1
    set d = 2
    while ($d * $d <= $n)
        @ mod = $n % $d
        if ($mod == 0) then
            set is_prime = 0
            break
        endif
        @ d++
    end
    if ($is_prime) then
        set primes = ($primes $n)
    endif
    @ n++
end
echo "2~30 소수: $primes"
echo "소수 개수: $#primes 개"

echo ""
echo "=== 최대공약수 (GCD) - 유클리드 알고리즘 ==="

set x = 48
set y = 18
echo "GCD($x, $y) 계산:"

set a = $x
set b = $y
while ($b != 0)
    @ tmp = $b
    @ b = $a % $b
    set a = $tmp
end
echo "  결과: GCD($x, $y) = $a"

echo ""
echo "=== 최소공배수 (LCM) ==="
@ gcd = $a
@ lcm = ($x * $y) / $gcd
echo "  결과: LCM($x, $y) = $lcm"

echo ""
echo "=== 팩토리얼 (1! ~ 10!) ==="

set i = 1
set fact = 1
while ($i <= 10)
    @ fact = $fact * $i
    echo "  $i! = $fact"
    @ i++
end
