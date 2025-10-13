# =============================================================================
# FILE: ddd-analyze.sh
# Description: Orchestrates full DDD analysis (requirements or repository mode)
# Usage: ./ddd-analyze.sh [--mode requirements|repo] [--repo <path>] [--feature <name>]
# =============================================================================
#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MODE="auto"
REPO_PATH=""
FEATURE_NAME="default"
DDD_DIR=".specify/ddd"
SPECS_DIR="specs"
VERBOSE=false

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
DDD Analysis Tool - Domain-Driven Design Model Generator

Usage: ./ddd-analyze.sh [OPTIONS]

Options:
    --mode <requirements|repo>    Analysis mode (default: auto-detect)
    --repo <path-or-url>          Repository path or URL (for repo mode)
    --feature <name>              Feature/domain name (default: default)
    --verbose                     Enable verbose output
    -h, --help                    Show this help message

Examples:
    # Auto-detect mode from current directory
    ./ddd-analyze.sh

    # Analyze repository
    ./ddd-analyze.sh --mode repo --repo https://github.com/org/project

    # Analyze requirements
    ./ddd-analyze.sh --mode requirements --feature "Order Management"

    # Analyze local repository with verbose output
    ./ddd-analyze.sh --mode repo --repo ./src --verbose

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --repo)
            REPO_PATH="$2"
            shift 2
            ;;
        --feature)
            FEATURE_NAME="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
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

# Create directory structure
setup_directories() {
    log_info "Setting up DDD directory structure..."
    
    mkdir -p "$DDD_DIR"/{cml,diagrams,contracts}
    mkdir -p "$DDD_DIR/../templates/ddd"
    mkdir -p "$DDD_DIR/../scripts"
    mkdir -p "$SPECS_DIR"
    
    log_success "Directory structure created"
}

# Detect analysis mode if auto
detect_mode() {
    if [[ "$MODE" == "auto" ]]; then
        log_info "Auto-detecting analysis mode..."
        
        if [[ -d ".git" ]] || [[ -d "src" ]] || [[ -d "services" ]]; then
            MODE="repo"
            REPO_PATH="${REPO_PATH:-.}"
            log_info "Detected repository mode (path: $REPO_PATH)"
        else
            MODE="requirements"
            log_info "Detected requirements mode"
        fi
    fi
}

# Validate inputs
validate_inputs() {
    if [[ "$MODE" == "repo" ]] && [[ -z "$REPO_PATH" ]]; then
        log_error "Repository path is required for repo mode"
        exit 1
    fi
    
    if [[ "$MODE" != "requirements" ]] && [[ "$MODE" != "repo" ]]; then
        log_error "Invalid mode: $MODE (must be 'requirements' or 'repo')"
        exit 1
    fi
}

# Scan repository (if repo mode)
scan_repository() {
    if [[ "$MODE" == "repo" ]]; then
        log_info "Scanning repository: $REPO_PATH"
        
        # Count files
        local file_count=$(find "$REPO_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.py" -o -name "*.cs" \) 2>/dev/null | wc -l)
        log_info "Found $file_count source files"
        
        # Detect languages
        local languages=$(find "$REPO_PATH" -type f -name "*.*" 2>/dev/null | sed 's/.*\.//' | sort -u | head -10 | tr '\n' ', ')
        log_info "Detected file types: $languages"
        
        # Look for service boundaries
        local services=$(find "$REPO_PATH" -type d -name "services" -o -name "src" -o -name "packages" 2>/dev/null | head -5)
        if [[ -n "$services" ]]; then
            log_info "Found potential service boundaries:"
            echo "$services" | while read -r service; do
                echo "  - $service"
            done
        fi
    fi
}

# Generate model.json (placeholder - would invoke AI)
generate_model() {
    log_info "Generating DDD model..."
    
    cat > "$DDD_DIR/model.json" << 'EOF'
{
  "meta": {
    "version": "2.0.0",
    "mode": "MODE_PLACEHOLDER",
    "inputs": ["INPUT_PLACEHOLDER"],
    "timestamp": "TIMESTAMP_PLACEHOLDER",
    "analysisScope": "full"
  },
  "ubiquitousLanguage": {
    "globalTerms": []
  },
  "domains": [],
  "boundedContexts": [],
  "relationships": [],
  "nonFunctionalConstraints": [],
  "assumptions": [],
  "openQuestions": []
}
EOF
    
    # Replace placeholders
    sed -i.bak "s/MODE_PLACEHOLDER/$MODE/" "$DDD_DIR/model.json"
    sed -i.bak "s/INPUT_PLACEHOLDER/$REPO_PATH/" "$DDD_DIR/model.json"
    sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$DDD_DIR/model.json"
    rm -f "$DDD_DIR/model.json.bak"
    
    log_success "Model generated: $DDD_DIR/model.json"
}

# Generate overview
generate_overview() {
    log_info "Generating overview..."
    
    cat > "$DDD_DIR/overview.md" << 'EOF'
# DDD Analysis Overview

## Analysis Summary

**Mode**: MODE_PLACEHOLDER
**Date**: TIMESTAMP_PLACEHOLDER
**Feature/Domain**: FEATURE_PLACEHOLDER

## Strategic Design

### Domains Identified
- [Domain names will be populated by AI analysis]

### Bounded Contexts
- [Context names will be populated by AI analysis]

### Context Map
See: `cml/context-map.cml`

## Tactical Design

### Aggregates
- [Aggregate names will be populated by AI analysis]

### Domain Events
- [Event names will be populated by AI analysis]

## Next Steps

1. Review assumptions in `assumptions.md`
2. Answer open questions in `open-questions.md`
3. Validate model with `ddd-validate.sh`
4. Generate CML artifacts with `ddd-generate-cml.sh`

---
Generated by ddd-analyze.sh
EOF
    
    sed -i.bak "s/MODE_PLACEHOLDER/$MODE/" "$DDD_DIR/overview.md"
    sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%d %H:%M:%S")/" "$DDD_DIR/overview.md"
    sed -i.bak "s/FEATURE_PLACEHOLDER/$FEATURE_NAME/" "$DDD_DIR/overview.md"
    rm -f "$DDD_DIR/overview.md.bak"
    
    log_success "Overview generated: $DDD_DIR/overview.md"
}

# Generate assumptions
generate_assumptions() {
    log_info "Generating assumptions document..."
    
    cat > "$DDD_DIR/assumptions.md" << 'EOF'
# Assumptions Made During DDD Analysis

## Analysis Metadata
- **Date**: TIMESTAMP_PLACEHOLDER
- **Mode**: MODE_PLACEHOLDER
- **Analyst**: Script-based analysis

## Assumptions

1. **Assumption**: [AI would populate actual assumptions]
   - **Rationale**: [Why this assumption was made]
   - **Risk**: [What could go wrong if assumption is incorrect]
   - **Verification**: [How to validate this assumption]

## Next Steps

Review these assumptions with domain experts and stakeholders to validate or correct them.

---
Generated by ddd-analyze.sh
EOF
    
    sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%d %H:%M:%S")/" "$DDD_DIR/assumptions.md"
    sed -i.bak "s/MODE_PLACEHOLDER/$MODE/" "$DDD_DIR/assumptions.md"
    rm -f "$DDD_DIR/assumptions.md.bak"
    
    log_success "Assumptions generated: $DDD_DIR/assumptions.md"
}

# Generate open questions
generate_open_questions() {
    log_info "Generating open questions document..."
    
    cat > "$DDD_DIR/open-questions.md" << 'EOF'
# Open Questions for Stakeholder Review

## Analysis Metadata
- **Date**: TIMESTAMP_PLACEHOLDER
- **Mode**: MODE_PLACEHOLDER

## Questions

### Strategic Questions
1. [AI would populate actual questions about domain boundaries]
2. [Questions about context relationships]

### Tactical Questions
1. [Questions about aggregate boundaries]
2. [Questions about consistency requirements]

### Non-Functional Questions
1. [Questions about performance requirements]
2. [Questions about scalability needs]

## Resolution Process

Please review these questions with:
- Domain experts
- Product owners
- Technical architects
- Development team leads

---
Generated by ddd-analyze.sh
EOF
    
    sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%d %H:%M:%S")/" "$DDD_DIR/open-questions.md"
    sed -i.bak "s/MODE_PLACEHOLDER/$MODE/" "$DDD_DIR/open-questions.md"
    rm -f "$DDD_DIR/open-questions.md.bak"
    
    log_success "Open questions generated: $DDD_DIR/open-questions.md"
}

# Generate validation checklist
generate_validation_checklist() {
    log_info "Generating validation checklist..."
    
    cat > "$DDD_DIR/validation-checklist.md" << 'EOF'
# DDD Validation Checklist

**Analysis Date**: TIMESTAMP_PLACEHOLDER

## Strategic Validation

- [ ] All domains categorized (core/supporting/generic)
- [ ] Each bounded context has clear purpose
- [ ] Ubiquitous language defined per context
- [ ] All context relationships have explicit patterns
- [ ] Each relationship has documented contracts
- [ ] Context boundaries align with team structure

## Tactical Validation

- [ ] Aggregates enforce invariants within boundaries
- [ ] No business logic in repositories
- [ ] Domain services are stateless
- [ ] Application services are thin orchestration
- [ ] Cross-aggregate rules use events/sagas
- [ ] Commands and events have intent-based names
- [ ] Idempotency guaranteed for commands/events

## Integration Validation

- [ ] Published Language defined for Open Host Services
- [ ] ACLs implemented where needed
- [ ] API contracts versioned
- [ ] Event schema evolution strategy defined
- [ ] Retry and timeout policies specified

## Documentation Quality

- [ ] Assumptions explicitly documented
- [ ] Open questions captured
- [ ] Non-functional requirements mapped
- [ ] Glossary maintained per context

## Status Summary

**Total Checks**: 24
**Passed**: 0
**Failed**: 0
**Not Applicable**: 0

Run `./ddd-validate.sh` to execute automated validation checks.

---
Generated by ddd-analyze.sh
EOF
    
    sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%d %H:%M:%S")/" "$DDD_DIR/validation-checklist.md"
    rm -f "$DDD_DIR/validation-checklist.md.bak"
    
    log_success "Validation checklist generated: $DDD_DIR/validation-checklist.md"
}

# Generate summary report
generate_summary() {
    log_info "Generating analysis summary..."
    
    echo ""
    echo "=============================================="
    echo "  DDD Analysis Complete"
    echo "=============================================="
    echo ""
    echo "Mode:     $MODE"
    if [[ -n "$REPO_PATH" ]]; then
        echo "Repo:     $REPO_PATH"
    fi
    echo "Feature:  $FEATURE_NAME"
    echo "Date:     $(date)"
    echo ""
    echo "Generated Files:"
    echo "  - $DDD_DIR/model.json"
    echo "  - $DDD_DIR/overview.md"
    echo "  - $DDD_DIR/assumptions.md"
    echo "  - $DDD_DIR/open-questions.md"
    echo "  - $DDD_DIR/validation-checklist.md"
    echo ""
    echo "Next Steps:"
    echo "  1. Review: $DDD_DIR/overview.md"
    echo "  2. Validate assumptions: $DDD_DIR/assumptions.md"
    echo "  3. Answer questions: $DDD_DIR/open-questions.md"
    echo "  4. Run validation: ./ddd-validate.sh"
    echo "  5. Generate CML: ./ddd-generate-cml.sh"
    echo ""
    echo "=============================================="
}

# Main execution
main() {
    log_info "Starting DDD Analysis..."
    echo ""
    
    setup_directories
    detect_mode
    validate_inputs
    scan_repository
    generate_model
    generate_overview
    generate_assumptions
    generate_open_questions
    generate_validation_checklist
    generate_summary
    
    log_success "DDD Analysis completed successfully!"
}

# Run main function
main