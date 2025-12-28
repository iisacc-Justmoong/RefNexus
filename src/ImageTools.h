#pragma once

#include <QObject>
#include <QVariantMap>

class ImageTools : public QObject
{
    Q_OBJECT

public:
    explicit ImageTools(QObject* parent = nullptr);

    Q_INVOKABLE QVariantMap imageSize(const QString& source) const;
};
