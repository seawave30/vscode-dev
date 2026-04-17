##############################################################
# 10_signoff_checks.tcl
# 사인오프(Signoff) 체크 – DRC / LVS / ERC / 전력
##############################################################

# ── 1. 설계 규칙 검사 (DRC) ──────────────────────────────────
proc run_drc { {effort high} } {
    verify_drc \
        -effort  $effort \
        -cell    mydesign \
        > ${::RPTS_DIR}/signoff_drc.rpt

    set viols [get_drc_violations]
    set cnt   [llength $viols]
    puts "INFO: DRC 위반 수: $cnt"
    if { $cnt > 0 } {
        foreach v [lrange $viols 0 9] {
            puts "  [get_attribute $v rule_name] @ \
                  [get_attribute $v bbox]"
        }
    }
    return $cnt
}

# ── 2. LVS 검사 ──────────────────────────────────────────────
proc run_lvs {} {
    verify_lvs \
        -netlist   mydesign \
        -layout    mydesign \
        -report    ${::RPTS_DIR}/signoff_lvs.rpt

    puts "INFO: LVS complete. See signoff_lvs.rpt"
}

# ── 3. ERC (Electrical Rule Check) ───────────────────────────
proc run_erc {} {
    check_voltage_areas
    check_level_shifters -verbose
    check_isolation_cells -verbose
    check_retention_cells -verbose

    report_erc -nosplit > ${::RPTS_DIR}/signoff_erc.rpt
    puts "INFO: ERC complete."
}

# ── 4. 사인오프 타이밍 (StarRC → PrimeTime 연계) ─────────────
proc export_for_primetime {} {
    # SPEF 내보내기
    write_parasitics \
        -format    spef \
        -output    ${::WORK_DIR}/mydesign.spef \
        -compress  gzip

    # SDF 내보내기
    write_sdf \
        -output ${::WORK_DIR}/mydesign.sdf \
        -edges  transition

    # 넷리스트 내보내기
    write_verilog \
        -output ${::WORK_DIR}/mydesign_final.v \
        -no_unconnected_nets \
        -no_empty_modules

    # SDC 내보내기
    write_sdc \
        -output ${::WORK_DIR}/mydesign_final.sdc

    puts "INFO: Exported SPEF / SDF / Verilog / SDC for PrimeTime."
}

# ── 5. GDS 내보내기 ───────────────────────────────────────────
proc export_gds {} {
    write_gds \
        -output  ${::WORK_DIR}/mydesign.gds \
        -format  GDSII \
        -cell    mydesign

    puts "INFO: GDS written → ${::WORK_DIR}/mydesign.gds"
}

# ── 6. DEF 내보내기 (P&R 결과물) ─────────────────────────────
proc export_def {} {
    write_def \
        -output  ${::WORK_DIR}/mydesign_final.def \
        -include_physical_status {placed fixed cover}

    puts "INFO: DEF written → ${::WORK_DIR}/mydesign_final.def"
}

# ── 7. 사인오프 체크리스트 ───────────────────────────────────
proc run_signoff_checklist {} {
    puts "=== Signoff Checklist ==="

    # DRC
    set drc_cnt [run_drc]
    puts "\[DRC\]  위반: $drc_cnt"

    # LVS
    run_lvs
    puts "\[LVS\]  완료"

    # ERC
    run_erc
    puts "\[ERC\]  완료"

    # 타이밍
    update_timing -full
    set wns [get_attribute [get_timing_paths -max_paths 1 \
        -delay_type max] slack]
    set whs [get_attribute [get_timing_paths -max_paths 1 \
        -delay_type min] slack]
    puts "\[타이밍\] Setup WNS=$wns  Hold WNS=$whs"

    # 전력
    update_power
    report_power -nosplit > ${::RPTS_DIR}/signoff_power.rpt
    puts "\[전력\]  리포트 완료"

    # 출력물 생성
    export_for_primetime
    export_gds
    export_def

    puts "=== Signoff 완료 ==="
}

# run_signoff_checklist
puts "INFO: Signoff checks script loaded."
