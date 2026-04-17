##############################################################
# 12_upf_low_power.tcl
# UPF 기반 저전력 설계 (Multi-Voltage / Power Gating)
##############################################################

# ── 전력 도메인 정의 ─────────────────────────────────────────
create_power_domain PD_TOP \
    -elements {.}

create_power_domain PD_CPU \
    -elements {u_cpu} \
    -shutoff_condition {!u_pmu/cpu_active}

create_power_domain PD_MEM \
    -elements {u_sram_4kx32 u_sram_8kx32}

create_power_domain PD_IO \
    -elements {u_io_ring}

# ── 전원 공급 설정 ────────────────────────────────────────────
# 메인 전원 포트
create_supply_port VDD  -direction in -domain PD_TOP
create_supply_port VSS  -direction in -domain PD_TOP

# 전원 네트
create_supply_net  VDD      -domain PD_TOP
create_supply_net  VSS      -domain PD_TOP
create_supply_net  VDD_CPU  -domain PD_CPU
create_supply_net  VDD_MEM  -domain PD_MEM

connect_supply_net VDD     -ports {VDD}
connect_supply_net VSS     -ports {VSS}
connect_supply_net VDD_CPU -domain PD_CPU -pg_pin VDD
connect_supply_net VDD_MEM -domain PD_MEM -pg_pin VDD

# ── 전원 스위치 (Power Switch) ────────────────────────────────
create_power_switch u_sw_cpu \
    -domain PD_CPU \
    -input_supply_port  {vin  VDD} \
    -output_supply_port {vout VDD_CPU} \
    -control_port       {en   u_pmu/cpu_pwr_en} \
    -on_state           {on   vin  {en}} \
    -off_state          {off      {!en}}

# ── 아이솔레이션 셀 ─────────────────────────────────────────
set_isolation iso_cpu \
    -domain       PD_CPU \
    -isolation_power_net VDD \
    -isolation_ground_net VSS \
    -clamp_value  0 \
    -applies_to   outputs \
    -location     parent

map_isolation_cell iso_cpu \
    -lib_cells [get_lib_cells */ISO_X*]

# ── 레벨 시프터 ──────────────────────────────────────────────
set_level_shifter ls_cpu_to_top \
    -domain      PD_CPU \
    -applies_to  outputs \
    -direction   both

map_level_shifter_cell ls_cpu_to_top \
    -lib_cells [get_lib_cells */LS_LH* */LS_HL*]

# ── 리텐션 레지스터 ──────────────────────────────────────────
set_retention ret_cpu \
    -domain PD_CPU \
    -retention_power_net VDD \
    -retention_ground_net VSS \
    -save_signal   {u_pmu/save  posedge} \
    -restore_signal {u_pmu/restore posedge}

map_retention_cell ret_cpu \
    -lib_cells [get_lib_cells */RSDFF*]

# ── UPF 읽기 / 적용 ──────────────────────────────────────────
proc load_upf_and_verify { upf_file } {
    load_upf $upf_file

    check_upf_supply_network
    report_power_domains -nosplit
    report_power_switches -nosplit

    check_isolation_cells   -verbose
    check_level_shifters    -verbose
    check_retention_cells   -verbose

    puts "INFO: UPF $upf_file loaded and verified."
}

# ── 전력 의도 확인 리포트 ────────────────────────────────────
proc report_low_power_summary {} {
    report_power_domains     -nosplit > ${::RPTS_DIR}/upf_domains.rpt
    report_power_switches    -nosplit > ${::RPTS_DIR}/upf_switches.rpt
    report_isolation_cells   -nosplit > ${::RPTS_DIR}/upf_isolation.rpt
    report_level_shifters    -nosplit > ${::RPTS_DIR}/upf_ls.rpt
    report_retention_cells   -nosplit > ${::RPTS_DIR}/upf_retention.rpt
    puts "INFO: Low power reports generated."
}

# load_upf_and_verify ${UPF_DIR}/top.upf
# report_low_power_summary

puts "INFO: UPF low-power script loaded."
