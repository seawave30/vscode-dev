##############################################################
# 04_placement.tcl
# 셀 배치 (Placement) – Fusion Compiler
##############################################################

# ── 배치 옵션 설정 ───────────────────────────────────────────
set_app_options \
    -name place.coarse.auto_density_control \
    -value true

set_app_options \
    -name place.coarse.congestion_driven \
    -value true

set_app_options \
    -name place.common.timing_driven \
    -value true

# 배치 중 리타이밍 허용 (레이턴시 줄이기)
set_app_options \
    -name place.common.enable_retiming \
    -value true

# ── 배치 블로케이지 ──────────────────────────────────────────
# 특정 영역에 표준 셀 배치 금지
create_placement_blockage \
    -name io_blockage \
    -type hard \
    -boundary {{0 0} {50 3000}}

# 소프트 블로케이지 (배치 밀도 낮추기)
create_placement_blockage \
    -name clock_buffer_area \
    -type soft \
    -blocked_percentage 50 \
    -boundary {{1400 1400} {1600 1600}}

# ── 배치 전 체크 ─────────────────────────────────────────────
check_design -checks pre_place_stage

# ── 글로벌 배치 ──────────────────────────────────────────────
place_opt \
    -flow               initial_opto \
    -congestion_effort  medium

# ── 고정 셀 설정 ─────────────────────────────────────────────
# 매크로 위치 고정
set_attribute [get_cells u_sram_4kx32] is_fixed true
set_attribute [get_cells u_sram_8kx32] is_fixed true

# ── 배치 최적화 (타이밍 기반) ────────────────────────────────
# 세부 배치 + 타이밍 최적화
place_opt \
    -flow               final_opto \
    -effort             high \
    -timing_driven      true

# ── 셀 패딩 설정 ─────────────────────────────────────────────
# 고팬아웃 버퍼에 여분 공간 확보
set_cell_padding \
    -cell [get_cells -filter "ref_name =~ BUF*"] \
    -left  2 \
    -right 2

# ── 피드스루 / 필러 셀 삽입 ─────────────────────────────────
add_cells_to_empty_spaces \
    -fill_only \
    -cell_name FILLER

# ── 혼잡도 / 타이밍 리포트 ──────────────────────────────────
report_placement -max_displacement
report_congestion -by_layer
report_timing -max_paths 20 -delay_type max -nosplit

# ── 저장 ─────────────────────────────────────────────────────
save_block -as mydesign_place
puts "INFO: Placement complete."
