import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../js/utils.js" as WtUtils

Page {
    id: newMetric
    backNavigation: true
    allowedOrientations: Orientation.All

    property string metric_code;
    property string user_code;
    property variant wtData;
    property string sleepTimeVal;
    property string wakeTimeVal;
    property string sleepTotal;

    function load() {
        wtData = WtUtils.info_user(user_code);

        WtUtils.getProfiles();
    }

    function calculateBMI() {

        var user_height = WtUtils.height / 100
        var height_square = (user_height * user_height)
        if ((WtUtils.weight > 0) && (user_height > 0)) {
            bmi = WtUtils.weight / height_square;
            // recommended_min_weight = 18.5 * height_square
            // recommended_max_weight = 24.9 * height_square
            // recommended_weight_description = "The recommended weight for your height is between " + recommended_min_weight.toFixed(2) + " kg and " + recommended_max_weight.toFixed(2) + " kg"
            // calculate_bmi_category();
        }
    }

    function calculateSleepTotal(sleepTime, wakeTime) {
        sleepTotal = sleepTime - wakeTime;

    }

    function addSleepMetric(sleepTime, wakeTime){
        //sleepTime = sleepTime.replace(',', '.');
        //wakeTime = wakeTime.replace(',', '.');
        //load user_code from homepage, if(depth==3)adding from history else from homepage
        //if(depth==3) user_code=previousPage().rootPage.user_code;
        //else user_code=previousPage().user_code;
        var db = LocalStorage.openDatabaseSync("WeightTracker", "1.0", "Database application", 100000);
        db.transaction(
            function(tx){
                var rs = tx.executeSql('SELECT MAX(METRIC_CODE) AS METRIC FROM METRICS ');
                if(rs.rows.item(0).METRIC===null) metric_code="1"
                else{
                    metric_code = rs.rows.item(0).METRIC;
                    metric_code = parseInt(metric_code) +1;
                }
                var date = new Date();
                date = Qt.formatDate(date, "yyyy-MM-dd");
                //sleepTotal = calculateSleepTotal(sleepTime, wakeTime)
                rs = tx.executeSql('INSERT INTO METRICS VALUES (?,?,?,?,?,?,?)',[user_code,metric_code,date,"SLEEP",sleepTime, wakeTime, sleepTotal]);
                rs = tx.executeSql('SELECT * FROM METRICS WHERE USER_CODE=?',[user_code]);
            }
        )
        //reload homepage if adding from homepage or history if adding metric from history page
        previousPage().load();
        //reload homepage if add from history page
        if(depth==3) previousPage().rootPage.load();
        navigateBack(PageStackAction.Animated);
    }


    function addWeightMetric(value){
        value = value.replace(',', '.');
        //load user_code from homepage, if(depth==3)adding from history else from homepage
        //if(depth==3) user_code=previousPage().rootPage.user_code;
        //else user_code=previousPage().user_code;
        var db = LocalStorage.openDatabaseSync("WeightTracker", "1.0", "Database application", 100000);
        db.transaction(
            function(tx){
                var rs = tx.executeSql('SELECT MAX(METRIC_CODE) AS METRIC FROM METRICS ');
                if(rs.rows.item(0).METRIC===null) metric_code="1"
                else{
                    metric_code = rs.rows.item(0).METRIC;
                    metric_code = parseInt(metric_code) +1;
                }
                var date = new Date();
                date = Qt.formatDate(date, "yyyy-MM-dd");

                var imc = calculateBMI()
                rs = tx.executeSql('INSERT INTO METRICS VALUES (?,?,?,?,?,?)',[user_code,metric_code,date,"WEIGHT",value, imc]);
                rs = tx.executeSql('SELECT * FROM METRICS WHERE USER_CODE=?',[user_code]);
            }
        )
        //reload homepage if adding from homepage or history if adding metric from history page
        previousPage().load();
        //reload homepage if add from history page
        if(depth==3) previousPage().rootPage.load();
        navigateBack(PageStackAction.Animated);
    }

    SilicaFlickable {

        PullDownMenu {
            MenuItem {
                text: "Add weight"
                onClicked: pageStack.animatorPush(weightPage)
            }
            MenuItem {
                text: "Sleep"
                onClicked: pageStack.animatorPush(sleepPage)
            }

            MenuLabel { text: "Menu" }
        }

        anchors.fill: parent
        contentHeight: column.height
    }

    Column {
        id: mainColumn
        x: Theme.paddingLarge
        width:page.width
        spacing: Theme.paddingLarge

        PageHeader{
            title: qsTr("Add metric")
        }

        ///////////////////////////////////////////////////////////////
        //  Page pour rajouter une données de type WEIGHT dans la BD //
        ///////////////////////////////////////////////////////////////
        Component {
            id: weightPage

            Dialog {
                canAccept: weightMetricField.text!=""
                acceptDestination: page
                acceptDestinationAction: PageStackAction.Pop

                Flickable {
                    width: parent.width
                    height: parent.height

                    Column {
                        id: dialogColumn
                        x: Theme.paddingLarge
                        width: page.width
                        spacing: Theme.paddingLarge

                        PageHeader { title: 'Add new weight metric' }

                        TextField {
                            id: weightMetricField
                            width: parent.width
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            label: "kg"
                            placeholderText: "Weight"
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"

                            validator: RegExpValidator { regExp: /^\d+([\.|,]\d{1,2})?$/ }
                            focus: true
                        }
                        Button {
                            text: 'Add'
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled:weightMetricField.acceptableInput
                            onClicked: addWeightMetric(weightMetricField.text)
                        }
                    }
                }
            }
        }


        ///////////////////////////////////////////////////////////////
        //  Page pour rajouter une données de type SLEEP dans la BD  //
        ///////////////////////////////////////////////////////////////
        Component {
            id: sleepPage

            Dialog {
                canAccept: sleepTime.text!="" && wakeTime.text!=""
                acceptDestination: page
                acceptDestinationAction: PageStackAction.Pop

                Flickable {
                    width: parent.width
                    height: parent.height

                    Column {
                        id: dialogColumn
                        x: Theme.paddingLarge
                        width: page.width
                        spacing: Theme.paddingLarge

                        PageHeader { title: 'Add new sleep metric' }

                        Button {
                             id: sleepTime
                             text: "Choose a sleeping time"

                             onClicked: {
                                 var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                     hour: 22,
                                     minute: 30,
                                     hourMode: DateTime.TwelveHours
                                 })
                                 dialog.accepted.connect(function() {
                                     sleepTimeVal = dialog.timeText
                                 })
                             }
                         }
                        Button {
                             id: wakeTime
                             text: "Choose a waking time"

                             onClicked: {
                                 var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                     hour: 22,
                                     minute: 30,
                                     hourMode: DateTime.TwelveHours
                                 })
                                 dialog.accepted.connect(function() {
                                     wakeTimeVal = dialog.timeText
                                 })
                             }
                         }
                        Button {
                            text: 'Add'
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled:sleepMetricField.acceptableInput, wakeMetricField.acceptableInput
                            onClicked: addSleepMetric(sleepTimeVal, wakeTimeVal.text)
                        }
                    }
                }
            }
        }
    }
}
