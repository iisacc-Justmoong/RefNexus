#include "ImageTools.h"

#include <QImageReader>
#include <QUrl>

ImageTools::ImageTools(QObject* parent)
    : QObject(parent)
{
}

QVariantMap ImageTools::imageSize(const QString& source) const
{
    QVariantMap result;
    if (source.trimmed().isEmpty()) {
        return result;
    }

    QUrl url(source);
    QString path = source;
    if (url.isValid()) {
        if (url.isLocalFile()) {
            path = url.toLocalFile();
        } else if (url.scheme() == QStringLiteral("qrc")) {
            path = source;
        }
    }

    QImageReader reader(path);
    reader.setAutoTransform(true);
    QSize size = reader.size();
    if (!size.isValid() && url.isValid() && url.isLocalFile()) {
        QImageReader fallback(url.toString());
        fallback.setAutoTransform(true);
        size = fallback.size();
    }

    if (size.isValid()) {
        result.insert("width", size.width());
        result.insert("height", size.height());
    }
    return result;
}
