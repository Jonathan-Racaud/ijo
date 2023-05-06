target("ijo")
    set_kind("binary")
    set_languages("cxx20")
    add_includedirs("../ijolib/include")
    add_files("src/*.c")

    add_deps("ijolib")