import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

SetupPage {
    id: page

    required property var flow
    required property int pageMaxWidth

    title: page.flow.secondStage
        ? qsTr("Finish Setup")
        : (page.flow.removeSdStage
            ? qsTr("Remove the SD Card")
            : (page.flow.nextAction === "install-internal" && page.flow.postActionRunning
                ? qsTr("Installing to Internal Storage")
                : (page.flow.nextAction === "install-internal" ? qsTr("Ready to Install") : qsTr("You're Ready"))))

    Label {
        text: page.flow.resultMessage.length > 0
            ? page.flow.resultMessage
            : (page.flow.secondStage && page.flow.wantsSteamSetup()
                ? qsTr("Finish setup to launch Steam. When Steam closes, Thorch will open the companion environment you selected.")
                : (page.flow.secondStage ? qsTr("Finish setup to start using Thorch.") : ""))
        color: "#f6fafc"
        font.pixelSize: 20
        wrapMode: Text.WordWrap
        Layout.maximumWidth: page.pageMaxWidth
        Layout.fillWidth: true
    }

    Label {
        visible: page.flow.secondStage && page.flow.wantsSteamSetup()
        text: qsTr("Steam will take over the top screen while your companion environment stays available below.")
        color: "#89a0aa"
        font.pixelSize: 17
        wrapMode: Text.WordWrap
        Layout.maximumWidth: page.pageMaxWidth
        Layout.fillWidth: true
    }

    DangerNotice {
        visible: page.flow.nextAction === "install-internal" && !page.flow.installWarningAccepted()
        message: page.flow.internalEraseWarning()
        checkboxText: qsTr("I understand. Install to internal storage.")
        checked: page.flow.internalDataLossAccepted
        Layout.maximumWidth: page.pageMaxWidth
        Layout.fillWidth: true
        onAcceptedChanged: accepted => {
            page.flow.internalDataLossAccepted = accepted;
            if (accepted) {
                page.flow.resultMessage = qsTr("Installing Thorch to internal storage now. Keep the SD card inserted until this finishes.");
                page.flow.scheduleInternalInstall();
            }
        }
    }

    ColumnLayout {
        visible: page.flow.postActionRunning
        Layout.maximumWidth: page.pageMaxWidth
        Layout.fillWidth: true
        spacing: 8

        ProgressBar {
            from: 0
            to: 100
            value: Math.max(2, page.flow.postActionProgressValue)
            Layout.fillWidth: true
        }

        Label {
            text: page.flow.postActionProgressMessage
            color: "#89a0aa"
            font.pixelSize: 16
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    Flow {
        Layout.maximumWidth: page.pageMaxWidth
        Layout.fillWidth: true
        spacing: 16

        Button {
            visible: !page.flow.secondStage
                && !page.flow.removeSdStage
                && page.flow.nextAction !== ""
                && (page.flow.nextAction !== "install-internal" || (page.flow.autoInternalInstallStarted && !page.flow.postActionRunning))
            text: page.flow.nextAction === "install-internal" ? qsTr("Try Install Again") : qsTr("Use Full SD Card")
            icon.name: page.flow.nextAction === "install-internal" ? "drive-harddisk" : "drive-removable-media"
            enabled: !page.flow.postActionRunning
            onClicked: page.flow.runPostAction(page.flow.nextAction)
        }

        Button {
            visible: page.flow.secondStage && page.flow.wantsSteamSetup()
            text: qsTr("Finish Setup & Launch Steam")
            icon.name: "applications-games"
            enabled: !page.flow.postActionRunning
            onClicked: page.flow.runPostAction("finish-and-launch-steam")
        }

        Button {
            visible: page.flow.secondStage && !page.flow.wantsSteamSetup()
            text: qsTr("Finish Setup")
            icon.name: "dialog-ok-apply"
            enabled: !page.flow.postActionRunning
            onClicked: page.flow.runPostAction("finish-firstboot")
        }

        Button {
            visible: !page.flow.secondStage
            text: qsTr("Reboot")
            icon.name: "system-reboot"
            enabled: !page.flow.postActionRunning
            onClicked: page.flow.backend.reboot()
        }
    }

    Label {
        visible: page.flow.postActionFailed && page.flow.postActionOutput.length > 0
        text: page.flow.postActionOutput
        color: "#b8c7ce"
        font.pixelSize: 14
        wrapMode: Text.WrapAnywhere
        Layout.maximumWidth: page.pageMaxWidth
        Layout.fillWidth: true
    }
}
