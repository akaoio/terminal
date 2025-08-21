#!/usr/bin/env bash
# AKAOIO TERMINAL - DOCUMENTATION VALIDATION SCRIPT
# Validates every claim in documentation against actual code

set -e

# Dracula Theme Colors
RED='\033[38;5;203m'    # Dracula Red (#ff5555)
GREEN='\033[38;5;84m'   # Dracula Green (#50fa7b)
YELLOW='\033[38;5;228m' # Dracula Yellow (#f1fa8c)
BLUE='\033[38;5;117m'   # Dracula Cyan (#8be9fd)
CYAN='\033[38;5;117m'   # Dracula Cyan (#8be9fd)
PURPLE='\033[38;5;141m' # Dracula Purple (#bd93f9)
PINK='\033[38;5;212m'   # Dracula Pink (#ff79c6)
ORANGE='\033[38;5;215m' # Dracula Orange (#ffb86c)
WHITE='\033[38;5;253m'  # Dracula Foreground (#f8f8f2)
NC='\033[0m'             # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
VALIDATION_ERRORS=()

# Validation function
validate_claim() {
    local claim="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo -e "${BLUE}Validating: $claim${NC}"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ VALID${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}  ✗ INVALID${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        VALIDATION_ERRORS+=("❌ $claim")
    fi
}

echo -e "${CYAN}AKAOIO TERMINAL - DOCUMENTATION VALIDATION${NC}"
echo ""

# Test package installation claims
echo -e "${YELLOW}Testing Package Installation Claims:${NC}"

# Commands claimed in README
validate_claim "matrix command (via cmatrix)" "grep -q 'cmatrix' install.sh"
validate_claim "weather command works" "curl -s --max-time 5 wttr.in >/dev/null"
validate_claim "moon command works" "curl -s --max-time 5 wttr.in/Moon >/dev/null"
validate_claim "crypto command works" "curl -s --max-time 5 rate.sx >/dev/null"
# validate_claim "parrot command works" "curl -s --max-time 5 parrot.live >/dev/null"  # Removed from docs
validate_claim "neofetch installed" "command -v neofetch"

# Enhanced CLI tools
validate_claim "tmux installed" "command -v tmux"
validate_claim "dex script exists" "[ -f dex ]"
validate_claim "claude command exists" "command -v claude"
validate_claim "exa installed" "command -v exa"
validate_claim "ripgrep installed" "command -v rg"
validate_claim "htop installed" "command -v htop"

echo ""
echo -e "${YELLOW}Testing Alias Claims:${NC}"

# Count aliases
ALIAS_COUNT=$(grep -c "^alias " install.sh)
validate_claim "60+ aliases exist" "[ $ALIAS_COUNT -ge 60 ]"

# Test specific aliases exist
validate_claim "git shortcuts (gs, ga, gc)" "grep -q 'alias gs=' install.sh && grep -q 'alias ga=' install.sh && grep -q 'alias gc=' install.sh"
validate_claim "docker shortcuts (dps, dimg)" "grep -q 'alias dps=' install.sh && grep -q 'alias dimg=' install.sh"
validate_claim "tmux shortcuts (ta, tls)" "grep -q 'alias ta=' install.sh && grep -q 'alias tls=' install.sh"
validate_claim "claude shortcuts (cc, ccode)" "grep -q 'alias cc=' install.sh && grep -q 'alias ccode=' install.sh"

echo ""
echo -e "${YELLOW}Testing Function Claims:${NC}"

# Test functions exist
validate_claim "mkcd function" "grep -q 'mkcd()' install.sh"
validate_claim "extract function" "grep -q 'extract()' install.sh"
validate_claim "backup function" "grep -q 'backup()' install.sh"
validate_claim "sysinfo function" "grep -q 'sysinfo()' install.sh"

echo ""
echo -e "${YELLOW}Testing Installation Script Integrity:${NC}"

validate_claim "install.sh syntax correct" "bash -n install.sh"
validate_claim "update.sh syntax correct" "bash -n update.sh" 
validate_claim "uninstall.sh syntax correct" "bash -n uninstall.sh"
validate_claim "dex syntax correct" "bash -n dex"

echo ""
echo -e "${YELLOW}Testing Package Coverage:${NC}"

# Verify all claimed packages are in install script
validate_claim "cmatrix in all package managers" "grep -q 'cmatrix' install.sh && [ $(grep -c 'cmatrix' install.sh) -ge 5 ]"
validate_claim "bat installation attempted" "grep -q 'bat' install.sh"
validate_claim "fzf in all environments" "grep -c 'fzf' install.sh | grep -q '[5-9]'"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}Validations Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Validations Failed: $TESTS_FAILED${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All documentation claims validated!${NC}"
    echo -e "${GREEN}📋 Documentation is production ready.${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Documentation validation failed!${NC}"
    echo ""
    echo -e "${YELLOW}Issues found:${NC}"
    for error in "${VALIDATION_ERRORS[@]}"; do
        echo -e "  $error"
    done
    echo ""
    echo -e "${CYAN}Please fix these issues before release.${NC}"
    exit 1
fi