target("ijo")
    set_kind("binary")
    set_languages("cxx20")
    add_includedirs("../ijolib/include")
    
    -- if (is_os("windows")) then
    --     add_files("windows/*.c")
    -- else
    --     add_files("unix/*.c")
    -- end
    add_files("src/*.c")

    add_deps("ijolib")