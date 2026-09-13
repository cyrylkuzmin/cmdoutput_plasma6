cmake_minimum_required(VERSION 3.16)

project(plasmoid_command_runner LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

qt_standard_project_setup()

qt_add_qml_module(commandrunner
    URI "org.kde.plasma.private.commandrunner"
    VERSION 1.0
    SOURCES
        CommandRunner.h
        CommandRunner.cpp
)

target_link_libraries(commandrunner PRIVATE Qt6::Core Qt6::Qml)

# Install QML module targets (qt_add_qml_module creates both commandrunner and commandrunnerplugin)
install(TARGETS commandrunner commandrunnerplugin
    LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/qt6/qml/org/kde/plasma/private/commandrunner"
    RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/qt6/qml/org/kde/plasma/private/commandrunner"
)

# Also install QML module metadata files
install(FILES "${CMAKE_BINARY_DIR}/qmldir"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/qt6/qml/org/kde/plasma/private/commandrunner"
)

install(FILES "${CMAKE_BINARY_DIR}/commandrunner.qmltypes"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/qt6/qml/org/kde/plasma/private/commandrunner"
)