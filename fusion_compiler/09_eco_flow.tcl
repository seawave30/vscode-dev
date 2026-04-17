##############################################################
# 09_eco_flow.tcl
# ECO (Engineering Change Order) 플로우
##############################################################

# ── ECO 타입 ─────────────────────────────────────────────────
# 1) 타이밍 ECO  2) 기능 ECO  3) 마스크-friendly ECO

# ── 1. 타이밍 ECO (Setup/Hold 수정) ─────────────────────────
proc run_timing_eco { mode } {
    if { $mode eq "setup" } {
        # 셀 업사이징으로 setup 개선
        size_cell \
            -delay_type max \
            -effort     high
        # 버퍼 삽입
        buffer_path -delay_type max -effort high
    } elseif { $mode eq "hold" } {
        # hold 버퍼 삽입
        set_fix_hold [all_clocks]
        fix_hold_violations \
            -buffer_list {CLKBUF_X4 BUF_X4 BUF_X8}
    }
    report_timing -delay_type $mode -max_paths 20 -nosplit
}

# ── 2. 기능 ECO (넷리스트 변경) ──────────────────────────────
proc apply_functional_eco { eco_file } {
    # 기존 저장점
    save_block -as pre_eco_backup

    # eco 파일 적용 (Verilog 패치)
    read_verilog $eco_file
    uniquify_fp -dont_skip_empty_designs

    # 재배치/재라우팅
    legalize_placement
    route_eco \
        -open_net_driven true \
        -fix_drc         true
    puts "INFO: Functional ECO applied from $eco_file"
}

# ── 3. 마스크-Friendly ECO (금속층만 변경) ───────────────────
proc mask_eco { net_changes } {
    # 하위 레이어(poly, diffusion) 변경 없이 금속층 조정
    set_eco_options \
        -eco_mode mask_eco \
        -allowed_layers {M1 M2 M3 M4 M5}

    foreach {old_net new_net} $net_changes {
        eco_netlist \
            -source_net $old_net \
            -target_net $new_net
    }
    route_eco -fix_drc true
    puts "INFO: Mask ECO complete."
}

# ── 4. 클록 스큐 ECO ─────────────────────────────────────────
proc clock_eco {} {
    report_clock_timing -type skew -nosplit
    optimize_clock_tree \
        -fix_hold_violations \
        -buffer_list {CLKBUF_X4 CLKBUF_X8 CLKBUF_X16}
    report_clock_timing -type skew -nosplit
}

# ── 5. 크로스토크 ECO ────────────────────────────────────────
proc fix_crosstalk {} {
    analyze_crosstalk_impact -verbose
    # 스페이서 셀 삽입 / 레이어 변경
    route_opt -effort medium
}

# ── ECO 후 검증 ──────────────────────────────────────────────
proc verify_eco {} {
    check_routes  -open_nets true -short_nets true
    verify_lvs
    report_timing -delay_type max -max_paths 50 -nosplit \
        > ${::RPTS_DIR}/eco_setup.rpt
    report_timing -delay_type min -max_paths 50 -nosplit \
        > ${::RPTS_DIR}/eco_hold.rpt
    puts "INFO: ECO verification done."
}

# ── 실행 예 ──────────────────────────────────────────────────
# run_timing_eco setup
# run_timing_eco hold
# apply_functional_eco "${PROJ_ROOT}/eco/patch_v2.v"
# verify_eco

puts "INFO: ECO flow script loaded."
