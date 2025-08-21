export const themes = {
    dracula: {
        name: 'dracula',
        style: 'dark',
        colors: {
            // ANSI escape codes for shell scripts
            ansi: {
                purple: '\\033[38;2;189;147;249m',  // BD93F9
                green: '\\033[38;2;80;250;123m',    // 50FA7B
                cyan: '\\033[38;2;139;233;253m',    // 8BE9FD
                pink: '\\033[38;2;255;121;198m',    // FF79C6
                yellow: '\\033[38;2;241;250;140m',  // F1FA8C
                red: '\\033[38;2;255;85;85m',       // FF5555
                orange: '\\033[38;2;255;184;108m',  // FFB86C
                blue: '\\033[38;2;139;233;253m',    // 8BE9FD
                comment: '\\033[38;2;98;114;164m',  // 6272A4
                white: '\\033[38;2;248;248;242m',   // F8F8F2
                background: '\\033[38;2;40;42;54m', // 282A36
                selection: '\\033[38;2;68;71;90m',  // 44475A
            },
            // RGB values for configurations
            rgb: {
                purple: '189,147,249',
                green: '80,250,123',
                cyan: '139,233,253',
                pink: '255,121,198',
                yellow: '241,250,140',
                red: '255,85,85',
                orange: '255,184,108',
                blue: '139,233,253',
                comment: '98,114,164',
                white: '248,248,242',
                background: '40,42,54',
                selection: '68,71,90',
            },
            // Hex values for web/GUI
            hex: {
                purple: '#BD93F9',
                green: '#50FA7B',
                cyan: '#8BE9FD',
                pink: '#FF79C6',
                yellow: '#F1FA8C',
                red: '#FF5555',
                orange: '#FFB86C',
                blue: '#8BE9FD',
                comment: '#6272A4',
                white: '#F8F8F2',
                background: '#282A36',
                selection: '#44475A',
            },
            // Terminal color indices
            term: {
                purple: 141,
                green: 84,
                cyan: 117,
                pink: 212,
                yellow: 228,
                red: 203,
                orange: 215,
                blue: 117,
                comment: 61,
                white: 253,
                background: 236,
                selection: 239,
            }
        }
    },
    
    cyberpunk: {
        name: 'cyberpunk',
        style: 'dark',
        colors: {
            ansi: {
                purple: '\\033[38;2;138;43;226m',   // BlueViolet
                green: '\\033[38;2;0;255;0m',       // Lime
                cyan: '\\033[38;2;0;255;255m',      // Cyan
                pink: '\\033[38;2;255;20;147m',     // DeepPink
                yellow: '\\033[38;2;255;255;0m',    // Yellow
                red: '\\033[38;2;255;0;0m',         // Red
                orange: '\\033[38;2;255;165;0m',    // Orange
                blue: '\\033[38;2;0;191;255m',      // DeepSkyBlue
                comment: '\\033[38;2;128;128;128m', // Gray
                white: '\\033[38;2;255;255;255m',   // White
                background: '\\033[38;2;0;0;0m',    // Black
                selection: '\\033[38;2;75;0;130m',  // Indigo
            },
            rgb: {
                purple: '138,43,226',
                green: '0,255,0',
                cyan: '0,255,255',
                pink: '255,20,147',
                yellow: '255,255,0',
                red: '255,0,0',
                orange: '255,165,0',
                blue: '0,191,255',
                comment: '128,128,128',
                white: '255,255,255',
                background: '0,0,0',
                selection: '75,0,130',
            },
            hex: {
                purple: '#8A2BE2',
                green: '#00FF00',
                cyan: '#00FFFF',
                pink: '#FF1493',
                yellow: '#FFFF00',
                red: '#FF0000',
                orange: '#FFA500',
                blue: '#00BFFF',
                comment: '#808080',
                white: '#FFFFFF',
                background: '#000000',
                selection: '#4B0082',
            },
            term: {
                purple: 92,
                green: 46,
                cyan: 51,
                pink: 198,
                yellow: 226,
                red: 196,
                orange: 208,
                blue: 39,
                comment: 244,
                white: 15,
                background: 0,
                selection: 54,
            }
        }
    },
    
    nord: {
        name: 'nord',
        style: 'dark',
        colors: {
            ansi: {
                purple: '\\033[38;2;180;142;173m',  // nord15
                green: '\\033[38;2;163;190;140m',   // nord14
                cyan: '\\033[38;2;136;192;208m',    // nord8
                pink: '\\033[38;2;180;142;173m',    // nord15
                yellow: '\\033[38;2;235;203;139m',  // nord13
                red: '\\033[38;2;191;97;106m',      // nord11
                orange: '\\033[38;2;208;135;112m',  // nord12
                blue: '\\033[38;2;129;161;193m',    // nord9
                comment: '\\033[38;2;76;86;106m',   // nord3
                white: '\\033[38;2;236;239;244m',   // nord6
                background: '\\033[38;2;46;52;64m', // nord0
                selection: '\\033[38;2;67;76;94m',  // nord2
            },
            rgb: {
                purple: '180,142,173',
                green: '163,190,140',
                cyan: '136,192,208',
                pink: '180,142,173',
                yellow: '235,203,139',
                red: '191,97,106',
                orange: '208,135,112',
                blue: '129,161,193',
                comment: '76,86,106',
                white: '236,239,244',
                background: '46,52,64',
                selection: '67,76,94',
            },
            hex: {
                purple: '#B48EAD',
                green: '#A3BE8C',
                cyan: '#88C0D0',
                pink: '#B48EAD',
                yellow: '#EBCB8B',
                red: '#BF616A',
                orange: '#D08770',
                blue: '#81A1C1',
                comment: '#4C566A',
                white: '#ECEFF4',
                background: '#2E3440',
                selection: '#434C5E',
            },
            term: {
                purple: 139,
                green: 150,
                cyan: 116,
                pink: 139,
                yellow: 222,
                red: 131,
                orange: 173,
                blue: 109,
                comment: 60,
                white: 255,
                background: 235,
                selection: 238,
            }
        }
    },
    
    gruvbox: {
        name: 'gruvbox',
        style: 'dark',
        colors: {
            ansi: {
                purple: '\\033[38;2;211;134;155m',  // gruvbox purple
                green: '\\033[38;2;184;187;38m',    // gruvbox green
                cyan: '\\033[38;2;142;192;124m',    // gruvbox aqua
                pink: '\\033[38;2;211;134;155m',    // gruvbox purple
                yellow: '\\033[38;2;250;189;47m',   // gruvbox yellow
                red: '\\033[38;2;251;73;52m',       // gruvbox red
                orange: '\\033[38;2;254;128;25m',   // gruvbox orange
                blue: '\\033[38;2;131;165;152m',    // gruvbox blue
                comment: '\\033[38;2;146;131;116m', // gruvbox gray
                white: '\\033[38;2;235;219;178m',   // gruvbox fg
                background: '\\033[38;2;40;40;40m', // gruvbox bg
                selection: '\\033[38;2;60;56;54m',  // gruvbox bg1
            },
            rgb: {
                purple: '211,134,155',
                green: '184,187,38',
                cyan: '142,192,124',
                pink: '211,134,155',
                yellow: '250,189,47',
                red: '251,73,52',
                orange: '254,128,25',
                blue: '131,165,152',
                comment: '146,131,116',
                white: '235,219,178',
                background: '40,40,40',
                selection: '60,56,54',
            },
            hex: {
                purple: '#D3869B',
                green: '#B8BB26',
                cyan: '#8EC07C',
                pink: '#D3869B',
                yellow: '#FABD2F',
                red: '#FB4934',
                orange: '#FE8019',
                blue: '#83A598',
                comment: '#928374',
                white: '#EBDBB2',
                background: '#282828',
                selection: '#3C3836',
            },
            term: {
                purple: 175,
                green: 142,
                cyan: 108,
                pink: 175,
                yellow: 214,
                red: 167,
                orange: 208,
                blue: 109,
                comment: 102,
                white: 223,
                background: 235,
                selection: 237,
            }
        }
    }
}