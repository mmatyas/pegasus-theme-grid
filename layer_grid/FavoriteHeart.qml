// Pegasus Frontend
// Copyright (C) 2017-2019  Mátyás Mustoha
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
import QtGraphicalEffects 1.0

Item {
    width: img.width
    height: img.height
    rotation: 10

    Image {
        id: img
        source: "../assets/icons/heart_filled.svg"
        sourceSize { width: 32; height: 32 }
        asynchronous: true
        fillMode: Image.PreserveAspectFit

        width: vpx(26)
        height: width
    }

    ColorOverlay {
        anchors.fill: img
        source: img
        color: "#d22"
    }
}
