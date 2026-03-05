#!/bin/csh
# ====================================================
# 학습 예제 02: 제어 흐름 (조건문 & 반복문)
# if/else, switch, while, foreach 사용법
# ====================================================

echo "=== if / else if / else ==="

set score = 75

if ($score >= 90) then
    echo "점수 $score: A학점"
else if ($score >= 80) then
    echo "점수 $score: B학점"
else if ($score >= 70) then
    echo "점수 $score: C학점"
else if ($score >= 60) then
    echo "점수 $score: D학점"
else
    echo "점수 $score: F학점"
endif

echo ""
echo "=== switch 문 ==="

set day = "월"

switch ($day)
    case "월":
    case "화":
    case "수":
    case "목":
    case "금":
        echo "$day 요일은 평일입니다"
        breaksw
    case "토":
    case "일":
        echo "$day 요일은 주말입니다"
        breaksw
    default:
        echo "알 수 없는 요일입니다"
        breaksw
endsw

echo ""
echo "=== while 반복문 ==="

set i = 1
set total = 0
while ($i <= 5)
    @ total = $total + $i
    echo "  $i 누적합: $total"
    @ i++
end
echo "1~5 합계: $total"

echo ""
echo "=== foreach 반복문 ==="

set languages = (csh bash zsh fish)
foreach lang ($languages)
    echo "  쉘: $lang"
end

echo ""
echo "=== 중첩 반복문 (구구단 3단, 4단) ==="

foreach dan (3 4)
    echo "--- $dan 단 ---"
    set j = 1
    while ($j <= 9)
        @ result = $dan * $j
        echo "  $dan x $j = $result"
        @ j++
    end
end
