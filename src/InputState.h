#pragma once

#include <QObject>

class InputState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool spacePressed READ spacePressed NOTIFY spacePressedChanged)

public:
    explicit InputState(QObject* parent = nullptr);

    bool spacePressed() const;

signals:
    void spacePressedChanged();

protected:
    bool eventFilter(QObject* watched, QEvent* event) override;

private:
    bool m_spacePressed = false;
};
