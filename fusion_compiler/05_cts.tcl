##############################################################
# 05_cts.tcl
# 클록 트리 합성 (Clock Tree Synthesis)
##############################################################

# ── CTS 이전 체크 ────────────────────────────────────────────
check_clock_tree

# ── 클록 트리 스펙 설정 ──────────────────────────────────────
set_clock_tree_options \
    -target_skew            100 \
    -target_latency         500 \
    -slew_rate_limit        200 \
    -max_fanout             32

# ── NDR (Non-Default Routing Rule) - 클록 라우팅용 ──────────
create_routing_rule clk_ndr_2x \
    -multiplier_width   2 \
    -multiplier_spacing 2

set_clock_routing_rules \
    -rules clk_ndr_2x \
    -net_type clock

# ── 클록 버퍼 라이브러리 설정 ────────────────────────────────
set_lib_cell_purpose \
    -include cts \
    [get_lib_cells */{CLKBUF,CLKINV}*]

# CTS 전용 버퍼/인버터 지정
set_clock_tree_options \
    -buffer_list [list \
        CLKBUF_X4  CLKBUF_X8  CLKBUF_X16 \
        CLKINV_X4  CLKINV_X8  CLKINV_X16 \
    ]

# ── 클록 게이팅 셀 설정 ──────────────────────────────────────
set_attribute [get_lib_cells */ICGX*] dont_touch false
set_clock_gating_check -setup 0.0 -hold 0.0

# ── 클록 제외 셀 (dont_touch) ────────────────────────────────
set_dont_touch_network [get_clocks *] false

# ── CTS 실행 ─────────────────────────────────────────────────
compile_clock_tree

# ── CTS 이후 최적화 ──────────────────────────────────────────
# hold 슬랙 수정을 위한 최적화
set_fix_hold [all_clocks]

optimize_clock_tree \
    -fix_hold_violations \
    -buffer_list [list CLKBUF_X4 CLKBUF_X8]

# ── 클록 트리 분석 리포트 ────────────────────────────────────
report_clock_tree \
    -summary \
    -nosplit > ${RPTS_DIR}/cts_summary.rpt

report_clock_tree \
    -skew \
    -clock [get_clocks clk] \
    -nosplit > ${RPTS_DIR}/cts_skew.rpt

report_clock_timing \
    -type skew \
    -nosplit > ${RPTS_DIR}/clock_skew.rpt

report_clock_timing \
    -type latency \
    -nosplit > ${RPTS_DIR}/clock_latency.rpt

# ── 타이밍 리포트 (CTS 이후) ─────────────────────────────────
report_timing \
    -delay_type  max \
    -max_paths   20 \
    -path_type   full_clock_expanded \
    -nosplit > ${RPTS_DIR}/cts_setup_timing.rpt

report_timing \
    -delay_type  min \
    -max_paths   20 \
    -path_type   full_clock_expanded \
    -nosplit > ${RPTS_DIR}/cts_hold_timing.rpt

# ── 저장 ─────────────────────────────────────────────────────
save_block -as mydesign_cts
puts "INFO: CTS complete."
