##############################################################
# 08_power_analysis.tcl
# 전력 분석 (Power Analysis) – Fusion Compiler
##############################################################

# ── SAIF 기반 동적 전력 분석 ────────────────────────────────
# RTL 시뮬레이션에서 얻은 SAIF 파일 로드
read_saif \
    -input    "${PROJ_ROOT}/sim/vcd/func.saif" \
    -instance mydesign/u_top \
    -auto_map_top_instances

# VCD 파일로도 가능
# read_vcd \
#     -input    "${PROJ_ROOT}/sim/vcd/func.vcd" \
#     -instance mydesign/u_top

# ── 내부 전력 (기생 성분 포함) 계산 ─────────────────────────
update_power

# ── 전체 전력 리포트 ─────────────────────────────────────────
report_power \
    -nosplit \
    -verbose \
    > ${RPTS_DIR}/power_total.rpt

# ── 계층별 전력 리포트 ───────────────────────────────────────
report_power \
    -hierarchy \
    -nosplit \
    > ${RPTS_DIR}/power_hierarchy.rpt

# ── 전력 구성 요소 분류 ──────────────────────────────────────
# (leakage / internal / switching)
proc summarize_power {} {
    set rpt [report_power -nosplit -return_string]
    foreach line [split $rpt "\n"] {
        if {[regexp {Total\s+Dynamic|Leakage|Cell\s+Internal|Net\s+Switching} $line]} {
            puts $line
        }
    }
}
summarize_power

# ── 전력 도메인별 분석 (UPF 적용 후) ────────────────────────
report_power \
    -power_domain PD_CPU \
    -nosplit \
    > ${RPTS_DIR}/power_cpu_domain.rpt

report_power \
    -power_domain PD_MEM \
    -nosplit \
    > ${RPTS_DIR}/power_mem_domain.rpt

# ── 레벨 시프터 / 아이솔레이션 셀 ───────────────────────────
report_level_shifter    -nosplit > ${RPTS_DIR}/level_shifters.rpt
report_isolation_cells  -nosplit > ${RPTS_DIR}/isolation_cells.rpt

# ── IR Drop 분석 (Power Grid) ────────────────────────────────
# Voltus 연계 시 사용
# analyze_power_grid \
#     -nets {VDD VSS} \
#     -corner slow_corner

# ── 전력 최적화 ──────────────────────────────────────────────
# 클록 게이팅 삽입
synthesize_clock_gating \
    -minimum_bitwidth  4 \
    -registering_stages 1

# 멀티 임계값 전압 셀 교체 (저전력)
swap_cell \
    -target_lib_cells [get_lib_cells */*HVT*] \
    -timing_slack_limit 0.2

# 오퍼랜드 아이솔레이션
synthesize_operand_isolation \
    -minimum_activity 0.3

puts "INFO: Power analysis complete."
