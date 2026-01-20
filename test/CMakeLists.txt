cmake_minimum_required(VERSION 3.19 FATAL_ERROR)
message(STATUS "CMake version: ${CMAKE_CURRENT_SOURCE_DIR}")

# set(SOURCE_LIST
# 	main.cpp
# 	InputHandler.cpp
# 	InputHandler.h
# 	QtGeneralUIMgr.h
# 	QtGeneralUIMgr.cpp
# 	QtGeneralUIMgr.Callable.cpp
# 	ActionsManagement.h
# 	ActionsManagement.cpp
# 	CommandAction.h
# 	CommandAction.cpp
# 	DScriptEventMgr.h
# 	DScriptEventMgr.cpp
# 	ribbonwindow.h
# 	ribbonwindow.cpp
# 	PlatHostOperator.h
# 	PlatHostOperator.cpp
# 	QtAboutDialog.h
# 	QtAboutDialog.cpp
# 	QtAboutDialog.ui
# 	RibbonPopMenu.h
# 	RibbonPopMenu.cpp
# 	CustomTooltip.h
# 	CustomTooltip.cpp
# 	translations/qtgeneralui_zh_CN.ts
#                 )

macro(source_group_by_dir source_files)
    if(MSVC)
        set(sgbd_cur_dir ${CMAKE_CURRENT_SOURCE_DIR})
        foreach(sgbd_file ${source_files})
		    set(GROUP "")
		    get_filename_component(PARENT_DIR "${sgbd_file}" DIRECTORY "${sgbd_cur_dir}")
			if(PARENT_DIR)
               string(REPLACE "/" "\\" GROUP ${PARENT_DIR})
			endif()
            if ("${sgbd_file}" MATCHES ".*\\.cpp")
               set(GROUP "Source Files\\${GROUP}")
            elseif("${sgbd_file}" MATCHES ".*\\.c")
                set(GROUP "Source Files\\${GROUP}")
            elseif("${sgbd_file}" MATCHES ".*\\.h")
                set(GROUP "Header Files\\${GROUP}")
            endif()
            source_group("${GROUP}" FILES "${sgbd_file}")
        endforeach(sgbd_file)
    endif(MSVC)
endmacro(source_group_by_dir)

# source_group_by_dir(${SOURCE_LIST})