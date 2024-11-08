import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Controls.Material 2.15  // Import Material style

Window
{
    visible: true
    width  : 900
    height : 600
    title  : "Whiteboard"

    property bool   drawing       : false
    property var    allCanvases   : [{allPaths : [], bgColor : "white"}]
    property int    totalPages    : 1
    property int    currentPageIdx: 1
    property var    allPaths      : allCanvases[currentPageIdx-1].allPaths  // Store all paths drawn by the user, along with their colors
    property var    currentPath   : []                                      // Store the current path being drawn
    property string penColor      : "black"                                 // Current color of the pen
    property string bgColor       : allCanvases[currentPageIdx-1].bgColor     // Background color of the canvas
    property bool   eraserMode    : false                                   // Toggle eraser mode
    property color  eraserColor   : bgColor                                 // Define eraser color (typically the background color)
    property real   eraserRadius  : 20                                      // Radius of the eraser for detecting hits
    property real   pencilWidth   : 2

    Canvas
    {
        id: canvas
        anchors
        {
            fill       : parent
        }
        // antialiasing: true

        onPaint:
        {
            var ctx = canvas.getContext("2d")

            // Fill the canvas with the selected background color
            ctx.fillStyle = bgColor
            ctx.fillRect(0, 0, canvas.width, canvas.height)

            // Draw all previous paths with their respective colors
            for (var j = 0; j < allPaths.length; j++)
            {
                let pathData  = allPaths[j]
                let path      = pathData.path
                let pathcolor = pathData.color
                let lineWidth = pathData.lineWidth

                ctx.lineWidth   = lineWidth
                ctx.strokeStyle = pathcolor  // Use the color stored with the path

                if (path.length > 0) {
                    ctx.beginPath()
                    for (var i = 0; i < path.length; i++)
                    {
                        if (i === 0) {
                            ctx.moveTo(path[i].x, path[i].y)
                        } else {
                            ctx.lineTo(path[i].x, path[i].y)
                        }
                    }
                    ctx.stroke()
                }
            }

            // Draw the current path being drawn with the selected pen color
            if (currentPath.length > 0)
            {
                ctx.lineWidth   = eraserMode ? eraserRadius *2 : pencilWidth  // Increase line width for eraser
                ctx.strokeStyle = eraserMode ? eraserColor     : penColor  // Use eraser color or pen color

                ctx.beginPath()
                for (let i = 0; i < currentPath.length; i++)
                {
                    if (i === 0) {
                        ctx.moveTo(currentPath[i].x, currentPath[i].y)
                    } else {
                        ctx.lineTo(currentPath[i].x, currentPath[i].y)
                    }
                }
                ctx.stroke()
            }

            if (eraserMode)
            {
                ctx.beginPath()
                ctx.arc(mouseArea.mouseX, mouseArea.mouseY, eraserRadius, 0, 2 * Math.PI, false)  // Draw a circle around the mouse
                ctx.lineWidth   = 1
                ctx.strokeStyle = "black"  // You can change the color of the eraser circle if needed
                ctx.stroke()
            }
        }

        MouseArea
        {
            id: mouseArea
            anchors.fill: parent
            onPressed: {
                drawing = true
                currentPath = []  // Start a new path
                currentPath.push({x: mouse.x, y: mouse.y})
                canvas.requestPaint()
            }
            onPositionChanged: {
                if (drawing)
                {
                    currentPath.push({x: mouse.x, y: mouse.y})
                    canvas.requestPaint()
                }
            }
            onReleased: {
                drawing = false
                allPaths.push({path: currentPath, color: eraserMode ? eraserColor : penColor, lineWidth : eraserMode ? eraserRadius *2 : pencilWidth})
                currentPath = []  // Reset current path for next drawing
                allCanvases[currentPageIdx-1].allPaths = allPaths
                allCanvases[currentPageIdx-1].bgColor  = bgColor
            }
        }
    }

    Button
    {
        id : btn_prev
        text: "Previous"
        enabled : currentPageIdx > 1

        anchors
        {
            top : btn_AddCanvas.top
            left: parent.left
            leftMargin : parent.width/14
        }
        onClicked:
        {
            currentPageIdx--;
            canvas.requestPaint()
            bgColor = allCanvases[currentPageIdx -1].bgColor
        }
    }

    Label
    {
        id : lbl_CurrentPage
        text : `${currentPageIdx}/${totalPages}`
        anchors
        {
            top : btn_prev.top
            left: btn_prev.right
            leftMargin : parent.width/40
        }
        font
        {
            pixelSize : 18
        }
    }

    Button
    {
        id : btn_next
        text: "Next"

        enabled : currentPageIdx < totalPages

        anchors
        {
            top : btn_AddCanvas.top
            left: btn_prev.right
            leftMargin : parent.width/14
        }

        onClicked:
        {
            currentPageIdx++;
            canvas.requestPaint()
            bgColor = allCanvases[currentPageIdx -1].bgColor
        }
    }
    Button
    {
        id : btn_AddCanvas
        text : "ADD"
        anchors
        {
            top : btn_eraser.top
            right : btn_eraser.left
            rightMargin : 15
        }
        onClicked :
        {
            totalPages++
            allCanvases.push({allPaths : [], bgColor : "white"})
            currentPageIdx = totalPages
            bgColor = allCanvases[currentPageIdx -1].bgColor
            canvas.requestPaint()
        }
    }
    Button {
        id : btn_eraser
        anchors
        {
            top : parent.top
            topMargin : 10
            horizontalCenter : parent.horizontalCenter
        }
        text: "Toggle Eraser"
        onClicked: {
            eraserMode = !eraserMode
            canvas.requestPaint()
        }
    }
    Button
    {
        id : btn_DeleteCanvas
        text : "DELETE"
        enabled : totalPages > 1
        anchors
        {
            top : btn_eraser.top
            left : btn_eraser.right
            leftMargin : 15
        }
        onClicked :
        {
            allCanvases.splice(currentPageIdx-1, 1)
            totalPages     = allCanvases.length
            currentPageIdx--; currentPageIdx++; //// updating currentPageIdx, so that canvas gets forcefully updated
            if(currentPageIdx > totalPages)
                currentPageIdx = totalPages
            canvas.requestPaint()
        }
    }

    // Pencil color palette on the left side
    Column {
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "Pencil Color"
            font.bold: true
            color: "black"
        }

        Rectangle {
            width: 40
            height: 40
            color: "black"
            border.color: "#ffd700"
            border.width: (penColor === color) ? 10 : 1
            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    penColor = "black"
                }
            }
        }
        Rectangle {
            width: 40
            height: 40
            color: "red"
            border.color: "#ffd700"
            border.width: (penColor === color) ? 10 : 1
            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    penColor = "red"
                }
            }
        }
        Rectangle {
            width: 40
            height: 40
            color: "blue"
            border.color: "#ffd700"
            border.width: (penColor === color) ? 10 : 1
            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    penColor = "blue"
                }
            }
        }
        Rectangle {
            width: 40
            height: 40
            color: "green"
            border.width: (penColor === color) ? 10 : 1
            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    penColor = "green"
                }
            }
        }
    }

    // Background color palette on the right side
    Column {
        spacing: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "Background Color"
            font.bold: true
            color: "black"
        }

        Rectangle {
            width: 40
            height: 40
            color: "white"
            border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bgColor = "white"
                    canvas.requestPaint()  // Redraw the canvas with the new background color
                    allCanvases[currentPageIdx-1].bgColor  = bgColor
                }
            }
        }
        Rectangle {
            width: 40
            height: 40
            color: "lightgray"
            border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bgColor = "lightgray"
                    canvas.requestPaint()  // Redraw the canvas with the new background color
                    allCanvases[currentPageIdx-1].bgColor  = bgColor
                }
            }
        }
        Rectangle {
            width: 40
            height: 40
            color: "yellow"
            border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bgColor = "yellow"
                    canvas.requestPaint()  // Redraw the canvas with the new background color
                    allCanvases[currentPageIdx-1].bgColor  = bgColor
                }
            }
        }
        Rectangle {
            width: 40
            height: 40
            color: "cyan"
            border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bgColor = "cyan"
                    canvas.requestPaint()  // Redraw the canvas with the new background color
                    allCanvases[currentPageIdx-1].bgColor  = bgColor
                }
            }
        }
    }

    // Control buttons at the bottom
    Row {
        spacing: 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            text: "Clear"
            onClicked: {
                allCanvases[currentPageIdx-1].allPaths = []
                currentPath                            = []
                currentPageIdx--; currentPageIdx++; //// updating currentPageIdx, so that canvas gets forcefully updated
                canvas.requestPaint()
            }
        }

        Button {
            text: "Save"
            onClicked: {
                // Saving the canvas with the selected background color
                canvas.save("whiteboard_with_background.png")
                pdfWriter.sampleFunction()
                savePopup.open()
            }
        }
    }

    FolderDialog {
        id   : folderDialog
        title: "Select a Folder to Save the PDF"
        onAccepted:
        {
            console.log("Selected folder: " + selectedFolder)
            pdfWriter.saveCanvasToPDF(selectedFolder, nameField.text, canvas.toDataURL())
        }
    }


    Popup {
        id: savePopup
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        modal: true
        width: parent.width/3
        height: 200

        anchors
        {
            centerIn : parent
        }

        Rectangle
        {
            anchors
            {
                fill : parent
            }

            Column
            {
                anchors
                {
                    centerIn: parent
                }
                TextField {
                    id: nameField
                    placeholderText: "PDF's Name"
                    placeholderTextColor: "#6C6C6C"
                    width : parent.parent.width
                    height: 40
                    font.pixelSize: 18
                    validator: RegularExpressionValidator {
                        regularExpression: /^[a-zA-Z0-9_-]{1,40}$/
                    }
                    onAccepted:
                    {
                        if(text !== "")
                        {
                            folderDialog.open()
                            savePopup.close()
                        }
                    }
                }

                Button {
                    text: "Next"
                    enabled : nameField.text !== ""

                    onClicked: {
                        folderDialog.open()
                        savePopup.close()
                    }
                }
            }
        }
    }
}
