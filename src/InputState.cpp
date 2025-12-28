#include "InputState.h"

#include <QCoreApplication>
#include <QEvent>
#include <QKeyEvent>

InputState::InputState(QObject* parent)
    : QObject(parent)
{
    if (auto app = QCoreApplication::instance()) {
        app->installEventFilter(this);
    }
}

bool InputState::spacePressed() const
{
    return m_spacePressed;
}

bool InputState::eventFilter(QObject* watched, QEvent* event)
{
    if (event->type() == QEvent::KeyPress || event->type() == QEvent::KeyRelease) {
        auto* keyEvent = static_cast<QKeyEvent*>(event);
        if (keyEvent->key() == Qt::Key_Space && !keyEvent->isAutoRepeat()) {
            const bool pressed = event->type() == QEvent::KeyPress;
            if (m_spacePressed != pressed) {
                m_spacePressed = pressed;
                emit spacePressedChanged();
            }
        }
    }
    return QObject::eventFilter(watched, event);
}
