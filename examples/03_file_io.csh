#!/bin/csh
# ====================================================
# 학습 예제 03: 파일 입출력
# 파일 읽기/쓰기, 존재 확인, 리다이렉션 사용법
# ====================================================

set tmpdir = "/tmp/csh_learn"

# 작업 디렉토리 생성
if (! -d $tmpdir) then
    mkdir -p $tmpdir
endif

echo "=== 파일 쓰기 (리다이렉션) ==="

set outfile = "$tmpdir/students.txt"

# > 는 덮어쓰기, >> 는 이어쓰기
echo "홍길동 95" >  $outfile
echo "이순신 88" >> $outfile
echo "강감찬 72" >> $outfile
echo "유관순 91" >> $outfile

echo "$outfile 에 저장 완료"

echo ""
echo "=== 파일 읽기 (foreach) ==="

foreach line ("`cat $outfile`")
    echo "  읽은 줄: $line"
end

echo ""
echo "=== 파일/디렉토리 존재 확인 ==="

# -e: 존재, -f: 일반파일, -d: 디렉토리, -r: 읽기가능
if (-f $outfile) then
    echo "$outfile: 일반 파일 존재"
endif

if (-d $tmpdir) then
    echo "$tmpdir: 디렉토리 존재"
endif

if (-r $outfile) then
    echo "$outfile: 읽기 가능"
endif

echo ""
echo "=== 파일 내용 처리 (awk로 평균 계산) ==="

set total = 0
set count = 0

foreach line ("`cat $outfile`")
    set score = `echo $line | awk '{print $2}'`
    @ total = $total + $score
    @ count++
end

if ($count > 0) then
    set avg = `echo "scale=1; $total / $count" | bc`
    echo "학생 수: $count 명"
    echo "총점: $total 점"
    echo "평균: $avg 점"
endif

echo ""
echo "=== 정리: 임시 파일 삭제 ==="
rm -rf $tmpdir
echo "$tmpdir 삭제 완료"
