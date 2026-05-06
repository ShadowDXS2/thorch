import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

SetupPage {
    id: page

    required property var flow
    required property int optionMaxWidth

    title: qsTr("Choose Your Start Mode")

    ColumnLayout {
        spacing: 14
        Layout.maximumWidth: page.optionMaxWidth

        ChoiceRow {
            text: qsTr("Desktop")
            checked: page.flow.modeChoice === "desktop"
            onClicked: page.flow.modeChoice = "desktop"
        }

        ChoiceRow {
            text: qsTr("Mobile")
            checked: page.flow.modeChoice === "mobile"
            onClicked: page.flow.modeChoice = "mobile"
        }

        ChoiceRow {
            text: qsTr("Steam")
            checked: page.flow.modeChoice === "steamos"
            onClicked: page.flow.modeChoice = "steamos"
        }
    }

    ColumnLayout {
        visible: page.flow.modeChoice === "steamos"
        spacing: 10
        Layout.topMargin: 20
        Layout.maximumWidth: page.optionMaxWidth

        Label {
            text: qsTr("Bottom screen environment")
            color: "#89a0aa"
            font.pixelSize: 18
        }

        ChoiceRow {
            text: qsTr("Plasma Mobile")
            checked: page.flow.steamCompanion === "mobile"
            onClicked: page.flow.steamCompanion = "mobile"
        }

        ChoiceRow {
            text: qsTr("KDE Desktop")
            checked: page.flow.steamCompanion === "desktop"
            onClicked: page.flow.steamCompanion = "desktop"
        }
    }
}
