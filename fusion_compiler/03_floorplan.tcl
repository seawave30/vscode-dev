##############################################################
# 03_floorplan.tcl
# 플로어플랜 (Floorplan) 설정
##############################################################

# ── 코어 영역 설정 ───────────────────────────────────────────
# initialize_floorplan: 다이(die) / 코어(core) 경계 설정
initialize_floorplan \
    -core_utilization   0.70 \
    -core_aspect_ratio  1.0  \
    -core_offset        {10 10 10 10} \
    -io_to_core_offset  {30 30 30 30}

# 또는 고정 크기로 직접 지정
# initialize_floorplan \
#     -die_size {0 0 3000 3000} \
#     -core_size {50 50 2950 2950}

# ── 전원 도메인 설정 (UPF) ───────────────────────────────────
load_upf ${UPF_DIR}/top.upf

# ── 전원 포트 배치 (I/O) ─────────────────────────────────────
set_io_pads [list \
    {VDD  CORNER {0 0}}   \
    {VSS  CORNER {0 1}}   \
]

# ── 하드 매크로 배치 ──────────────────────────────────────────
# SRAM 매크로
set_cell_location -coordinates {100 200} -orientation R0 \
    [get_cells u_sram_4kx32]

set_cell_location -coordinates {600 200} -orientation MY \
    [get_cells u_sram_8kx32]

# 매크로 블로케이지 설정 (매크로 주변 라우팅 여백)
create_placement_blockage \
    -name sram_halo \
    -type hard \
    -boundary [transform_coords -cell u_sram_4kx32 -offset {5 5 5 5}]

# ── 전원 계획 (Power Plan) ──────────────────────────────────
# 전원 스트랩 (Power Straps)
create_power_straps \
    -nets {VDD VSS} \
    -layer M8 \
    -direction horizontal \
    -start_at 50 \
    -pitch  60 \
    -width  4 \
    -spacing 2

create_power_straps \
    -nets {VDD VSS} \
    -layer M9 \
    -direction vertical \
    -start_at 50 \
    -pitch  60 \
    -width  4 \
    -spacing 2

# 전원 링 (Power Ring)
create_power_rings \
    -nets {VDD VSS} \
    -layer  {M8 M9} \
    -width  5 \
    -spacing 2 \
    -offset  5

# 전원 연결
preroute_standard_cells \
    -nets {VDD VSS} \
    -connect power_and_ground

# ── 웰 탭 / 엔드캡 셀 삽입 ──────────────────────────────────
add_tap_cell_array \
    -master_cell_name  TAPCELL_X4 \
    -distance 30 \
    -pattern  stagger

add_end_cap_cell \
    -master_cell_name ENDCAP_X1

# ── 플로어플랜 확인 ───────────────────────────────────────────
report_floorplan_attributes
check_floorplan -error_prefix FP

# 저장
save_block -as mydesign_fp
puts "INFO: Floorplan complete."
