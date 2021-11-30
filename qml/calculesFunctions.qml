import QtQuick 2.0


Item {
    property double bmi: 0.0;
    property string bmi_text;
    property double height_bmi: 0.0;
    property double weight_bmi: 0.0;
    property double recommended_min_weight: 0.0;
    property double recommended_max_weight: 0.0;
    property string category_bmi;
    property string category_bmi_description;
    property string recommended_weight_description;
    property double height_square: 0.0;

    function calculate() {
        weight_bmi = weightField.value
        height_bmi = heightField.value / 100

        height_square = (height_bmi * height_bmi)

        if ((weight_bmi > 0) && (height_bmi > 0)) {
            bmi = weight_bmi / height_square;
            recommended_min_weight = 18.5 * height_square
            recommended_max_weight = 24.9 * height_square
            recommended_weight_description = "The recommended weight for your height is between " + recommended_min_weight.toFixed(2) + " kg and " + recommended_max_weight.toFixed(2) + " kg"
            calculate_bmi_category();
        }

        bmi_text = "Your BMI is: " + bmi.toFixed(2);
    }

    function calculate_bmi_category() {
        if (bmi < 18.5) {
            category_bmi = "Underweight";
            category_bmi_description = "Your weight is under the recommended values. Talk to your doctor for medical advice."
        } else if (bmi < 25) {
            category_bmi = "Normal weight";
            category_bmi_description = "Your weight is in the normal category for adults of your height."
        } else if (bmi < 30) {
            category_bmi = "Overweight (pre-obesity)";
            category_bmi_description = "Your weight is above the recommended values. Talk to your doctor for medical advice."
        } else if (bmi < 35) {
            category_bmi = "Obese Class I";
            category_bmi_description = "Your weight is high above the recommended values. People who are overweight or obese are at higher risk for chronic conditions such as high blood pressure, diabetes, and high cholesterol. Talk to your doctor for medical advice."
        } else if (bmi < 40) {
            category_bmi = "Obese Class II";
            category_bmi_description = "Your weight is high above the recommended values. People who are overweight or obese are at higher risk for chronic conditions such as high blood pressure, diabetes, and high cholesterol. Talk to your doctor for medical advice."
        } else if (bmi >= 40) {
            category_bmi = "Obese Class III";
            category_bmi_description = "Your weight is high above the recommended values. People who are overweight or obese are at higher risk for chronic conditions such as high blood pressure, diabetes, and high cholesterol. Talk to your doctor for medical advice."
        } else {
            category_bmi = "Unkown category";
            category_bmi_description = ""
        }
    }

}
