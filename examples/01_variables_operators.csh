#!/bin/csh
# ====================================================
# 학습 예제 01: 변수와 연산자
# C Shell 기초 - 변수 선언, 산술/비교 연산자 사용법
# ====================================================

echo "=== 변수 기초 ==="

# 변수 선언 및 출력
set name = "C Shell"
set version = 6
echo "언어: $name, 버전: $version"

# 숫자 산술 연산 (@는 csh의 산술 연산자)
set a = 10
set b = 3

@ sum  = $a + $b
@ diff = $a - $b
@ prod = $a * $b
@ quot = $a / $b
@ rem  = $a % $b

echo ""
echo "=== 산술 연산 (a=$a, b=$b) ==="
echo "덧셈: $a + $b = $sum"
echo "뺄셈: $a - $b = $diff"
echo "곱셈: $a * $b = $prod"
echo "나눗셈: $a / $b = $quot"
echo "나머지: $a % $b = $rem"

echo ""
echo "=== 비교 연산 (if 문) ==="

if ($a > $b) then
    echo "$a 는 $b 보다 큽니다"
endif

if ($a != $b) then
    echo "$a 와 $b 는 다릅니다"
endif

echo ""
echo "=== 환경 변수 ==="
setenv MY_APP "vscode-cshell"
echo "앱 이름: $MY_APP"
echo "현재 사용자: $USER"
echo "홈 디렉토리: $HOME"

echo ""
echo "=== 배열 변수 ==="
set fruits = (사과 바나나 포도 딸기)
echo "과일 목록: $fruits"
echo "첫 번째: $fruits[1]"
echo "마지막: $fruits[$#fruits]"
echo "개수: $#fruits 개"
