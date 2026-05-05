import QtQuick

QtObject {
    id: flow

    required property var backend

    readonly property int applyPage: 5
    readonly property int donePage: 6

    property int page: 0
    property var wifiNetworks: []
    property int wifiSelectedIndex: -1
    property string wifiPassword: ""
    property string wifiMessage: ""
    property string wifiConnectedSsid: ""
    property bool wifiScanning: false
    property bool wifiConnecting: false
    property string installChoice: "live-sd"
    property string modeChoice: "desktop"
    property string steamCompanion: "mobile"
    property string themeChoice: "thorch-oled"
    property string username: "thorch"
    property string password: ""
    property string confirmPassword: ""
    property bool applying: false
    property bool applied: false
    property string resultMessage: ""
    property string nextAction: ""
    property string activePostAction: ""
    property bool postActionRunning: false
    property string postActionOutput: ""
    property bool postActionFailed: false
    property int postActionProgressValue: 0
    property string postActionProgressMessage: ""
    property bool autoInternalInstallStarted: false
    property bool internalDataLossAccepted: false
    property var savedState: backend.initialState || ({})
    property string bootRole: backend.initialBootRole || "unknown"
    property bool secondStage: false
    property bool removeSdStage: false

    function selectedWifiSsid() {
        if (wifiSelectedIndex < 0 || wifiSelectedIndex >= wifiNetworks.length) {
            return "";
        }
        return wifiNetworks[wifiSelectedIndex].ssid || "";
    }

    function wifiLabel(network) {
        const lock = network.security && network.security.length > 0 ? qsTr(" secured") : qsTr(" open");
        const active = network.active ? qsTr("Connected: ") : "";
        return active + network.ssid + "  " + network.signal + "%" + lock;
    }

    function wifiReviewLabel() {
        return wifiConnectedSsid.length > 0 ? wifiConnectedSsid : qsTr("Not connected");
    }

    function finalMode() {
        if (modeChoice !== "steamos") {
            return modeChoice;
        }
        return steamCompanion === "desktop" ? "steamos-desktop" : "steamos-mobile";
    }

    function activeMode() {
        return savedState && savedState.mode ? savedState.mode : finalMode();
    }

    function wantsSteamSetup() {
        return activeMode().indexOf("steamos") === 0;
    }

    function storageChoiceLabel(choice) {
        if (choice === "install-internal") {
            return qsTr("Install to internal storage");
        }
        if (choice === "expand-sd") {
            return qsTr("Use the full SD card");
        }
        return qsTr("Keep using the SD card");
    }

    function modeChoiceLabel(mode) {
        if (mode === "mobile") {
            return qsTr("Mobile");
        }
        if (mode === "steamos-desktop") {
            return qsTr("Steam, then KDE Desktop");
        }
        if (mode === "steamos-mobile" || mode === "steamos") {
            return qsTr("Steam, then Plasma Mobile");
        }
        return qsTr("Desktop");
    }

    function themeChoiceLabel(theme) {
        if (theme === "breeze-dark") {
            return qsTr("Breeze Dark");
        }
        if (theme === "breeze-light") {
            return qsTr("Breeze Light");
        }
        if (theme === "high-contrast") {
            return qsTr("High Contrast");
        }
        return qsTr("Thorch OLED");
    }

    function internalEraseWarning() {
        return qsTr("Installing to internal storage can erase data on this device. If Thorch creates space from Android, Android's userdata partition (apps, files, and settings) will be wiped. Back up anything important before continuing.");
    }

    function installWarningAccepted() {
        return internalDataLossAccepted
            || (savedState && savedState.internalDataLossAccepted === true);
    }

    function runPostAction(action) {
        activePostAction = action;
        backend.launchPostAction(action);
    }

    function scheduleInternalInstall() {
        if (!autoInternalInstallStarted
                && nextAction === "install-internal"
                && !secondStage
                && !removeSdStage
                && installWarningAccepted()
                && !postActionRunning) {
            autoInternalInstallTimer.restart();
        }
    }

    function restoreStateChoices(state) {
        if (!state) {
            return;
        }
        if (state.username) {
            username = state.username;
        }
        if (state.theme) {
            themeChoice = state.theme;
        }
        if (state.installChoice) {
            installChoice = state.installChoice;
        }
        if (state.internalDataLossAccepted === true) {
            internalDataLossAccepted = true;
        }
        if (state.mode === "desktop" || state.mode === "mobile") {
            modeChoice = state.mode;
        } else if (state.mode === "steamos-desktop" || state.mode === "steamos-mobile") {
            modeChoice = "steamos";
            steamCompanion = state.mode === "steamos-desktop" ? "desktop" : "mobile";
        }
    }

    function restoreInternalStage() {
        const state = savedState || {};
        restoreStateChoices(state);

        if ((state.phase === "internal-install-ready" || state.phase === "internal-install-complete-remove-sd") && bootRole === "internal") {
            applied = true;
            secondStage = true;
            resultMessage = wantsSteamSetup()
                ? qsTr("You're now running from internal storage. Install Steam support next, then finish setup.")
                : qsTr("You're now running from internal storage. Finish setup to keep these choices.");
            page = donePage;
        } else if (state.phase === "internal-install-ready") {
            applied = true;
            nextAction = "install-internal";
            resultMessage = installWarningAccepted()
                ? qsTr("Your choices are saved. Installing Thorch to internal storage now. Keep the SD card inserted until this finishes.")
                : qsTr("Your choices are saved. Review the erase warning to continue.");
            page = donePage;
            scheduleInternalInstall();
        } else if (state.phase === "internal-install-complete-remove-sd") {
            applied = true;
            removeSdStage = true;
            resultMessage = qsTr("Thorch has been copied to internal storage. Remove the SD card, then reboot.");
            page = donePage;
        }
    }

    function validUsername() {
        return /^[a-z_][a-z0-9_-]{0,31}$/.test(username);
    }

    function canContinue() {
        if (page === 3) {
            if (!validUsername() || password.length === 0 || password !== confirmPassword) {
                return false;
            }
        }
        if (page === applyPage && installChoice === "install-internal" && !internalDataLossAccepted) {
            return false;
        }
        return !applying;
    }

    function applyConfig() {
        applying = true;
        resultMessage = "";
        backend.apply({
            "installChoice": installChoice,
            "mode": finalMode(),
            "theme": themeChoice,
            "username": username,
            "password": password,
            "internalDataLossAccepted": internalDataLossAccepted
        });
    }

    Component.onCompleted: {
        restoreInternalStage();
        wifiScanning = true;
        wifiMessage = qsTr("Looking for Wi-Fi networks...");
        backend.scanWifi();
    }

    property Timer autoInternalInstallTimer: Timer {
        interval: 700
        repeat: false
        onTriggered: {
            if (flow.nextAction === "install-internal" && !flow.secondStage && !flow.removeSdStage && flow.installWarningAccepted() && !flow.postActionRunning) {
                flow.autoInternalInstallStarted = true;
                flow.runPostAction("install-internal");
            }
        }
    }

    property Connections backendConnections: Connections {
        target: flow.backend

        function onApplyFinished(ok, message, action) {
            flow.applying = false;
            flow.applied = ok;
            flow.resultMessage = message;
            flow.nextAction = action;
            if (ok) {
                flow.page = flow.donePage;
                if (action === "install-internal") {
                    flow.resultMessage = qsTr("Your choices are saved. Installing Thorch to internal storage now. Keep the SD card inserted until this finishes.");
                    flow.scheduleInternalInstall();
                }
            }
        }

        function onWifiScanFinished(ok, message, networks) {
            flow.wifiScanning = false;
            flow.wifiMessage = message;
            flow.wifiNetworks = networks || [];
            if (flow.wifiNetworks.length > 0 && (flow.wifiSelectedIndex < 0 || flow.wifiSelectedIndex >= flow.wifiNetworks.length)) {
                flow.wifiSelectedIndex = 0;
            }
            for (let i = 0; i < flow.wifiNetworks.length; i++) {
                if (flow.wifiNetworks[i].active) {
                    flow.wifiConnectedSsid = flow.wifiNetworks[i].ssid || "";
                    break;
                }
            }
        }

        function onWifiConnectFinished(ok, message) {
            flow.wifiConnecting = false;
            flow.wifiMessage = message;
            if (ok) {
                flow.wifiConnectedSsid = flow.selectedWifiSsid();
                flow.backend.scanWifi();
            }
        }

        function onPostActionStarted(ok, message) {
            flow.resultMessage = message;
            if (ok) {
                flow.postActionRunning = true;
                flow.postActionOutput = "";
                flow.postActionFailed = false;
                flow.postActionProgressValue = flow.activePostAction === "install-internal" ? 2 : 0;
                flow.postActionProgressMessage = message;
            }
        }

        function onPostActionProgress(progress, message, output) {
            flow.postActionProgressValue = progress;
            flow.postActionProgressMessage = message;
            if (message.length > 0) {
                flow.resultMessage = message;
            }
            flow.postActionOutput = output;
        }

        function onPostActionFinished(ok, message, output) {
            flow.postActionRunning = false;
            flow.resultMessage = message;
            flow.postActionOutput = output;
            flow.postActionFailed = !ok;
            flow.postActionProgressValue = ok ? 100 : flow.postActionProgressValue;
            flow.postActionProgressMessage = message;
            if (ok && flow.activePostAction === "install-internal") {
                flow.removeSdStage = true;
                flow.nextAction = "";
            }
            if (ok && (flow.activePostAction === "finish-firstboot" || flow.activePostAction === "finish-and-launch-steam")) {
                flow.secondStage = false;
                flow.removeSdStage = false;
            }
            flow.activePostAction = "";
        }

        function onRebootStarted(ok, message) {
            flow.resultMessage = message;
        }
    }
}
