-- resume-header.lua — build the top of the resume from frontmatter.
--
-- Inserts, before the body:
--   contact line   email - phone - location - website   (whichever are set)
--   ---
--   objective
--
-- Contact info stays plain text (no links) to keep the resume ATS-safe.

local CONTACT_KEYS = { "email", "phone", "location", "website" }

local function inlines(value)
  if value == nil then
    return nil
  end
  if pandoc.utils.type(value) == "Inlines" then
    return value
  end
  return pandoc.Inlines(pandoc.utils.stringify(value))
end

function Pandoc(doc)
  local meta = doc.meta
  local header = pandoc.Blocks({})

  local contact = pandoc.Inlines({})
  for _, key in ipairs(CONTACT_KEYS) do
    local value = inlines(meta[key])
    if value and #value > 0 then
      if #contact > 0 then
        contact:extend({ pandoc.Space(), pandoc.Str("-"), pandoc.Space() })
      end
      contact:extend(value)
    end
  end
  if #contact > 0 then
    header:insert(pandoc.Para(contact))
  end

  local objective = inlines(meta.objective)
  if objective and #objective > 0 then
    header:insert(pandoc.HorizontalRule())
    header:insert(pandoc.Para(objective))
  end

  header:extend(doc.blocks)
  doc.blocks = header
  return doc
end
