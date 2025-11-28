local capabilities = require("cmp_nvim_lsp").default_capabilities()

local vue_language_server_path = vim.fn.stdpath("data")
	.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
}
local vtsls_config = {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},

		typescript = {
			preferences = {
			  importModuleSpecifier = "non-relative",
			  updateImportsOnFileMove = {
				enabled = "always",
			  },
			  suggest = {
				completeFunctionCalls = true,
			  },
			},
			enableInlayHints = {
				parameterTypes = true,
				variableTypes = true,
				propertyDeclarationTypes = true,
				enumMemberValues = true,
				functionLikeReturnTypes = true,
			},
		  },
	},
	filetypes = { "vue", "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
}

local vue_ls_config = {
	init_options = {
		typescript = {
			tsdk = "",
		},
	},
}

vim.lsp.config("vtsls", vtsls_config)
vim.lsp.config("vue_ls", vue_ls_config)
vim.lsp.enable({ "vue_ls" })

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = { version = "Lua 5.1" },
			diagnostics = {
				globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
			},
		},
	},
})
