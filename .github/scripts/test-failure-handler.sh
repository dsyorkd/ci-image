#!/bin/bash

# Test script for automated CI failure handler
# This script can be used to validate the failure handling system

set -e

echo "🧪 Testing CI Failure Handler System"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test functions
test_workflow_files() {
    echo -e "\n${YELLOW}📋 Testing workflow file existence...${NC}"
    
    required_workflows=(
        ".github/workflows/failure-handler.yml"
        ".github/workflows/ci-tests.yml"
        ".github/workflows/security-scan.yml"
    )
    
    all_exist=true
    for workflow in "${required_workflows[@]}"; do
        if [ -f "$workflow" ]; then
            echo -e "  ✅ ${GREEN}$workflow${NC}"
        else
            echo -e "  ❌ ${RED}Missing: $workflow${NC}"
            all_exist=false
        fi
    done
    
    if [ "$all_exist" = true ]; then
        echo -e "  ${GREEN}✅ All required workflow files present${NC}"
    else
        echo -e "  ${RED}❌ Some workflow files missing${NC}"
        return 1
    fi
}

test_workflow_syntax() {
    echo -e "\n${YELLOW}🔍 Testing workflow YAML syntax...${NC}"
    
    # Basic YAML syntax validation (requires yq or similar)
    if command -v yq > /dev/null; then
        for workflow in .github/workflows/*.yml; do
            if yq eval '.' "$workflow" > /dev/null 2>&1; then
                echo -e "  ✅ ${GREEN}$(basename "$workflow")${NC} - Valid YAML"
            else
                echo -e "  ❌ ${RED}$(basename "$workflow")${NC} - Invalid YAML"
                return 1
            fi
        done
    else
        echo -e "  ${YELLOW}⚠️ yq not available, skipping YAML validation${NC}"
    fi
}

test_permissions() {
    echo -e "\n${YELLOW}🔐 Testing workflow permissions...${NC}"
    
    # Check that failure-handler.yml has required permissions
    if grep -q "contents: write" .github/workflows/failure-handler.yml && \
       grep -q "pull-requests: write" .github/workflows/failure-handler.yml && \
       grep -q "actions: read" .github/workflows/failure-handler.yml; then
        echo -e "  ✅ ${GREEN}Failure handler has required permissions${NC}"
    else
        echo -e "  ❌ ${RED}Missing required permissions in failure handler${NC}"
        return 1
    fi
}

test_security_files() {
    echo -e "\n${YELLOW}🛡️ Testing security documentation...${NC}"
    
    security_files=(
        ".github/SECURITY.md"
        ".github/FAILURE_HANDLER_README.md"
    )
    
    for file in "${security_files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "  ✅ ${GREEN}$file${NC}"
        else
            echo -e "  ❌ ${RED}Missing: $file${NC}"
            return 1
        fi
    done
}

test_workflow_triggers() {
    echo -e "\n${YELLOW}⚡ Testing workflow trigger configuration...${NC}"
    
    # Check that failure-handler.yml monitors the right workflows
    if grep -q "Build and Publish Images" .github/workflows/failure-handler.yml && \
       grep -q "CI Tests" .github/workflows/failure-handler.yml && \
       grep -q "Security Scan" .github/workflows/failure-handler.yml; then
        echo -e "  ✅ ${GREEN}Failure handler monitors required workflows${NC}"
    else
        echo -e "  ❌ ${RED}Failure handler missing workflow monitors${NC}"
        return 1
    fi
    
    # Check workflow_run event
    if grep -q "workflow_run:" .github/workflows/failure-handler.yml; then
        echo -e "  ✅ ${GREEN}workflow_run event configured${NC}"
    else
        echo -e "  ❌ ${RED}workflow_run event not found${NC}"
        return 1
    fi
}

test_failure_conditions() {
    echo -e "\n${YELLOW}🎯 Testing failure condition logic...${NC}"
    
    # Check for proper failure condition
    if grep -q "github.event.workflow_run.conclusion == 'failure'" .github/workflows/failure-handler.yml; then
        echo -e "  ✅ ${GREEN}Failure condition properly configured${NC}"
    else
        echo -e "  ❌ ${RED}Failure condition missing or incorrect${NC}"
        return 1
    fi
}

simulate_failure_analysis() {
    echo -e "\n${YELLOW}🔬 Testing failure analysis logic...${NC}"
    
    # Check for key analysis components
    analysis_components=(
        "workflow-details"
        "create-branch" 
        "generate-fixes"
        "create-pr"
    )
    
    all_present=true
    for component in "${analysis_components[@]}"; do
        if grep -q "$component" .github/workflows/failure-handler.yml; then
            echo -e "  ✅ ${GREEN}$component step present${NC}"
        else
            echo -e "  ❌ ${RED}Missing: $component step${NC}"
            all_present=false
        fi
    done
    
    if [ "$all_present" = true ]; then
        echo -e "  ${GREEN}✅ All analysis components present${NC}"
    else
        return 1
    fi
}

run_integration_test() {
    echo -e "\n${YELLOW}🔗 Running integration test...${NC}"
    
    # This would normally trigger a test failure and check the response
    # For now, we'll just validate the setup is correct
    
    if [ -d ".git" ]; then
        echo -e "  ✅ ${GREEN}Git repository detected${NC}"
        
        # Check if we're in GitHub (has .github directory with workflows)
        if [ -d ".github/workflows" ]; then
            echo -e "  ✅ ${GREEN}GitHub Actions environment ready${NC}"
        else
            echo -e "  ❌ ${RED}Not in GitHub Actions environment${NC}"
            return 1
        fi
    else
        echo -e "  ❌ ${RED}Not in a Git repository${NC}"
        return 1
    fi
}

# Main test execution
main() {
    local exit_code=0
    
    echo "Starting automated tests..."
    
    # Run all tests
    test_workflow_files || exit_code=1
    test_workflow_syntax || exit_code=1
    test_permissions || exit_code=1
    test_security_files || exit_code=1
    test_workflow_triggers || exit_code=1
    test_failure_conditions || exit_code=1
    simulate_failure_analysis || exit_code=1
    run_integration_test || exit_code=1
    
    echo -e "\n=================================="
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! Failure handler system is ready.${NC}"
        echo -e "\nTo test in practice:"
        echo -e "1. Push changes to trigger a workflow"
        echo -e "2. Introduce a failure (e.g., bad Dockerfile syntax)"
        echo -e "3. Watch for automatic PR creation"
    else
        echo -e "${RED}❌ Some tests failed. Please review and fix issues.${NC}"
    fi
    
    return $exit_code
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi