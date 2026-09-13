#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <qqmlregistration.h>

class CommandRunner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString command READ command WRITE setCommand NOTIFY commandChanged)
    Q_PROPERTY(QString output READ output NOTIFY outputChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    QML_ELEMENT

public:
    explicit CommandRunner(QObject *parent = nullptr);

    QString command() const;
    QString output() const;
    bool running() const;

public slots:
    void setCommand(const QString &command);
    void start();
    void stop();

signals:
    void commandChanged();
    void outputChanged();
    void runningChanged();
    void finished(int exitCode, const QString &stdoutText, const QString &stderrText);

private slots:
    void onReadyReadStandardOutput();
    void onReadyReadStandardError();
    void onFinished(int exitCode, QProcess::ExitStatus status);

private:
    void setOutput(const QString &value);
    void setRunning(bool value);

    QString m_command;
    QString m_output;
    bool m_running = false;
    QProcess m_process;
};
