import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Connections {
        target: myModel

        onSendToQml: {
            if (count == 1){

            }

            labelCurId.text = "Номер: " + count;
        }
    }

    // Слой с TaxtField`ами и Button для занесения записей в базу данных
    RowLayout {
        id: rowLayout
        anchors.rightMargin: 0
        anchors.leftMargin: 10
        anchors.topMargin: 44
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5

        spacing: 10

        Text {text: qsTr("Дата")}
        TextField {id: fnameField}
        Text {text: qsTr("Оценка")}
        TextField { id: snameField}
        Text {text: qsTr("Текст")}
        TextField {id: nikField}

        Button {
            text: qsTr("Добавить")

            // Вносим новую запись в базу данных
            onClicked: {
                database.inserIntoTable(fnameField.text , snameField.text, nikField.text)
                myModel.updateModel() // И обновляем модель данных с новой записью
            }
        }
    }

    TableView {
        id: tableView
        anchors.rightMargin: 5
        anchors.bottomMargin: 0
        anchors.leftMargin: 5
        anchors.topMargin: 6
        anchors.top: rowLayout.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5

        TableViewColumn {
            role: "fname"
            title: "Имя"
        }
        TableViewColumn {
            role: "sname"
            title: "Фамилия"
        }
        TableViewColumn {
            role: "nik"
            title: "НИК"
        }

        model: myModel

        // Настройка строки в TableView для перехавата левого клика мыши
        rowDelegate: Rectangle {
            anchors.fill: parent
            color: styleData.selected ? 'skyblue' : (styleData.alternate ? 'whitesmoke' : 'white');
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.LeftButton
                onClicked: {
                    tableView.selection.clear()
                    tableView.selection.select(styleData.row)
                    tableView.currentRow = styleData.row
                    tableView.focus = true

                    switch(mouse.button) {
                    case Qt.RightButton:
                        contextMenu.popup() // Вызываем контексткное меню
                        break
                    default:
                        break
                    }
                }
            }
        }
    }

    // Контекстно меню предлагает удаление строки из базы данных
    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Удалить")
            onTriggered: {
                /* Вызываем диалоговое окно,
                 * которое уточнит намерение удалить строку из базы данных
                 * */
                dialogDelete.open()
            }
        }
    }

    // Диалог подтверждения удаления строки из базы данных
    MessageDialog {
        id: dialogDelete
        title: qsTr("Удаление записи")
        text: qsTr("Подтвердите удаление записи из журнала")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel

        // При положительном ответе ...
        onAccepted: {
            /* ... удаляем строку по id,
             * который забираем из модели данных
             * по номеру строки в представлении
             * */
            database.removeRecord(myModel.getId(tableView.currentRow))
            myModel.updateModel();  // Обновляем модель данных
        }
    }

    ComboBox {
        id: comboBox
        x: 10
        y: 11
        width: 399
        height: 20
        currentIndex: 0
                  model: ListModel {
                      id: dbItems
                      ListElement { text: "Пользователи"; curId: 0 }
                      ListElement { text: "Клиент"; curId: 1 }
                      ListElement { text: "Транзакции"; curId: 2 }
                      ListElement { text: "Компания"; curId: 3 }
                      ListElement { text: "Интерфейс"; curId: 4 }
                      ListElement { text: "Локация"; curId: 5 }
                      ListElement { text: "Мнения"; curId: 6 }
                      ListElement { text: "Категории сервисов"; curId: 7 }
                      ListElement { text: "Анонимный клиент"; curId: 8 }
                      ListElement { text: "Контактные ресурсы"; curId: 9 }
                      ListElement { text: "Элементы галереи"; curId: 10 }
                      ListElement { text: "Правовая информация"; curId: 11 }
                  }
    }

    Button {
        id: button
        x: 509
        y: 10
        text: qsTr("Выбрать базу данных")
        onClicked: {
            myModel.setCurDb(comboBox.currentIndex)
        }
    }

    Text {
        id: labelCurId
        x: 425
        y: 14
        width: 50
        height: 17
        text: "Номер: " + qsTr(myModel.getCurDb())
        font.pixelSize: 12
    }
}
