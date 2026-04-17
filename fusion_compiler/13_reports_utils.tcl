##############################################################
# 13_reports_utils.tcl
# 자주 쓰는 리포트 & 유틸리티 프로시저 모음
##############################################################

# ── 전체 리포트 한 번에 생성 ─────────────────────────────────
proc generate_all_reports { {tag ""} } {
    set suffix [expr {$tag eq "" ? "" : "_$tag"}]
    set r ${::RPTS_DIR}

    update_timing -full
    update_power

    # 타이밍
    report_timing -max -max_paths 100 -nosplit > ${r}/setup${suffix}.rpt
    report_timing -min -max_paths 100 -nosplit > ${r}/hold${suffix}.rpt
    report_constraint -all_violators -nosplit  > ${r}/viols${suffix}.rpt

    # 면적
    report_area           -nosplit > ${r}/area${suffix}.rpt
    report_cell_usage     -nosplit > ${r}/cell_usage${suffix}.rpt
    report_reference      -nosplit > ${r}/reference${suffix}.rpt

    # 전력
    report_power          -nosplit > ${r}/power${suffix}.rpt
    report_power -hierarchy -nosplit > ${r}/power_hier${suffix}.rpt

    # 클록
    report_clock_tree     -summary  -nosplit > ${r}/cts${suffix}.rpt
    report_clock_timing   -type skew -nosult > ${r}/skew${suffix}.rpt

    # 배선
    report_congestion     -by_layer -nosplit > ${r}/congestion${suffix}.rpt
    report_route_drc      -nosplit           > ${r}/drc${suffix}.rpt

    puts "INFO: All reports generated with suffix='$suffix'."
}

# ── WNS / TNS / 위반 수 요약 출력 ───────────────────────────
proc print_timing_summary { {view ""} } {
    set opts {}
    if { $view ne "" } { lappend opts -view $view }

    foreach type {max min} {
        set paths [get_timing_paths -delay_type $type \
            -max_paths 999 -slack_lesser_than 0 {*}$opts]
        set cnt  [llength $paths]
        if { $cnt == 0 } {
            set wns 0
            set tns 0
        } else {
            set wns [get_attribute [lindex $paths 0] slack]
            set tns 0
            foreach p $paths {
                set tns [expr {$tns + [get_attribute $p slack]}]
            }
        }
        set label [expr {$type eq "max" ? "Setup" : "Hold "}]
        puts [format "  %-6s  WNS=%7.3f  TNS=%9.3f  Violations=%d" \
            $label $wns $tns $cnt]
    }
}

# ── 면적 요약 ────────────────────────────────────────────────
proc print_area_summary {} {
    set rpt [report_area -nosplit -return_string]
    foreach line [split $rpt "\n"] {
        if {[regexp {Total|Combinational|Noncombinational|Net Interconnect} $line]} {
            puts $line
        }
    }
}

# ── 혼잡도 핫스팟 찾기 ───────────────────────────────────────
proc find_congestion_hotspots { {threshold 0.85} } {
    set bins [get_congestion_map -threshold $threshold]
    puts "INFO: 혼잡 영역 (>= ${threshold}):"
    foreach bin $bins {
        puts "  [get_attribute $bin bbox]  \
              overflow=[get_attribute $bin overflow]"
    }
}

# ── 셀 통계 ──────────────────────────────────────────────────
proc cell_stats {} {
    set all_cells [get_cells -hierarchical *]
    set total     [llength $all_cells]

    set buf_cnt   [llength [get_cells -hier -filter "ref_name=~BUF*"]]
    set inv_cnt   [llength [get_cells -hier -filter "ref_name=~INV*"]]
    set ff_cnt    [llength [get_cells -hier -filter "ref_name=~DFF*"]]
    set clkbuf_cnt [llength [get_cells -hier -filter "ref_name=~CLKBUF*"]]

    puts "  전체 셀: $total"
    puts "  버퍼:    $buf_cnt ([format %.1f [expr {100.0*$buf_cnt/$total}]]%)"
    puts "  인버터:  $inv_cnt"
    puts "  플립플롭: $ff_cnt"
    puts "  클록버퍼: $clkbuf_cnt"
}

# ── 넷 연결 정보 확인 ────────────────────────────────────────
proc inspect_net { net_name } {
    set net [get_nets $net_name]
    if { $net eq "" } { puts "ERROR: Net '$net_name' not found"; return }

    puts "Net: $net_name"
    puts "  Driver : [get_attribute $net drivers]"
    puts "  Fanout : [get_attribute $net fanout]"
    puts "  Length : [get_attribute $net total_wire_length]"
    puts "  Loads  : [get_attribute $net loads]"
}

# ── 타이밍 위반 경로 자동 분류 ───────────────────────────────
proc classify_violations { {max_paths 200} } {
    set paths [get_timing_paths \
        -delay_type max \
        -max_paths $max_paths \
        -slack_lesser_than 0]

    array set by_module {}
    foreach p $paths {
        set ep [get_attribute $p endpoint]
        set cell [get_cells -of_objects [get_pins $ep]]
        set mod  [get_attribute $cell full_name]
        set top  [lindex [split $mod "/"] 0]
        incr by_module($top)
    }

    puts "모듈별 Setup 위반:"
    foreach {mod cnt} [array get by_module] {
        puts "  $mod : $cnt 경로"
    }
}

# ── 타이밍 QoR 히스토리 기록 ────────────────────────────────
proc log_qor_snapshot { tag } {
    set ts  [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
    set log [open "${::RPTS_DIR}/qor_history.log" a]
    puts $log "[$ts] $tag"

    update_timing -full
    set paths_s [get_timing_paths -delay_type max -max_paths 1]
    set paths_h [get_timing_paths -delay_type min -max_paths 1]
    set wns_s [expr {[llength $paths_s] > 0 ? \
        [get_attribute [lindex $paths_s 0] slack] : 0}]
    set wns_h [expr {[llength $paths_h] > 0 ? \
        [get_attribute [lindex $paths_h 0] slack] : 0}]
    puts $log "  Setup WNS=$wns_s  Hold WNS=$wns_h"
    close $log
    puts "INFO: QoR snapshot '$tag' recorded."
}

puts "INFO: Reports & utilities loaded."
