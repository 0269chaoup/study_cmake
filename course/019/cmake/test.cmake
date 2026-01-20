cmake_minimum_required(VERSION 3.26 FATAL_ERROR)

message("test CMAKE_CURRENT_SOURCE_DIR = ${CMAKE_CURRENT_SOURCE_DIR}")
message("test CMAKE_CURRENT_BINARY_DIR = ${CMAKE_CURRENT_BINARY_DIR}")

message("test CMAKE_CURRENT_LIST_DIR   = ${CMAKE_CURRENT_LIST_DIR}")
message("test CMAKE_CURRENT_LIST_FILE  = ${CMAKE_CURRENT_LIST_FILE}")
message("test CMAKE_CURRENT_LIST_LINE  = ${CMAKE_CURRENT_LIST_LINE}")


set(SOURCE_LISTS
	main.cpp
	InputHandler.cpp
	InputHandler.h
	QtGeneralUIMgr.h
	QtGeneralUIMgr.cpp
	QtGeneralUIMgr.Callable.cpp
	ActionsManagement.h
	ActionsManagement.cpp
	CommandAction.h
	CommandAction.cpp
	DScriptEventMgr.h
	DScriptEventMgr.cpp
	ribbonwindow.h
	ribbonwindow.cpp
	PlatHostOperator.h
	PlatHostOperator.cpp
	QtAboutDialog.h
	QtAboutDialog.cpp
	QtAboutDialog.ui
	RibbonPopMenu.h
	RibbonPopMenu.cpp
	CustomTooltip.h
	CustomTooltip.cpp
	translations/qtgeneralui_zh_CN.ts
                )

set(PARENT_DIR string "xxxxx")
macro(source_group_by_dir source_files)
        set(sgbd_cur_dir ${CMAKE_CURRENT_SOURCE_DIR})
        foreach(sgbd_file ${source_files})
		    set(GROUP "")
		    get_filename_component(PARENT_DIR "${sgbd_file}" DIRECTORY "${sgbd_cur_dir}")
            message(STATUS "PARENT_DIR === ${PARENT_DIR}")
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
            message(STATUS "GROUP is ==== ${GROUP}")
        endforeach(sgbd_file)
endmacro(source_group_by_dir)


source_group_by_dir(${SOURCE_LISTS})