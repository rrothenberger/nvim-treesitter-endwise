local parsers = require('nvim-treesitter.parsers')

local M = {}

function M.init()
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        callback = function(details)
            require('nvim-treesitter.endwise').detach(details.buf)

            local lang = vim.treesitter.language.get_lang(details.match)
            if not M.is_supported(lang) then
                return
            end

            require('nvim-treesitter.endwise').attach(details.buf)
        end,
    })
    vim.api.nvim_create_autocmd({ 'BufUnload' }, {
        callback = function(details)
            require('nvim-treesitter.endwise').detach(details.buf)
        end,
    })
end

function M.is_supported(lang)
    local seen = {}
    local function has_nested_endwise_language(nested_lang)
        if not nested_lang then
            return false
        end

        if not vim.treesitter.language.add(nested_lang) then
            return false
        end
        if #vim.treesitter.query.get_files(nested_lang, 'endwise') > 0 then
            return true
        end
        if seen[nested_lang] then
            return false
        end
        seen[nested_lang] = true

        local query = vim.treesitter.query.get(nested_lang, 'injections')
        if not query then
            return false
        end
        for _, capture in ipairs(query.info.captures) do
            if capture == 'language' or has_nested_endwise_language(capture) then
                return true
            end
        end

        return false
    end

    return has_nested_endwise_language(lang)
end

return M
