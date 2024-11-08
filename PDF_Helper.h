#ifndef PDF_HELPER_H
#define PDF_HELPER_H

#include <qobject.h>
#include "QDebug"
#include <QImage>
#include <QPdfWriter>
#include <QPainter>
#include <QFileInfo>
#include <QDir>
#include <QUrl>

class PDF_Helper : public QObject
{
    Q_OBJECT
public:
    explicit PDF_Helper(QObject *parent = nullptr);

    Q_INVOKABLE void sampleFunction();
    Q_INVOKABLE void saveCanvasToPDF(const QString &directory, const QString &fileName, const QString &base64Image);
};

#endif // PDF_HELPER_H
