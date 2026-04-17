##############################################################
# 01_design_setup.tcl
# 디자인 초기화 및 라이브러리 설정
# Synopsys Fusion Compiler (fc_shell)
##############################################################

# ── 작업 디렉토리 구조 ──────────────────────────────────────
set PROJ_ROOT  "/proj/mydesign"
set RTL_DIR    "$PROJ_ROOT/rtl"
set SDC_DIR    "$PROJ_ROOT/constraints"
set UPF_DIR    "$PROJ_ROOT/upf"
set RPTS_DIR   "$PROJ_ROOT/rpts"
set WORK_DIR   "$PROJ_ROOT/work"

foreach dir [list $RPTS_DIR $WORK_DIR] {
    file mkdir $dir
}

# ── 공정 / 라이브러리 설정 ──────────────────────────────────
set TECH_NODE  "7nm"
set PDK_ROOT   "/pdk/${TECH_NODE}"

# 타이밍 라이브러리 (PVT 코너별)
set_app_var target_library [list \
    ${PDK_ROOT}/lib/tt_0p8v_25c.db \
    ${PDK_ROOT}/lib/ss_0p7v_125c.db \
    ${PDK_ROOT}/lib/ff_0p9v_m40c.db \
]
set_app_var synthetic_library [list \
    dw_foundation.sldb \
]
set_app_var link_library [list \
    * \
    ${PDK_ROOT}/lib/tt_0p8v_25c.db \
    ${PDK_ROOT}/lib/ss_0p7v_125c.db \
]

# 물리 라이브러리 (LEF)
set_app_var mw_reference_library [list \
    ${PDK_ROOT}/lef/tech.lef \
    ${PDK_ROOT}/lef/std_cells.lef \
    ${PDK_ROOT}/lef/macros.lef \
]

# ── 기술 파일 설정 ───────────────────────────────────────────
set_app_var mw_techfile_file   "${PDK_ROOT}/techfile/tech.tf"
set_app_var tluplus_file       "${PDK_ROOT}/tluplus/max.tluplus"
set_app_var min_tluplus_file   "${PDK_ROOT}/tluplus/min.tluplus"
set_app_var tech2itf_map_file  "${PDK_ROOT}/map/tech2itf.map"

# ── NDM (New Data Model) 라이브러리 생성 ────────────────────
set_app_options -name lib.configuration.create_analysis_views_for_each_pvt \
    -value true

create_lib \
    -technology  ${PDK_ROOT}/tech/tech.tf \
    -ref_libs    [list \
        ${PDK_ROOT}/ndm/stdcell.ndm \
        ${PDK_ROOT}/ndm/io.ndm     \
        ${PDK_ROOT}/ndm/memory.ndm \
    ] \
    ${WORK_DIR}/mydesign.ndm

# ── RTL 읽기 ────────────────────────────────────────────────
set RTL_FILES [glob -directory $RTL_DIR *.v *.sv]
read_hdl -sv $RTL_FILES

# ── 엘라보레이션 ─────────────────────────────────────────────
elaborate mydesign
link_design mydesign

# ── 체크 ────────────────────────────────────────────────────
check_design -summary
check_library

puts "INFO: Design setup complete."
