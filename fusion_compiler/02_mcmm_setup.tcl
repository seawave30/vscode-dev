##############################################################
# 02_mcmm_setup.tcl
# Multi-Corner Multi-Mode (MCMM) 설정
##############################################################

# ── 코너(Corner) 정의 ────────────────────────────────────────
# 슬로우 코너 (worst-case 타이밍)
create_corner slow_corner
set_process_number -corner slow_corner 1
set_pvt -corner slow_corner -library_label ss_0p7v_125c

# 패스트 코너 (best-case 타이밍)
create_corner fast_corner
set_pvt -corner fast_corner -library_label ff_0p9v_m40c

# 타입 코너
create_corner typical_corner
set_pvt -corner typical_corner -library_label tt_0p8v_25c

# ── 모드(Mode) 정의 ──────────────────────────────────────────
# 기능 동작 모드
create_mode func_mode
set_constraints_mode func_mode
read_sdc -mode func_mode ${SDC_DIR}/func.sdc

# 스캔 테스트 모드
create_mode scan_mode
set_constraints_mode scan_mode
read_sdc -mode scan_mode ${SDC_DIR}/scan.sdc

# ── 분석 뷰(Analysis View) 생성 ──────────────────────────────
# Setup 체크용 뷰 (slow / func)
create_analysis_view \
    -name func_slow_setup \
    -constraint_mode func_mode \
    -delay_corner slow_corner

# Hold 체크용 뷰 (fast / func)
create_analysis_view \
    -name func_fast_hold \
    -constraint_mode func_mode \
    -delay_corner fast_corner

# 스캔 모드 뷰
create_analysis_view \
    -name scan_slow_setup \
    -constraint_mode scan_mode \
    -delay_corner slow_corner

# ── 활성 분석 뷰 설정 ────────────────────────────────────────
set_analysis_view \
    -setup [list func_slow_setup scan_slow_setup] \
    -hold  [list func_fast_hold]

# ── 기생 파라미터 (TLU+ per corner) ─────────────────────────
set_parasitic_parameters \
    -corner slow_corner \
    -early_spec ${PDK_ROOT}/tluplus/min.tluplus \
    -late_spec  ${PDK_ROOT}/tluplus/max.tluplus \
    -interconnect_map ${PDK_ROOT}/map/tech2itf.map

set_parasitic_parameters \
    -corner fast_corner \
    -early_spec ${PDK_ROOT}/tluplus/min.tluplus \
    -late_spec  ${PDK_ROOT}/tluplus/min.tluplus \
    -interconnect_map ${PDK_ROOT}/map/tech2itf.map

# ── MMMC 확인 ────────────────────────────────────────────────
report_analysis_view
report_pvt

puts "INFO: MCMM setup complete."
