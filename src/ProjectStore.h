#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVector>

class ProjectStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList projects READ projects NOTIFY projectsChanged)

public:
    explicit ProjectStore(QObject* parent = nullptr);

    QVariantList projects() const;

    Q_INVOKABLE void reload();
    Q_INVOKABLE bool saveProject(const QString& name, const QVariantList& items);
    Q_INVOKABLE QVariantList projectData(int index) const;

signals:
    void projectsChanged();

private:
    struct ProjectEntry {
        QString name;
        QVariantList data;
    };

    QVector<ProjectEntry> m_projects;

    void loadFromSettings();
    void saveToSettings() const;
    bool setProjects(QVector<ProjectEntry> projects);
    QVector<ProjectEntry> parseProjects(const QVariant& raw) const;
    QVariantList parseProjectData(const QVariant& raw) const;
    QVariantList sanitizeItems(const QVariantList& items, bool* changed) const;
    static QVariantList toVariantList(const QVector<ProjectEntry>& projects);
};
