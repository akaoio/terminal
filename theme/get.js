import { themes } from './data/themes.js'

export function get(name) {
    const themeName = name || this.current
    const theme = themes[themeName]
    
    if (!theme) {
        throw new Error(`Theme '${themeName}' not found`)
    }
    
    return theme
}