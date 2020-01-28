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


import QtQuick 2.3


FocusScope {
    id: root

    property alias filteredModel: grid.model
    property var originalModel

    property alias gridWidth: grid.width
    property int gridMarginTop: 0
    property int gridMarginRight: 0
    property bool memoryLoaded: false

    property alias currentIndex: grid.currentIndex
    readonly property var currentGame: {
        // BUG/FIXME: SortFilterProxyModel returns an 'Object {}' instead of null/undefined
        const src_idx = grid.count
            ? filteredModel.mapToSource(grid.currentIndex)
            : -1;
        return originalModel.get(src_idx);
    }

    signal detailsRequested
    signal launchRequested

    function cells_need_recalc() {
        grid.currentRecalcs = 0;
        grid.cellHeightRatio = 0.5;
    }

    onOriginalModelChanged: if (memoryLoaded && grid.count) currentIndex = 0;

    GridView {
        id: grid

        focus: true

        anchors.top: parent.top
        anchors.topMargin: root.gridMarginTop
        anchors.right: parent.right
        anchors.rightMargin: root.gridMarginRight
        anchors.bottom: parent.bottom

        Keys.onPressed: {
            if (event.isAutoRepeat)
                return;

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

        readonly property int maxRecalcs: 5
        property int currentRecalcs: 0
        property real cellHeightRatio: 0.5

        function update_cell_height_ratio(img_w, img_h) {
            cellHeightRatio = Math.min(Math.max(cellHeightRatio, img_h / img_w), 1.5);
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
            height: GridView.view.cellHeight
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

            onImageLoaded: {
                if (grid.currentRecalcs < grid.maxRecalcs) {
                    grid.currentRecalcs++;
                    grid.update_cell_height_ratio(imageWidth, imageHeight);
                }
            }
        }
    }
}
