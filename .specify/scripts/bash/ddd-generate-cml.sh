# =============================================================================
# FILE: ddd-generate-cml.sh
# Description: Generate Context Mapper CML from model.json
# Usage: ./ddd-generate-cml.sh [--with-diagrams]
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
CML_DIR="$DDD_DIR/cml"
DIAGRAMS_DIR="$DDD_DIR/diagrams"
WITH_DIAGRAMS=false

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
DDD CML Generator - Context Mapper DSL Generator

Usage: ./ddd-generate-cml.sh [OPTIONS]

Options:
    --with-diagrams    Generate PlantUML diagrams
    -h, --help        Show this help message

Examples:
    # Generate CML only
    ./ddd-generate-cml.sh

    # Generate CML and PlantUML diagrams
    ./ddd-generate-cml.sh --with-diagrams

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --with-diagrams)
            WITH_DIAGRAMS=true
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

# Check if model.json exists
check_model() {
    if [[ ! -f "$MODEL_FILE" ]]; then
        log_error "model.json not found at $MODEL_FILE"
        echo "Run './ddd-analyze.sh' first to generate the DDD model."
        exit 1
    fi
    log_info "Found model.json"
}

# Create directories
setup_directories() {
    mkdir -p "$CML_DIR"
    if [[ "$WITH_DIAGRAMS" == true ]]; then
        mkdir -p "$DIAGRAMS_DIR"
    fi
}

# Generate context map CML
generate_context_map_cml() {
    log_info "Generating context-map.cml..."
    
    # This is a simplified version - in production, parse model.json with jq
    cat > "$CML_DIR/context-map.cml" << 'EOF'
/* Context Map generated from DDD model.json
 * Generated: TIMESTAMP_PLACEHOLDER
 */

ContextMap DDDSystemMap {
    type = SYSTEM_LANDSCAPE
    state = TO_BE
    
    /* Bounded Contexts would be extracted from model.json */
    contains SampleContextA, SampleContextB
    
    /* Relationships would be extracted from model.json */
    SampleContextA [D,C]<-[U,S] SampleContextB {
        implementationTechnology = "RESTful HTTP"
    }
}

/* Bounded Context Definitions */
BoundedContext SampleContextA {
    type = FEATURE
    domainVisionStatement = "Example context from model.json"
    implementationTechnology = "Spring Boot"
    responsibilities = "Sample responsibilities"
    
    Aggregate SampleAggregate {
        Entity SampleEntity {
            aggregateRoot
            - String sampleField
        }
    }
}

BoundedContext SampleContextB {
    type = FEATURE
    domainVisionStatement = "Example context from model.json"
    implementationTechnology = "Node.js"
}

/* 
 * NOTE: This is a template. In production, this would be generated 
 * by parsing model.json and extracting:
 * - Bounded contexts from model.boundedContexts[]
 * - Relationships from model.relationships[]
 * - Aggregates from boundedContexts[].aggregates[]
 */
EOF
    
    sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%d %H:%M:%S")/" "$CML_DIR/context-map.cml"
    rm -f "$CML_DIR/context-map.cml.bak"
    
    log_success "Generated: $CML_DIR/context-map.cml"
}

# Generate per-context CML files
generate_context_cml_files() {
    log_info "Generating per-context CML files..."
    
    # In production, iterate through boundedContexts in model.json
    # For now, create a sample
    cat > "$CML_DIR/sample-context.cml" << 'EOF'
/* Bounded Context: SampleContext
 * Generated: TIMESTAMP_PLACEHOLDER
 */

BoundedContext SampleContext {
    type = FEATURE
    domainVisionStatement = "Extracted from model.json"
    implementationTechnology = "Technology Stack"
    responsibilities = "Context responsibilities"
    
    Aggregate SampleAggregate {
        Entity SampleRoot {
            aggregateRoot
            - String id
            - String name
            - int version
        }
        
        Entity SampleChild {
            - String childId
            - String value
        }
        
        ValueObject SampleValueObject {
            - String field1
            - int field2
        }
        
        Service SampleDomainService {
            void performOperation(@SampleRoot root);
        }
    }
}

/* 
 * NOTE: In production, parse model.json to extract:
 * - Aggregate details from boundedContexts[].aggregates[]
 * - Entities from aggregates[].entities[]
 * - Value objects from aggregates[].valueObjects[]
 */
EOF
    
    sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%d %H:%M:%S")/" "$CML_DIR/sample-context.cml"
    rm -f "$CML_DIR/sample-context.cml.bak"
    
    log_success "Generated: $CML_DIR/sample-context.cml"
}

# Generate PlantUML diagrams
generate_plantuml_diagrams() {
    if [[ "$WITH_DIAGRAMS" == true ]]; then
        log_info "Generating PlantUML diagrams..."
        
        cat > "$DIAGRAMS_DIR/context-map.puml" << 'EOF'
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

title Context Map

System_Boundary(contextA, "Sample Context A") {
    System(systemA, "Context A System", "Description")
}

System_Boundary(contextB, "Sample Context B") {
    System(systemB, "Context B System", "Description")
}

Rel(systemA, systemB, "Uses", "REST API")

SHOW_LEGEND()
@enduml
EOF
        
        log_success "Generated: $DIAGRAMS_DIR/context-map.puml"
        log_info "To render: plantuml $DIAGRAMS_DIR/context-map.puml"
    fi
}

# Generate summary
generate_summary() {
    echo ""
    echo "=============================================="
    echo "  CML Generation Complete"
    echo "=============================================="
    echo ""
    echo "Generated Files:"
    echo "  - $CML_DIR/context-map.cml"
    echo "  - $CML_DIR/sample-context.cml"
    if [[ "$WITH_DIAGRAMS" == true ]]; then
        echo "  - $DIAGRAMS_DIR/context-map.puml"
    fi
    echo ""
    echo "Next Steps:"
    echo "  1. Review CML files in $CML_DIR/"
    echo "  2. Open with Context Mapper (VS Code extension)"
    if [[ "$WITH_DIAGRAMS" == true ]]; then
        echo "  3. Render PlantUML: plantuml $DIAGRAMS_DIR/*.puml"
    fi
    echo ""
    echo "=============================================="
}

# Main execution
main() {
    log_info "Starting CML generation..."
    echo ""
    
    check_model
    setup_directories
    generate_context_map_cml
    generate_context_cml_files
    generate_plantuml_diagrams
    generate_summary
    
    log_success "CML generation completed successfully!"
}

main
# End of script