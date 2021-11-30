import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/d3.js" as D3

Page {


    id: page
    allowedOrientations: Orientation.All
    backNavigation: plot.controlNavigation()

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Graph test")
            }

            Label {
                wrapMode: Text.Wrap
                x: Theme.horizontalPageMargin
                width: parent.width - ( 2 * Theme.horizontalPageMargin )
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Testing D3.js library to display graph")
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            SectionHeader {
                text: qsTr("Graph")
            }

            Label {
                wrapMode: Text.Wrap
                x: Theme.horizontalPageMargin
                text: qsTr("Test graph with D3 js library.")
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Canvas {
                id: mycanvas
                width: 100
                height: 200
                onPaint: {
                    var context = plot.getContext('2d');
                    var xScale = d3.scaleLinear()
                      .range([leftMargin, width])
                      .domain([minX, maxX]);
                    var yScale = d3.scaleLinear()
                      .range([height - bottomMargin, 0])
                      .domain([minY, maxY]);
                    var line = d3.line().x(function (d) {
                        return xScale(d[0]);
                      }).y(function (d) {
                        return yScale(d[1]);
                      }).curve(d3.curveNatural).context(context);
                }
            }

        }
    }
}
