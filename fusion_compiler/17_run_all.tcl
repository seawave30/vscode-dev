##############################################################
# 17_run_all.tcl
# 전체 P&R 플로우 통합 실행 스크립트
# 사용법:  fc_shell -f 17_run_all.tcl
##############################################################

set SCRIPT_DIR [file dirname [info script]]

# ── 공통 변수 ────────────────────────────────────────────────
set PROJ_ROOT  "/proj/mydesign"
set RTL_DIR    "$PROJ_ROOT/rtl"
set SDC_DIR    "$PROJ_ROOT/constraints"
set UPF_DIR    "$PROJ_ROOT/upf"
set RPTS_DIR   "$PROJ_ROOT/rpts"
set WORK_DIR   "$PROJ_ROOT/work"
set PDK_ROOT   "/pdk/7nm"

foreach dir [list $RPTS_DIR $WORK_DIR] { file mkdir $dir }

# ── 로그 설정 ────────────────────────────────────────────────
set LOG_FILE [open "${RPTS_DIR}/run_all.log" w]
proc log_msg { msg } {
    set ts [clock format [clock seconds] -format "%H:%M:%S"]
    set line "\[$ts\] $msg"
    puts $line
    puts $::LOG_FILE $line
    flush $::LOG_FILE
}

# ── 단계별 실행 제어 ─────────────────────────────────────────
array set STEPS {
    setup     1
    mcmm      1
    floorplan 1
    placement 1
    cts       1
    routing   1
    signoff   1
}

# ── 각 단계 실행 함수 ────────────────────────────────────────
proc run_step { step_name script_file } {
    if { !$::STEPS($step_name) } {
        log_msg "SKIP: $step_name"
        return
    }
    log_msg "START: $step_name"
    set t0 [clock seconds]

    if { [catch { source $script_file } err] } {
        log_msg "ERROR in $step_name: $err"
        close $::LOG_FILE
        exit 1
    }

    set elapsed [expr {[clock seconds] - $t0}]
    log_msg "DONE: $step_name (${elapsed}s)"
}

# ── 메인 플로우 ──────────────────────────────────────────────
log_msg "=== Fusion Compiler P&R 플로우 시작 ==="

run_step setup     $SCRIPT_DIR/01_design_setup.tcl
run_step mcmm      $SCRIPT_DIR/02_mcmm_setup.tcl
run_step floorplan $SCRIPT_DIR/03_floorplan.tcl
run_step placement $SCRIPT_DIR/04_placement.tcl
run_step cts       $SCRIPT_DIR/05_cts.tcl
run_step routing   $SCRIPT_DIR/06_routing.tcl

# ── 타이밍 / 전력 분석 ───────────────────────────────────────
source $SCRIPT_DIR/07_timing_analysis.tcl
source $SCRIPT_DIR/08_power_analysis.tcl
source $SCRIPT_DIR/13_reports_utils.tcl

generate_all_reports final
print_timing_summary
print_area_summary

run_step signoff   $SCRIPT_DIR/10_signoff_checks.tcl

# ── 최종 저장 ────────────────────────────────────────────────
save_block -as mydesign_final
write_gds  -output ${WORK_DIR}/mydesign.gds
write_def  -output ${WORK_DIR}/mydesign_final.def

log_msg "=== 전체 플로우 완료 ==="
close $LOG_FILE
