import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Rectangle {
    id: root
    width: Screen.width || 1920
    height: Screen.height || 1080
    color: "#16161D"

    // ── Font Loaders ──────────────────────────────────────────────
    FontLoader {
        id: silkscreenRegular
        source: "fonts/Silkscreen-Regular.ttf"
    }
    FontLoader {
        id: silkscreenBold
        source: "fonts/Silkscreen-Bold.ttf"
    }
    FontLoader {
        id: jetBrainsMono
        source: "/usr/share/fonts/TTF/JetBrainsMono-Regular.ttf"
    }
    FontLoader {
        id: jetBrainsMonoBold
        source: "/usr/share/fonts/TTF/JetBrainsMono-Bold.ttf"
    }

    // Fallback font family helpers
    function monoFont() {
        return jetBrainsMono.status === FontLoader.Ready ? jetBrainsMono.name : "monospace"
    }
    function monoBoldFont() {
        return jetBrainsMonoBold.status === FontLoader.Ready ? jetBrainsMonoBold.name : "monospace"
    }
    function clockFont() {
        return silkscreenRegular.status === FontLoader.Ready ? silkscreenRegular.name : "monospace"
    }

    // ── Background ─────────────────────────────────────────────────
    Image {
        id: bgImage
        anchors.fill: parent
        source: "mountain-night.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0.95
    }

    // Gradient overlay
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e60a0b0d" }
            GradientStop { position: 0.5; color: "#cc0a0b0d" }
            GradientStop { position: 1.0; color: "#f20a0b0d" }
        }
    }

    // ── State ──────────────────────────────────────────────────────
    property string loadingStatus: ""
    property real sc: Math.min(root.width / 1920, root.height / 1080)

    // Hidden ComboBoxes bridge SDDM's QAbstractListModel → QML strings.
    // QAbstractItemModel::data() is NOT Q_INVOKABLE in Qt5, so direct
    // model.data() calls fail. A ComboBox reads the model natively.
    ComboBox {
        id: sessionCombo
        model: sessionModel
        textRole: "name"
        visible: false
        currentIndex: 0
    }
    ComboBox {
        id: userCombo
        model: userModel
        textRole: "name"
        visible: false
        currentIndex: 0
    }

    // ── Keyboard Shortcuts ─────────────────────────────────────────
    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onPressed: {
            switch (event.key) {
                case Qt.Key_F10:
                    event.accepted = true
                    simulateShortcut("suspend")
                    break
                case Qt.Key_F11:
                    event.accepted = true
                    simulateShortcut("reboot")
                    break
                case Qt.Key_F12:
                    event.accepted = true
                    simulateShortcut("poweroff")
                    break
            }
        }
    }

    // ── MAIN CONTENT ───────────────────────────────────────────────
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 32 * sc
        z: 10

        // Pixel Clock
        Text {
            id: clockText
            Layout.alignment: Qt.AlignHCenter
            font.family: clockFont()
            font.pixelSize: Math.min(root.width * 0.10, 150)
            font.letterSpacing: 4
            color: "#ffffff"

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var now = new Date()
                    var h = ("0" + now.getHours()).slice(-2)
                    var m = ("0" + now.getMinutes()).slice(-2)
                    var s = ("0" + now.getSeconds()).slice(-2)
                    clockText.text = h + ":" + m + ":" + s
                }
            }
        }

        // Login Panel
        Rectangle {
            id: loginPanel
            Layout.alignment: Qt.AlignHCenter
            width: 380 * root.sc
            height: loginGrid.height + 60 * root.sc
            color: "#731A1A26"
            radius: 6 * root.sc
            border.color: "#0dffffff"
            border.width: Math.max(1, Math.round(1 * root.sc))

            ColumnLayout {
                id: loginGrid
                anchors.centerIn: parent
                width: parent.width - 44 * root.sc
                spacing: 12 * root.sc

                // Row 1: Session selector
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8 * root.sc

                    Label {
                        text: "Wayland"
                        font.family: monoFont()
                        font.pixelSize: Math.round(11 * root.sc)
                        font.weight: Font.Medium
                        font.letterSpacing: 2 * root.sc
                        color: "#d5c89a"
                        Layout.preferredWidth: 85 * root.sc
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 28 * root.sc
                        color: "#cc1A1A26"
                        border.color: "#0dffffff"
                        border.width: Math.max(1, Math.round(1 * root.sc))
                        radius: 4 * root.sc

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 12 * root.sc

                            Button {
                                flat: true
                                onClicked: cycleSession(-1)
                                contentItem: Text {
                                    text: "<"
                                    font.family: monoFont()
                                    font.pixelSize: Math.round(10 * root.sc)
                                    color: "#b8d5c89a"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Item {}
                                Layout.preferredWidth: 20 * root.sc
                                Layout.preferredHeight: 20 * root.sc
                            }

                            Text {
                                id: sessionLabel
                                text: sessionCombo.currentText || "Hyprland"
                                font.family: monoFont()
                                font.pixelSize: Math.round(11 * root.sc)
                                font.weight: Font.Medium
                                color: "#d4d4d4"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 140 * root.sc
                            }

                            Button {
                                flat: true
                                onClicked: cycleSession(1)
                                contentItem: Text {
                                    text: ">"
                                    font.family: monoFont()
                                    font.pixelSize: Math.round(10 * root.sc)
                                    color: "#b8d5c89a"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Item {}
                                Layout.preferredWidth: 20 * root.sc
                                Layout.preferredHeight: 20 * root.sc
                            }
                        }
                    }
                }

                // Row 2: User selector
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8 * root.sc

                    Label {
                        text: "user"
                        font.family: monoFont()
                        font.pixelSize: Math.round(11 * root.sc)
                        font.weight: Font.Medium
                        font.letterSpacing: 2 * root.sc
                        color: "#d5c89a"
                        Layout.preferredWidth: 85 * root.sc
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 28 * root.sc
                        color: "#cc1A1A26"
                        border.color: "#0dffffff"
                        border.width: Math.max(1, Math.round(1 * root.sc))
                        radius: 4 * root.sc

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 12 * root.sc

                            Button {
                                flat: true
                                onClicked: cycleUser(-1)
                                contentItem: Text {
                                    text: "<"
                                    font.family: monoFont()
                                    font.pixelSize: Math.round(10 * root.sc)
                                    color: "#b8d5c89a"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Item {}
                                Layout.preferredWidth: 20 * root.sc
                                Layout.preferredHeight: 20 * root.sc
                            }

                            Text {
                                id: userLabel
                                text: userCombo.currentText || "Xuanz"
                                font.family: monoBoldFont()
                                font.pixelSize: Math.round(11 * root.sc)
                                color: "#d4d4d4"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 140 * root.sc
                            }

                            Button {
                                flat: true
                                onClicked: cycleUser(1)
                                contentItem: Text {
                                    text: ">"
                                    font.family: monoFont()
                                    font.pixelSize: Math.round(10 * root.sc)
                                    color: "#b8d5c89a"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Item {}
                                Layout.preferredWidth: 20 * root.sc
                                Layout.preferredHeight: 20 * root.sc
                            }
                        }
                    }
                }

                // Row 3: Password input
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8 * root.sc

                    Label {
                        text: "password"
                        font.family: monoFont()
                        font.pixelSize: Math.round(11 * root.sc)
                        font.weight: Font.Medium
                        font.letterSpacing: 2 * root.sc
                        color: "#d5c89a"
                        Layout.preferredWidth: 85 * root.sc
                    }

                    Rectangle {
                        id: passwordBox
                        Layout.fillWidth: true
                        height: 28 * root.sc
                        color: "#cc1A1A26"
                        border.color: passwordInput.activeFocus ? "#d5c89a" : "#0dffffff"
                        border.width: Math.max(1, Math.round(1 * root.sc))
                        radius: 4 * root.sc

                        TextInput {
                            id: passwordInput
                            anchors.centerIn: parent
                            width: parent.width - 16 * root.sc
                            font.family: monoBoldFont()
                            font.pixelSize: Math.round(11 * root.sc)
                            font.letterSpacing: 3 * root.sc
                            color: "#ffffff"
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            focus: true

                            onAccepted: attemptLogin()

                            Rectangle {
                                anchors.right: parent.right
                                anchors.rightMargin: -8 * root.sc
                                anchors.verticalCenter: parent.verticalCenter
                                width: 6 * root.sc; height: 6 * root.sc; radius: 3 * root.sc
                                color: "#d5c89a"
                                opacity: passwordInput.activeFocus ? 0.75 : 0.3

                                SequentialAnimation on opacity {
                                    running: passwordInput.activeFocus
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 1500 }
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 1500 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── FOOTER ─────────────────────────────────────────────────────
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16 * sc
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24 * sc
        z: 10

        Repeater {
            model: [
                { label: "Suspend", action: "suspend" },
                { label: "Reboot", action: "reboot" },
                { label: "PowerOff", action: "poweroff" }
            ]

            Row {
                id: shortcutRow
                spacing: 4 * sc

                property string actionStr: modelData.action

                Text {
                    text: modelData.label
                    font.family: monoFont()
                    font.pixelSize: Math.round(11 * sc)
                    color: shortcutMouse.containsMouse ? "#d5c89a" : "#b6b09e"
                }

                MouseArea {
                    id: shortcutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: simulateShortcut(shortcutRow.actionStr)
                }
            }
        }
    }

    // ── LOADING / TERMINAL OVERLAY ─────────────────────────────────
    Rectangle {
        id: loadingOverlay
        anchors.fill: parent
        color: "#f2000000"
        z: 50
        visible: false
        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        onOpacityChanged: {
            if (opacity === 0) {
                hideCleanupTimer.start()
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16 * sc
            width: Math.min(parent.width * 0.8, 480 * sc)

            RowLayout {
                spacing: 8 * sc

                Rectangle {
                    width: 8 * sc; height: 8 * sc; radius: 4 * sc
                    color: "#d5c89a"
                    SequentialAnimation on opacity {
                        running: loadingOverlay.visible
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.3; to: 1.0; duration: 400 }
                        NumberAnimation { from: 1.0; to: 0.3; duration: 400 }
                    }
                }

                Text {
                    id: statusText
                    text: loadingStatus
                    font.family: monoBoldFont()
                    font.pixelSize: Math.round(11 * sc)
                    font.letterSpacing: 2 * sc
                    color: "#b6b09e"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 160 * sc
                color: "#e6000000"
                border.color: "#0dffffff"
                border.width: Math.max(1, Math.round(1 * sc))
                radius: 4 * sc
                clip: true

                ListView {
                    id: terminalLogView
                    anchors.fill: parent
                    anchors.margins: Math.round(12 * sc)
                    model: terminalLogModel
                    spacing: 4 * sc
                    currentIndex: terminalLogModel.count - 1

                    delegate: Text {
                        text: model.text
                        font.family: monoFont()
                        font.pixelSize: Math.round(10 * sc)
                        color: "#66b981"
                    }

                    onCountChanged: positionViewAtEnd()
                }
            }
        }
    }

    ListModel {
        id: terminalLogModel
    }

    // ── HELPERS ────────────────────────────────────────────────────

    function cycleSession(dir) {
        var count = sessionModel.count
        if (count === 0) return
        sessionCombo.currentIndex = (sessionCombo.currentIndex + dir + count) % count
    }

    function cycleUser(dir) {
        var count = userModel.count
        if (count === 0) return
        userCombo.currentIndex = (userCombo.currentIndex + dir + count) % count
    }

    property string pendingUsername: ""
    property string pendingPassword: ""
    property int pendingSessionIdx: 0

    function attemptLogin() {
        if (userModel.count === 0) return
        pendingUsername = userCombo.currentText
        pendingPassword = passwordInput.text
        pendingSessionIdx = sessionCombo.currentIndex

        loadingStatus = "Connecting to " + sessionLabel.text + "..."
        terminalLogModel.clear()
        terminalLogModel.append({ text: "[  OK  ] Verifying user credentials: " + pendingUsername })
        terminalLogModel.append({ text: "[  OK  ] Encrypted password matched successfully." })
        terminalLogModel.append({ text: "[  OK  ] Loading session module: systemd-logind" })
        terminalLogModel.append({ text: "[ INFO ] Opening pam_unix session for user " + pendingUsername })
        terminalLogModel.append({ text: "[  OK  ] Starting Wayland Display Server..." })
        terminalLogModel.append({ text: "[  OK  ] Connecting to Wayland-0 socket protocol" })
        terminalLogModel.append({ text: "[  OK  ] Reading compositor configuration: " + sessionLabel.text })
        terminalLogModel.append({ text: "[  OK  ] Login successful! Closing login manager..." })
        showOverlay()

        loginTimer.start()
    }

    function simulateShortcut(action) {
        loadingStatus =
            action === "suspend"   ? "Suspending System" :
            action === "reboot"    ? "Rebooting System" :
                                     "Powering Off System"

        terminalLogModel.clear()
        showOverlay()

        if (action === "suspend") {
            terminalLogModel.append({ text: "[  OK  ] Freezing background process activity..." })
            terminalLogModel.append({ text: "[  OK  ] Saving system state to RAM..." })
            terminalLogModel.append({ text: "[  OK  ] Entering ACPI S3 low-power mode..." })
            suspendTimer.start()
        } else if (action === "reboot") {
            terminalLogModel.append({ text: "[  OK  ] Sending SIGTERM to all processes..." })
            terminalLogModel.append({ text: "[  OK  ] Unmounting local filesystems..." })
            terminalLogModel.append({ text: "[  OK  ] Starting hardware reboot cycle..." })
            rebootTimer.start()
        } else if (action === "poweroff") {
            terminalLogModel.append({ text: "[  OK  ] Saving all activity logs..." })
            terminalLogModel.append({ text: "[  OK  ] Stopping Linux kernel..." })
            terminalLogModel.append({ text: "[  OK  ] Cutting main power supply (ACPI Off)..." })
            poweroffTimer.start()
        }
    }

    function showOverlay() {
        loadingOverlay.visible = true
        loadingOverlay.opacity = 1
    }

    Timer { id: loginTimer; interval: 1500; onTriggered: sddm.login(pendingUsername, pendingPassword, pendingSessionIdx) }
    Timer { id: suspendTimer; interval: 1500; onTriggered: sddm.suspend() }
    Timer { id: rebootTimer; interval: 1500; onTriggered: sddm.reboot() }
    Timer { id: poweroffTimer; interval: 1500; onTriggered: sddm.powerOff() }

    Timer {
        id: hideTimer
        interval: 2500
        onTriggered: {
            loadingOverlay.opacity = 0
            passwordInput.text = ""
            passwordInput.focus = true
        }
    }

    Timer {
        id: hideCleanupTimer
        interval: 350
        onTriggered: loadingOverlay.visible = false
    }

    // ── SDDM Signal Handlers ──────────────────────────────────────
    Connections {
        target: sddm
        onLoginFailed: {
            terminalLogModel.append({ text: "[ FAIL ] Authentication denied. Try again." })
            hideTimer.start()
        }
        onLoginSucceeded: {
            // SDDM will close automatically — no action needed
        }
    }

    // ── Initialization ─────────────────────────────────────────────
    Component.onCompleted: {
        // Select first available user
        if (userModel.count > 0) {
            userCombo.currentIndex = 0
        }
        // Gunakan session terakhir yang disimpan SDDM di state.conf
        if (sessionModel.count > 0) {
            sessionCombo.currentIndex = sessionModel.lastIndex
        }
        passwordInput.focus = true
    }

    // Return focus to password when clicking elsewhere
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: passwordInput.focus = true
    }
}
