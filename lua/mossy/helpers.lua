local h = {}

---@params string[]
function h.make_args_range(args, start_arg, end_arg, opts)
	---@param params mossy.fmt.params
	return function(params)
		if not params.range then
			return args
		end
		local row, col, end_row, end_col =
			params.range.rstart[1], params.range.rstart[2], params.range.rend[1], params.range.rend[2]
		if opts.row_offset then
			row = row + opts.row_offset
			end_row = end_row + opts.row_offset
		end
		if opts.col_offset then
			col = col + opts.col_offset
			end_col = end_col + opts.col_offset
		end

		local range_start = opts.use_rows and row or vim.api.nvim_buf_get_offset(params.buf, row) + col
		local range_end = opts.use_rows and end_row or vim.api.nvim_buf_get_offset(params.buf, end_row) + end_col

		if opts.use_length then
			range_end = range_end - range_start
		end

		table.insert(args, start_arg)

		if opts.delimiter then
			local joined_range = range_start .. opts.delimiter .. range_end
			table.insert(args, joined_range)
		else
			table.insert(args, range_start)
			if end_arg then
				table.insert(args, end_arg)
			end
			table.insert(args, range_end)
		end

		return args
	end
end

return h
