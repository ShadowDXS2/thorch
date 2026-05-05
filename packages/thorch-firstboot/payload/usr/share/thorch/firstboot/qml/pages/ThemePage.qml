import QtQuick
import QtQuick.Layouts
import "../components"

SetupPage {
    id: page

    required property var flow
    required property int optionMaxWidth

    title: qsTr("Pick a Theme")

    ColumnLayout {
        spacing: 14
        Layout.maximumWidth: page.optionMaxWidth

        ChoiceRow {
            text: qsTr("Thorch OLED")
            checked: page.flow.themeChoice === "thorch-oled"
            onClicked: page.flow.themeChoice = "thorch-oled"
        }

        ChoiceRow {
            text: qsTr("Breeze Dark")
            checked: page.flow.themeChoice === "breeze-dark"
            onClicked: page.flow.themeChoice = "breeze-dark"
        }

        ChoiceRow {
            text: qsTr("Breeze Light")
            checked: page.flow.themeChoice === "breeze-light"
            onClicked: page.flow.themeChoice = "breeze-light"
        }

        ChoiceRow {
            text: qsTr("High Contrast")
            checked: page.flow.themeChoice === "high-contrast"
            onClicked: page.flow.themeChoice = "high-contrast"
        }
    }
}
