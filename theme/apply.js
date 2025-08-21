export function apply() {
    const theme = this.get()
    const colors = theme.colors
    
    // Return shell variables for sourcing
    const shellVars = []
    
    // ANSI escape codes for shell scripts
    for (const [key, value] of Object.entries(colors.ansi)) {
        shellVars.push(`export ${key.toUpperCase()}='${value}'`)
    }
    shellVars.push(`export NC='\\033[0m'`)
    
    // RGB values for configurations
    for (const [key, value] of Object.entries(colors.rgb)) {
        shellVars.push(`export ${key.toUpperCase()}_RGB='${value}'`)
    }
    
    // Hex values for web/GUI tools
    for (const [key, value] of Object.entries(colors.hex)) {
        shellVars.push(`export ${key.toUpperCase()}_HEX='${value}'`)
    }
    
    // Theme metadata
    shellVars.push(`export THEME_NAME='${theme.name}'`)
    shellVars.push(`export THEME_STYLE='${theme.style}'`)
    
    return shellVars.join('\n')
}