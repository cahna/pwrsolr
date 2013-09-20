-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")
require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/home/ilya/.config/awesome/themes/powerarrow/theme_new.lua")

config_dir = ("/home/ilya/.config/awesome/")
themes_dir = (config_dir .. "/themes")
beautiful.init(themes_dir .. "/pwrsolr/theme.lua")


-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--   awful.layout.suit.spiral,
--   awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--   awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

--{{---| Menu |-------------------------------------------------------------------------------------

myawesomemenu = {
  {"edit config",           "terminal -x vim /home/ilya/.config/awesome/rc.lua"},
  {"edit theme",            "terminal -x vim /home/ilya/.config/awesome/themes/powerarrow/theme.lua"},
  {"hibernate",             "sudo pm-hibernate", beautiful.hibernate_icon},
  {"suspend",               "sudo pm-suspend", beautiful.suspend_icon},
  {"restart",               awesome.restart },
  {"reboot",                "sudo reboot", beautiful.halt_icon},
  {"quit",                  awesome.quit }
}


mygraphicsmenu = {
  {" Gimp",                 "gimp", beautiful.gimp_icon},
  {" Inkscape",             "inkscape", beautiful.inkscape_icon},
}

myofficemenu = {
  {" LibreOffice Base",     "libreoffice --base", beautiful.librebase_icon},
  {" LibreOffice Calc",     "libreoffice --calc", beautiful.librecalc_icon},
  {" LibreOffice Draw",     "libreoffice --draw", beautiful.libredraw_icon},
  {" LibreOffice Impress",  "libreoffice --impress", beautiful.libreimpress_icon},
  {" LibreOffice Math",     "libreoffice --math", beautiful.libremath_icon},	
  {" LibreOffice Writer",   "libreoffice --writer", beautiful.librewriter_icon},
}

mywebmenu = {
  {" Chrome",               "google-chrome", beautiful.chromium_icon},
  {" Droppox",              "dropbox", beautiful.dropbox_icon},
  {" Firefox",              "firefox", beautiful.firefox_icon},
}


mymainmenu = awful.menu({ items = { 
  { " @wesome",             myawesomemenu, beautiful.awesome_icon },
  {" graphics",             mygraphicsmenu, beautiful.mygraphicsmenu_icon},
  {" office",               myofficemenu, beautiful.myofficemenu_icon},
  {" web",                  mywebmenu, beautiful.mywebmenu_icon},
  {" htop",                 terminal .. " -x htop", beautiful.htop_icon},
  {" terminal",             terminal, beautiful.terminal_icon} 
}
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon), menu = mymainmenu })

-- {{{ Wibox
---{{---| Create a textclock widget |--------------------------------------------------------------
datetimewidget = widget({ type="textbox" })
vicious.register(datetimewidget, vicious.widgets.date,
'<span background="#586e75" color="#eee8d5" font="Terminus 12"> <span font="Terminus 9">%a %b %d, %H:%M</span> </span>')

-- {{---| Create an uptime widget |-----------------------------------------------------------------
uptimewidget = widget({ type = "textbox" })
vicious.register(uptimewidget, vicious.widgets.uptime,
'<span background="#586e75" color="#eee8d5" font="Terminus 12"> <span font="Terminus 9">Uptime: $1 days $2 h $3 min</span> </span>')

-- {{---| Create an updates widget |-----------------------------------------------------------------
updateswidget = widget({ type = "textbox" })
vicious.register(updateswidget, vicious.widgets.pkg,
'<span background="#859900" color="#073642" font="Terminus 12"> <span font="Terminus 9">$1 updates</span> </span>', 300, "Ubuntu")

-- {{---| Create a WiFi widget |-----------------------------------------------------------------
wifiwidget = widget({ type = "textbox" })
vicious.register(wifiwidget, vicious.widgets.wifi,
'<span background="#002b36" color="#93a1a1" font="Terminus 12"><span font="Terminus 9">${ssid}  Rate: <span color="#268bd2">${rate}</span> Mb/sec  </span></span>', 60, "wlan0")

-- {{---| Create a gmail widget |-------------------------------------------------------------------
mygmail = widget({ type="textbox" })
gmail_t = awful.tooltip({ objects = {mygmail}, })
vicious.register(mygmail, vicious.widgets.gmail,
    function (wdget, args)
        gmail_t:set_text(args["{subject}"])
        return '<span background="#eee8d5" color="#586e75" font="Terminus 12"> <span font="Terminus 9">' .. args["{count}"] .. '</span> </span>'
    end, 120)
gmailicon = widget({ type = "imagebox" })
gmailicon.image = image(beautiful.widget_gmail)


-- Create a systray
mysystray = widget({ type = "systray" })

-- seperator-widget
sprd = widget({ type = "textbox" })
sprd.text = '<span background="#002b36" font="sans 12"> </span>'

spr_base2 = widget({ type = "textbox" })
spr_base2.text = '<span background="#eee8d5" font="sans 12"> </span>'

--{{---| MEM widget |-------------------------------------------------------------------------------

memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, '<span background="#586e75" font="Terminus 12"> <span font="Terminus 9" color="#eee8d5" background="#586e75">$2MB </span></span>', 13)
memicon = widget ({type = "imagebox" })
memicon.image = image(beautiful.widget_mem)

--{{---| CPU / sensors widget |---------------------------------------------------------------------

cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu,
'<span background="#859900" font="Terminus 12"> <span font="Terminus 9" color="#002b36">$1% <span color="#002b36">·</span> $2% </span><span color="#002b36">·</span> <span font="Terminus 9" color="#002b36">$3% <span color="#002b36">·</span> $4% </span></span>', 3)
cpuicon = widget ({type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
sensors = widget({ type = "textbox" })
vicious.register(sensors, vicious.widgets.sensors)
tempicon = widget ({type = "imagebox" })
tempicon.image = image(beautiful.widget_temp)

--{{---| Battery widget |---------------------------------------------------------------------------  

baticon = widget ({type = "imagebox" })
baticon.image = image(beautiful.widget_battery)
batwidget = widget({ type = "textbox" })
vicious.register( batwidget, vicious.widgets.bat, '<span background="#eee8d5" font="Terminus 12"> <span font="Terminus 9" color="#586e75" background="#eee8d5">$1$2% </span></span>', 1, "BAT0" )

--{{---| Net widget |-------------------------------------------------------------------------------

netwidget = widget({ type = "textbox" })
vicious.register(netwidget, 
vicious.widgets.net,
'<span background="#002b36" font="Terminus 12"> <span font="Terminus 9" color="#93a1a1">${wlan0 down_kb} ↓↑ ${wlan0 up_kb}</span> </span>', 3)
neticon = widget ({type = "imagebox" })
neticon.image = image(beautiful.widget_net)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(iptraf) end)))


--{{---| Separators widgets |-----------------------------------------------------------------------

arr_base01_base2 = widget ({type = "imagebox" })
arr_base01_base2.image = image(beautiful.arr_base01_base2)
arr_base01_base03 = widget ({type = "imagebox" })
arr_base01_base03.image = image(beautiful.arr_base01_base03)
arr_base01_green = widget ({type = "imagebox" })
arr_base01_green.image = image(beautiful.arr_base01_green)

arr_base2_base0 = widget ({type = "imagebox" })
arr_base2_base0.image = image(beautiful.arr_base2_base0)
arr_base2_base01 = widget ({type = "imagebox" })
arr_base2_base01.image = image(beautiful.arr_base2_base01)
arr_base2_base03 = widget ({type = "imagebox" })
arr_base2_base03.image = image(beautiful.arr_base2_base03)
arr_base2_green = widget ({type = "imagebox" })
arr_base2_green.image = image(beautiful.arr_base2_green)

arr_base03_base0 = widget ({type = "imagebox" })
arr_base03_base0.image = image(beautiful.arr_base03_base0)
arr_base03_base01 = widget ({type = "imagebox" })
arr_base03_base01.image = image(beautiful.arr_base03_base01)
arr_base03_base2 = widget ({type = "imagebox" })
arr_base03_base2.image = image(beautiful.arr_base03_base2)
arr_base03_green = widget ({type = "imagebox" })
arr_base03_green.image = image(beautiful.arr_base03_green)

arr_green_base0 = widget ({type = "imagebox" })
arr_green_base0.image = image(beautiful.arr_green_base0)
arr_green_base01 = widget ({type = "imagebox" })
arr_green_base01.image = image(beautiful.arr_green_base01)
arr_green_base2 = widget ({type = "imagebox" })
arr_green_base2.image = image(beautiful.arr_green_base2)
arr_green_base03 = widget ({type = "imagebox" })
arr_green_base03.image = image(beautiful.arr_green_base03)


-- Create a battery widget
-- bat_widget = wibox.widget.textbox()
-- vicious.register(bat_widget, vicious.widgets.bat, "BATT $1$2 ", 32, "BAT0")
-- baticon = widget ({type = "imagebox" })
-- baticon.image = image(beautiful.widget_battery)
-- batwidget = widget({ type = "textbox" })
-- vicious.register( batwidget, vicious.widgets.bat, '<span background="#002b36" font="sans 12"><span font="sans 9" -- color="#657b83" background="#eee8d5"> $1 $2% </span></span>', 1, "BAT0" )

-- Create a wibox for each screen and add it
mywibox = {}
mywiboxb = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    mywiboxb[s] = awful.wibox({ position = "bottom", scrren = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        arr_base2_base03,
        sprd,
        s == 1 and mysystray or nil,        
        netwidget,
        neticon,
        arr_base03_base01,
        datetimewidget,
        arr_base01_green,
        updateswidget,
        arr_green_base2,
        mygmail,
        gmailicon,
        arr_base2_base03,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    mywiboxb[s].widgets = {
--        arr_base2_base01,
        wifiwidget,
        arr_base03_base2,
        batwidget,
        baticon,
        arr_base2_base01,
        sensors,
        tempicon,
        arr_base01_green, 
        cpuwidget,
        cpuicon,
        arr_green_base01,
        uptimewidget,
        arr_base01_base03,
        sprd,
        arr_base03_base01,
        memwidget,
        memicon,
        arr_base01_base03,
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
