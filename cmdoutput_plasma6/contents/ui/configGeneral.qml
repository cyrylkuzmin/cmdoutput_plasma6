import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit
        spacing: Kirigami.Units.smallSpacing

        Kirigami.FormLayout {
            id: form
            Layout.fillWidth: true
            Layout.fillHeight: true

            PlasmaComponents.TextField {
                id: commandInput
                text: plasmoid.configuration.command ?? "uptime"
                placeholderText: "uptime"
                Kirigami.FormData.label: i18n("Command to run:")
                Layout.fillWidth: true
                onEditingFinished: plasmoid.configuration.command = text
            }

            PlasmaComponents.SpinBox {
                id: maxOutputLengthInput
                from: 10; to: 200; stepSize: 1
                value: plasmoid.configuration.maxOutputLength ?? 50
                Kirigami.FormData.label: i18n("Maximum output length:")
                Layout.fillWidth: true
                onValueChanged: plasmoid.configuration.maxOutputLength = value
            }

            PlasmaComponents.SpinBox {
                id: widgetWidthInput
                from: 32; to: 2000; stepSize: 1
                value: plasmoid.configuration.widgetWidth ?? 150
                Kirigami.FormData.label: i18n("Widget width:")
                Layout.fillWidth: true
                onValueChanged: plasmoid.configuration.widgetWidth = value
            }

            PlasmaComponents.SpinBox {
                id: intervalInput
                from: 0; to: 60; stepSize: 1
                value: plasmoid.configuration.updateInterval ?? 0
                Kirigami.FormData.label: i18n("Update interval:")
                Layout.fillWidth: true
                onValueChanged: plasmoid.configuration.updateInterval = value
            }
        }

        PlasmaComponents.Button {
            text: i18n("Save")
            icon.name: "dialog-ok"
            Layout.alignment: Qt.AlignRight
            Layout.topMargin: Kirigami.Units.smallSpacing
            onClicked: {
                plasmoid.configuration.command = commandInput.text
                plasmoid.configuration.maxOutputLength = maxOutputLengthInput.value
                plasmoid.configuration.widgetWidth = widgetWidthInput.value
                plasmoid.configuration.updateInterval = intervalInput.value
            }
        }
    }
}