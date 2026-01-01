cmake_minimum_required (VERSION 3.31)
project (RefNexus VERSION 0.1.0 LANGUAGES CXX)

list (PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED ON)

if (APPLE)
    set (CMAKE_OSX_DEPLOYMENT_TARGET "13.0" CACHE STRING "Minimum macOS version")
endif ()

find_package (Qt6 6.5 REQUIRED COMPONENTS
        Core
        Gui
        Qml
        Quick
        QuickControls2
)

qt_standard_project_setup (REQUIRES 6.5)
qt_policy (SET QTP0004 NEW)

qt_add_executable (RefNexus
        MANUAL_FINALIZATION
        MACOSX_BUNDLE
        src/ImageTools.cpp
        src/ImageTools.h
        src/InputState.cpp
        src/InputState.h
        src/main.cpp
        src/ProjectStore.cpp
        src/ProjectStore.h
)

qt_add_qml_module (RefNexus
        URI RefNexus
        VERSION 1.0
        RESOURCE_PREFIX /qt/qml
        NO_IMPORT_SCAN
        NO_GENERATE_QMLTYPES
        NO_CACHEGEN
        QML_FILES
        qml/Main.qml
        qml/MainToolBar.qml
        qml/ImageImportDialog.qml
        qml/ProjectSidebar.qml
        qml/ProjectListItem.qml
        qml/CanvasView.qml
        qml/CanvasItem.qml
        qml/ImageCardContent.qml
        qml/ToolPanel.qml
        qml/ToolSection.qml
        RESOURCES
        resources/icon-add-image.svg
        resources/icon-pin.svg
        resources/icon-new-project.svg
        resources/icon-trash.svg
        resources/icon-chevron-left.svg
        resources/icon-chevron-right.svg
        resources/icon-flip-h.svg
        resources/icon-flip-v.svg
        resources/icon-rotate-left.svg
        resources/icon-rotate-right.svg
        resources/icon-duplicate.svg
        resources/icon-forward.svg
        resources/icon-backward.svg
        resources/icon-front.svg
        resources/icon-back.svg
        resources/icon-close-dark.svg
        resources/icon-chevron-down-dark.svg
        resources/icon-chevron-right-dark.svg
        resources/icon-grid.svg
        resources/icon-snap.svg
        resources/icon-fit.svg
)

target_link_libraries (RefNexus
        PRIVATE Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)


set_target_properties (RefNexus PROPERTIES
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.refnexus.app"
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
)

qt_finalize_executable (RefNexus)

include (GNUInstallDirs)

install (TARGETS RefNexus
        BUNDLE DESTINATION .
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_qml_app_script (
        TARGET RefNexus
        OUTPUT_SCRIPT deploy_qml_script
        NO_UNSUPPORTED_PLATFORM_ERROR
)

install (SCRIPT ${deploy_qml_script})
