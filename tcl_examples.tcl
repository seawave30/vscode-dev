#!/usr/bin/env tclsh
# Tcl 자주 쓰는 예제 모음
# ==============================================

# --------------------------------------------------
# 1. 변수 선언 및 출력
# --------------------------------------------------
set name "홍길동"
set age 30
puts "이름: $name, 나이: $age"

# 문자열 보간
puts "안녕하세요, ${name}님!"

# --------------------------------------------------
# 2. 산술 연산
# --------------------------------------------------
set a 10
set b 3
puts "덧셈: [expr {$a + $b}]"
puts "뺄셈: [expr {$a - $b}]"
puts "곱셈: [expr {$a * $b}]"
puts "나눗셈: [expr {$a / $b}]"
puts "나머지: [expr {$a % $b}]"
puts "거듭제곱: [expr {$a ** $b}]"
puts "실수 나눗셈: [expr {double($a) / $b}]"

# --------------------------------------------------
# 3. 문자열 처리
# --------------------------------------------------
set str "Hello, Tcl World!"

# 문자열 길이
puts "길이: [string length $str]"

# 대소문자 변환
puts "대문자: [string toupper $str]"
puts "소문자: [string tolower $str]"

# 부분 문자열
puts "부분 문자열: [string range $str 0 4]"

# 문자열 찾기
puts "인덱스: [string first "Tcl" $str]"

# 문자열 치환
puts "치환: [string map {Tcl Python} $str]"

# 문자열 자르기 (공백 제거)
set padded "  hello  "
puts "trim: '[string trim $padded]'"

# 문자열 분리 (split)
set csv "apple,banana,cherry"
set fruits [split $csv ","]
puts "분리: $fruits"

# 문자열 합치기 (join)
puts "합치기: [join $fruits " | "]"

# --------------------------------------------------
# 4. 리스트
# --------------------------------------------------
set mylist {apple banana cherry orange}

# 리스트 길이
puts "리스트 길이: [llength $mylist]"

# 인덱스 접근
puts "첫 번째: [lindex $mylist 0]"
puts "마지막: [lindex $mylist end]"

# 리스트 추가
lappend mylist "grape"
puts "추가 후: $mylist"

# 리스트 삽입
set mylist [linsert $mylist 2 "mango"]
puts "삽입 후: $mylist"

# 리스트 정렬
puts "정렬: [lsort $mylist]"
puts "역순 정렬: [lsort -decreasing $mylist]"

# 리스트 검색
puts "검색: [lsearch $mylist "banana"]"

# 리스트 슬라이싱
puts "슬라이스: [lrange $mylist 1 3]"

# 리스트 삭제
set mylist [lreplace $mylist 2 2]
puts "삭제 후: $mylist"

# --------------------------------------------------
# 5. 딕셔너리 (dict)
# --------------------------------------------------
set person [dict create name "김철수" age 25 city "서울"]

# 값 가져오기
puts "이름: [dict get $person name]"
puts "나이: [dict get $person age]"

# 값 설정
dict set person email "kim@example.com"
puts "딕셔너리: $person"

# 키 존재 확인
if {[dict exists $person email]} {
    puts "이메일이 있습니다: [dict get $person email]"
}

# 딕셔너리 순회
dict for {key value} $person {
    puts "  $key = $value"
}

# 딕셔너리 키 목록
puts "키 목록: [dict keys $person]"

# --------------------------------------------------
# 6. 조건문 (if / elseif / else)
# --------------------------------------------------
set score 85

if {$score >= 90} {
    puts "학점: A"
} elseif {$score >= 80} {
    puts "학점: B"
} elseif {$score >= 70} {
    puts "학점: C"
} else {
    puts "학점: F"
}

# switch 문
set day "Monday"
switch $day {
    Monday  { puts "월요일" }
    Tuesday { puts "화요일" }
    default { puts "다른 요일" }
}

# --------------------------------------------------
# 7. 반복문
# --------------------------------------------------

# for 루프
puts "for 루프:"
for {set i 0} {$i < 5} {incr i} {
    puts -nonewline "$i "
}
puts ""

# foreach 루프
puts "foreach 루프:"
foreach fruit {apple banana cherry} {
    puts -nonewline "$fruit "
}
puts ""

# while 루프
puts "while 루프:"
set n 1
while {$n <= 5} {
    puts -nonewline "$n "
    incr n
}
puts ""

# break / continue
puts "break/continue:"
for {set i 0} {$i < 10} {incr i} {
    if {$i == 3} { continue }
    if {$i == 7} { break }
    puts -nonewline "$i "
}
puts ""

# --------------------------------------------------
# 8. 프로시저 (proc)
# --------------------------------------------------

# 기본 프로시저
proc greet {name} {
    return "안녕하세요, ${name}님!"
}
puts [greet "세계"]

# 기본값이 있는 인자
proc power {base {exp 2}} {
    return [expr {$base ** $exp}]
}
puts "2의 기본 거듭제곱: [power 2]"
puts "2의 3승: [power 2 3]"

# 가변 인자
proc sum {args} {
    set total 0
    foreach n $args {
        set total [expr {$total + $n}]
    }
    return $total
}
puts "합계: [sum 1 2 3 4 5]"

# 전역 변수 접근
set counter 0
proc increment {} {
    global counter
    incr counter
}
increment
increment
puts "카운터: $counter"

# upvar - 상위 스코프 변수 참조
proc double_value {varName} {
    upvar $varName var
    set var [expr {$var * 2}]
}
set x 5
double_value x
puts "두 배: $x"

# --------------------------------------------------
# 9. 파일 입출력
# --------------------------------------------------

# 파일 쓰기
set fh [open "/tmp/test_tcl.txt" w]
puts $fh "첫 번째 줄"
puts $fh "두 번째 줄"
puts $fh "세 번째 줄"
close $fh

# 파일 읽기 (전체)
set fh [open "/tmp/test_tcl.txt" r]
set content [read $fh]
close $fh
puts "파일 내용:\n$content"

# 파일 한 줄씩 읽기
set fh [open "/tmp/test_tcl.txt" r]
puts "한 줄씩 읽기:"
while {[gets $fh line] >= 0} {
    puts "  >> $line"
}
close $fh

# 파일 추가 쓰기
set fh [open "/tmp/test_tcl.txt" a]
puts $fh "추가된 줄"
close $fh

# 파일 존재 확인
if {[file exists "/tmp/test_tcl.txt"]} {
    puts "파일 크기: [file size /tmp/test_tcl.txt] bytes"
}

# --------------------------------------------------
# 10. 에러 처리 (catch / try)
# --------------------------------------------------

# catch 사용
set result [catch {expr {1 / 0}} errMsg]
if {$result != 0} {
    puts "에러 발생: $errMsg"
}

# try 사용 (Tcl 8.6+)
try {
    set val [expr {10 / 2}]
    puts "결과: $val"
} on error {msg} {
    puts "에러: $msg"
}

# 에러 발생시키기
proc divide {a b} {
    if {$b == 0} {
        error "0으로 나눌 수 없습니다"
    }
    return [expr {$a / $b}]
}

catch {divide 10 0} err
puts "에러 처리: $err"

# --------------------------------------------------
# 11. 정규식
# --------------------------------------------------
set text "전화번호: 010-1234-5678, 이메일: test@example.com"

# 매칭 확인
if {[regexp {\d{3}-\d{4}-\d{4}} $text match]} {
    puts "전화번호 매칭: $match"
}

# 그룹 캡처
if {[regexp {(\w+)@(\w+)\.(\w+)} $text full user domain ext]} {
    puts "이메일 전체: $full"
    puts "사용자: $user"
    puts "도메인: $domain"
}

# 전체 매칭 찾기
set numbers [regexp -all -inline {\d+} $text]
puts "숫자들: $numbers"

# 치환
set result [regsub -all {\d} $text "*"]
puts "숫자 가리기: $result"

# --------------------------------------------------
# 12. 수학 함수
# --------------------------------------------------
puts "절댓값: [expr {abs(-5)}]"
puts "반올림: [expr {round(3.7)}]"
puts "올림: [expr {ceil(3.2)}]"
puts "내림: [expr {floor(3.9)}]"
puts "최솟값: [expr {min(3, 1, 4, 1, 5, 9)}]"
puts "최댓값: [expr {max(3, 1, 4, 1, 5, 9)}]"
puts "제곱근: [expr {sqrt(16)}]"
puts "로그: [expr {log(100) / log(10)}]"

# 난수
expr {srand(42)}
puts "난수 (0~1): [expr {rand()}]"
puts "정수 난수 (0~9): [expr {int(rand() * 10)}]"

# --------------------------------------------------
# 13. 시간 처리
# --------------------------------------------------

# 현재 시간 (초)
set now [clock seconds]
puts "현재 타임스탬프: $now"

# 형식화된 시간
puts "현재 날짜: [clock format $now -format "%Y-%m-%d"]"
puts "현재 시간: [clock format $now -format "%H:%M:%S"]"
puts "전체 날짜시간: [clock format $now -format "%Y-%m-%d %H:%M:%S"]"

# 문자열을 시간으로 변환
set ts [clock scan "2024-01-01" -format "%Y-%m-%d"]
puts "2024-01-01 타임스탬프: $ts"

# 시간 차이 계산
set diff [expr {$now - $ts}]
set days [expr {$diff / 86400}]
puts "2024-01-01로부터 ${days}일 경과"

# --------------------------------------------------
# 14. 네임스페이스
# --------------------------------------------------
namespace eval myapp {
    variable version "1.0.0"
    variable debug 0

    proc hello {name} {
        variable version
        return "MyApp v${version}: 안녕하세요, ${name}!"
    }

    proc add {a b} {
        return [expr {$a + $b}]
    }
}

puts [myapp::hello "사용자"]
puts "덧셈: [myapp::add 3 4]"
puts "버전: $myapp::version"

# --------------------------------------------------
# 15. 고급 리스트 처리
# --------------------------------------------------

# lmap - 리스트 변환 (Tcl 8.6+)
set numbers {1 2 3 4 5}
set doubled [lmap n $numbers {expr {$n * 2}}]
puts "두 배: $doubled"

# 필터링
set evens [lmap n $numbers {
    if {$n % 2 == 0} {set n} else {continue}
}]
puts "짝수: $evens"

# 정렬 (사용자 정의)
set words {banana apple cherry date elderberry}
set sorted [lsort -command {apply {{a b} {string compare $a $b}}} $words]
puts "정렬된 단어: $sorted"

# 리스트 평탄화
set nested {{1 2} {3 4} {5 6}}
set flat {}
foreach sub $nested {
    lappend flat {*}$sub
}
puts "평탄화: $flat"

# --------------------------------------------------
# 16. 문자열 포맷팅
# --------------------------------------------------
puts [format "이름: %-10s 나이: %3d" "홍길동" 30]
puts [format "원주율: %.4f" 3.14159265]
puts [format "16진수: %#x" 255]
puts [format "과학적 표기: %e" 123456.789]

# --------------------------------------------------
# 17. 환경 변수 및 시스템
# --------------------------------------------------

# 환경 변수 읽기
if {[info exists env(HOME)]} {
    puts "홈 디렉토리: $env(HOME)"
}

# 현재 디렉토리
puts "현재 디렉토리: [pwd]"

# 명령어 실행
catch {exec date} output
puts "날짜 명령어: $output"

# Tcl 버전 정보
puts "Tcl 버전: [info tclversion]"
puts "플랫폼: $tcl_platform(os)"

# --------------------------------------------------
# 18. OOP - TclOO (Tcl 8.6+)
# --------------------------------------------------
package require TclOO

oo::class create Animal {
    variable name sound

    constructor {n s} {
        set name $n
        set sound $s
    }

    method speak {} {
        puts "${name}이(가) '${sound}'라고 말합니다"
    }

    method getName {} {
        return $name
    }
}

oo::class create Dog {
    superclass Animal

    constructor {n} {
        next $n "멍멍"
    }

    method fetch {} {
        puts "[my getName]이(가) 공을 가져옵니다!"
    }
}

set dog [Dog new "바둑이"]
$dog speak
$dog fetch
$dog destroy

# --------------------------------------------------
# 19. 채널 및 파이프
# --------------------------------------------------

# 문자열을 채널로 (Tcl 8.6+)
# set chan [tcl::chan::string "가나다라마바사"]

# 파이프 실행
catch {
    set pipe [open "|ls /tmp" r]
    while {[gets $pipe line] >= 0} {
        # puts "파일: $line"
    }
    close $pipe
}

# --------------------------------------------------
# 20. 유용한 유틸리티 프로시저
# --------------------------------------------------

# 배열 범위 생성
proc range {start end {step 1}} {
    set result {}
    for {set i $start} {$i < $end} {incr i $step} {
        lappend result $i
    }
    return $result
}
puts "범위: [range 0 10 2]"

# 리스트 중복 제거
proc unique {lst} {
    set seen {}
    set result {}
    foreach item $lst {
        if {$item ni $seen} {
            lappend seen $item
            lappend result $item
        }
    }
    return $result
}
puts "중복 제거: [unique {1 2 3 2 1 4 3 5}]"

# 문자열 반복
proc repeat {str n} {
    return [string repeat $str $n]
}
puts "반복: [repeat "ab" 4]"

# 딕셔너리 병합
proc dict_merge {args} {
    set result {}
    foreach d $args {
        dict for {k v} $d {
            dict set result $k $v
        }
    }
    return $result
}
set d1 [dict create a 1 b 2]
set d2 [dict create b 3 c 4]
puts "병합: [dict_merge $d1 $d2]"

puts "\n=== 예제 실행 완료 ==="
