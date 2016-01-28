==Aufgabe 4==

* Erklären Sie den Unterschied zwischen Interrupt Level und Kernel Level.
Kernel-Ebene. Nach einem Software-Interrupt wird Code auf der Kernel-Ebene abgearbeitet. Diesem Code stehen sämtliche Funktionalitäten des Betriebssystemkerns zur Verfügung – auch die Funktionalität, das Verarbeiten des Codes für einige Zeit anzuhalten (schlafen zu legen) oder Daten zwischen den Speicherbereichen der Applikationen und des Kernels zu übertragen. Applikationsgetriggerte Funktionen eines Gerätetreibers, Systemcalls, Kernel-Threads und damit auch Workqueues werden in dieser Prozess-Kontext genannten Umgebung abgearbeitet.

Code im Prozess-Kontext wird nur durch einen Hardware-Interrupt unterbrochen. Die zugehörigen Hardware-ISRs können dafür sorgen, dass – bevor das Codefragment zu Ende bearbeitet wird – zwischendurch anderer Code im Prozess-Kontext abgearbeitet wird.

Darüber hinaus kann jede Funktion der Kernelebene auf einer Mehrprozessormaschine mehrfach parallel abgearbeitet werden.

ISR-Ebene. Interrupt-Service-Routinen laufen auf der ISR-Ebene ab. Dieser Code ist normalerweise nicht unterbrechbar, es sei denn, die Unterbrechbarkeit ist vom Entwickler explizit erwünscht. Der Kontext ist ebenfalls der Interrupt-Kontext. Auch den ISRs ist es damit untersagt, sich schlafen zu legen oder Funktionen aufzurufen, die einen Rechenprozess schlafen legen wollen.
* Skizzieren Sie ein Beispiel für einen kritischen Abschnitt innerhalb eines Treibers.

* Was ist ein Spinlock? Läßt sich ein Spinlock auf einem Einprozessorsystem einsetzen?
Ein Spinlock (Spin-Lock) ist ein Mechanismus zur Prozesssynchronisation. Es ist eine Sperre (Lock) zum Schutz einer gemeinsam genutzten Ressource durch konkurrierende Prozesse bzw. Threads (siehe Kritischer Abschnitt) nach dem Prinzip des wechselseitigen Ausschlusses (Mutex).
* Worin besteht der Unterschied zwischen einem Spinlock und einem Semaphor?
Der Einsatz von Semaphoren funktioniert nur bei Prozessen bzw. Routinen, die im Prozess-Kontext aktiv sind. Semaphore legen Prozesse schlafen, was sie im Kernelkontext nicht dürfen.
* Über welche Technologien lassen sich kritische Abschnitte schützen?
Atomare Variablen, Semaphore, Spinlocks, Sequencelocks,  Interruptsperre und Kernel-Lock, Memory Barriers, Synchronisiert warten
* Nennen Sie zwei Ausprägungen von Softirqs.
* Nennen Sie zwei Ausprägungen von Kernel-Threads.
* Welche Ressourcen werden durch den Kernel verwaltet und müssen daher vom Treiber angefordert werden?
* Über welchen Mechanismus kann ein Linux-Treiber Ausgaben machen?
* Welche Instanz versetzt eine Applikation in den Zustand wartend?
* Was ist ein Tasklet?
* Was passiert, wenn man innerhalb eines Treibers eine Workqueue aufgesetzt hat, der Treiber wieder entladen wird aber die Workqueue nicht aufgeräumt wird (Begründung)?
* Welche Bedeutung hat die globale Variable jiffies im Linux-Kernel?
