import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.private.commandrunner 1.0
import org.kde.kirigami as Kirigami


PlasmoidItem {
    id: mainWidget
    preferredRepresentation: compactRepresentation

    property int maxOutputLength: plasmoid.configuration.maxOutputLength !== undefined ? plasmoid.configuration.maxOutputLength : 50
    property var outputLabelRef: null

    function formatCommandOutput(rawText) {
        if (!rawText) {
            return "No output";
        }

        var text = String(rawText)
            .replace(/\r?\n/g, " ")
            .replace(/\s+/g, " ")
            .trim();

        if (text.length > maxOutputLength) {
            text = text.substring(0, maxOutputLength);
        }

        return text || "No output";
    }

    CommandRunner {
        id: commandRunner

        onFinished: function(exitCode, stdoutText, stderrText) {
            if (!mainWidget.outputLabelRef) return;
            
            if (exitCode === 0 && stdoutText !== undefined && stdoutText !== "") {
                mainWidget.outputLabelRef.text = mainWidget.formatCommandOutput(stdoutText);
                return;
            }

            if (stderrText !== undefined && String(stderrText).trim() !== "") {
                mainWidget.outputLabelRef.text = mainWidget.formatCommandOutput(stderrText);
                return;
            }

            mainWidget.outputLabelRef.text = exitCode !== undefined && exitCode !== 0 ? "Command failed" : "No output";
        }
    }

    function refresh() {
        if (!mainWidget.outputLabelRef) return;
        
        var commandText = plasmoid.configuration.command ?? "uptime";
        if (!commandText || commandText.trim() === "") {
            mainWidget.outputLabelRef.text = "No command set";
            return;
        }

        mainWidget.outputLabelRef.text = "Running…";
        commandRunner.command = commandText;
        commandRunner.start();
    }

    compactRepresentation:  Item {
            id: main
            implicitWidth: 150
            implicitHeight: 32
            clip: true
            Layout.fillWidth: true
            Layout.preferredWidth: Math.max(120, outputLabel.implicitWidth + 16)
            Layout.maximumWidth: 1e9

            PlasmaComponents.Label {
                id: outputLabel
                text: "Loading…"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                anchors.centerIn: parent
                width: parent.width - 12
            }

            MouseArea {
                anchors.fill: main
                onClicked: {
                    outputLabel.text = "Refreshing…";
                    mainWidget.refresh();
                }
            }

            Timer {
                id: refreshTimer
                interval: (plasmoid.configuration.updateInterval !== undefined ? plasmoid.configuration.updateInterval : 0) * 60000
                running: (plasmoid.configuration.updateInterval > 0)
                repeat: true
                onTriggered: {
                    mainWidget.refresh();
                }
            }

            Connections {
                target: plasmoid.configuration
                function onCommandChanged() {
                    mainWidget.refresh();
                }
                function onMaxOutputLengthChanged() {
                    mainWidget.refresh();
                }
                function onUpdateIntervalChanged() {
                    refreshTimer.interval = plasmoid.configuration.updateInterval > 0 ? plasmoid.configuration.updateInterval * 60000 : 0;
                    refreshTimer.running = plasmoid.configuration.updateInterval > 0;
                    mainWidget.refresh();
                }
            }

            Component.onCompleted: {
                mainWidget.outputLabelRef = outputLabel;
                mainWidget.refresh();
            }
    }

    fullRepresentation: Item {
        implicitWidth: 220
        implicitHeight: 80
        PlasmaComponents.Label {
            anchors.centerIn: parent
            text: "Command output"
            color: Kirigami.Theme.textColor
        }
    }
}


