Resultate zu Fragen
-------------------

**Wie könnte ein Update-Mechanismus aussehen, der das installierte Paket auf aktuellem Stand hält?**

Die einfache Methode wäre, bei der Initialisierung des Systems, ein Sysinfo (ipkc update sysoinfo) einzufügen, der immer beim Booten nach neuen Updates sucht.

Ansonsten könnte man täglich oder wöchentlich einen Cronjob laufen lassen, der jeweils die Pakete sucht, dann über
* ipkg -cl update   (Aktualisierung der internen Datenbank der Packages)
* ipkg -cl upgrade  (Pakete aktualisieren)
* ipkg -cl install  (Pakete installieren)
die Neuerungen installiert.

**Wie können Sie die Menge der übertragenen Daten, trotz gleichbleibender Funktionalität, reduzieren?**

Einmal wöchentlich einen Cronjob laufen lassen und dabei nur das Binary updaten. Die Daten komprimiert übertragen und eine Versionierung benutzen, so dass nur die versionrelevanten Daten übertragen werden.

**Welche Vorteile bietet so ein Paketverwaltungssystem im Vergleich zur manuellen Softwareinstallation?**

Die Abhängigkeiten eines Paketes werden mit installiert oder zumindest verlangt vor dem Installation und gehen dabei nicht verloren. Eine mühsame Fehlersuche oder Nachinstallation entfällt damit. Ausserdem kann man mit einem Paketverwaltungssystem die Überprüfung auf neue Updates automatisieren und dadurch sein System aktuell halten. 

**Wie können Sie sicherstellen, dass das richtige Softwarepaket installiert wurde und nicht infizierte Schadsoftware eingeschleust wurde? (z.b Übertragung etc.)**

Indem die Checksumme des zu installierenden Paketes überprüft wird. Wobei es auch möglich war, die Überprüfung auf die Checksumme zu umgehen, siehe Bug bei https://cxsecurity.com/cveproduct/35/4487/dpkg/ . Daher ist es wichtig, Pakete nur von den offiziellen Quellen zu installieren. 
Ein weitere sichere Übertragung der Daten wird mit FTPS oder HTTPS ermöglicht.