$Kompilator = "C:\Users\Ja\source\repos\MINILang\MINILang\output\MINILang.exe"
$Ilasm = "C:/Windows/Microsoft.NET/Framework/v4.0.30319/ilasm.exe"
$Peverify = "C:/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8 Tools/PEVerify.exe"
$Dir = ".\tasks"
$Log = "aa.log"

$score = 0

Write-Host "Testy prawidłowych plików"

Get-ChildItem $Dir -Filter prog??? | 
Foreach-Object {
    $Prog = $_.FullName

    Write-Host $Prog

    & $Kompilator $Prog > $Log
    if($lastExitCode -ne 0)
    {
        Write-Host "Program sie nie skompilowal";
        $score = $score+1
        return;
    }
    & $Ilasm ($Prog + ".il") >> $Log
    if($lastExitCode -ne 0)
    {
        Write-Host "Blad w wygenerowanym kodzie";
        $score = $score+1
        return;
    }
    & $Peverify ($Prog + ".exe") >> $Log
    if($lastExitCode -ne 0)
    {
        Write-Host "Peverify wykrył blad";
        $score = $score+1
        return;
    }
    Start-Process ($Prog + ".exe") -RedirectStandardInput ($Prog + ".in") -RedirectStandardOutput ($Prog + ".out_real") -NoNewWindow -Wait
    if($lastExitCode -ne 0)
    {
        Write-Host "Skompilowany program się wyjebał";
        $score = $score+1
        return;
    }
    $result = $null;
    $result = Compare-Object (Get-Content ($Prog + ".out")) (Get-Content ($Prog + ".out_real"))
    if($result -ne $null)
    {
        Write-Host "Pliki wyjsciowe się nie zgadzaja";
        $score = $score+1
    }
    else
    {
        Write-Host "Success";
    }
}

Write-Host "Liczba bledow: " $score

Write-Host "Testy nieprawidłowych plików"

$score = 0

Get-ChildItem $Dir -Filter fprog??? | 
Foreach-Object {
    $Prog = $_.FullName

    Write-Host $Prog

    & $Kompilator $Prog > $Log
    if($lastExitCode -ne 0)
    {
        Write-Host "Sukces - program sie nie skompilowal";
        return;
    }
    Write-Host "Blad - program sie skompilowal";
    $score = $score+1
}

Write-Host "Liczba bledow: " $score