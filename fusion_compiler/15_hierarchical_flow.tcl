##############################################################
# 15_hierarchical_flow.tcl
# 계층적 설계 플로우 (Hierarchical / Block-level)
##############################################################

# ── 블록 레벨 컴파일 ─────────────────────────────────────────
proc compile_block { block_name rtl_files sdc_file } {
    set lib_name "${block_name}.ndm"
    create_lib \
        -technology ${::PDK_ROOT}/tech/tech.tf \
        -ref_libs   ${::PDK_ROOT}/ndm/stdcell.ndm \
        $lib_name

    read_hdl -sv $rtl_files
    elaborate $block_name
    link_design $block_name

    read_sdc $sdc_file

    compile_fusion -map -opt

    write_block_abstraction \
        -output ${::WORK_DIR}/${block_name}_abstract.ndm

    puts "INFO: Block '$block_name' compiled."
    return ${::WORK_DIR}/${block_name}_abstract.ndm
}

# ── 탑 레벨 어셈블리 ─────────────────────────────────────────
proc assemble_top { top_name block_libs } {
    set ref_libs [list ${::PDK_ROOT}/ndm/stdcell.ndm]
    foreach lib $block_libs { lappend ref_libs $lib }

    create_lib \
        -technology ${::PDK_ROOT}/tech/tech.tf \
        -ref_libs   $ref_libs \
        ${top_name}.ndm

    read_hdl -sv ${::RTL_DIR}/${top_name}.sv
    elaborate $top_name
    link_design $top_name

    puts "INFO: Top '$top_name' assembled."
}

# ── 블록 예산 할당 (Budget) ──────────────────────────────────
proc allocate_budgets { block_name } {
    # 입력 지연 예산
    set_input_delay \
        -max 0.1 \
        -clock [get_clocks clk] \
        [get_ports [get_pins ${block_name}/* -filter "direction==in"]]

    # 출력 지연 예산
    set_output_delay \
        -max 0.1 \
        -clock [get_clocks clk] \
        [get_ports [get_pins ${block_name}/* -filter "direction==out"]]
}

# ── 탑-다운 타이밍 바짐 ─────────────────────────────────────
proc extract_block_timing { block_name } {
    set_timing_path_group \
        -name block_${block_name} \
        -from [get_cells ${block_name}] \
        -to   [get_cells ${block_name}]

    report_timing \
        -group block_${block_name} \
        -max_paths 20 \
        -nosplit > ${::RPTS_DIR}/${block_name}_timing.rpt
}

# ── 인터페이스 타이밍 체크 ───────────────────────────────────
proc check_block_interface { block_name } {
    set pins [get_pins ${block_name}/*]
    foreach pin $pins {
        set slack [get_attribute \
            [get_timing_paths -through $pin -max_paths 1] slack]
        if { $slack < 0 } {
            puts "VIOLATED: [get_attribute $pin full_name] slack=$slack"
        }
    }
}

# ── ILM (Interface Logic Model) 추출 ─────────────────────────
proc extract_ilm { block_name } {
    # ILM: 블록 내부를 추상화해 상위 타이밍 분석 속도 개선
    extract_interface_timing_model \
        -cell   $block_name \
        -output ${::WORK_DIR}/${block_name}.ilm

    puts "INFO: ILM extracted → ${::WORK_DIR}/${block_name}.ilm"
}

# ── ETM (Extracted Timing Model) ─────────────────────────────
proc extract_etm { block_name } {
    extract_timing_model \
        -cell   $block_name \
        -format db \
        -output ${::WORK_DIR}/${block_name}_etm.db

    puts "INFO: ETM extracted → ${::WORK_DIR}/${block_name}_etm.db"
}

# ── 실행 예 ──────────────────────────────────────────────────
# set cpu_lib [compile_block "u_cpu" \
#     [glob ${RTL_DIR}/cpu/*.sv] \
#     ${SDC_DIR}/cpu.sdc]
# set mem_lib [compile_block "u_mem" \
#     [glob ${RTL_DIR}/mem/*.sv] \
#     ${SDC_DIR}/mem.sdc]
# assemble_top "chip_top" [list $cpu_lib $mem_lib]

puts "INFO: Hierarchical flow script loaded."
