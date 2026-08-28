import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtMultimedia

Item {
    id: root

    property bool firstInput
    property bool blurEnabled
    property real mainCardRadius
    property real blurAmount
    property int rootHeight
    property int rootWidth
    property string greetingText
    property string username
    
    // Video Wallpaper Properties
    property string bgSrc: config.backgroundSource ? "../" + config.backgroundSource : "../assets/background"
    property bool isVideo: bgSrc.endsWith(".mp4") || bgSrc.endsWith(".webm") || bgSrc.endsWith(".mkv")

    readonly property var fontAxes: ({
        "wght": 700,
        "wdth": 115,
        "ROND": 10,
        "opsz": 224
    })

    FontLoader {
        id: googleSansFlex

        source: "../assets/google-sans-flex/GoogleSansFlex.ttf"
    }

    Rectangle {
        id: welcomeTextRectBlur

        width: root.firstInput ? welcomeTextRect.width + 30 : welcomeTextRect.width / 10
        height: root.firstInput ? welcomeTextRect.height + 30 : welcomeTextRect.height / 10
        color: "transparent"
        anchors.centerIn: parent
        radius: root.mainCardRadius
        clip: true
        layer.enabled: true

        AnimatedImage {
            id: backgroundBlur

            anchors.centerIn: parent
            width: root.rootWidth
            height: root.rootHeight
            source: root.bgSrc
            fillMode: Image.PreserveAspectCrop
            visible: !root.isVideo
            opacity: root.firstInput ? 1 : 0
        }

        AudioOutput {
            id: greetAudio
            muted: true
        }

        MediaPlayer {
            id: greetMediaPlayer
            source: root.isVideo ? Qt.resolvedUrl(root.bgSrc) : ""
            videoOutput: greetVideoOutput
            audioOutput: greetAudio
            loops: MediaPlayer.Infinite
            
            Component.onCompleted: {
                if (root.isVideo) {
                    play()
                }
            }
        }

        VideoOutput {
            id: greetVideoOutput
            anchors.centerIn: parent
            width: root.rootWidth
            height: root.rootHeight
            visible: root.isVideo
            fillMode: VideoOutput.PreserveAspectCrop
            opacity: root.firstInput ? 1 : 0
        }

        MultiEffect {
            blurEnabled: root.blurEnabled
            source: root.isVideo ? greetVideoOutput : backgroundBlur
            blur: root.blurAmount
            autoPaddingEnabled: false
            blurMultiplier: 1
            blurMax: 64
            anchors.fill: root.isVideo ? greetVideoOutput : backgroundBlur
            opacity: root.firstInput ? 1 : 0

            Behavior on blur {
                NumberAnimation {
                    duration: 400
                    easing: Easing.InOutCubic
                }

            }

        }

        Rectangle {
            anchors.fill: root.isVideo ? greetVideoOutput : backgroundBlur
            color: Qt.rgba(parseInt(config.background.substring(1, 3), 16) / 255, parseInt(config.background.substring(3, 5), 16) / 255, parseInt(config.background.substring(5, 7), 16) / 255, root.welcomeBgOpacity)
            opacity: root.firstInput ? parseFloat(config.welcomeColorOpacity) : 0
        }

        Behavior on width {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutBack
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutBack
            }

        }

        layer.effect: OpacityMask {

            maskSource: Rectangle {
                width: welcomeTextRectBlur.width
                height: welcomeTextRectBlur.height
                radius: welcomeTextRectBlur.radius
            }

        }

    }

    Item {
        id: welcomeTextRect

        width: welcomeText.width + 50
        height: welcomeText.height + 30
        anchors.centerIn: parent
        opacity: 1

        Text {
            id: welcomeText

            renderType: Text.QtRendering
            text: "<span style='color:" + config.text + ";'>" + root.greetingText + " " + "</span>" + "<span style='color:" + config.primary + ";'>" + root.username + "</span>"
            textFormat: Text.RichText
            font.pointSize: 80
            font.family: googleSansFlex.name
            font.variableAxes: root.fontAxes
            font.features: ({
                "liga": 0
            })
            color: config.text
            opacity: root.firstInput ? 1 : 0
            anchors.centerIn: parent
        }

        PropertyAnimation {
            target: welcomeTextRect
            property: "scale"
            from: 0.1
            to: 1
            duration: 600
            easing.type: Easing.OutBack
            running: root.firstInput ? true : false
        }

    }

}
