
function Disconnect-UserSession
{
    <#
    
    .SYNOPSIS
    Log out the current user.

    #>
    
    param(
        [switch]$Force
    )

    $kCoreEventClass = 'aevt'

    $kAELogOut = 'logo'
    $kAEReallyLogOut = 'rlgo'

    $eventId = $Force ? $kAEReallyLogOut : $kAELogOut

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
}

function Restart-MacComputer
{
    <#
    
    .SYNOPSIS
    Restart the computer.

    #>
    
    param(
        [switch]$Force
    )
    
    $kCoreEventClass = 'aevt'

    $kAEShowRestartDialog = 'rrst'
    $kAERestart = 'rest'

    $eventId = $Force ? $kAERestart : $kAEShowRestartDialog

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
}


function Stop-MacComputer
{
    <#
    
    .SYNOPSIS
    Shut Down the computer.

    #>

    param(
        [switch]$Force
    )

    $kCoreEventClass = 'aevt'

    $kAEShowShutdownDialog = 'rsdn'
    $kAEShutDown = 'shut'

    $eventId = $Force ? $kAEShutDown : $kAEShowShutdownDialog

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
}

function Suspend-MacComputer
{
    <#
    
    .SYNOPSIS
    Put the computer to sleep.

    #>
    
    $kCoreEventClass = 'aevt'
    $kAESleep = 'slep'

    $eventId = $kAESleep

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
}
