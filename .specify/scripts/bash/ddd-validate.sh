# =============================================================================
# FILE: ddd-validate.sh
# Description: Validate DDD model against best practices checklist
# Usage: ./ddd-validate.sh [--fix] [--checklist]
# =============================================================================
#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DDD_DIR=".specify/ddd"
MODEL_FILE="$DDD_DIR/model.json"
CHECKLIST_FILE="$DDD_DIR/validation-checklist.md"
FIX_MODE=false
CHECKLIST_ONLY=false

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

show_help() {
    cat << EOF
DDD Validator - DDD Model Validation Tool

Usage: ./ddd-validate.sh [OPTIONS]

Options:
    --fix          Suggest fixes for common issues
    --checklist    Show checklist only (no validation)
    -h, --help     Show this help message

Examples:
    # Run validation
    ./ddd-validate.sh

    # Run validation with fix suggestions
    ./ddd-validate.sh --fix

    # Show checklist without validation
    ./ddd-validate.sh --checklist

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            FIX_MODE=true
            shift
            ;;
        --checklist)
            CHECKLIST_ONLY=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if files exist
check_files() {
    if [[ ! -f "$MODEL_FILE" ]]; then
        log_error "model.json not found at $MODEL_FILE"
        echo "Run './ddd-analyze.sh' first."
        exit 1
    fi
    log_info "Found model.json"
}

# Show checklist
show_checklist() {
    if [[ -f "$CHECKLIST_FILE" ]]; then
        cat "$CHECKLIST_FILE"
    else
        log_warning "Checklist not found. Run './ddd-analyze.sh' first."
    fi
}

# Validate strategic design
validate_strategic() {
    echo ""
    log_info "Validating Strategic Design..."
    echo ""
    
    # Check 1: Domains categorized
    ((TOTAL_CHECKS++))
    if grep -q '"domains"' "$MODEL_FILE" && grep -q '"type"' "$MODEL_FILE"; then
        log_success "Domains are categorized (core/supporting/generic)"
        ((PASSED_CHECKS++))
    else
        log_error "Domains not properly categorized"
        ((FAILED_CHECKS++))
        if [[ "$FIX_MODE" == true ]]; then
            echo "  Fix: Add 'type' field to each domain in model.json"
        fi
    fi
    
    # Check 2: Bounded contexts defined
    ((TOTAL_CHECKS++))
    if grep -q '"boundedContexts"' "$MODEL_FILE"; then
        local context_count=$(grep -o '"boundedContexts"' "$MODEL_FILE" | wc -l)
        if [[ $context_count -gt 0 ]]; then
            log_success "Bounded contexts are defined"
            ((PASSED_CHECKS++))
        else
            log_warning "No bounded contexts found"
            ((WARNING_CHECKS++))
        fi
    else
        log_error "Bounded contexts section missing"
        ((FAILED_CHECKS++))
    fi
    
    # Check 3: Ubiquitous language
    ((TOTAL_CHECKS++))
    if grep -q '"ubiquitousLanguage"' "$MODEL_FILE"; then
        log_success "Ubiquitous language section present"
        ((PASSED_CHECKS++))
    else
        log_warning "Ubiquitous language not defined"
        ((WARNING_CHECKS++))
        if [[ "$FIX_MODE" == true ]]; then
            echo "  Fix: Add 'ubiquitousLanguage' section to model.json"
        fi
    fi
    
    # Check 4: Relationships defined
    ((TOTAL_CHECKS++))
    if grep -q '"relationships"' "$MODEL_FILE"; then
        log_success "Context relationships are defined"
        ((PASSED_CHECKS++))
    else
        log_warning "No context relationships found"
        ((WARNING_CHECKS++))
    fi
}

# Validate tactical design
validate_tactical() {
    echo ""
    log_info "Validating Tactical Design..."
    echo ""
    
    # Check 1: Aggregates defined
    ((TOTAL_CHECKS++))
    if grep -q '"aggregates"' "$MODEL_FILE"; then
        log_success "Aggregates are defined"
        ((PASSED_CHECKS++))
    else
        log_warning "No aggregates found"
        ((WARNING_CHECKS++))
    fi
    
    # Check 2: Invariants documented
    ((TOTAL_CHECKS++))
    if grep -q '"invariants"' "$MODEL_FILE"; then
        log_success "Invariants are documented"
        ((PASSED_CHECKS++))
    else
        log_warning "Invariants not documented"
        ((WARNING_CHECKS++))
        if [[ "$FIX_MODE" == true ]]; then
            echo "  Fix: Add 'invariants' to each aggregate"
        fi
    fi
    
    # Check 3: Events defined
    ((TOTAL_CHECKS++))
    if grep -q '"events"' "$MODEL_FILE"; then
        log_success "Domain events are defined"
        ((PASSED_CHECKS++))
    else
        log_warning "No domain events found"
        ((WARNING_CHECKS++))
    fi
    
    # Check 4: Commands defined
    ((TOTAL_CHECKS++))
    if grep -q '"commands"' "$MODEL_FILE"; then
        log_success "Commands are defined"
        ((PASSED_CHECKS++))
    else
        log_warning "No commands found"
        ((WARNING_CHECKS++))
    fi
}

# Validate integration
validate_integration() {
    echo ""
    log_info "Validating Integration..."
    echo ""
    
    # Check 1: APIs documented
    ((TOTAL_CHECKS++))
    if grep -q '"apis"' "$MODEL_FILE"; then
        log_success "APIs are documented"
        ((PASSED_CHECKS++))
    else
        log_warning "APIs not documented"
        ((WARNING_CHECKS++))
    fi
    
    # Check 2: Consistency model
    ((TOTAL_CHECKS++))
    if grep -q '"consistency"' "$MODEL_FILE"; then
        log_success "Consistency model is defined"
        ((PASSED_CHECKS++))
    else
        log_warning "Consistency model not defined"
        ((WARNING_CHECKS++))
    fi
}

# Validate documentation
validate_documentation() {
    echo ""
    log_info "Validating Documentation..."
    echo ""
    
    # Check 1: Assumptions documented
    ((TOTAL_CHECKS++))
    if [[ -f "$DDD_DIR/assumptions.md" ]]; then
        log_success "Assumptions are documented"
        ((PASSED_CHECKS++))
    else
        log_warning "assumptions.md not found"
        ((WARNING_CHECKS++))
    fi
    
    # Check 2: Open questions documented
    ((TOTAL_CHECKS++))
    if [[ -f "$DDD_DIR/open-questions.md" ]]; then
        log_success "Open questions are documented"
        ((PASSED_CHECKS++))
    else
        log_warning "open-questions.md not found"
        ((WARNING_CHECKS++))
    fi
    
    # Check 3: Overview exists
    ((TOTAL_CHECKS++))
    if [[ -f "$DDD_DIR/overview.md" ]]; then
        log_success "Overview documentation exists"
        ((PASSED_CHECKS++))
    else
        log_error "overview.md not found"
        ((FAILED_CHECKS++))
    fi
}

# Update checklist
update_checklist() {
    if [[ -f "$CHECKLIST_FILE" ]]; then
        log_info "Updating validation checklist..."
        
        # Update status summary
        sed -i.bak "s/\*\*Passed\*\*: [0-9]*/\*\*Passed\*\*: $PASSED_CHECKS/" "$CHECKLIST_FILE"
        sed -i.bak "s/\*\*Failed\*\*: [0-9]*/\*\*Failed\*\*: $FAILED_CHECKS/" "$CHECKLIST_FILE"
        rm -f "$CHECKLIST_FILE.bak"
        
        log_success "Checklist updated"
    fi
}

# Generate summary
generate_summary() {
    local pass_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        pass_rate=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    fi
    
    echo ""
    echo "=============================================="
    echo "  Validation Summary"
    echo "=============================================="
    echo ""
    echo "Total Checks:    $TOTAL_CHECKS"
    echo "Passed:          $PASSED_CHECKS (${GREEN}✓${NC})"
    echo "Failed:          $FAILED_CHECKS (${RED}✗${NC})"
    echo "Warnings:        $WARNING_CHECKS (${YELLOW}⚠${NC})"
    echo "Pass Rate:       ${pass_rate}%"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]] && [[ $WARNING_CHECKS -eq 0 ]]; then
        echo "Status: ${GREEN}ALL CHECKS PASSED${NC} ✓"
    elif [[ $FAILED_CHECKS -eq 0 ]]; then
        echo "Status: ${YELLOW}PASSED WITH WARNINGS${NC} ⚠"
    else
        echo "Status: ${RED}VALIDATION FAILED${NC} ✗"
    fi
    
    echo ""
    echo "=============================================="
    
    if [[ "$FIX_MODE" == true ]]; then
        echo ""
        echo "Run with --fix to see suggested fixes"
    fi
}

# Main execution
main() {
    log_info "Starting DDD validation..."
    
    if [[ "$CHECKLIST_ONLY" == true ]]; then
        show_checklist
        exit 0
    fi
    
    check_files
    validate_strategic
    validate_tactical
    validate_integration
    validate_documentation
    update_checklist
    generate_summary
    
    # Exit code based on failures
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main