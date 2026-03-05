#!/bin/csh
# ====================================================
# 학습 예제 04: 문자열 처리
# 문자열 비교, 길이, 대소문자, 검색/치환 사용법
# ====================================================

echo "=== 문자열 변수 ==="

set str = "Hello, C Shell World!"
echo "원본: $str"

echo ""
echo "=== 문자열 길이 ==="

set len = `echo "$str" | wc -c`
@ len = $len - 1   # wc -c 는 개행문자 포함이므로 -1
echo "길이: $len 글자"

echo ""
echo "=== 대소문자 변환 ==="

set upper = `echo "$str" | tr 'a-z' 'A-Z'`
set lower = `echo "$str" | tr 'A-Z' 'a-z'`
echo "대문자: $upper"
echo "소문자: $lower"

echo ""
echo "=== 문자열 비교 ==="

set s1 = "apple"
set s2 = "apple"
set s3 = "banana"

if ("$s1" == "$s2") then
    echo "$s1 == $s2: 같습니다"
endif

if ("$s1" != "$s3") then
    echo "$s1 != $s3: 다릅니다"
endif

echo ""
echo "=== 부분 문자열 / 검색 ==="

set sentence = "C Shell은 유닉스 계열 쉘 언어입니다"
echo "문장: $sentence"

# grep으로 패턴 검색
echo "$sentence" | grep -q "쉘"
if ($status == 0) then
    echo "  '쉘' 포함: 발견됨"
endif

echo ""
echo "=== 문자열 치환 (sed) ==="

set original = "나는 Python을 좋아합니다"
set replaced = `echo "$original" | sed 's/Python/C Shell/'`
echo "원본:  $original"
echo "치환:  $replaced"

echo ""
echo "=== 문자열 분리 (공백 기준) ==="

set csv = "홍길동 25 서울"
set col1 = `echo "$csv" | awk '{print $1}'`
set col2 = `echo "$csv" | awk '{print $2}'`
set col3 = `echo "$csv" | awk '{print $3}'`
echo "이름: $col1, 나이: $col2, 지역: $col3"

echo ""
echo "=== 문자열 이어붙이기 ==="

set first = "Hello"
set second = "World"
set combined = "${first}, ${second}!"
echo "합치기: $combined"
