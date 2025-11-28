# Neovim Configuration

A modern, feature-rich Neovim configuration built with Lua and managed by [Lazy.nvim](https://github.com/folke/lazy.nvim).

## 🚀 Features

- **Plugin Management**: Lazy.nvim for fast and efficient plugin loading
- **Language Support**: Full LSP support for multiple languages
- **Code Completion**: Advanced completion with nvim-cmp
- **File Navigation**: Telescope for fuzzy finding and navigation
- **File Explorer**: Oil.nvim for modern file browsing
- **Code Formatting**: Automatic formatting with conform.nvim
- **Syntax Highlighting**: Tree-sitter for enhanced syntax highlighting
- **Theme**: Gruvbox dark theme
- **Terminal Integration**: Image preview support for kitty terminal

## 📁 Structure

```
~/.config/nvim/
├── init.lua                 # Main configuration entry point
├── lazy-lock.json          # Lazy.nvim lock file
├── lua/
│   ├── config/
│   │   └── lazy.lua        # Lazy.nvim bootstrap and setup
│   └── plugins/            # Plugin configurations
│       ├── autoclose.lua
│       ├── conform.lua
│       ├── gruvbox.lua
│       ├── image.lua
│       ├── lsp-config.lua
│       ├── mason.lua
│       ├── native-sorter.lua
│       ├── nvim-cmp.lua
│       ├── nvim-ts-autotag.lua
│       ├── oil.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       └── which-key.lua
└── syntax/
    └── rgbds.vim          # Custom syntax highlighting
```



## 🎨 Plugins

### Core Plugins

| Plugin | Purpose | Configuration |
|--------|---------|---------------|
| [Lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager | `lua/config/lazy.lua` |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Code completion | `lua/plugins/nvim-cmp.lua` |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Code formatting | `lua/plugins/conform.lua` |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder | `lua/plugins/telescope.lua` |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | File explorer | `lua/plugins/oil.lua` |

### Language Support

| Plugin | Purpose | Configuration |
|--------|---------|---------------|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP configuration | `lua/plugins/lsp-config.lua` |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP installer | `lua/plugins/mason.lua` |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting | `lua/plugins/treesitter.lua` |

### UI & Experience

| Plugin | Purpose | Configuration |
|--------|---------|---------------|
| [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) | Color scheme | `lua/plugins/gruvbox.lua` |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap help | `lua/plugins/which-key.lua` |
| [autoclose.nvim](https://github.com/m4xshen/autoclose.nvim) | Auto-close brackets | `lua/plugins/autoclose.lua` |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto-close tags | `lua/plugins/nvim-ts-autotag.lua` |
| [image.nvim](https://github.com/3rd/image.nvim) | Image preview | `lua/plugins/image.lua` |

## ⌨️ Keymaps

### Leader Key
- **Leader**: `<Space>`

### File Navigation
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>ff` | Telescope find files | Find files with fuzzy search |
| `<leader>fg` | Telescope live grep | Search in files with hidden files |
| `<leader>fb` | Telescope buffers | Switch between buffers |
| `<leader>fh` | Telescope help tags | Search help documentation |
| `<leader>oi` | Oil file explorer | Open file explorer |

### Code Actions
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>cf` | Format code | Format current file or selection |
| `<leader>ee` | Show diagnostics | Display line diagnostics |

### Terminal
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>lt` | Leave terminal | Exit terminal mode |

### Completion
| Keymap | Action | Description |
|--------|--------|-------------|
| `<C-Space>` | Trigger completion | Open completion menu |
| `<C-e>` | Abort completion | Close completion menu |
| `<CR>` | Confirm selection | Select completion item |
| `<Tab>` | Next item/snippet | Navigate completion or expand snippet |

## 🎯 Language Support

### Supported Languages
- **Lua** - Full LSP support with `lua_ls`
- **JavaScript/TypeScript** - Full LSP support with `tsserver`
- **Vue** - TypeScript plugin integration
- **PHP** - Full LSP support with `phpactor`
- **Python** - Formatting with `black` and `isort`
- **CSS/HTML/JSON** - Formatting with `prettier`
- **Markdown** - Formatting with `prettier`

### Formatting
Automatic formatting is configured for:
- **JavaScript/TypeScript/Vue**: Prettier
- **Python**: Black + isort
- **Lua**: Stylua
- **CSS/HTML/JSON/Markdown**: Prettier

## 🔧 Configuration

### General Settings
- **Tab size**: 2 spaces
- **Expand tabs**: Yes
- **Smart indent**: Enabled
- **Line numbers**: Relative + absolute
- **Sign column**: Always visible
- **Mouse**: Disabled (forces proper usage)
- **Arrow keys**: Disabled (forces proper usage)

### Editor Features
- **Break indent**: Enabled
- **Undo history**: Persistent
- **Case-insensitive search**: Smart case
- **Live substitution preview**: Enabled
- **Cursor line**: Highlighted
- **Scroll offset**: 10 lines

### Terminal Integration
- **Image preview**: Supported in kitty terminal
- **Backend**: kitty
- **Processor**: ImageMagick CLI

## 🚀 Getting Started

1. **Open Neovim**: `nvim`
2. **Install plugins**: Wait for Lazy.nvim to install plugins
3. **Check keymaps**: Press `<leader>?` to see available keymaps
4. **Find files**: Press `<leader>ff` to start file navigation
5. **Format code**: Press `<leader>cf` to format current file

## 🔍 Troubleshooting

### Common Issues

**Plugins not loading**:
- Check if Lazy.nvim is properly installed
- Run `:Lazy sync` to sync plugins

**LSP not working**:
- Install language servers: `:Mason`
- Check LSP status: `:LspInfo`

**Formatting not working**:
- Install formatters: `:Mason`
- Check formatter status: `:ConformInfo`

**Completion not working**:
- Check if nvim-cmp is loaded: `:checkhealth nvim-cmp`
- Verify LSP is running: `:LspInfo`

### Useful Commands
- `:Lazy` - Open Lazy.nvim interface
- `:Mason` - Open Mason interface
- `:Telescope` - Open Telescope
- `:Oil` - Open file explorer
- `:checkhealth` - Check Neovim health

## 📝 Customization

### Adding New Plugins
1. Create a new file in `lua/plugins/`
2. Follow the Lazy.nvim configuration format
3. Restart Neovim or run `:Lazy sync`

### Modifying Keymaps
- Global keymaps: Edit `init.lua`
- Plugin-specific keymaps: Edit the respective plugin file in `lua/plugins/`

### Changing Theme
- Edit `lua/plugins/gruvbox.lua` to modify theme settings
- Or replace with another theme plugin

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is open source and available under the [MIT License](LICENSE). 