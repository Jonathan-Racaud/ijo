set_project("ijoLang")
add_rules("mode.debug", "mode.release")

ijolib_include = "ijolib/include"

add_subdirs("ijolib")
add_subdirs("vm")
add_subdirs("tests")