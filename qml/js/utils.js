.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

function getProfiles(){
    var db = Sql.LocalStorage.openDatabaseSync("WeightTracker", "1.0", "Database application", 100000);
    db.transaction(
        function(tx){
            var rs = tx.executeSql('SELECT * FROM USERS');
            if(rs.rows.length > 0){
                profiles = true;
            }
            else profiles=false;
    })
}

function loadUser(val) {
    user_code=val;
    var db = LocalStorage.openDatabaseSync("WeightTracker", "1.0", "Database application", 100000);
    db.transaction(
        function(tx){
            tx.executeSql('UPDATE SETTINGS USER_CODE=?',[user_code]);
        })
}

function getLastUser() {
    var user_code = null;
    var db = Sql.LocalStorage.openDatabaseSync("WeightTracker", "1.0", "Database application", 100000);
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM SETTINGS');
            if(rs.rows.length > 0) {
                 user_code = rs.rows.item(0).USER_CODE;
            } else {
                user_code = null;
            }
    })
    return user_code;
}

function info_user(user_code) {
    var db = Sql.LocalStorage.openDatabaseSync("WeightTracker", "1.0", "Database application", 100000);
    var user_lastname, user_first_name, user_height, metric_code, user_weight, user_height_m, height_square, user_bmi;
    var arrayData = null;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM USERS WHERE USER_CODE=?',[user_code]);
            if (rs.rows.length > 0) {
                user_lastname = rs.rows.item(0).LASTNAME;
                user_first_name = rs.rows.item(0).FIRSTNAME;
                user_height = parseFloat(rs.rows.item(0).HEIGHT);
            }

            rs = tx.executeSql('SELECT MAX(METRIC_CODE) AS METRIC FROM METRICS WHERE USER_CODE=?',[user_code]);
            if (rs.rows.item(0).METRIC===null) user_weight = 0
            else {
                metric_code = rs.rows.item(0).METRIC;
            }

            rs = tx.executeSql('SELECT * FROM METRICS WHERE USER_CODE=? AND CATEGORIE=? AND METRIC_CODE=?',[user_code,"WEIGHT",metric_code]);
            if (rs.rows.length > 0) {
                user_weight = parseFloat(rs.rows.item(0).VAL);
                user_bmi = parseFloat(rs.rows.item(0).IMC);
            }

            rs = tx.executeSql('SELECT * FROM METRICS WHERE USER_CODE=? AND CATEGORIE=? AND METRIC_CODE=?',[user_code,"SLEEP",metric_code]);
            if (rs.rows.length > 0) {
                user_sleep_time = parseFloat(rs.rows.item(0).VAL);
                user_wake_time = parseFloat(rs.rows.item(0).VAL2);
                user_sleep_total = parseFloat(rs.rows.item(0).VAL3);
            }

            arrayData = {
                firstname: user_first_name,
                lastname: user_lastname,
                height: user_height,
                weight: user_weight,
                bmi: user_bmi,
                sleep_time: user_sleep_total,
                wake_time: user_wake_time,
                sleep_total: user_sleep_total
            };
        }
    )
    return arrayData;
}
