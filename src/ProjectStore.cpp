#include "ProjectStore.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QMetaType>
#include <QJSValue>
#include <QSettings>
#include <QSet>
#include <QUrl>
#include <QUuid>

namespace {
constexpr const char kProjectsKey[] = "Projects/Stored";
constexpr const char kCurrentProjectKey[] = "Projects/Current";
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

QString ProjectStore::currentProject() const
{
    return m_currentProjectName;
}

int ProjectStore::currentProjectIndex() const
{
    return indexOfProject(m_currentProjectName);
}

void ProjectStore::reload()
{
    loadFromSettings();
}

bool ProjectStore::createProject(const QString& name)
{
    const QString projectName = makeUniqueName(name);
    if (projectName.isEmpty()) {
        return false;
    }

    m_projects.push_back({ projectName, {} });
    setCurrentProjectName(projectName);
    saveToSettings();
    emit projectsChanged();
    return true;
}

bool ProjectStore::deleteProject(int index)
{
    if (index < 0 || index >= m_projects.size()) {
        return false;
    }
    const QString removedName = m_projects.at(index).name;
    m_projects.removeAt(index);
    if (m_projects.isEmpty()) {
        m_projects.push_back({ defaultProjectName(), {} });
    }
    if (removedName == m_currentProjectName) {
        setCurrentProjectName(m_projects.front().name);
    }
    saveToSettings();
    emit projectsChanged();
    return true;
}

bool ProjectStore::duplicateProject(int index)
{
    if (index < 0 || index >= m_projects.size()) {
        return false;
    }

    const ProjectEntry source = m_projects.at(index);
    const QString baseName = source.name.isEmpty()
        ? defaultProjectName()
        : QString("%1 Copy").arg(source.name);
    ProjectEntry duplicateEntry;
    duplicateEntry.name = makeUniqueName(baseName);
    duplicateEntry.data = sanitizeItems(source.data, nullptr);
    m_projects.insert(index + 1, duplicateEntry);
    setCurrentProjectName(duplicateEntry.name);
    saveToSettings();
    emit projectsChanged();
    return true;
}

bool ProjectStore::renameProject(int index, const QString& name)
{
    if (index < 0 || index >= m_projects.size()) {
        return false;
    }

    const QString trimmed = name.trimmed();
    if (trimmed.isEmpty()) {
        return false;
    }

    const QString oldName = m_projects.at(index).name;
    if (trimmed == oldName) {
        return false;
    }

    QString candidate = trimmed;
    int suffix = 2;
    while (true) {
        const int existingIndex = indexOfProject(candidate);
        if (existingIndex < 0 || existingIndex == index) {
            break;
        }
        candidate = QString("%1 %2").arg(trimmed).arg(suffix);
        suffix += 1;
    }

    m_projects[index].name = candidate;
    if (oldName == m_currentProjectName) {
        setCurrentProjectName(candidate);
    }
    saveToSettings();
    emit projectsChanged();
    return true;
}

bool ProjectStore::setCurrentProject(int index)
{
    if (index < 0 || index >= m_projects.size()) {
        return false;
    }
    if (setCurrentProjectName(m_projects.at(index).name)) {
        saveToSettings();
    }
    return true;
}

bool ProjectStore::updateCurrentProject(const QVariantList& items)
{
    int index = currentProjectIndex();
    if (index < 0) {
        if (m_projects.isEmpty()) {
            m_projects.push_back({ defaultProjectName(), {} });
        }
        setCurrentProjectName(m_projects.front().name);
        index = currentProjectIndex();
        if (index < 0) {
            return false;
        }
    }

    m_projects[index].data = sanitizeItems(items, nullptr);
    saveToSettings();
    return true;
}

QVariantList ProjectStore::currentProjectData() const
{
    const int index = currentProjectIndex();
    return projectData(index);
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
    const QString storedCurrent = settings.value(kCurrentProjectKey).toString();
    QVector<ProjectEntry> projects = parseProjects(settings.value(kProjectsKey));
    bool updated = setProjects(projects);

    if (m_projects.isEmpty()) {
        m_projects.push_back({ defaultProjectName(), {} });
        updated = true;
        emit projectsChanged();
    }

    if (!storedCurrent.isEmpty()) {
        updated = setCurrentProjectName(storedCurrent) || updated;
    }
    if (indexOfProject(m_currentProjectName) < 0) {
        updated = setCurrentProjectName(m_projects.front().name) || updated;
    }
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
    settings.setValue(kCurrentProjectKey, m_currentProjectName);
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
        const QVariant sourceValue = cleaned.value("source");
        if (sourceValue.isValid() && sourceValue.userType() != QMetaType::QString
            && sourceValue.canConvert<QUrl>()) {
            const QUrl url = sourceValue.toUrl();
            const QString urlString = url.toString();
            if (!urlString.isEmpty()) {
                cleaned.insert("source", urlString);
                updated = true;
            }
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

QString ProjectStore::defaultProjectName()
{
    return QStringLiteral("Untitled");
}

int ProjectStore::indexOfProject(const QString& name) const
{
    for (int i = 0; i < m_projects.size(); ++i) {
        if (m_projects.at(i).name == name) {
            return i;
        }
    }
    return -1;
}

QString ProjectStore::makeUniqueName(const QString& base) const
{
    QString trimmed = base.trimmed();
    if (trimmed.isEmpty()) {
        trimmed = defaultProjectName();
    }
    if (indexOfProject(trimmed) < 0) {
        return trimmed;
    }
    int suffix = 2;
    QString candidate;
    do {
        candidate = QString("%1 %2").arg(trimmed).arg(suffix);
        suffix += 1;
    } while (indexOfProject(candidate) >= 0);
    return candidate;
}

bool ProjectStore::setCurrentProjectName(const QString& name)
{
    if (name.isEmpty()) {
        return false;
    }
    if (m_currentProjectName == name) {
        return false;
    }
    m_currentProjectName = name;
    emit currentProjectChanged();
    return true;
}
