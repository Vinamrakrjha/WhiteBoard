#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "PDF_Helper.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    PDF_Helper *pdfHelper = new PDF_Helper();
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("pdfWriter", pdfHelper);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("WhiteBoard", "Main");

    return app.exec();
}
