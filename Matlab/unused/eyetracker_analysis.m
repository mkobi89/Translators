%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Eyetracker Analysis CLINT    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setting parameters and data paths

w_dev = 3;          %allowed deviation of the x-coordinate of a specific fixation to still be accounted for a word
h_dev = 30;         %allowed deviation of the y-coordinate of a specific fixation to still be accounted for a word
path_data = "E:/All_Data/"; % data path
path_savetable = "E:/All_Data/";  %Pfad, wohin Tabelle gespeichert werden soll als String speichern


cd(path_data) %Change to data path

%% Preallocation of results table and group affiliation of subjects

T=cell(10,11); %Preallocation of results table
k = 0; %control variable for current row in T

%look through All_data folder to look for subjects and assign them to groups
group_pilot = [dir('C2*');dir('C3*')]; 
group_traba = [dir('CA*');dir('CB*');dir('CC*');dir('CD*')];
group_trama = [dir('CE*');dir('CF*');dir('CG*');dir('CH*')];
group_trapro = [dir('CI*');dir('CJ*');dir('CK*');dir('CL*')];
group_mulba = [dir('CM*');dir('CN*');dir('CO*');dir('CP*')];
group_mulma = [dir('CQ*');dir('CR*');dir('CS*');dir('CT*')];
group_mulpro = [dir('CU*');dir('CV*');dir('CW*');dir('CX*')];

group_all = [group_pilot;group_traba;group_trama;group_trapro;group_mulba;group_mulma;group_mulpro]; %Get all subjects

group_size_pilot = size(group_pilot); %Determining size of group to know, how long result tables have to be 
group_size_traba = size(group_traba);
group_size_trama = size(group_trama);
group_size_trapro = size(group_trapro);
group_size_mulba = size(group_mulba);
group_size_mulma = size(group_mulma);
group_size_mulpro = size(group_mulpro);
group_size_all = size(group_all);



z=1; %control variable to loop through subjects &determine in which subgroub subject is

while z <= group_size_all(1,1) %control statement to keep z below amount of all subjects

    cd(path_data+"\"+group_all(z,1).name) %open folder of current subject
    
    fullresults = dir("Fullresults*");
    load(fullresults.name); %load original answer file 
    
    sentences_ue{1, 1}{1, 30}  = strrep(sentences_ue{1, 1}{1, 30}, '.  ','.'); %get rid of unnecessary space at the end of sentence 30
    
    x=1; %control variable if text 1 or text 2 is processed
    
    if z <= group_size_pilot(1,2) %solange z kleiner als Anzahl aller Piloten --> muss Gruppe Pilot sein
        group = 'Pilot';
    elseif z <= group_size_pilot(1,2)+group_size_traba(1,2) %z muss also grösser als Anzahl aller Piloten sein. Wenn trotzdem kleiner als Anzahl aller Piloten und aller Traba --> muss Gruppe Traba sein
        group = 'TraBA';
    elseif z <= group_size_pilot(1,2)+group_size_traba(1,2)+group_size_trama(1,2) %z muss also grösser sein als Anzahl aller Piloten und Trabas. Wenn trotzdem kleiner als Anzahl aller Piloten, Trabas und Trama --> muss Gruppe Trama sein
        group = 'TraMA';
    elseif z <= group_size_pilot(1,2)+group_size_traba(1,2)+group_size_trama(1,2)+group_size_trapro(1,2) %usw. Prinzip von oben
        group = 'TraPro';
    elseif z <= group_size_pilot(1,2)+group_size_traba(1,2)+group_size_trama(1,2)+group_size_trapro(1,2)+group_size_mulba(1,2)
        group = 'MulBA';
    elseif z <= group_size_pilot(1,2)+group_size_traba(1,2)+group_size_trama(1,2)+group_size_trapro(1,2)+group_size_mulba(1,2)+group_size_mulma(1,2)
        group = 'MulMA';
    elseif z <= group_size_pilot(1,2)+group_size_traba(1,2)+group_size_trama(1,2)+group_size_trapro(1,2)+group_size_mulba(1,2)+group_size_mulma(1,2)+group_size_mulpro(1,2)
        group = 'MulPro';
    end
    
    while x <= 2 %darf nicht grösser als 2 werden, da nur zwei Texte
        text = dir(strjoin("*_E"+x+"*ET.mat"));
        load(text.name); %Laden des jeweiligen Textes innerhalb des Probandenordners
        i = 1; %Variable um mit while-Schleife event durchzulaufen
        while event(i,2) < 101 && event(i,2) > 112 %i wird erhöht solange bis Starttrigger gefunden wird
            i = i + 1;
        end
        if event (i,2) == 101 %Schleife für Starttrigger 101
            q = k + 1; %k zu Zeitpunkt neuer Starttrigger (wichtige Info für Regression-Bestimmung)
            i = i + 2; %Überspringen der 11, da keine Implikationen für Programm, direkt zur ersten 21
            j = 1; %Variable für while-Schleife in eyeevent.fixations.data
            sentence = 0; %Variable welche Nummer des präsentierten Satzes mitzählt
            while event (i,2) == 21 %solange event 21 ist, wird neuer Satz präsentiert
                sentence= sentence + 1; %Satzzähler wird um 1 erhöht
                splitsentence= strsplit(sentences_ue{1,1}{1,sentence+1},{' ', '\\n'}); %Wörter welche sich im Satz befinden werden aufgesplitet und einzeln in Array abgespeichert
                while eyeevent.fixations.data(j,1) < event(i,1) %solange Zeit bei eyeevent.fixations.data tiefer als bei momentanem event, wurde noch kein Satz präsentiert und fixation somit uninteressant
                    j=j+1; %gehe zur nächsten Zeile in eyeevent.fixations.data
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1) %solange Zeit bei eyeevent.fixations.data tiefer als bei nächstem event, befinden wir uns noch bei Fixationen von momentan präsentiertem Satz
                    k = k + 1; %zu bearbeitende Zeile wird 1 nach untern verschoben
                    T{k,1}=group_all(z,1).name; %ersten Spalte der Zeile mit Namen der Versuchsperson
                    T{k,2}=group; %zweite Spalte der Zeile mit Gruppe der Versuchsperson
                    T{k,3}='Text1'; %dritte Spalte der Zeile mit 'Text1', weil event 101
                    T{k,4}='SE'; %vierte Spalte der Zeile mit 'SE', weil event 101
                    T{k,5}='first'; %fünfte Spalte der Zeile mit 'first', weil event 101
                    T{k,6}=sentence; %sechste Spalte der Zeile mit Satznummer
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1); %neunte SPalte der Zeile mit Dauer der Fixation
                    T{k,10}=eyeevent.fixations.data(j,6); %zehnte Spalte der Zeile mit Avg.PS
                    n=1; %Variable für whileschlaufe für wordbounds_reading (enthält Koordinaten der Wörter)
                    words=size(wordbounds_reading{1,1}{1,sentence+1});%Anzahl der Wörter(bzw derer Koordinaten) für jeweiligen Satz
                    while wordbounds_reading{1,1}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,1}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5) %solange Koordinaten der Fixation nicht innerhalb des Koordinatenrasters des Wortes wird zum nächsten Wort gesprungen
                        n = n + 1; %Sprung zum nächsten Wort (bzw Koordinatenraster des Wortes)
                        if words(1,1) < n %wenn n grösser ist als die Anzahl Wörter(bzw. derer Koordinaten) ist Fixation keinem Wort zuzuordnen
                            T{k,7}="unknown"; %siebte Spalte der Zeile mit "unknown" da kein Wort
                            break %Sprung aus dieser Whileschlaufe
                        end
                    end
                    if words(1,1) >= n %wenn n kleinergleich ist als die Anzahl Wörter(bzw. derer Koordinaten) ist Fixation einem Wort zuordenbar
                        T{k,7}= "word"; %siebte Spalte der Zeile mit "word" da Wort
                        T{k,8}= splitsentence(1,n); %achte Spalte der Zeile mit Abruf, welches Wort es ist
                        T{k,11}= n; %elfte Spalte der Zeile mit Wortnummer (ohne String)
                        
                    end
                    j = j+1; %gehe zur nächsten Zeile in eyeevent.fixations
                end
                i = i + 1; %gehe zur nächsten Zeile in event und solang event = 21 zu neuem Satz
            end
        elseif event (i,2) == 102 %Schleife für Starttrigger 102, siehe bei Schleife 101 für Erklärungen (nur Änderungen bei T{k,3},T{k,4} und T{k,5} da je nach starttrigger unterschiedlich)
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            while event (i,2) == 22
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,2}{1,sentence+1},{' ', '\\n'});
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(z,1).name;
                    T{k,2}=group;
                    T{k,3}='Text1';
                    T{k,4}='ELF';
                    T{k,5}='first';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,2}{1,sentence+1});
                    while wordbounds_reading{1,2}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{1,sentence+1}(n,2) - h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,2}{1,sentence+1}(n,3) + w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{sentence+1}(n,4) + h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}="unknown";
                            break
                        end
                    end
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        elseif event (i,2) == 103 %Schleife für Starttrigger 103, siehe bei Schleife 101 für Erklärungen (nur Änderungen bei T{k,3},T{k,4} und T{k,5} da je nach starttrigger unterschiedlich)
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            while event (i,2) == 23
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,3}{1,sentence+1},{' ', '\\n'});
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(z,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='SE';
                    T{k,5}='first';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,3}{1,sentence+1});
                    while wordbounds_reading{1,3}{1,sentence+1}(n,1) - w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{1,sentence+1}(n,2) - h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,3}{1,sentence+1}(n,3) + w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{sentence+1}(n,4) + h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}="unknown";
                            break
                        end
                    end
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        elseif event (i,2) == 104 %Schleife für Starttrigger 104, siehe bei Schleife 101 für Erklärungen (nur Änderungen bei T{k,3},T{k,4} und T{k,5} da je nach starttrigger unterschiedlich)
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            while event (i,2) == 24
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,4}{1,sentence+1},{' ', '\\n'});
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(z,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='ELF';
                    T{k,5}='first';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,4}{1,sentence+1});
                    while wordbounds_reading{1,4}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,4}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}="unknown";
                            break
                        end
                    end
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        elseif event (i,2) == 109 %Schleife für Starttrigger 109, siehe bei Schleife 101 für Erklärungen (nur Änderungen bei T{k,3},T{k,4} und T{k,5} da je nach starttrigger unterschiedlich)
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            while event (i,2) == 21
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,1}{1,sentence+1},{' ', '\\n'});
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(z,1).name;
                    T{k,2}=group;
                    T{k,3}='Text1';
                    T{k,4}='SE';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,1}{1,sentence+1});
                    while wordbounds_reading{1,1}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,1}{1,sentence+1}(n,3) +w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{sentence+1}(n,4) + h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}="unknown";
                            break
                        end
                    end
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        elseif event (i,2) == 110 %Schleife für Starttrigger 110, siehe bei Schleife 101 für Erklärungen (nur Änderungen bei T{k,3},T{k,4} und T{k,5} da je nach starttrigger unterschiedlich)
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            while event (i,2) == 22
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,2}{1,sentence+1},{' ', '\\n'});
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(z,1).name;
                    T{k,2}=group;
                    T{k,3}='Text1';
                    T{k,4}='ELF';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,2}{1,sentence+1});
                    while wordbounds_reading{1,2}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,2}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}="unknown";
                            break
                        end
                    end
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        elseif event (i,2) == 111 %Schleife für Starttrigger 111, siehe bei Schleife 101 für Erklärungen (nur Änderungen bei T{k,3},T{k,4} und T{k,5} da je nach starttrigger unterschiedlich)
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            while event (i,2) == 23
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,3}{1,sentence+1},{' ', '\\n'});
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(z,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='SE';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,3}{1,sentence+1});
                    while wordbounds_reading{1,3}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,3}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}="unknown";
                            break
                        end
                    end
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        elseif event (i,2) == 112 %Schleife für Starttrigger 112, siehe bei Schleife 101 für Erklärungen (nur Änderungen bei T{k,3},T{k,4} und T{k,5} da je nach starttrigger unterschiedlich)
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            while event (i,2) == 24
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,4}{1,sentence+1},{' ', '\\n'});
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(z,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='ELF';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,4}{1,sentence+1});
                    while wordbounds_reading{1,4}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{1,sentence+1}(n,2) -h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,4}{1,sentence+1}(n,3) + w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{sentence+1}(n,4)+ h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}="unknown";
                            break
                        end
                    end
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        end
        %Regressionsteil ala Basil gelöst (nicht gut, Prakti-Pfusch)
        while q < k %solange erste k-Zeile der Eventschleife (q) tiefer als jetziges k
            y=q+1; %y soll eine Zeile unter q starten
            while y <= k && T{y,6} == T{q,6} %solange y nicht grösser als k (also Ende der Tabelle) und Satznummer(sentence) von y und q gleich sind
                if T{y,11} == T{q,11} %wenn Wort aus Zeile q gleich wie Wort aus Zeile y dann ist es eine Regression
                    T{y,7}="regression";
                end
                y=y+1; %nächstes Wort eine Zeile tiefer mit q vergleichen
            end
            q=q+1; %wenn erstes Wort ganz verglichen mit allen Wörtern im Satzevent, gehe ich eine Zeile tiefer
        end
        %regression fertig
        
        x=x+1; %x erhöhen um zweiten Text des Probanden zu laden
    end
    z=z+1; %z erhöhen um zu nächsten Probanden zu gelangen
end

T_words=cell(10,11); %Tabelle vorbereiten für Tabelle nur mit den Wörtern ohne Regressionen und "unknown"
h=1; %für Schleife durch Tabelle T
o=1; %für Schleife um in T_words zu schreiben
while h <= k %solange h nicht grösser als Tabelle insgesamt
    if T{h,7} == "word" %wenn siebte Spalte in h-ter Zeile "word" ist übernehme ich die Daten aus der gesamten Zeile in t_words
        T_words{o,1}=T{h,1};
        T_words{o,2}=T{h,2};
        T_words{o,3}=T{h,3};
        T_words{o,4}=T{h,4};
        T_words{o,5}=T{h,5};
        T_words{o,6}=T{h,6};
        T_words{o,7}=T{h,7};
        T_words{o,8}=T{h,8};
        T_words{o,9}=T{h,9};
        T_words{o,10}=T{h,10};
        T_words{o,11}=T{h,11};
        o=o+1; %nächste Zeile in T_words
    end
    h=h+1; %nächste Zeile in T
end

cd(path_savetable);

Table_Readingdata = table(T(:,1),T(:,2),T(:,3),T(:,4),T(:,5),T(:,6),T(:,7),T(:,8),T(:,9),T(:,10),T(:,11),'VariableNames', {'id','group','text','condition','time','sentence','type','word','duration','avgPS','wordNumber'});

writetable(Table_Readingdata,'Eyetracking_Daten_Basil.csv','FileType','spreadsheet'); %Abspeicherung der Tabelle in oben vorgegebenem Ordner