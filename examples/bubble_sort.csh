#!/bin/csh

set arr = (64 34 25 12 22 11 90)
echo "정렬 전: $arr"

set n = $#arr
set i = 1
while ($i < $n)
    set j = 1
    while ($j <= `expr $n - $i`)
        set next = `expr $j + 1`
        if ($arr[$j] > $arr[$next]) then
            set tmp = $arr[$j]
            set arr[$j] = $arr[$next]
            set arr[$next] = $tmp
        endif
        set j = `expr $j + 1`
    end
    set i = `expr $i + 1`
end

echo "정렬 후: $arr"
