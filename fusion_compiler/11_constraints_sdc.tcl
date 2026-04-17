##############################################################
# 11_constraints_sdc.tcl
# SDC 제약 조건 예제 (Synopsys Design Constraints)
##############################################################

# ── 클록 정의 ────────────────────────────────────────────────
# 기본 클록 (1GHz = 1000ps)
create_clock \
    -name clk \
    -period 1.000 \
    -waveform {0.0 0.5} \
    [get_ports clk]

# 파생 클록 (분주)
create_generated_clock \
    -name clk_div2 \
    -source [get_ports clk] \
    -divide_by 2 \
    [get_pins u_clkdiv/clk_out]

# 가상 클록 (I/O 타이밍용)
create_clock \
    -name virt_clk \
    -period 1.000

# DDR 클록 (양쪽 에지)
create_clock \
    -name ddr_clk \
    -period 2.000 \
    -waveform {0.0 1.0} \
    [get_ports ddr_clk]

# ── 클록 불확실성 ────────────────────────────────────────────
set_clock_uncertainty \
    -setup 0.05 \
    [get_clocks clk]

set_clock_uncertainty \
    -hold  0.03 \
    [get_clocks clk]

# 클록 간 불확실성 (크로스 도메인)
set_clock_uncertainty \
    -setup 0.10 \
    -from  [get_clocks clk] \
    -to    [get_clocks clk_div2]

# ── 클록 레이턴시 ────────────────────────────────────────────
set_clock_latency \
    -source 0.2 \
    [get_clocks clk]

set_clock_latency \
    0.5 \
    [get_clocks clk]

# ── 입력 지연 ────────────────────────────────────────────────
# 외부에서 들어오는 신호가 클록 이후 얼마나 늦게 도착하는가
set_input_delay \
    -max 0.3 \
    -clock [get_clocks clk] \
    [get_ports {data_in[*] valid_in}]

set_input_delay \
    -min 0.1 \
    -clock [get_clocks clk] \
    [get_ports {data_in[*] valid_in}]

# ── 출력 지연 ────────────────────────────────────────────────
set_output_delay \
    -max 0.2 \
    -clock [get_clocks clk] \
    [get_ports {data_out[*] valid_out}]

set_output_delay \
    -min -0.05 \
    -clock [get_clocks clk] \
    [get_ports {data_out[*] valid_out}]

# ── 드라이빙 셀 / 부하 ───────────────────────────────────────
set_driving_cell \
    -lib_cell BUF_X8 \
    -pin      Z \
    [all_inputs]

set_load \
    -pin_load 0.05 \
    [all_outputs]

# ── 경로 예외 설정 ───────────────────────────────────────────
# 멀티사이클 패스
set_multicycle_path \
    -setup 2 \
    -from  [get_cells u_slow_path/*] \
    -to    [get_cells u_slow_reg/*]

set_multicycle_path \
    -hold  1 \
    -from  [get_cells u_slow_path/*] \
    -to    [get_cells u_slow_reg/*]

# 폴스 패스 (타이밍 분석 무시)
set_false_path \
    -from  [get_clocks clk] \
    -to    [get_clocks clk_div2]

# 스캔 경로 폴스
set_false_path \
    -from [get_ports scan_in] \
    -to   [get_ports scan_out]

# 리셋 비동기 폴스
set_false_path \
    -from [get_ports rst_n]

# 최대 경로 지연 (스펙 설정)
set_max_delay \
    -datapath_only 2.0 \
    -from [get_clocks clk] \
    -to   [get_clocks clk_div2]

# ── 버스 스키우 ─────────────────────────────────────────────
set_bus_skew \
    -max 0.1 \
    [get_ports {data_out[*]}]

# ── 전환 / 팬아웃 제한 ───────────────────────────────────────
set_max_transition 0.15 [current_design]
set_max_fanout     32   [current_design]
set_max_capacitance 0.5 [current_design]

# ── 설계 규칙 제약 ───────────────────────────────────────────
set_drive_strength_scaling_factor 1.0

# ── 클록 그룹 ────────────────────────────────────────────────
# 비동기 클록 도메인 간 타이밍 분석 제외
set_clock_groups \
    -asynchronous \
    -group [get_clocks clk] \
    -group [get_clocks {clk_div2 ddr_clk}]

# ── 제약 확인 ────────────────────────────────────────────────
check_timing -verbose
report_clock -all -nosplit

puts "INFO: SDC constraints loaded."
