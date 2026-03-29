cmake_minimum_required(VERSION 3.21)

project(SegmentedLinearFit LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

qt_add_executable(SegmentedLinearFit
    src/main.cpp
    src/AppController.cpp
    src/PointTableModel.cpp
    src/SegmentFitService.cpp
)

target_include_directories(SegmentedLinearFit PRIVATE src)

target_link_libraries(SegmentedLinearFit
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::QuickControls2
)

qt_add_qml_module(SegmentedLinearFit
    URI SegmentedLinearFit
    VERSION 1.0
    QML_FILES
        qml/Main.qml
)

set_target_properties(SegmentedLinearFit PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

install(TARGETS SegmentedLinearFit
    BUNDLE DESTINATION .
    RUNTIME DESTINATION bin
)
