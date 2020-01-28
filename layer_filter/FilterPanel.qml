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


import QtQuick 2.6


FocusScope {
    id: root

    property alias withTitle: itemTitle.text
    property alias withMultiplayer: itemMultiplayer.checked
    property alias withFavorite: itemFavorite.checked

    property alias panelColor: panel.color
    property color textColor: "#eee"

    width: content.width
    height: content.height

    Rectangle {
        id: panel
        color: "#ff6235"
        anchors.fill: parent
    }

    Column {
        id: content

        property int normalTextSize: vpx(20)
        property int selectedIndex: 0
        padding: vpx(20)
        spacing: vpx(8)

        width: vpx(300)

        Text {
            id: header
            text: "Filters"
            color: root.textColor
            font.bold: true
            font.pixelSize: vpx(26)
            font.family: globalFonts.sans
            height: font.pixelSize * 1.5
        }

        TextLine {
            id: itemTitle

            placeholder: "title"
            placeholderColor: "#bbb"
            textColor: root.textColor
            fontSize: content.normalTextSize

            focus: true
            KeyNavigation.down: itemFavorite
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: parent.padding
            anchors.rightMargin: parent.padding
        }

        CheckBox {
            id: itemFavorite
            text: "Favorite"
            textColor: root.textColor
            fontSize: content.normalTextSize

            KeyNavigation.down: itemMultiplayer
        }

        CheckBox {
            id: itemMultiplayer
            text: "Multiplayer"
            textColor: root.textColor
            fontSize: content.normalTextSize
        }
    }
}
