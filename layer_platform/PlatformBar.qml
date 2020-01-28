// Pegasus Frontend
// Copyright (C) 2017-2020  Mátyás Mustoha
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


import QtQuick 2.0
import "qrc:/qmlutils" as PegasusUtils

Rectangle {
    property alias model: platformPath.model
    property alias currentIndex: platformPath.currentIndex
    readonly property var currentCollection: model.get(currentIndex)

    color: "#333"
    height: vpx(54)

    function next() {
        platformPath.incrementCurrentIndex();
    }
    function prev() {
        platformPath.decrementCurrentIndex();
    }

    PathView {
        id: platformPath
        delegate: platformCardDelegate

        path: Path {
            startX: vpx(-400)
            startY: vpx(36)
            PathAttribute { name: "itemZ"; value: 201 }

            PathLine { x: parent.width * 0.2; y: vpx(36) }
            PathPercent { value: 0.04 }
            PathAttribute { name: "itemZ"; value: 200 }

            PathLine { x: parent.width * 0.23; y: vpx(18) }
            PathPercent { value: 0.08 }
            PathAttribute { name: "itemZ"; value: 199 }

            PathLine { x: parent.width * 0.7; y: vpx(18) }
            PathPercent { value: 1 }
            PathAttribute { name: "itemZ"; value: 0 }
        }

        pathItemCount: 20

        snapMode: PathView.SnapOneItem
        preferredHighlightBegin: 0.04
        preferredHighlightEnd: 0.05
    }

    Component {
        id: platformCardDelegate

        PlatformCard {
            platformShortName: modelData.shortName
            isOnTop: PathView.isCurrentItem
            z: PathView.itemZ
            width: parent.parent.width * 0.5
            height: vpx(72)
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: {
            wheel.accepted = true;
            if (wheel.angleDelta.x > 0 || wheel.angleDelta.y > 0)
                next();
            else
                prev();
        }
    }
    PegasusUtils.HorizontalSwipeArea {
        anchors.fill: parent
        onSwipeLeft: next()
        onSwipeRight: prev()
    }
}
