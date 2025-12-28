#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "ProjectStore.h"

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setOrganizationName("RefNexus");
    QCoreApplication::setOrganizationDomain("refnexus.app");
    QCoreApplication::setApplicationName("RefNexus");

    ProjectStore projectStore;
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/qt/qml");
    engine.rootContext()->setContextProperty("projectStore", &projectStore);
    engine.loadFromModule("RefNexus", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
