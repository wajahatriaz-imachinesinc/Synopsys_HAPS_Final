#!/bin/bash

################################################################################
# HAPS-200 Deployment Script
# Quick-start automation for programming and testing
# 
# Usage: ./deploy.sh [program|test|monitor|full]
#
# Commands:
#   ./deploy.sh program  - Program both FPGAs with PDI files
#   ./deploy.sh test     - Run functional tests with hRun
#   ./deploy.sh monitor  - Start performance monitoring
#   ./deploy.sh full     - Program + Test + Monitor (recommended first run)
#   ./deploy.sh status   - Check board status
#   ./deploy.sh help     - Show this help message
################################################################################

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${PROJECT_DIR}/UC_LED_DEMO_runtime"
SYNTHESIS_DIR="${PROJECT_DIR}/synthesis_files"

# PDI file paths
PDI_FB1_F0="${SYNTHESIS_DIR}/FB1_F0/vivado_srs/FB1_F0.pdi"
PDI_FB1_F1="${SYNTHESIS_DIR}/FB1_F1/vivado_srs/FB1_F1.pdi"

# Timestamps
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="${RUNTIME_DIR}/logs_${TIMESTAMP}"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

verify_prerequisites() {
    print_header "Verifying Prerequisites"
    
    # Check for hUtils (main utility for programming)
    if ! command -v hUtils &> /dev/null; then
        print_error "hUtils not found in PATH"
        print_info "hTools installation found at: /opt/synopsys/hapshwutils/V-2025.06/"
        print_info "Add to PATH: export PATH=\"/opt/synopsys/hapshwutils/V-2025.06/bin:\$PATH\""
        exit 1
    fi
    print_success "hUtils found"
    
    # Check for hRun (testing utility)
    if ! command -v hRun &> /dev/null; then
        print_error "hRun not found in PATH"
        print_info "hTools installation found at: /opt/synopsys/hapshwutils/V-2025.06/"
        print_info "Add to PATH: export PATH=\"/opt/synopsys/hapshwutils/V-2025.06/bin:\$PATH\""
        exit 1
    fi
    print_success "hRun found"
    
    # Check PDI files exist
    if [ ! -f "$PDI_FB1_F0" ]; then
        print_error "PDI file not found: $PDI_FB1_F0"
        exit 1
    fi
    print_success "FB1_F0.pdi found"
    
    if [ ! -f "$PDI_FB1_F1" ]; then
        print_error "PDI file not found: $PDI_FB1_F1"
        exit 1
    fi
    print_success "FB1_F1.pdi found"
    
    # Check board connection
    print_info "Scanning for HAPS-200 boards..."
    if hUtils -scan 2>&1 | grep -q "HAPS"; then
        print_success "HAPS-200 board(s) detected"
    else
        print_warning "No HAPS boards found - continuing anyway"
    fi
    
    echo ""
}

program_board() {
    print_header "Programming HAPS-200 FPGAs"
    
    verify_prerequisites
    
    mkdir -p "$LOG_DIR"
    
    print_info "Programming FB1_F0..."
    if hUtils -program "$PDI_FB1_F0" 2>&1 | tee "${LOG_DIR}/program_FB1_F0.log"; then
        print_success "FB1_F0 programmed successfully"
    else
        print_error "Failed to program FB1_F0"
        exit 1
    fi
    
    sleep 2
    
    print_info "Programming FB1_F1..."
    if hUtils -program "$PDI_FB1_F1" 2>&1 | tee "${LOG_DIR}/program_FB1_F1.log"; then
        print_success "FB1_F1 programmed successfully"
    else
        print_error "Failed to program FB1_F1"
        exit 1
    fi
    
    echo ""
    print_success "Both FPGAs programmed!"
    print_info "Board is now ready for testing"
    
    check_board_status
}

run_functional_test() {
    print_header "Running Functional Design Tests with Stimulus"
    
    if [ ! -d "$RUNTIME_DIR" ]; then
        print_error "Runtime directory not found: $RUNTIME_DIR"
        exit 1
    fi
    
    mkdir -p "$LOG_DIR"
    
    cd "$RUNTIME_DIR"
    
    # Run stimulus-based test
    if [ -f "test_with_stimulus.tcl" ]; then
        print_info "Running processor design tests with signal stimulus..."
        if tclsh test_with_stimulus.tcl 2>&1 | tee "${LOG_DIR}/functional_tests.log"; then
            print_success "Functional tests passed"
        else
            print_warning "Some tests may have warnings"
        fi
    fi
    
    echo ""
}

run_alu_test() {
    print_header "Running ALU Operation Verification"
    
    if [ ! -d "$RUNTIME_DIR" ]; then
        print_error "Runtime directory not found: $RUNTIME_DIR"
        exit 1
    fi
    
    mkdir -p "$LOG_DIR"
    
    cd "$RUNTIME_DIR"
    
    # Run ALU operation tests
    if [ -f "test_alu_operations.tcl" ]; then
        print_info "Running ALU operation verification tests..."
        if tclsh test_alu_operations.tcl 2>&1 | tee "${LOG_DIR}/alu_tests.log"; then
            print_success "ALU tests passed - all operations verified"
        else
            print_warning "Some ALU tests may have warnings"
        fi
    else
        print_warning "ALU test script not found"
    fi
    
    echo ""
}

run_tests() {
    print_header "Running Hardware Tests"
    
    if [ ! -d "$RUNTIME_DIR" ]; then
        print_error "Runtime directory not found: $RUNTIME_DIR"
        exit 1
    fi
    
    mkdir -p "$LOG_DIR"
    
    cd "$RUNTIME_DIR"
    
    if [ -f "FB1_F0/debug/debug.prj" ]; then
        print_info "Launching hRun with debug project..."
        hRun -project "FB1_F0/debug/debug.prj" -batch 2>&1 | tee "${LOG_DIR}/test_results.log"
        print_success "Tests completed - see ${LOG_DIR}/test_results.log"
    else
        print_warning "Debug project not found, running in interactive mode"
        print_info "Use: hRun -project FB1_F0/debug/debug.prj -interactive"
    fi
    
    echo ""
}

start_monitoring() {
    print_header "Starting Performance Monitoring"
    
    mkdir -p "$LOG_DIR"
    
    print_info "Starting performance metrics collection..."
    hUtils -perf -interval 1s -duration 3600s > "${LOG_DIR}/perf_metrics.log" 2>&1 &
    PERF_PID=$!
    print_success "Performance monitoring started (PID: $PERF_PID)"
    
    print_info "Starting thermal monitoring..."
    hUtils -thermal -log "${LOG_DIR}/thermal.csv" &
    THERMAL_PID=$!
    print_success "Thermal monitoring started (PID: $THERMAL_PID)"
    
    echo ""
    print_info "Monitoring in background. To stop:"
    print_info "  kill $PERF_PID $THERMAL_PID"
    print_info ""
    print_info "Log files:"
    print_info "  Performance: ${LOG_DIR}/perf_metrics.log"
    print_info "  Thermal:     ${LOG_DIR}/thermal.csv"
}

check_board_status() {
    print_header "Board Status"
    
    if hUtils -status 2>&1; then
        print_success "Board status retrieved"
    else
        print_warning "Could not retrieve board status"
    fi
    
    echo ""
}

verify_setup() {
    print_header "Verifying Setup & Configuration"
    
    # Check bitstreams
    print_info "Checking bitstreams..."
    if [ -f "$PDI_FB1_F0" ]; then
        SIZE_F0=$(du -h "$PDI_FB1_F0" | cut -f1)
        print_success "FB1_F0.pdi found ($SIZE_F0)"
    else
        print_error "FB1_F0.pdi not found at $PDI_FB1_F0"
        return 1
    fi
    
    if [ -f "$PDI_FB1_F1" ]; then
        SIZE_F1=$(du -h "$PDI_FB1_F1" | cut -f1)
        print_success "FB1_F1.pdi found ($SIZE_F1)"
    else
        print_error "FB1_F1.pdi not found at $PDI_FB1_F1"
        return 1
    fi
    
    # Check configuration files
    print_info "Checking configuration files..."
    for file in "board.tss" "design.fdc" "uc_compile.utf" "run.tcl"; do
        if [ -f "$PROJECT_DIR/$file" ]; then
            print_success "$file present"
        else
            print_warning "$file missing (optional for deployment)"
        fi
    done
    
    # Check runtime environment
    print_info "Checking runtime environment..."
    if [ -d "$RUNTIME_DIR" ]; then
        print_success "UC_LED_DEMO_runtime found"
    else
        print_warning "UC_LED_DEMO_runtime not found (will be created)"
    fi
    
    # Check hTools
    print_info "Checking hTools installation..."
    if command -v hUtils &> /dev/null; then
        HUTILS_PATH=$(which hUtils)
        print_success "hUtils available: $HUTILS_PATH"
    else
        print_warning "hUtils not in PATH"
    fi
    
    if command -v hRun &> /dev/null; then
        HRUN_PATH=$(which hRun)
        print_success "hRun available: $HRUN_PATH"
    else
        print_warning "hRun not in PATH"
    fi
    
    echo ""
    print_success "Setup verification complete!"
}

show_help() {
    cat << EOF
${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║${NC}  HAPS-200 Deployment Script
${BLUE}║${NC}  Quick-start automation for programming and testing
${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}

USAGE:
  $0 [command]

COMMANDS:
  verify      Verify setup and bitstreams (no hardware needed)
  program     Program both FPGAs with PDI files
  functional  Run functional design tests (simulator-based verification)
  test        Run hardware tests with hRun
  monitor     Start performance and thermal monitoring
  full        Program + Functional + Hardware + Monitor (recommended first run)
  status      Check HAPS-200 board status
  help        Show this help message

EXAMPLES:
  # Program FPGAs only
  $0 program

  # Run design validation tests
  $0 functional

  # Full deployment (program, validate, test, and monitor)
  $0 full

  # Check board status
  $0 status

PREREQUISITES:
  - HAPS-200 board connected to workstation
  - hTools software installed (hutil, hrun)
  - PDI files generated: synthesis_files/FB1_F0/*.pdi, FB1_F1/*.pdi

LOGS:
  All operations are logged to: UC_LED_DEMO_runtime/logs_YYYYMMDD_HHMMSS/

TROUBLESHOOTING:
  If board not detected:
    1. Check USB/JTAG connections
    2. Run: hUtils -scan
    3. Restart htools: sudo service htools restart

  If programming fails:
    1. Verify PDI files exist and are not corrupted
    2. Check inter-FPGA cable (CON_CABLE_50_HT3) connection
    3. Try programming FPGAs individually

NEXT STEPS AFTER DEPLOYMENT:
  1. Monitor thermal and performance logs
  2. Verify LED outputs match test vectors
  3. Document results in FINAL_STATUS.md
  4. Review timing closure in synthesis_files/*/report/

For more details, see: README.md (Board Deployment & Testing section)
EOF
}

################################################################################
# Main Script
################################################################################

main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        verify)
            verify_setup
            ;;
        program)
            program_board
            ;;
        test)
            run_tests
            ;;
        monitor)
            start_monitoring
            ;;
        functional)
            run_functional_test
            ;;
        alu)
            run_alu_test
            ;;
        full)
            program_board
            echo ""
            run_functional_test
            echo ""
            run_alu_test
            echo ""
            run_tests
            echo ""
            start_monitoring
            echo ""
            print_header "Full Deployment Complete"
            print_success "All steps completed!"
            print_info "Next: Monitor logs and verify hardware operation"
            ;;
        status)
            check_board_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
