##############################################################
# 07_timing_analysis.tcl
# 타이밍 분석 및 리포트 생성
##############################################################

# ── 기생 성분 추출 갱신 ──────────────────────────────────────
extract_rc -corners_list {slow_corner fast_corner}

# ── 타이밍 업데이트 ──────────────────────────────────────────
update_timing -full

# ── Setup 타이밍 ─────────────────────────────────────────────
proc report_setup_timing { rpt_file } {
    report_timing \
        -delay_type     max \
        -max_paths      100 \
        -nworst         3 \
        -path_type      full_clock_expanded \
        -input_pins \
        -nosplit \
        > $rpt_file
    puts "INFO: Setup timing → $rpt_file"
}

# ── Hold 타이밍 ──────────────────────────────────────────────
proc report_hold_timing { rpt_file } {
    report_timing \
        -delay_type     min \
        -max_paths      100 \
        -nworst         3 \
        -path_type      full_clock_expanded \
        -input_pins \
        -nosplit \
        > $rpt_file
    puts "INFO: Hold timing → $rpt_file"
}

# ── 슬랙 요약 ────────────────────────────────────────────────
proc report_slack_summary {} {
    set setup_slack [get_attribute [get_timing_paths -delay_type max] slack]
    set hold_slack  [get_attribute [get_timing_paths -delay_type min] slack]
    puts "  Setup WNS : $setup_slack ps"
    puts "  Hold  WNS : $hold_slack  ps"

    # TNS
    report_timing \
        -delay_type max \
        -slack_lesser_than 0 \
        -max_paths  999 \
        -nosplit > /tmp/violators.rpt

    set lines [exec wc -l < /tmp/violators.rpt]
    puts "  Setup 위반 경로 수: $lines"
}

# ── 경로별 상세 분석 ─────────────────────────────────────────
proc analyze_critical_paths { n } {
    set paths [get_timing_paths -delay_type max -max_paths $n]
    foreach path $paths {
        set slack      [get_attribute $path slack]
        set startpoint [get_attribute $path startpoint]
        set endpoint   [get_attribute $path endpoint]
        if { $slack < 0 } {
            puts "VIOLATED  slack=[format %.3f $slack] \
                  $startpoint -> $endpoint"
        }
    }
}

# ── 클록 도메인 크로싱 체크 ──────────────────────────────────
proc check_cdc {} {
    report_cdc \
        -summary \
        -nosplit > ${::RPTS_DIR}/cdc_summary.rpt
    check_cdc
    puts "INFO: CDC check done."
}

# ── PBA (Path-Based Analysis) ────────────────────────────────
# 지정된 경로에 정밀 분석 적용
proc run_pba { endpoint_pattern } {
    set paths [get_timing_paths \
        -through [get_pins $endpoint_pattern] \
        -delay_type max \
        -max_paths 10]
    report_timing \
        -pba_mode    exhaustive \
        -max_paths   10 \
        -nosplit
}

# ── CPPR (Clock Path Pessimism Removal) ──────────────────────
set_app_options \
    -name time.remove_clock_reconvergence_pessimism \
    -value true

# ── OCV (On-Chip Variation) 설정 ─────────────────────────────
set_timing_derate \
    -cell_delay      \
    -data            \
    -early  0.94     \
    -late   1.06

set_timing_derate \
    -cell_delay      \
    -clock           \
    -early  0.96     \
    -late   1.04

# ── 전체 리포트 실행 ─────────────────────────────────────────
report_setup_timing ${RPTS_DIR}/final_setup.rpt
report_hold_timing  ${RPTS_DIR}/final_hold.rpt
report_slack_summary
analyze_critical_paths 20
check_cdc

# 클록 리포트
report_clock -all -nosplit > ${RPTS_DIR}/clocks.rpt

# 입출력 타이밍
report_port -verbose -nosplit > ${RPTS_DIR}/ports.rpt

# 제약 위반 체크
report_constraint -all_violators -nosplit > ${RPTS_DIR}/constraint_viols.rpt

puts "INFO: Timing analysis complete."
