##############################################################
# 16_advanced_opt.tcl
# 고급 최적화 기법 모음
##############################################################

# ── 1. 레지스터 재타이밍 ─────────────────────────────────────
proc run_retiming {} {
    set_app_options \
        -name compile.flow.enable_register_retiming \
        -value true
    set_app_options \
        -name compile.flow.retiming_effort \
        -value high

    compile_fusion -incremental -retime
    puts "INFO: Retiming complete."
}

# ── 2. 논리 복제 (Logic Duplication) ─────────────────────────
proc run_logic_duplication { fanout_threshold } {
    set high_fanout_cells [get_cells -hierarchical \
        -filter "fanout_net_count > $fanout_threshold"]

    foreach cell $high_fanout_cells {
        set cname [get_attribute $cell full_name]
        puts "  고팬아웃 셀 복제: $cname"
    }

    set_app_options \
        -name compile.flow.duplicate_logic_for_timing \
        -value true
    compile_fusion -incremental
}

# ── 3. 중요 경로 리타이밍 ────────────────────────────────────
proc retime_critical_paths { slack_threshold } {
    set paths [get_timing_paths \
        -delay_type max \
        -slack_lesser_than $slack_threshold \
        -max_paths 50]

    puts "INFO: [llength $paths]개 경로 재타이밍 대상"
    compile_fusion -incremental -retime
}

# ── 4. 고팬아웃 넷 버퍼링 ────────────────────────────────────
proc buffer_high_fanout_nets { {fanout_limit 32} } {
    set nets [get_nets -hierarchical \
        -filter "fanout_net_count > $fanout_limit"]

    puts "INFO: [llength $nets]개 고팬아웃 넷 발견"
    foreach net $nets {
        set name [get_attribute $net full_name]
        set fo   [get_attribute $net fanout_net_count]
        puts "  $name (fanout=$fo)"
    }

    # 자동 버퍼 삽입
    set_app_options \
        -name compile.flow.auto_buffer_high_fanout \
        -value true
    set_app_options \
        -name compile.flow.high_fanout_net_threshold \
        -value $fanout_limit

    compile_fusion -incremental
}

# ── 5. 신호 무결성 최적화 ────────────────────────────────────
proc optimize_signal_integrity {} {
    set_si_options \
        -delta_delay     true \
        -static_noise    true \
        -crosstalk_driven true \
        -noise_budget_ratio 0.9

    route_opt -effort medium -si_driven
    puts "INFO: SI optimization complete."
}

# ── 6. 셀 스와핑 (VT 최적화) ─────────────────────────────────
proc optimize_vt_cells { {slack_margin 0.1} } {
    # 타이밍 여유 있는 셀 → HVT (저전력)
    foreach cell [get_cells -hierarchical -filter "lib_cell.vt == LVT"] {
        set paths [get_timing_paths -through $cell -delay_type max -max_paths 1]
        if { [llength $paths] > 0 } {
            set slack [get_attribute [lindex $paths 0] slack]
            if { $slack > $slack_margin } {
                set hvt [regsub {_LVT} [get_attribute $cell ref_name] "_HVT"]
                if { [get_lib_cells */$hvt] ne "" } {
                    size_cell $cell [get_lib_cells */$hvt]
                }
            }
        }
    }
    puts "INFO: VT cell swap complete."
}

# ── 7. 레이아웃 인식 최적화 (LAO) ────────────────────────────
proc run_layout_aware_opt {} {
    set_app_options \
        -name place.common.enable_layout_aware_optimization \
        -value true

    place_opt -flow final_opto -effort high
    route_opt  -effort medium
    puts "INFO: Layout-aware optimization done."
}

# ── 8. 물리적 합성 고도화 ────────────────────────────────────
proc run_physical_synthesis {} {
    compile_fusion \
        -physical \
        -effort  high \
        -incremental false

    report_timing -max_paths 20 -nosplit
    report_area   -nosplit
    puts "INFO: Physical synthesis done."
}

# ── 9. 전력-성능-면적 (PPA) 트레이드오프 스위프 ────────────
proc ppa_sweep { efforts } {
    foreach effort $efforts {
        puts "\n=== effort=$effort ==="
        compile_fusion -effort $effort
        update_timing -full
        update_power

        set wns [get_attribute \
            [get_timing_paths -delay_type max -max_paths 1] slack]
        set area [get_attribute [current_design] area]
        puts "  WNS=$wns  Area=$area"
        log_qor_snapshot "effort_$effort"
    }
}

# ── 실행 예 ──────────────────────────────────────────────────
# run_retiming
# buffer_high_fanout_nets 64
# optimize_vt_cells 0.05
# ppa_sweep {low medium high}

puts "INFO: Advanced optimization script loaded."
