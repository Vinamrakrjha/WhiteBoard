#include "PDF_Helper.h"

PDF_Helper::PDF_Helper(QObject *parent): QObject(parent) {}

void PDF_Helper::sampleFunction()
{

}

void PDF_Helper::saveCanvasToPDF(const QString &directory, const QString &fileName, const QString &base64Image)
{
    QString pdfPath = directory + "/" + fileName + ".pdf";
    QUrl url(pdfPath);
    QString filePath = url.toLocalFile();
    QPdfWriter writer(filePath);

    writer.setPageSize(QPageSize(QPageSize::A3));
    writer.setResolution(300);
    writer.setPageOrientation(QPageLayout::Orientation::Landscape);

    int pageWidth  = writer.width();
    int pageHeight = writer.height();

    QPainter painter(&writer);

    QByteArray imageData = QByteArray::fromBase64(base64Image.toLatin1().split(',')[1]);
    QImage image;
    image.loadFromData(imageData, "PNG");

    QImage scaledImg = image.scaled(pageWidth, pageHeight, Qt::KeepAspectRatio);

    int x = (pageWidth - scaledImg.width()) / 2;
    int y = 0;  // Align with the top of the page since height fills the page

    painter.drawImage(QPoint(x, y), scaledImg);
    painter.end();
}
