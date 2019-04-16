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


import QtQuick 2.3
import SortFilterProxyModel 0.2


FocusScope {
    id: root

    property alias gridWidth: grid.width
    property int gridMarginTop: 0
    property int gridMarginRight: 0
    property bool memoryLoaded: false

    property string filterTitle: ""

    property var platform
    property alias gameIndex: grid.currentIndex
    readonly property bool gameIndexValid: 0 <= gameIndex && gameIndex < grid.count
    readonly property int srcGameIndex: gameIndexValid ? filteredGames.mapToSource(gameIndex) : -1
    readonly property var currentGame: srcGameIndex >= 0 ? platform.games.get(srcGameIndex) : null

    signal detailsRequested
    signal filtersRequested
    signal nextPlatformRequested
    signal prevPlatformRequested
    signal launchRequested

    onPlatformChanged: if (memoryLoaded && grid.count) gameIndex = 0;

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevPlatformRequested();
            return;
        }
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextPlatformRequested();
            return;
        }
        if (api.keys.isDetails(event)) {
            event.accepted = true;
            detailsRequested();
            return;
        }
        if (api.keys.isFilters(event)) {
            event.accepted = true;
            filtersRequested();
            return;
        }
    }

    SortFilterProxyModel {
        id: filteredGames
        sourceModel: platform.games
        filters: RegExpFilter {
            roleName: "title"
            pattern: filterTitle
            caseSensitivity: Qt.CaseInsensitive
        }
    }

    GridView {
        id: grid

        focus: true

        anchors {
            top: parent.top; topMargin: root.gridMarginTop
            right: parent.right; rightMargin: root.gridMarginRight
            bottom: parent.bottom
        }

        function cells_need_recalc() {
            firstImageLoaded = false;
            cellHeightRatio = 0.5;
        }

        model: filteredGames
        onModelChanged: cells_need_recalc()
        onCountChanged: cells_need_recalc()


        Keys.onPressed: {
            if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
                event.accepted = true;
                var rows_to_skip = Math.max(1, Math.round(grid.height / cellHeight));
                var games_to_skip = rows_to_skip * columnCount;
                if (api.keys.isPageUp(event))
                    currentIndex = Math.max(currentIndex - games_to_skip, 0);
                else
                    currentIndex = Math.min(currentIndex + games_to_skip, model.count - 1);
            }
        }

        // For better visibility, box arts should be displayed in five columns if
        // the boxes are "tall", and four if they are "wide". There are two issues:
        //
        //   1. We don't want to hardcode the column count per platforms, so we need
        // a way to decide it in runtime. The problem is, because the images are
        // loaded asynchronously and individually, we don't know their dimensions!
        // Also technically images can have arbitrary sizes, that is, mixed tall and
        // wide images. As a workaround/heuristic, the first loaded image is used as
        // a base for further calculations.
        //
        //   2. GridView is too stupid to automatically set the cell dimensions,
        // we have to do it manually. Loop bindings and such also have to be avoided.

        property real columnCount: {
            if (cellHeightRatio > 1.2) return 5;
            if (cellHeightRatio > 0.6) return 4;
            return 3;
        }

        property bool firstImageLoaded: false
        property real cellHeightRatio: 0.5

        function calcHeightRatio(imageW, imageH) {
            cellHeightRatio = 0.5;

            if (imageW > 0 && imageH > 0)
                cellHeightRatio = imageH / imageW;
        }


        cellWidth: width / columnCount
        cellHeight: cellWidth * cellHeightRatio;

        displayMarginBeginning: anchors.topMargin

        highlight: Rectangle {
            color: "#0074da"
            width: grid.cellWidth
            height: grid.cellHeight
            scale: 1.20
            z: 2
        }

        highlightMoveDuration: 0

        delegate: GameGridItem {
            width: GridView.view.cellWidth
            selected: GridView.isCurrentItem

            game: modelData

            onClicked: GridView.view.currentIndex = index
            onDoubleClicked: {
                GridView.view.currentIndex = index;
                root.detailsRequested();
            }
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    root.launchRequested();
                }
            }

            imageHeightRatio: {
                if (grid.firstImageLoaded) return grid.cellHeightRatio;
                return 0.5;
            }
            onImageLoaded: {
                // NOTE: because images are loaded asynchronously,
                // firstImageLoaded may appear false multiple times!
                if (!grid.firstImageLoaded) {
                    grid.firstImageLoaded = true;
                    grid.calcHeightRatio(imageWidth, imageHeight);
                }
            }
        }
    }
}
