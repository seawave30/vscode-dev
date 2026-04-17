# Fusion Compiler Tcl 스크립트 모음

Synopsys Fusion Compiler (fc_shell) 에서 사용하는 P&R 플로우 스크립트입니다.

## 파일 목록

| 파일 | 내용 |
|------|------|
| `01_design_setup.tcl`    | 디자인 초기화, 라이브러리·NDM 설정, RTL 읽기 |
| `02_mcmm_setup.tcl`      | Multi-Corner Multi-Mode 코너/모드/분석뷰 설정 |
| `03_floorplan.tcl`       | 플로어플랜, 전원 링/스트랩, 매크로 배치 |
| `04_placement.tcl`       | 셀 배치, 배치 블로케이지, 필러 삽입 |
| `05_cts.tcl`             | 클록 트리 합성, NDR 규칙, CTS 리포트 |
| `06_routing.tcl`         | 글로벌/세부 라우팅, 안테나 수정, RC 추출 |
| `07_timing_analysis.tcl` | Setup/Hold 분석, OCV, PBA, CDC 체크 |
| `08_power_analysis.tcl`  | SAIF 기반 동적 전력, 클록 게이팅, VT 스와핑 |
| `09_eco_flow.tcl`        | 타이밍/기능/마스크 ECO 플로우 |
| `10_signoff_checks.tcl`  | DRC, LVS, ERC, GDS/DEF/SPEF 출력 |
| `11_constraints_sdc.tcl` | SDC 제약 (클록, 입출력, MCP, 폴스패스) |
| `12_upf_low_power.tcl`   | UPF 전력 도메인, 파워스위치, 아이솔레이션 |
| `13_reports_utils.tcl`   | 전체 리포트 생성, QoR 히스토리, 유틸 함수 |
| `14_scan_dft.tcl`        | 스캔 체인 삽입, JTAG, Memory BIST |
| `15_hierarchical_flow.tcl` | 블록/탑 계층 컴파일, ILM/ETM 추출 |
| `16_advanced_opt.tcl`    | 재타이밍, VT 최적화, PPA 스위프 |
| `17_run_all.tcl`         | 전체 플로우 통합 실행 (단계별 ON/OFF 제어) |

## 실행 방법

```tcsh
# 전체 플로우
fc_shell -f 17_run_all.tcl | tee run.log

# 개별 단계
fc_shell
fc_shell> source 01_design_setup.tcl
fc_shell> source 02_mcmm_setup.tcl
...
```

## 주요 변수 (17_run_all.tcl 수정)

```tcl
set PROJ_ROOT  "/proj/mydesign"   ;# 프로젝트 루트
set PDK_ROOT   "/pdk/7nm"         ;# PDK 경로
set STEPS(cts) 0                  ;# 해당 단계 건너뛰기
```
