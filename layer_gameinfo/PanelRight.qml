// Pegasus Frontend
// Copyright (C) 2017-2018  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import QtQuick 2.6
import QtMultimedia 5.9


Item {
    property var game

    onGameChanged: {
        videoPreview.state = "";
        videoPreview.stop();
        videoPreview.playlist.clear();
        videoDelay.restart();
    }

    // a small delay to avoid loading videos during scrolling
    Timer {
        id: videoDelay
        interval: 300
        onTriggered: {
            if (game && game.assets.videos.length > 0) {
                for (var i = 0; i < game.assets.videos.length; i++)
                    videoPreview.playlist.addItem(game.assets.videos[i]);

                videoPreview.play();
                videoPreview.state = "playing";
            }
        }
    }


    Image {
        id: logo
        width: parent.width
        height: width * 0.35

        asynchronous: true
        source: (game && game.assets.logo) || ""
        sourceSize { width: 512; height: 192 }
        fillMode: Image.PreserveAspectFit

        // title
        Text {
            color: "#eee"
            text: (game && game.title) || ""

            width: parent.width * 0.8
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter

            font {
                bold: true
                pixelSize: vpx(30)
                capitalization: Font.SmallCaps
                family: globalFonts.sans
            }

            visible: parent.status != Image.Ready && parent.status != Image.Loading
        }
    }

    // year -- developer / publisher -- players
    Text {
        id: releaseDetails
        width: parent.width
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter

        anchors.top: logo.bottom
        topPadding: vpx(16)
        bottomPadding: vpx(16)

        text: {
            if (!game)
                return "";

            const parts = [];

            if (game.releaseYear) {
                parts.push(game.releaseYear);
            }
            if (game.developer || game.publisher) {
                if (game.developer === game.publisher) {
                    parts.push(game.developer);
                }
                else {
                    const str = [game.developer, game.publisher]
                        .filter(Boolean)
                        .join(' / ');
                    parts.push(str);
                }
            }
            if (game.players > 1) {
                let str = '\u263b\u2060'.repeat(Math.min(game.players, 4));
                if (game.players > 4)
                    str += '+';
                parts.push(str);
            }

            return parts.join(' \u2014 ');
        }
        color: "#eee"
        font {
            pixelSize: vpx(18)
            family: globalFonts.sans
        }

        visible: text
    }

    Text {
        id: summary
        width: parent.width
        wrapMode: Text.WordWrap

        anchors.top: releaseDetails.bottom
        topPadding: vpx(20)
        bottomPadding: vpx(40)

        text: game ? (game.summary || game.description) : ""
        color: "#eee"
        font {
            pixelSize: vpx(16)
            family: globalFonts.sans
        }
        maximumLineCount: 4
        elide: Text.ElideRight

        visible: text
    }

    Rectangle {
        id: videoBox
        color: "#000"
        border { color: "#444"; width: 1 }

        anchors.top: summary.bottom
        anchors.bottom: parent.bottom

        width: parent.width
        radius: vpx(4)

        visible: (game && (game.assets.videos.length || game.assets.screenshots.length)) || false

        Image {
            visible: !videoPreview.visible || videoPreview.opacity < 0.99

            anchors { fill: parent; margins: 1 }
            fillMode: Image.PreserveAspectFit

            source: (game && game.assets.screenshots.length && game.assets.screenshots[0]) || ""
            sourceSize { width: 512; height: 512 }
            asynchronous: true
        }

        Video {
            id: videoPreview
            visible: playlist.itemCount > 0 && opacity > 0
            opacity: 0

            anchors { fill: parent; margins: 1 }
            fillMode: VideoOutput.PreserveAspectFit

            playlist: Playlist {
                playbackMode: Playlist.Loop
            }

            states: State {
                name: "playing"
                PropertyChanges { target: videoPreview; opacity: 1 }
            }
            transitions: Transition {
                from: ""; to: "playing"
                NumberAnimation { properties: 'opacity'; duration: 1000 }
            }
        }
    }
}
