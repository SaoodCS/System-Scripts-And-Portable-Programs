#SingleInstance Force
#Persistent
#Include ..\..\Packages\XInput.ahk

; Initialize the XInput library
XInput_Init()

; Set a timer to poll the controller state every 100 milliseconds
SetTimer, PollController, 100
return

PollController:
    ; Get the state of controller 0 (first controller)
    state := XInput_GetState(0)
    if (!state) {
        ToolTip, Controller not connected.
        return
    }

    ; Extract button states
    buttons := state.wButtons
    leftTrigger := state.bLeftTrigger
    rightTrigger := state.bRightTrigger
    thumbLX := state.sThumbLX
    thumbLY := state.sThumbLY
    thumbRX := state.sThumbRX
    thumbRY := state.sThumbRY

    ; Build a string to display the controller state
    info := "Buttons Pressed:`n"
    if (buttons & XINPUT_GAMEPAD_A)
        info .= "XINPUT_GAMEPAD_A "
    if (buttons & XINPUT_GAMEPAD_B)
        info .= "XINPUT_GAMEPAD_B "
    if (buttons & XINPUT_GAMEPAD_X)
        info .= "XINPUT_GAMEPAD_X "
    if (buttons & XINPUT_GAMEPAD_Y)
        info .= "XINPUT_GAMEPAD_Y "
    if (buttons & XINPUT_GAMEPAD_LEFT_SHOULDER)
        info .= "XINPUT_GAMEPAD_LEFT_SHOULDER "
    if (buttons & XINPUT_GAMEPAD_RIGHT_SHOULDER)
        info .= "XINPUT_GAMEPAD_RIGHT_SHOULDER "
    if (buttons & XINPUT_GAMEPAD_BACK)
        info .= "XINPUT_GAMEPAD_BACK "
    if (buttons & XINPUT_GAMEPAD_START)
        info .= "XINPUT_GAMEPAD_START "
    if (buttons & XINPUT_GAMEPAD_DPAD_UP)
        info .= "XINPUT_GAMEPAD_DPAD_UP "
    if (buttons & XINPUT_GAMEPAD_DPAD_DOWN)
        info .= "XINPUT_GAMEPAD_DPAD_DOWN "
    if (buttons & XINPUT_GAMEPAD_DPAD_LEFT)
        info .= "XINPUT_GAMEPAD_DPAD_LEFT "
    if (buttons & XINPUT_GAMEPAD_DPAD_RIGHT)
        info .= "XINPUT_GAMEPAD_DPAD_RIGHT "
    if (buttons & XINPUT_GAMEPAD_LEFT_THUMB)
        info .= "XINPUT_GAMEPAD_LEFT_THUMB "
    if (buttons & XINPUT_GAMEPAD_RIGHT_THUMB)
        info .= "XINPUT_GAMEPAD_RIGHT_THUMB "

    ; Add trigger and thumbstick information
    info .= "`n`nTriggers:`n"
    info .= "leftTrigger: " . leftTrigger . "`n"
    info .= "rightTrigger: " . rightTrigger . "`n"

    info .= "`nThumbsticks:`n"
    info .= "thumbLX=" . thumbLX . " thumbLY=" . thumbLY . "`n"
    info .= "thumbRX=" . thumbRX . " thumbRY=" . thumbRY

    ; Display the information in a tooltip
    ToolTip, %info%
return
