#!/bin/csh

set arr = (64 25 12 22 11)
echo "정렬 전: $arr"

set n = $#arr
set i = 1
while ($i < $n)
    set min_idx = $i
    set j = `expr $i + 1`
    while ($j <= $n)
        if ($arr[$j] < $arr[$min_idx]) then
            set min_idx = $j
        endif
        set j = `expr $j + 1`
    end
    if ($min_idx != $i) then
        set tmp = $arr[$i]
        set arr[$i] = $arr[$min_idx]
        set arr[$min_idx] = $tmp
    endif
    set i = `expr $i + 1`
end

echo "정렬 후: $arr"
