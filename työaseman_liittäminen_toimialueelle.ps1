#----------------------------Alla oleva koodi liittää käyttäjän tietokoneen toimialueelle------------------

# Käyttäjän tietokoneen IP-osoitteen määrittäminen

$satunnaisNumero = Get-Random -Maximum 99
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.20.30.$satunnaisNumero -PrefixLength 24

# Työaseman DNS-palvelimen osoitteen määrittäminen, palvelimella 10.20.30.100
# Tarkistus, onko DNS-palvelimen osoite jo määritetty halutuksi

$tarkistusDNS = Get-DnsClientServerAddress
$dnsOsoitePalvelin = "10.20.30.100"

if($tarkistusDNS -ne $dnsOsoitePalvelin) {
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $dnsOsoitePalvelin
    Write-Output "DNS-osoite on määritetty ja se on: "$dnsOsoitePalvelin
} else {
    Write-Output "DNS osoite on jo $dnsOsoitePalvelin !"
}

# Käyttäjän tietokoneen liittäminen toimialueelle

$haeKansio = Test-Path "C:\Startup_files"
$kansioPolku = "C:\Startup_files"
if($haeKansio -eq $false) {
    Write-Host "Kansiota Startup_files ei löydy. Luodaan uusi..."
    New-Item -Path $kansioPolku -ItemType Directory
    Write-Host "Uusi kansio on luotu (Startup_files)!"
} else {
    Write-Host "Startup_files kansio on jo luotu."
}

#$haeSalasana = Get-Content -Path "C:\Startup_files\password_local_admin.txt"
$salasanaTiedosto = "password_domain_admin.txt"
$testaaSalasanaPolku = Test-Path "C:\Startup_files\password_domain_admin.txt"
$salasanaPolku = "C:\Startup_files\password_domain_admin.txt"
if($testaaSalasanaPolku -eq $false) {
    Write-Host "Tiedostoa ei löydy. Luodaan uusi..."
    New-Item -Path $salasanaPolku -ItemType File
    Write-Host "Uusi tiedosto luotu salasanan hallintaa varten..."
    Write-Host "Lisätään salasana tekstitiedostoon..."
@"
7F6yxyi4!
"@ | Out-File -FilePath $salasanaPolku -Encoding UTF8 -Force
} else {
    Write-Host "Tiedosto $salasanaTiedosto on jo olemassa!"
}

$toimialueNimi = "testimetsa24.edu"
$toimialueAdmin = "workstation.admin"
$toimialueAdminSalasana = Get-Content -Path "C:\Startup_files\password_domain_admin.txt"
Write-Host "Sisältö on: $toimialueAdminSalasana"
$turvallinenSalasana = ConvertTo-SecureString $toimialueAdminSalasana -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential($toimialueAdmin, $turvallinenSalasana)
Write-Output "Credential on: "$credential

$tietokone = Get-WmiObject -Class Win32_ComputerSystem
Write-Output "Get-WmiObject on: "$tietokone

# Tarkistetaan, onko tietokone jo lisätty toimialueelle. Jos sitä ei ole, se lisätään
if($tietokone.Domain -ne $toimialueNimi) {

    try {
        Add-Computer -DomainName $toimialueNimi -Credential $credential -Force
        Write-Output "Tietokone liitettiin onnistuneesti toimialueelle."
        Write-OutPut "Käynnistä tietokone uudelleen saadaksesi muutokset voimaan."
    }
    catch {
        Write-Error "Virhe toimialueelle liittämisessä. Virhe on: $_"
    }
} else {
	Write-Output "Tietokone on jo liitetty toimialueeseen ($toimialueNimi)."
}

# Asetetaan käyttäjälle Network Discovery näkyviin, jos niitä ei ole vielä määritetty
Write-Output "Asetetaan seuraavat asetukset päälle: Network Discovery, File and Printer Sharing..."
Enable-NetFirewallRule -DisplayGroup "Network Discovery"
Write-Output "Suojaussääntö Network Discovery on asetettu."

# Asetetaan käyttäjälle File and Printer Sharing näkyviin, jos niitä ei ole vielä määritetty
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
Write-Output "Suojaussääntö File and Printer Sharing on asetettu."
Write-Output "Valmis."