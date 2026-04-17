##############################################################
# 06_routing.tcl
# 라우팅 (Routing) – Fusion Compiler
##############################################################

# ── 라우팅 전 체크 ───────────────────────────────────────────
check_design -checks pre_route_stage

# ── 라우팅 규칙 설정 ─────────────────────────────────────────
set_app_options \
    -name route.global.timing_driven \
    -value true

set_app_options \
    -name route.track.timing_driven \
    -value true

set_app_options \
    -name route.detail.timing_driven \
    -value true

# 혼잡도 대응 레이어 사용
set_app_options \
    -name route.global.crosstalk_driven \
    -value true

# ── 신호 무결성 설정 ─────────────────────────────────────────
set_si_options \
    -delta_delay true \
    -static_noise true \
    -noise_budget_ratio 0.8

# ── 라우팅 레이어 방향 지정 ──────────────────────────────────
set_attribute [get_layers M1] routing_direction horizontal
set_attribute [get_layers M2] routing_direction vertical
set_attribute [get_layers M3] routing_direction horizontal
set_attribute [get_layers M4] routing_direction vertical
set_attribute [get_layers M5] routing_direction horizontal
set_attribute [get_layers M6] routing_direction vertical
set_attribute [get_layers M7] routing_direction horizontal
set_attribute [get_layers M8] routing_direction vertical

# ── 전원 라우팅 ──────────────────────────────────────────────
route_global \
    -nets {VDD VSS} \
    -congestion_map_only false

# ── 글로벌 라우팅 ────────────────────────────────────────────
route_global

# ── 트랙 배정 ────────────────────────────────────────────────
route_track

# ── 세부 라우팅 ──────────────────────────────────────────────
route_detail \
    -incremental false \
    -diode_mode  always

# ── DRC 위반 수정 (자동) ─────────────────────────────────────
route_detail \
    -incremental true \
    -fix_drc      true

# ── 안테나 수정 ──────────────────────────────────────────────
check_routes -antenna
fix_antenna_violations \
    -use_diodes   true \
    -diode_prefix ANTENNA_DIODE

# ── 라우팅 후 최적화 ─────────────────────────────────────────
route_opt

# ── 기생 성분 추출 ───────────────────────────────────────────
extract_rc \
    -corner_list {slow_corner fast_corner typical_corner} \
    -effort      medium

# ── DRC / LVS 체크 ───────────────────────────────────────────
verify_lvs

check_routes \
    -open_nets    true \
    -short_nets   true \
    -antenna      true \
    > ${RPTS_DIR}/route_drc.rpt

# ── 타이밍 리포트 (라우팅 이후) ──────────────────────────────
report_timing \
    -delay_type  max \
    -max_paths   50 \
    -nosplit > ${RPTS_DIR}/route_setup_timing.rpt

report_timing \
    -delay_type  min \
    -max_paths   50 \
    -nosplit > ${RPTS_DIR}/route_hold_timing.rpt

# ── 저장 ─────────────────────────────────────────────────────
save_block -as mydesign_route
puts "INFO: Routing complete."
