#include "CommandRunner.h"

#include <QByteArray>
#include <QString>

CommandRunner::CommandRunner(QObject *parent)
    : QObject(parent)
{
    connect(&m_process, &QProcess::readyReadStandardOutput, this, &CommandRunner::onReadyReadStandardOutput);
    connect(&m_process, &QProcess::readyReadStandardError, this, &CommandRunner::onReadyReadStandardError);
    connect(&m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &CommandRunner::onFinished);
}

QString CommandRunner::command() const
{
    return m_command;
}

QString CommandRunner::output() const
{
    return m_output;
}

bool CommandRunner::running() const
{
    return m_running;
}

void CommandRunner::setCommand(const QString &command)
{
    if (m_command == command) {
        return;
    }

    m_command = command;
    emit commandChanged();
}

void CommandRunner::start()
{
    if (m_command.trimmed().isEmpty()) {
        setOutput(QStringLiteral("No command set"));
        emit finished(1, QString(), QStringLiteral("No command set"));
        return;
    }

    if (m_running) {
        stop();
    }

    setOutput(QString());
    setRunning(true);
    // Use shell to execute the command so pipes, redirects, etc work
    m_process.start(QStringLiteral("/bin/sh"), QStringList() << QStringLiteral("-c") << m_command);
}

void CommandRunner::stop()
{
    if (m_process.state() != QProcess::NotRunning) {
        m_process.kill();
        m_process.waitForFinished(500);
    }

    setRunning(false);
}

void CommandRunner::onReadyReadStandardOutput()
{
    const QString data = QString::fromLocal8Bit(m_process.readAllStandardOutput());
    if (!data.isEmpty()) {
        m_output += data;
        emit outputChanged();
    }
}

void CommandRunner::onReadyReadStandardError()
{
    const QString data = QString::fromLocal8Bit(m_process.readAllStandardError());
    if (!data.isEmpty()) {
        m_output += data;
        emit outputChanged();
    }
}

void CommandRunner::onFinished(int exitCode, QProcess::ExitStatus status)
{
    Q_UNUSED(status)
    setRunning(false);

    // Note: We've already accumulated output in m_output via onReadyReadStandardOutput
    // and onReadyReadStandardError, so we emit it directly rather than reading again
    emit outputChanged();
    emit finished(exitCode, m_output, QString());  // Pass accumulated output as stdout
}

void CommandRunner::setOutput(const QString &value)
{
    if (m_output == value) {
        return;
    }

    m_output = value;
    emit outputChanged();
}

void CommandRunner::setRunning(bool value)
{
    if (m_running == value) {
        return;
    }

    m_running = value;
    emit runningChanged();
}
