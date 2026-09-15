import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root

    ColumnLayout {
        spacing: 10
        anchors.fill: parent
        anchors.margins: 10

        PlasmaComponents.Label {
            text: i18n("Command to run")
            Layout.fillWidth: true
        }

        PlasmaComponents.TextField {
            id: commandInput
            text: plasmoid.configuration.command ?? "uptime"
            placeholderText: "uptime"
            Layout.fillWidth: true
            onEditingFinished: plasmoid.configuration.command = text
        }

        PlasmaComponents.Label {
            text: i18n("Maximum output length (characters):")
            Layout.fillWidth: true
        }

        PlasmaComponents.SpinBox {
            id: maxOutputLengthInput
            from: 10; to: 200; stepSize: 1
            value: plasmoid.configuration.maxOutputLength ?? 50
            Layout.fillWidth: true
            onValueChanged: plasmoid.configuration.maxOutputLength = value
        }

        PlasmaComponents.Label {
            text: i18n("Max width:")
            Layout.fillWidth: true
        }

        PlasmaComponents.SpinBox {
            id: widgetWidthInput
            from: 32; to: 2000; stepSize: 1
            value: plasmoid.configuration.widgetWidth ?? 150
            Layout.fillWidth: true
            onValueChanged: plasmoid.configuration.widgetWidth = value
        }

        PlasmaComponents.Label {
            text: i18n("Update Interval (minutes, 0 = only at startup):")
            Layout.fillWidth: true
        }

        PlasmaComponents.SpinBox {
            id: intervalInput
            from: 0; to: 60; stepSize: 1
            value: plasmoid.configuration.updateInterval ?? 0
            Layout.fillWidth: true
            onValueChanged: plasmoid.configuration.updateInterval = value
        }

        PlasmaComponents.Button {
            text: i18n("Save")
            icon.name: "dialog-ok"
            Layout.alignment: Qt.AlignRight
            onClicked: {
                plasmoid.configuration.command = commandInput.text
                plasmoid.configuration.maxOutputLength = maxOutputLengthInput.value
                plasmoid.configuration.widgetWidth = widgetWidthInput.value
                plasmoid.configuration.updateInterval = intervalInput.value
            }
        }
    }
}
