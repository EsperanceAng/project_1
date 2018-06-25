import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.0

Window {
    id: mainwindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Список цветов")

    property variant colorName: []
    property variant colorResult: []

    function returnColor (index){
        var color = ["red", "green", "blue", "purple", "yellow", "black", "grey", "white", "teal", "lime",
                     "aqua", "fuchsia","chocolate", "maroon", "olive", "darkBlue", "yellowGreen", "skyBlue",
                     "silver", "tomato","indigo", "coral", "cornsilk", "darkSlateGray", "goldenrod", "Pink", "OrangeRed", "Khaki","IndianRed", "DeepPink"];
        return color[index];
    }
    function returnColorName (index){
        var color = ["Красный", "Зеленый", "Синий", "Пурпурный", "Желтый", "Черный", "Серый", "Белый", "Непонятный", "Лаймовый",
                     "Голубой", "Розовый","Оранжевый", "Темно-Красный", "Оливковый", "Темно-Синий", "Желто-Зеленый", "Светло-Голубой",
                     "Серебряный", "Томатный","Индиго", "Коралловый", "Песчаный", "Серо-Зеленый", "Золотой", "Светло-Розовый", "Красно-Оранжевый", "Хаки", "Светлый красный", "Яркий розовый"];
        return color[index];
    }

    function colorSaving(color, colorname)
    {
        var db = LocalStorage.openDatabaseSync("ColorDB", "1.0", "Colors", 10000);

        db.transaction(function(tx) {
                tx.executeSql('INSERT INTO Colors(color, colorname) VALUES(?, ?)', [color, colorname]);
            })
    }


    function colorReadAll()
    {
        var colorResult = [];
        var nameResult = [];
        var result = [];
        var db = LocalStorage.openDatabaseSync("ColorDB", "1.0", "Colors", 10000);

        db.transaction(function (tx) {
            var results = tx.executeSql('SELECT * FROM Colors')
            var s = 0;

            for (var i = 0; i < results.rows.length; i++)
                {
                    colorResult[i] = results.rows.item(i).color;
                    nameResult[i] = results.rows.item(i).colorname;

                    for (var j = 0; j < 2; j++)
                    {
                        if (j == 0) {result[s] = colorResult[i]}
                        else if (j == 1) {result[s] = nameResult[i]}
                        s += 1;
                    }
                }
        })
        return result;
    }


    StackView {
        id: page_stack
        anchors.fill: parent
        initialItem: mainpage
    }

    ListModel {
            id: dataModel
        }

    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("ColorDB", "1.0", "Colors", 10000);

        db.transaction(function(tx){
            tx.executeSql('CREATE TABLE IF NOT EXISTS Colors(id AUTO_INCREMENT, color TEXT, colorname TEXT)');
        })

        colorResult = colorReadAll();

        for (var i = 0; i < colorResult.length; i += 2)
        {
            dataModel.append({color: colorResult[i], text: colorResult[i + 1]})
        }
    }

    Component {
        id:mainpage

        Rectangle {

            Row {
                id: row
                height: 50
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                z: 2

                Rectangle {
                    width: parent.width
                    height: 50

                    Rectangle {
                        id: rect1
                        width: (parent.width / 6) * 2 - 10
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 10

                        Button {
                            id: button_create
                            anchors.fill: parent
                            text: "Добавить готовый"
                            onClicked: { page_stack.push(select_color_page) }
                        }
                    }
                    Rectangle {
                        id: rect2
                        width: (parent.width / 6) * 2 - 20
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: rect1.right
                        anchors.margins: 10

                        Button {
                            id: button_input
                            anchors.fill: parent
                            text: "Ввести вручную"
                            onClicked: { page_stack.push(input_color_page) }
                        }
                    }
                    Rectangle {
                        id: rect3
                        width: (parent.width / 6) * 2 - 10
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: rect2.right
                        anchors.margins: 10

                        Button {
                            id: button_delete
                            anchors.fill: parent
                            text: "Очистить список"
                            onClicked: {
                                dataModel.clear()
                                var db = LocalStorage.openDatabaseSync("ColorDB", "1.0", "Colors", 10000);
                                db.transaction(function(tx){
                                tx.executeSql('DELETE FROM Colors');
                                })
                            }
                        }
                    }
                }
            }

            ListView {
                id: listview
                spacing: 10
                model: dataModel
                anchors.top: row.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                delegate: Item {
                    id: listitem

                    width: parent.width
                    height: 40

                    Rectangle {
                        anchors.fill: parent
                        radius: 3
                        color: model.color
                        border {
                            color: "black"
                            width: 1
                        }

                        Text {
                            anchors.centerIn: parent
                            text: model.text
                            color: (model.color === "black" || model.color === "blue") ? "white" : "black"
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                colorName = [model.color, model.text]
                                page_stack.push(color_page)
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: select_color_page

        Rectangle {
            id: rect
            ScrollView {
                width: parent.width
                height: parent.height
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                Grid {
                    rows: 6; columns: 5; spacing: 10
                    Repeater {
                        id: repeater
                        model: 30
                        Rectangle {
                            width: rect.width / 5 - 10
                            height: rect.height / 5 - 10
                            id: button
                            color: returnColor(index)
                            border.color: "black"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    dataModel.append({color: returnColor(index), text:returnColorName(index) })
                                    colorSaving(returnColor(index), returnColorName(index))
                                    page_stack.pop()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    Component {
        id: input_color_page

        Row {
            id: row
            height: 50
            z: 2

            Rectangle {
                width: parent.width
                height: 50

                Rectangle {
                    id: rect1
                    width: (parent.width / 5)
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 10

                    Button {
                        id: button_create
                        anchors.fill: parent
                        text: "Добавить"
                        onClicked: {
                            if (textInput_1.text != "" && textInput_2.text != "")
                            {
                                dataModel.append({color: textInput_1.text, text: textInput_2.text})
                                colorSaving(textInput_1.text, textInput_2.text)
                                textInput_1.text = ""
                                textInput_2.text = ""
                                page_stack.pop()
                            }
                        }

                    }
                }
                Rectangle {
                    id: rect2
                    width: (parent.width / 5) * 2 - 20
                    height: 30
                    radius: 3
                    border.color: "black"

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: rect1.right
                    anchors.margins: 10

                    TextInput {
                        id: textInput_1
                        font.family: "Times New Roman"
                        font.pointSize: 10
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Keys.onPressed: {
                            // 16777220 - код клавиши Enter
                            if(event.key === 16777220){
                                if (textInput_1.text != "" && textInput_2.text != "")
                                {
                                    dataModel.append({color: textInput_1.text, text: textInput_2.text})
                                    textInput_1.text = ""
                                    textInput_2.text = ""
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: rect3
                    height: 30
                    radius: 3
                    border.color: "black"

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: rect2.right
                    anchors.margins: 10

                    TextInput {
                        id: textInput_2
                        font.family: "Times New Roman"
                        font.pointSize: 10
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Keys.onPressed: {
                            // 16777220 - код клавиши Enter
                            if(event.key === 16777220){
                                if (textInput_1.text != "" && textInput_2.text != "")
                                {
                                    dataModel.append({color: textInput_1.text, text: textInput_2.text})
                                    textInput_1.text = ""
                                    textInput_2.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id:color_page
        Loader {
            id: loader
            sourceComponent: color
        }
    }

    Component {
        id: color
        Rectangle {
            anchors.fill: parent
            color: colorName[0]

            Text {
                text: colorName[1]
                color: (colorName[0] === "yellow" || colorName[0] === "white") ? "black" : "white"
                anchors.centerIn: parent
                font.pixelSize: 30
                renderType: Text.NativeRendering
            }
            Button {
                 width: 120
                 height: 30
                 anchors.right: parent.right
                 anchors.bottom: parent.bottom
                 onClicked: page_stack.pop()
                 Text {
                     text: "Назад"
                     anchors.centerIn: parent
                     renderType: Text.NativeRendering
                 }
             }
        }
    }
}
