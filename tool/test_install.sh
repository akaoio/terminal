#!/usr/bin/env bash
# AKAOIO TERMINAL - SAFE TEST SCRIPT
# Tests installation components without modifying system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_component() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}  ✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo -e "${CYAN}AKAOIO TERMINAL - INSTALLATION TEST${NC}"
echo ""

# Test 1: Script syntax
test_component "install.sh syntax" "bash -n install.sh"

# Test 2: Required commands
test_component "curl available" "command -v curl"
test_component "git available" "command -v git"

# Test 3: tmux installation
test_component "tmux installed" "command -v tmux"
test_component "tmux version" "tmux -V"

# Test 4: dex script
test_component "dex script exists" "[ -f dex ]"
test_component "dex syntax" "bash -n dex"
test_component "dex help" "./dex --help"

# Test 5: Claude Code
test_component "claude command" "command -v claude"
test_component "claude version" "claude --version"

# Test 6: File permissions
test_component "install.sh executable" "[ -x install.sh ]"
test_component "dex executable" "[ -x dex ]"

# Test 7: Dependencies for LazyVim
test_component "neovim in PATH or installable" "command -v nvim || command -v apt-get || command -v brew || command -v pkg"

# Test 8: Node.js for Claude fallback
test_component "nodejs available" "command -v node || command -v npm || command -v bun"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Installation should work.${NC}"
    echo ""
    echo -e "${YELLOW}To run full installation:${NC}"
    echo -e "${CYAN}  ./install.sh${NC}"
    echo ""
    echo -e "${YELLOW}To test individual components:${NC}"
    echo -e "${CYAN}  tmux -V                   # Check tmux${NC}"
    echo -e "${CYAN}  ./dex test-session        # Test workspace${NC}"
    echo -e "${CYAN}  claude --version          # Check Claude${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Check the issues above.${NC}"
    exit 1
fi