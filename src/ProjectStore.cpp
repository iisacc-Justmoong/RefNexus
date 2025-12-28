#include "ProjectStore.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QMetaType>
#include <QJSValue>
#include <QSettings>
#include <QSet>
#include <QUuid>

namespace {
constexpr const char kProjectsKey[] = "Projects/Stored";
}

ProjectStore::ProjectStore(QObject* parent)
    : QObject(parent)
{
    loadFromSettings();
}

QVariantList ProjectStore::projects() const
{
    return toVariantList(m_projects);
}

void ProjectStore::reload()
{
    loadFromSettings();
}

bool ProjectStore::saveProject(const QString& name, const QVariantList& items)
{
    const QString trimmed = name.trimmed();
    if (trimmed.isEmpty()) {
        return false;
    }

    QVariantList sanitizedItems = sanitizeItems(items, nullptr);

    bool updated = false;
    for (auto& entry : m_projects) {
        if (entry.name == trimmed) {
            entry.data = sanitizedItems;
            updated = true;
            break;
        }
    }

    if (!updated) {
        m_projects.push_back({ trimmed, sanitizedItems });
    }

    saveToSettings();
    emit projectsChanged();
    return true;
}

QVariantList ProjectStore::projectData(int index) const
{
    if (index < 0 || index >= m_projects.size()) {
        return {};
    }
    return sanitizeItems(m_projects.at(index).data, nullptr);
}

void ProjectStore::loadFromSettings()
{
    QSettings settings;
    const bool updated = setProjects(parseProjects(settings.value(kProjectsKey)));
    if (updated) {
        saveToSettings();
    }
}

void ProjectStore::saveToSettings() const
{
    QJsonArray array;
    for (const auto& entry : m_projects) {
        QJsonObject obj;
        obj.insert("name", entry.name);
        obj.insert("data", QJsonValue::fromVariant(entry.data));
        array.append(obj);
    }

    QSettings settings;
    settings.setValue(kProjectsKey,
        QString::fromUtf8(QJsonDocument(array).toJson(QJsonDocument::Compact)));
}

bool ProjectStore::setProjects(QVector<ProjectEntry> projects)
{
    bool updated = false;
    for (auto& entry : projects) {
        bool entryUpdated = false;
        entry.data = sanitizeItems(entry.data, &entryUpdated);
        updated = updated || entryUpdated;
    }
    m_projects = std::move(projects);
    emit projectsChanged();
    return updated;
}

QVector<ProjectStore::ProjectEntry> ProjectStore::parseProjects(const QVariant& raw) const
{
    QVector<ProjectEntry> results;
    if (!raw.isValid()) {
        return results;
    }

    if (raw.userType() == QMetaType::QVariantList) {
        const QVariantList list = raw.toList();
        results.reserve(list.size());
        for (const auto& entryVariant : list) {
            const QVariantMap entryMap = entryVariant.toMap();
            const QString name = entryMap.value("name").toString();
            results.push_back({ name.isEmpty() ? QStringLiteral("Untitled") : name,
                parseProjectData(entryMap.value("data")) });
        }
        return results;
    }

    const QString rawString = raw.toString();
    if (rawString.trimmed().isEmpty()) {
        return results;
    }

    const QJsonDocument document = QJsonDocument::fromJson(rawString.toUtf8());
    if (!document.isArray()) {
        return results;
    }

    const QJsonArray array = document.array();
    results.reserve(array.size());
    for (const auto& value : array) {
        if (!value.isObject()) {
            continue;
        }
        const QJsonObject obj = value.toObject();
        const QString name = obj.value("name").toString();
        QVariantList data = obj.value("data").toArray().toVariantList();
        if (data.isEmpty() && obj.value("data").isString()) {
            data = parseProjectData(obj.value("data").toString());
        }
        results.push_back({ name.isEmpty() ? QStringLiteral("Untitled") : name, data });
    }
    return results;
}

QVariantList ProjectStore::parseProjectData(const QVariant& raw) const
{
    if (!raw.isValid()) {
        return {};
    }

    if (raw.userType() == QMetaType::QVariantList) {
        return raw.toList();
    }

    if (raw.userType() == QMetaType::QJsonArray) {
        return raw.toJsonArray().toVariantList();
    }

    if (raw.userType() == QMetaType::QJsonValue) {
        const QJsonValue value = raw.toJsonValue();
        if (value.isArray()) {
            return value.toArray().toVariantList();
        }
    }

    if (raw.userType() == QMetaType::QString) {
        const QByteArray bytes = raw.toString().toUtf8();
        const QJsonDocument doc = QJsonDocument::fromJson(bytes);
        if (doc.isArray()) {
            return doc.array().toVariantList();
        }
    }

    if (raw.canConvert<QVariantList>()) {
        return raw.toList();
    }

    return {};
}

QVariantList ProjectStore::sanitizeItems(const QVariantList& items, bool* changed) const
{
    QVariantList sanitized;
    sanitized.reserve(items.size());
    bool updated = false;
    QSet<QString> seenIds;

    for (const auto& item : items) {
        QVariantMap map;
        if (item.userType() == QMetaType::QVariantMap) {
            map = item.toMap();
        } else if (item.userType() == QMetaType::QJsonObject) {
            map = item.toJsonObject().toVariantMap();
        } else if (item.userType() == QMetaType::QJsonValue) {
            map = item.toJsonValue().toObject().toVariantMap();
        } else if (item.userType() == qMetaTypeId<QJSValue>()) {
            map = item.value<QJSValue>().toVariant().toMap();
        } else if (item.canConvert<QVariantMap>()) {
            map = item.toMap();
        }
        QVariantMap cleaned;
        for (auto it = map.cbegin(); it != map.cend(); ++it) {
            cleaned.insert(it.key(), it.value());
        }
        QString uid = cleaned.value("uid").toString();
        if (uid.trimmed().isEmpty() || seenIds.contains(uid)) {
            uid = QUuid::createUuid().toString(QUuid::WithoutBraces);
            cleaned.insert("uid", uid);
            updated = true;
        }
        seenIds.insert(uid);
        sanitized.append(cleaned);
    }

    if (changed) {
        *changed = updated;
    }

    return sanitized;
}

QVariantList ProjectStore::toVariantList(const QVector<ProjectEntry>& projects)
{
    QVariantList list;
    list.reserve(projects.size());
    for (const auto& entry : projects) {
        QVariantMap map;
        map.insert("name", entry.name);
        map.insert("data", entry.data);
        list.push_back(map);
    }
    return list;
}
