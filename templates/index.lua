-- index.lua — index page filter.
--
-- Appends a file size to links that point at built files: build.sh sets
-- RESUME_OUTDIR to the output directory, and any relative link whose target
-- exists there gets " (17 KB)" appended after it.
--
-- Also turns the `url` metadata value into a plain string. The gfm reader
-- auto-links bare URLs, even in frontmatter, which would put an <a> tag
-- inside the template's href/content attributes.

local outdir = os.getenv("RESUME_OUTDIR")

local function file_size(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local size = f:seek("end")
  f:close()
  return size
end

local function human(bytes)
  if bytes < 1024 then
    return bytes .. " B"
  end
  return math.ceil(bytes / 1024) .. " KB"
end

function Meta(meta)
  if meta.url then
    meta.url = pandoc.utils.stringify(meta.url)
    return meta
  end
end

function Link(link)
  if not outdir or link.target:match("^%a[%w+.-]*:") or link.target:match("^[/#]") then
    return nil
  end
  local size = file_size(outdir .. "/" .. link.target)
  if not size then
    return nil
  end
  local label = pandoc.Span({ pandoc.Str("(" .. human(size) .. ")") }, { class = "file-size" })
  return { link, pandoc.Space(), label }
end
