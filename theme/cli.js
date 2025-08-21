#!/usr/bin/env node

import Theme from './index.js'
import { writeFileSync, readFileSync, existsSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const theme = new Theme()

// Get command from arguments
const [,, command, ...args] = process.argv

// Handle current theme storage - use same file as shell
const THEME_FILE = process.env.HOME + '/.terminal-theme'

// Load saved theme preference
if (existsSync(THEME_FILE)) {
    try {
        const saved = readFileSync(THEME_FILE, 'utf8').trim()
        // Extract theme name from shell export statement
        const match = saved.match(/TERMINAL_THEME=['"]?([^'"]+)/)
        if (match) {
            theme.current = match[1]
        }
    } catch(e) {}
}

function showHelp() {
    console.log(`
Theme Manager - Single source of truth for terminal colors

Usage: theme <command> [options]

Commands:
  list              List all available themes
  get [name]        Get current or specified theme
  set <name>        Set active theme
  apply             Apply current theme (outputs shell variables)
  export <file>     Export theme variables to file
  
Examples:
  theme list                    # Show all themes
  theme set dracula            # Switch to Dracula theme  
  theme apply > ~/.theme       # Export for shell sourcing
  source <(theme apply)        # Apply directly in shell
`)
}

switch(command) {
    case 'list':
        const themes = theme.list()
        console.log('Available themes:')
        themes.forEach(name => {
            const t = theme.get(name)
            const marker = name === theme.current ? ' (current)' : ''
            console.log(`  - ${name} (${t.style})${marker}`)
        })
        break
        
    case 'get':
        const name = args[0]
        const current = theme.get(name)
        console.log(JSON.stringify(current, null, 2))
        break
        
    case 'set':
        if (!args[0]) {
            console.error('Error: Theme name required')
            process.exit(1)
        }
        try {
            theme.set(args[0])
            // Save current theme preference in shell format
            writeFileSync(THEME_FILE, `export TERMINAL_THEME='${args[0]}'`)
            console.log(`Theme set to: ${args[0]}`)
        } catch(e) {
            console.error(e.message)
            process.exit(1)
        }
        break
        
    case 'apply':
        console.log(theme.apply())
        break
        
    case 'export':
        if (!args[0]) {
            console.error('Error: Output file required')
            process.exit(1)
        }
        const output = theme.apply()
        writeFileSync(args[0], output)
        console.log(`Theme exported to: ${args[0]}`)
        break
        
    default:
        showHelp()
}