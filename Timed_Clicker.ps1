<#
Obecne rady:
1) je dobre ukoncit vsechny programy, ktere vyuzivaji hodne CPU (hry, hudbu, video,...).
2) je taky idealni si synchronizovat systemovy cas pres Start > Nastaveni > Cas a jazyk > Datum a cas > Dalsi nastaveni > synchronizovat.
3) Zkuste si prikazem "ping cs98.divokekmeny.cz" bez uvozovek zjistit latenci (time=XXms) od vas k serveru. Pokud je latence vice nez 60ms, budete mozna muset jeste odecist nejake ms z casu kliknuti, aby se to kompenzovalo.
4) Urcite si udelejte par cvicnych behu, at vite, jake mate celkove latence, podle toho pocitejte casy

Autor: Daniel Miks
Verze: 1.0 - Prvni vydani
Skript je poskytován tak, jak je, nenesu žádnou odpovědnost za případné škody způsobené tímto skriptem.
#>

# KROK 1 - Oznac blok textu mezi hranicemi a stiskni F8. Zpresneni systemoveho timeru, je potreba spoustet 1x vzdy pri otevreni tohoto skriptu. Po ukonceni PowerShell procesu se opet uvede do puvodniho stavu.
# Zdroj: https://xkln.net/blog/powershell-sleep-duration-accuracy-and-windows-timers/
#----------------------------------------------------------------------------------------------------------------
$timeBeginPeriod = @'
[DllImport("winmm.dll", SetLastError=true)]
public static extern uint timeBeginPeriod(uint uPeriod);
'@

$timeEndPeriod = @'
[DllImport("winmm.dll", SetLastError=true)]
public static extern uint timeEndPeriod(uint uPeriod);
'@

$WinMM = Add-Type -MemberDefinition $timeBeginPeriod,$timeEndPeriod -Name 'WinMM' -Namespace 'Win32' -PassThru
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;

#Aktivace zpresneni
$WinMM::timeBeginPeriod(1)
#----------------------------------------------------------------------------------------------------------------


# KROK 2 - Oznac blok textu mezi hranicemi a stiskni F8. Overeni, ze timer je spravne nastaveny. Pokud je hodnota vystupu kolem 15, pak je nastaveni spatne. Musi být okolo 0.8.
#----------------------------------------------------------------------------------------------------------------
function MeasureDelay([int]$Sleep) {
    $Start = [System.Diagnostics.Stopwatch]::GetTimestamp()
    [System.Threading.Thread]::Sleep($Sleep)
    $End = [System.Diagnostics.Stopwatch]::GetTimestamp()
    (($End - $Start) * (1000.0 / [System.Diagnostics.Stopwatch]::Frequency)) - $Sleep
}

1..100 | % {MeasureDelay 1} | Measure-Object -Average | Select -ExpandProperty Average
#----------------------------------------------------------------------------------------------------------------

# KROK 3 - Do hodnoty $Cas_nastaveny zadej cas, kdy chces, aby skript klikl. Oznac blok textu mezi hranicemi a stiskni F8. Skript zacne cekat na nastaveny cas.
    #Mezitim si priprav utok/obranu ve hre tak, aby stacilo jen kliknout na tlacitko k poslani jednotek. Pak umisti kurzor nad tlacitko a cekej.
#Zdroj: https://stackoverflow.com/questions/39353073/how-i-can-send-mouse-click-in-powershell
#----------------------------------------------------------------------------------------------------------------
$Cas_nastaveny = "19:56:02.521"
$Cas_realny = Get-Date -Format HH:mm:ss.fff
do{
    $Cas_realny = Get-Date -Format HH:mm:ss.fff
} until ($Cas_realny -ge $Cas_nastaveny)

#left mouse click
[W.U32]::mouse_event(6,0,0,0,0);

Write-Host "Cas ukonceni smycky: $($Cas_realny)" -ForegroundColor Cyan
$Cas_realny = Get-Date -Format HH:mm:ss.fff
$Rozdil = [System.DateTime]$Cas_realny-[System.DateTime]$Cas_nastaveny
#([System.DateTime]$Cas_realny-[System.DateTime]$Cas_nastaveny).Milliseconds | Out-File C:\Temp\DK_Latence.txt -Append
Write-Host "Cas vykonani akce: $($Cas_realny)" -ForegroundColor Green
Write-Host "Doba trvani: $($Rozdil.Milliseconds) ms" -ForegroundColor Yellow
#----------------------------------------------------------------------------------------------------------------
