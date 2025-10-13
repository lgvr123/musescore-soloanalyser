import QtQuick 2.9
import QtQuick.Controls 2.2

/**********************
/
/**********************************************/

Button {
    id: control
    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.6
        color: (mscoreMajorVersion >= 4)? ui.theme.fontPrimaryColor : sysActivePalette.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    
    SystemPalette {
        id: sysActivePalette;
        colorGroup: SystemPalette.Active
    }

}
