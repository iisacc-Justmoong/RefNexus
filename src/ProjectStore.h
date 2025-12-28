#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVector>

class ProjectStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList projects READ projects NOTIFY projectsChanged)
    Q_PROPERTY(QString currentProject READ currentProject NOTIFY currentProjectChanged)
    Q_PROPERTY(int currentProjectIndex READ currentProjectIndex NOTIFY currentProjectChanged)

public:
    explicit ProjectStore(QObject* parent = nullptr);

    QVariantList projects() const;
    QString currentProject() const;
    int currentProjectIndex() const;

    Q_INVOKABLE void reload();
    Q_INVOKABLE bool createProject(const QString& name);
    Q_INVOKABLE bool deleteProject(int index);
    Q_INVOKABLE bool renameProject(int index, const QString& name);
    Q_INVOKABLE bool setCurrentProject(int index);
    Q_INVOKABLE bool updateCurrentProject(const QVariantList& items);
    Q_INVOKABLE QVariantList currentProjectData() const;
    Q_INVOKABLE QVariantList projectData(int index) const;

signals:
    void projectsChanged();
    void currentProjectChanged();

private:
    struct ProjectEntry {
        QString name;
        QVariantList data;
    };

    QVector<ProjectEntry> m_projects;
    QString m_currentProjectName;

    void loadFromSettings();
    void saveToSettings() const;
    bool setProjects(QVector<ProjectEntry> projects);
    QVector<ProjectEntry> parseProjects(const QVariant& raw) const;
    QVariantList parseProjectData(const QVariant& raw) const;
    QVariantList sanitizeItems(const QVariantList& items, bool* changed) const;
    static QVariantList toVariantList(const QVector<ProjectEntry>& projects);
    static QString defaultProjectName();
    int indexOfProject(const QString& name) const;
    QString makeUniqueName(const QString& base) const;
    bool setCurrentProjectName(const QString& name);
};
