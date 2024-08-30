local source = {}

function source:is_available()
  -- Only returns `true` if the buffer is a markup file inside my blog directory.
  -- as long as this is only an aexample, it should not appear anywhere
  return vim.bo.filetype == "donotappear in any file"
end

function source:complete(params, callback)
  local items = {}

  -- There's also the `cursor_after_line`, `cursor_line`, and a `cursor` fields on `context`.
  local cursor_before_line = params.context.cursor_before_line

  -- Only complete if there's a `/` anywhere before the cursor.
  if cursor_before_line:sub(1, 1) == "/" then
    items = {
      { label = "/one" },
      { label = "/two" },
    }
  end

  -- `callback` should always be called.
  callback(items)
end

-- Trigger completion (i.e. open up cmp) on these characters.
-- We can also trigger it manually, see `:help cmp.mapping.complete`.
function source:get_trigger_characters()
  return { "/" }
end

return source
