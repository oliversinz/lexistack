$script:adbPath = 'C:/Users/olive/AppData/Local/Android/sdk/platform-tools/adb.exe'
$script:evidencePath = 'C:/Codex/LexiStack/docs/evidence/f4-d01'
function A {
  $line = "$(Get-Date -Format o) adb -s emulator-5554 $($args -join ' ')"
  Add-Content "$script:evidencePath/android-commands.txt" $line
  $result = & $script:adbPath -s emulator-5554 @args 2>&1
  $code = $LASTEXITCODE
  $result | Add-Content "$script:evidencePath/android-commands.txt"
  Add-Content "$script:evidencePath/android-commands.txt" "EXIT CODE: $code"
  $result
  if ($code -ne 0) { throw "adb failed: $line" }
}
function Dump {
  A shell uiautomator dump /sdcard/f4d01-window.xml | Out-Null
  A pull /sdcard/f4d01-window.xml "$script:evidencePath/current.xml" | Out-Null
  [xml]$script:screenXml = Get-Content -Raw "$script:evidencePath/current.xml"
}
function ShowUi {
  Dump
  $script:screenXml.SelectNodes('//node') | Where-Object { $_.'content-desc' -or $_.text } |
    Select-Object text,content-desc,bounds,enabled,selected | Format-Table -Wrap
}
function TapLabel([string]$label) {
  Dump
  $node = $script:screenXml.SelectNodes('//node') | Where-Object { $_.'content-desc' -eq $label -or $_.text -eq $label } | Select-Object -First 1
  if (-not $node) { throw "No visible node: $label" }
  $xy = [regex]::Matches($node.bounds,'\d+') | ForEach-Object { [int]$_.Value }
  A shell input tap ([int](($xy[0]+$xy[2])/2)) ([int](($xy[1]+$xy[3])/2)) | Out-Null
}
function Snap([string]$name) {
  Dump
  A shell screencap -p /sdcard/f4d01-screen.png | Out-Null
  A pull /sdcard/f4d01-screen.png "$script:evidencePath/$name.png" | Out-Null
  Dump
  Copy-Item -LiteralPath "$script:evidencePath/current.xml" -Destination "$script:evidencePath/$name.xml"
}
function DragLabels([string]$source, [string]$target) {
  Dump
  $points = @()
  foreach ($label in @($source,$target)) {
    $node = $script:screenXml.SelectNodes('//node') | Where-Object { $_.'content-desc' -eq $label } | Select-Object -First 1
    if (-not $node) { throw "No visible drag node: $label" }
    $xy = [regex]::Matches($node.bounds,'\d+') | ForEach-Object { [int]$_.Value }
    $points += ,@([int](($xy[0]+$xy[2])/2),[int](($xy[1]+$xy[3])/2))
  }
  A shell input motionevent DOWN $points[0][0] $points[0][1] | Out-Null
  Start-Sleep -Milliseconds 750
  A shell input motionevent MOVE $points[1][0] $points[1][1] | Out-Null
  Start-Sleep -Milliseconds 160
  A shell input motionevent UP $points[1][0] $points[1][1] | Out-Null
}
