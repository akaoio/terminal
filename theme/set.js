import { themes } from './data/themes.js'

export function set(name) {
    if (!themes[name]) {
        throw new Error(`Theme '${name}' not found. Available themes: ${Object.keys(themes).join(', ')}`)
    }
    
    this.current = name
    return themes[name]
}