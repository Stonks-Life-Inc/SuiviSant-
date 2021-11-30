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

    function load() {
        wtData = WtUtils.info_user(user_code);

        WtUtils.getProfiles();
    }

    function calculateBMI() {
        var user_height = wtData.height / 100
        height_square = (user_height * user_height)
        if ((wtData.weight > 0) && (user_height > 0)) {
            bmi = wtData.weight / height_square;
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
        sleepTime = sleepTime.replace(',', '.');
        wakeTime = wakeTime.replace(',', '.');
        //load user_code from homepage, if(depth==3)adding from history else from homepage
        if(depth==3) user_code=previousPage().rootPage.user_code;
        else user_code=previousPage().user_code;
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
                sleepTotal = calculateSleepTotal(sleepTime, wakeTime)
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
        if(depth==3) user_code=previousPage().rootPage.user_code;
        else user_code=previousPage().user_code;
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

                imc = calculateBMI()
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
                        EnterKey.onClicked: phoneField.focus = true
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
        Component {
        id: sleepPage

        Dialog {
            canAccept: sleepMetricField.text!="" && wakeMetricField.text!=""
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

                    TextField {
                        id: sleepMetricField
                        width: parent.width
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        label: "Sleep time"
                        placeholderText: "Sleep time"
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: phoneField.focus = true
                        validator: RegExpValidator { regExp: /^\d+([\.|,]\d{1,2})?$/ }
                        focus: true
                    }
                    TextField {
                        id: wakeMetricField
                        width: parent.width
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        label: "Wake up time"
                        placeholderText: "Wake up time"
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: phoneField.focus = true
                        validator: RegExpValidator { regExp: /^\d+([\.|,]\d{1,2})?$/ }
                        focus: true
                    }
                    Button {
                        text: 'Add'
                        anchors.horizontalCenter: parent.horizontalCenter
                        enabled:sleepMetricField.acceptableInput
                        enabled:wakeMetricField.acceptableInput
                        onClicked: addSleepMetric(sleepMetricField.text, wakeMetricField.text)
                    }
                }
            }
        }
    }
}

