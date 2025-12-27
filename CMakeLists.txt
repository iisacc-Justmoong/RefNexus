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

qt_standard_project_setup ()

qt_add_executable (RefNexus
        MACOSX_BUNDLE
        src/main.cpp
)

qt_add_qml_module (RefNexus
        URI RefNexus
        VERSION 1.0
        QML_FILES
        qml/Main.qml
        qml/AppHeader.qml
        qml/SidebarSection.qml
        qml/LeftSidebar.qml
        qml/BoardTabs.qml
        qml/BoardToolbar.qml
        qml/CanvasCard.qml
        qml/CanvasView.qml
        qml/InspectorPanel.qml
        qml/StatusBar.qml
        qml/SearchDrawer.qml
        qml/CaptureDrawer.qml
        qml/SettingsDialog.qml
        qml/ImportDialog.qml
        qml/ExportDialog.qml
        qml/MigrationWizard.qml
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
