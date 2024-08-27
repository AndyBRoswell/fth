function fth {
    [CmdletBinding(DefaultParameterSetName = 'in')]
    param(
        [Parameter(Position=0, ParameterSetName='in')][Parameter(Position=0, ParameterSetName='pin')][Parameter(Position=0, ParameterSetName='lpin')][string]$RE,
        [Parameter(Position=1, ValueFromPipeline=$true, ParameterSetName='in')][string]$InputObject,
        [Parameter(ParameterSetName='pin')][string[]]$Paths,
        [Parameter(ParameterSetName='lpin')][string[]]$LiteralPaths
    )

    if ($PSCmdlet.MyInvocation.BoundParameters.Count -eq 0) {
        echo "fth <RE> [-InputObject <InputObject> | -Paths <Paths> | -LiteralPaths <LiteralPaths>]"
        echo '<InputObject> and <file> cannot be both empty and cannot be both designated.'
        return
    }
    if (-not $RE) { write-error '$RE cannot be empty.'; return }
    if (-not $InputObject -and -not $Paths -and -not $LiteralPaths) { write-error '$InputObject, $Paths and $LiteralPaths cannot be all empty.'; return }

    $foreach_block = {
        $line = $_
        $ret = sls $RE -inp $line -a
        $startPos = 0
        foreach ($match in $ret.Matches) {
            $substr = $line.Substring($startPos, $match.Index - $startPos)
            Write-Host $substr -n
            Write-Host $match.Value -n -f Yellow
            $startPos = $match.Index + $match.Length
        }
        Write-Host $line.Substring($startPos)
    }

    if ($InputObject) { $InputObject | % -proc $foreach_block } 
    elseif ($Paths) { cat $Paths | % -proc $foreach_block } 
    else { cat -li $LiteralPaths | % -proc $foreach_block }
}
