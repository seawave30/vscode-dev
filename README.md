# vscode-dev
노트북없이 코딩하기 예제

## 프로젝트 구성

- `sorting.py` - 5가지 정렬 알고리즘 구현
- `bar_chart.py` - 정렬 알고리즘 성능 비교 막대 차트 생성
- `chart.png` - 생성된 차트 이미지

## 사용법

### 정렬 알고리즘 실행

```bash
python sorting.py
```

랜덤한 10개의 숫자를 생성하여 5가지 정렬 알고리즘으로 정렬한 결과를 출력합니다.

**출력 예시:**
```
원본: [42, 7, 93, 15, 68, ...]
버블 정렬:    [7, 15, 42, 68, 93, ...]
선택 정렬:    [7, 15, 42, 68, 93, ...]
삽입 정렬:    [7, 15, 42, 68, 93, ...]
합병 정렬:    [7, 15, 42, 68, 93, ...]
퀵 정렬:      [7, 15, 42, 68, 93, ...]
```

### 정렬 알고리즘 직접 사용

```python
from sorting import bubble_sort, selection_sort, insertion_sort, merge_sort, quick_sort

arr = [64, 34, 25, 12, 22, 11, 90]

print(bubble_sort(arr[:]))    # [11, 12, 22, 25, 34, 64, 90]
print(merge_sort(arr[:]))     # [11, 12, 22, 25, 34, 64, 90]
print(quick_sort(arr[:]))     # [11, 12, 22, 25, 34, 64, 90]
```

### 성능 비교 차트 생성

```bash
pip install matplotlib
python bar_chart.py
```

`chart.png` 파일이 생성됩니다. (GUI 없는 환경에서도 동작)

## 구현된 정렬 알고리즘

| 알고리즘 | 평균 시간복잡도 | 공간복잡도 | 특징 |
|---------|--------------|----------|------|
| 버블 정렬 (Bubble Sort) | O(n²) | O(1) | 단순하지만 느림 |
| 선택 정렬 (Selection Sort) | O(n²) | O(1) | 교환 횟수 최소 |
| 삽입 정렬 (Insertion Sort) | O(n²) | O(1) | 거의 정렬된 경우 빠름 |
| 합병 정렬 (Merge Sort) | O(n log n) | O(n) | 안정적이고 빠름 |
| 퀵 정렬 (Quick Sort) | O(n log n) | O(log n) | 평균적으로 가장 빠름 |

## 요구사항

- Python 3.x
- matplotlib (차트 생성 시 필요)
