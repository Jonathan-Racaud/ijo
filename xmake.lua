set_project("ijoLang")
add_rules("mode.debug", "mode.release")

ijolib_include = "ijolib/include"

target("ijolib")
    set_kind("shared")
    add_includedirs(ijolib_include)
    add_files("ijolib/src/**.c")

target("ijo")
    set_kind("binary")
    add_includedirs(ijolib_include)
    add_files("vm/src/*.c")
    add_deps("ijolib")
