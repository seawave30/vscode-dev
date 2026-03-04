import matplotlib
matplotlib.use('Agg')  # GUI 없는 환경용
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm

# 한글 폰트 설정
plt.rcParams['axes.unicode_minus'] = False
try:
    # 시스템에서 한글 폰트 찾기
    fonts = [f.name for f in fm.fontManager.ttflist if any(k in f.name for k in ['Nanum', 'Malgun', 'Gothic', 'Dotum'])]
    if fonts:
        plt.rcParams['font.family'] = fonts[0]
except:
    pass

names = ['Bubble', 'Selection', 'Insertion', 'Merge', 'Quick']
values = [85, 60, 70, 30, 20]
colors = ['#e74c3c', '#e67e22', '#f1c40f', '#2ecc71', '#3498db']

fig, ax = plt.subplots(figsize=(9, 5))
bars = ax.bar(names, values, color=colors, edgecolor='white', linewidth=1.2)

# 막대 위에 값 표시
for bar, val in zip(bars, values):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 1,
            str(val), ha='center', va='bottom', fontsize=12, fontweight='bold')

ax.set_title('Sorting Algorithm Comparison (Operations, Lower is Better)', fontsize=13, pad=15)
ax.set_ylabel('Operation Count', fontsize=11)
ax.set_ylim(0, 100)
ax.grid(axis='y', linestyle='--', alpha=0.5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.tight_layout()
plt.savefig('chart.png', dpi=150)
print("chart.png saved!")
