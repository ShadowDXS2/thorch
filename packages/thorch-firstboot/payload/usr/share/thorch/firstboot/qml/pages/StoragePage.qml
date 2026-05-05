import QtQuick
import QtQuick.Layouts
import "../components"

SetupPage {
    id: page

    required property var flow
    required property int optionMaxWidth

    title: qsTr("Choose Where Thorch Runs")
    description: qsTr("Keep using this SD card, use the rest of the card for storage, or move Thorch onto the device's internal storage.")

    ColumnLayout {
        spacing: 14
        Layout.maximumWidth: page.optionMaxWidth

        ChoiceRow {
            text: qsTr("Keep using the SD card")
            checked: page.flow.installChoice === "live-sd"
            onClicked: page.flow.installChoice = "live-sd"
        }

        ChoiceRow {
            text: qsTr("Use the full SD card")
            checked: page.flow.installChoice === "expand-sd"
            onClicked: page.flow.installChoice = "expand-sd"
        }

        ChoiceRow {
            text: qsTr("Install to internal storage")
            checked: page.flow.installChoice === "install-internal"
            onClicked: page.flow.installChoice = "install-internal"
        }
    }
}
