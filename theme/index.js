#!/usr/bin/env node

import { get } from './get.js'
import { set } from './set.js'
import { list } from './list.js'
import { colors } from './colors.js'
import { apply } from './apply.js'

export class Theme {
    constructor() {
        // Initialize with default theme
        this.current = 'dracula'
    }
    
    get(name) {
        return get.call(this, name)
    }
    
    set(name) {
        return set.call(this, name)
    }
    
    list() {
        return list.call(this)
    }
    
    colors() {
        return colors.call(this)
    }
    
    apply() {
        return apply.call(this)
    }
}

export default Theme