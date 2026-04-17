##############################################################
# 14_scan_dft.tcl
# DFT (Design For Test) – 스캔 체인 삽입 및 검증
##############################################################

# ── 스캔 스타일 설정 ─────────────────────────────────────────
set_scan_configuration \
    -style               multiplexed_flip_flop \
    -clock_mixing        no_mix \
    -chain_count         32 \
    -add_lockup_latch    true

# ── 테스트 포트 설정 ─────────────────────────────────────────
set_dft_signal \
    -view spec \
    -type ScanClock \
    -port [get_ports clk] \
    -timing {45 55}

set_dft_signal \
    -view spec \
    -type ScanEnable \
    -port [get_ports scan_en] \
    -active_state 1

set_dft_signal \
    -view spec \
    -type ScanDataIn \
    -port [get_ports scan_in[*]]

set_dft_signal \
    -view spec \
    -type ScanDataOut \
    -port [get_ports scan_out[*]]

set_dft_signal \
    -view spec \
    -type Reset \
    -port [get_ports rst_n] \
    -active_state 0

# ── 테스트 모드 ──────────────────────────────────────────────
set_dft_signal \
    -view spec \
    -type TestMode \
    -port [get_ports test_mode] \
    -active_state 1

# ── ATPG 전처리 체크 ─────────────────────────────────────────
dft_drc \
    -verbose \
    > ${RPTS_DIR}/dft_drc_pre.rpt

# ── 스캔 체인 삽입 ───────────────────────────────────────────
insert_dft

# ── 스캔 삽입 후 DRC ─────────────────────────────────────────
dft_drc \
    -verbose \
    > ${RPTS_DIR}/dft_drc_post.rpt

# ── ATPG용 STIL / SPF 내보내기 ───────────────────────────────
write_test_protocol \
    -output ${WORK_DIR}/mydesign.stil \
    -format  stil

write_scan_def \
    -output ${WORK_DIR}/mydesign_scan.def

# ── 스캔 체인 리포트 ─────────────────────────────────────────
report_scan_chains  -nosplit > ${RPTS_DIR}/scan_chains.rpt
report_dft_summary  -nosplit > ${RPTS_DIR}/dft_summary.rpt

# ── 경계 스캔 (JTAG / IEEE 1149.1) ──────────────────────────
proc setup_jtag {} {
    set_bscan_configuration \
        -standard 1149.1 \
        -tck_port  TCK \
        -tdi_port  TDI \
        -tdo_port  TDO \
        -tms_port  TMS \
        -trst_port TRST_N

    insert_bscan
    report_bscan -nosplit > ${::RPTS_DIR}/bscan.rpt
    puts "INFO: JTAG boundary scan inserted."
}

# ── 메모리 BIST 설정 ─────────────────────────────────────────
proc setup_mbist {} {
    create_mbist_controller \
        -name mbist_ctrl \
        -memories [get_cells -hierarchical -filter "is_memory==true"] \
        -algorithm march_lrd

    insert_mbist

    report_mbist -nosplit > ${::RPTS_DIR}/mbist.rpt
    puts "INFO: Memory BIST inserted."
}

# setup_jtag
# setup_mbist

puts "INFO: DFT/Scan script loaded."
