import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../js/utils.js" as WtUtils

Page {
    id: page
    backNavigation: true
    allowedOrientations: Orientation.All

    property string metric_code;
    property string user_code;

    property variant wtData;
    property date sleepTimeVal;
    property date wakeTimeVal;
    property int sleepTotalValH;
    property int sleepTotalValM;

    function load() {
        wtData = WtUtils.info_user(user_code);

        //WtUtils.getProfiles();
    }

    function calculateBMI(weight) {
        var bmi;
        var user_height = wtData.height / 100
        var height_square = (user_height * user_height)
        bmi = weight / height_square;
        print("BMI = " + bmi)
        return bmi
    }

    function calculateSleepTotal(sleepTime, wakeTime) {

        //TODO: Sleep total time calc
        sleepTotalValH = wakeTime.getHours() - sleepTime.getHours()
        sleepTotalValM = wakeTime.getMinutes() - sleepTime.getMinutes()

        print(totalSleepTimeHOUR, totalSleepTimeMIN, totalSleepTimeVal)

    }

    function addSleepMetric(){
        print("Adding new sleep")
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
                //var sleepTotalVal = calculateSleepTotal(sleepTimeVal, wakeTimeVal)
                rs = tx.executeSql('INSERT INTO METRICS VALUES (?,?,?,?,null,null,null,?,?,?,?,?,?)',[user_code,metric_code,date,"SLEEP",sleepTimeVal.getHours(),sleepTimeVal.getMinutes(), wakeTimeVal.getHours(), wakeTimeVal.getMinutes(), sleepTotalValH, sleepTotalValM]);
                rs = tx.executeSql('SELECT * FROM METRICS WHERE USER_CODE=?',[user_code]);
                //Debug print to display added data
                print("New sleep data : \n",
                      "User code : " + user_code + "\n",
                      "Metric code : " + metric_code + "\n",
                      "Date : " + date + "\n",
                      "Type : SLEEP \n",
                      "Sleeping time : " + sleepTimeVal.getHours() + ":" + sleepTimeVal.getMinutes() + "\n",
                      "Waking time : " + wakeTimeVal.getHours() + ":" + wakeTimeVal.getMinutes() + "\n",
                      "Total sleep time : " + sleepTotalValH + ":" + sleepTotalValM + "\n")
            }
        )
        //reload homepage if adding from homepage or history if adding metric from history page
        previousPage().load();
        //reload homepage if add from history page
        if(depth==3) previousPage().load();
        navigateBack(PageStackAction.Animated);
    }


    function addWeightMetric(value){
        var imc = calculateBMI()
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

                imc = calculateBMI(value)

                rs = tx.executeSql('INSERT INTO METRICS VALUES (?,?,?,?,?,?,null,null,null,null,null,null,null)',[user_code,metric_code,date,"WEIGHT",value, imc]);
                rs = tx.executeSql('SELECT * FROM METRICS WHERE USER_CODE=?',[user_code]);
                print("New weight data : \n",
                      "User code : " + user_code + "\n",
                      "Metric code : " + metric_code + "\n",
                      "Date : " + date + "\n",
                      "Type : WEIGHT \n",
                      "Weight : " + value + "\n",
                      "IMC : " + imc + "\n")
            }
        )
        //reload homepage if adding from homepage or history if adding metric from history page
        previousPage().load();
        //reload homepage if add from history page
        if(depth==3) previousPage().load();
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

        Column {
            id: mainColumn
            x: Theme.paddingLarge
            width:page.width
            spacing: Theme.paddingLarge

            PageHeader{
                title: qsTr("Add a new metric")
            }

            Label {
                text: qsTr("You can add your metric here")
                width:page.width
                color: Theme.secondaryHighlightColor
            }
            Label {
                text: qsTr("At the moment you can add:")
                width:page.width
                color: Theme.secondaryHighlightColor
            }
            Label {
                text: qsTr("Your weight to get your BMI calculated")
                width:page.width
                color: Theme.secondaryHighlightColor
            }
            Label {
                text: qsTr("Your sleep shcedule to track your sleep regularity")
                width:page.width
                color: Theme.secondaryHighlightColor
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
                            id: weightDialogColumn
                            x: Theme.paddingLarge
                            width: page.width
                            spacing: Theme.paddingLarge

                            DialogHeader { title: 'Add new weight metric' }

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
                        }
                    }
                    onAccepted: {
                        addWeightMetric(weightMetricField.text)
                        page.load();
                    }
                }
            }

        ///////////////////////////////////////////////////////////////
        //  Page pour rajouter une données de type SLEEP dans la BD  //
        ///////////////////////////////////////////////////////////////
        Component {
            id: sleepPage

            Dialog {
                canAccept: sleepTime.text!="Choose a sleeping time" && wakeTime.text!="Choose a waking time"
                //acceptDestination: page
                acceptDestinationAction: PageStackAction.Pop

                Flickable {
                    width: parent.width
                    height: parent.height

                    Column {
                        id: sleepDialogColumn
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
                                     hourMode: DateTime.TwentyFourHours
                                 })
                                 dialog.accepted.connect(function() {
                                     sleepTimeVal = dialog.time
                                     print(sleepTimeVal.getHours() + ":" + sleepTimeVal.getMinutes())
                                     sleepTime.text = "Choose a sleeping time: " + dialog.timeText
                                 })
                             }
                         }
                        Button {
                             id: wakeTime
                             text: "Choose a waking time"

                             onClicked: {
                                 var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                     hour: 8,
                                     minute: 30,
                                     hourMode: DateTime.TwentyFourHours
                                 })
                                 dialog.accepted.connect(function() {
                                     wakeTimeVal = dialog.time
                                     print(wakeTimeVal.getHours() + ":" + wakeTimeVal.getMinutes())
                                     wakeTime.text = "Choose a waking time: " + dialog.timeText
                                 })
                             }
                         }
                    }
                 }
                onAccepted: {
                    addSleepMetric()
                    page.load();

                }
            }
        }
        Component.onCompleted:{
            user_code = WtUtils.getLastUser()
            load()
            print(user_code)
        }
    }
}
}
