local item = {
  type = "selection-tool",
  name = "station-group-nominator",
  subgroup = "tool",
  order = "z[station-group-nominator]",
  show_in_library = false,
  icons = {
    {
      icon = "__station-group-nominator-forked__/graphics/icons/station-group-nominator.png",
      icon_size = 32,
    }
  },
  flags = {"only-in-cursor", "spawnable"},
  stack_size = 1,
  stackable = false,
  select = {
    mode = { "buildable-type", "same-force" },
    cursor_box_type = "entity",
    border_color = { r = 0.72, g = 0.45, b = 0.2, a = 1 },
  },
  alt_select = {
    mode = { "buildable-type", "same-force" },
    cursor_box_type = "entity",
    border_color = { r = 0.72, g = 0.22, b = 0.1, a = 1 },
  },
}

local shortcut = {
  type = "shortcut",
  name = "shortcut-station-group-nominator-item",
  action = "spawn-item",
  item_to_spawn  = "station-group-nominator",
  order = "m[station-group-nominator]",
  icon = "__station-group-nominator-forked__/graphics/icons/station-group-nominator-x32.png",
  small_icon = "__station-group-nominator-forked__/graphics/icons/station-group-nominator-x24.png",
  disabled_small_icon = "__station-group-nominator-forked__/graphics/icons/station-group-nominator-x24-white.png",
}

data:extend{item, shortcut}
