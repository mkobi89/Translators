function [sentences_l,sentences_l_g,sentences_ue]=files

SI_SE_sentences_file = 'ABS_Social_Info_SE.csv';
SI_ELF_sentences_file = 'ABS_Social_Info_ELF.csv';
EA_SE_sentences_file = 'ABS_Energy_Advisors_SE.csv';
EA_ELF_sentences_file = 'ABS_Energy_Advisors_ELF.csv';

SI_SE_sentences_raw=readtable(SI_SE_sentences_file,'FileEncoding', 'UTF-8');
SI_ELF_sentences_raw=readtable(SI_ELF_sentences_file,'FileEncoding', 'UTF-8');
EA_SE_sentences_raw=readtable(EA_SE_sentences_file,'FileEncoding', 'UTF-8');
EA_ELF_sentences_raw=readtable(EA_ELF_sentences_file,'FileEncoding', 'UTF-8');

sentences_l_pre{1} = SI_SE_sentences_raw.Sentence;
sentences_l_pre{2} = SI_ELF_sentences_raw.Sentence;
sentences_l_pre{3} = EA_SE_sentences_raw.Sentence;
sentences_l_pre{4} = EA_ELF_sentences_raw.Sentence;

absatz{1} = SI_SE_sentences_raw.Absatz;
absatz{2} = SI_ELF_sentences_raw.Absatz;
absatz{3} = EA_SE_sentences_raw.Absatz;
absatz{4} = EA_ELF_sentences_raw.Absatz;


sentences_l_p = cell(1,4);


for t = 1:4
sentences_l_x{t}=cell(1,max(absatz{1,t}));
sentences_l_g_p{t}=cell(1,max(absatz{1,t}));
end

maxChars = 81;

% Files for Uebersetzen

for t=1:4
    for i=1:length(sentences_l_pre{t})
%         for t = 2
%             for i = 2:20
        s=sentences_l_pre{t}{i};
        s = strrep(s,' ','  ');
        nBreaks = 0;
        if length(s)>maxChars
            
            
            j = maxChars;
            
            while true
                
                nBreaks= nBreaks + 1;
                
                if strcmp(s(j+1),' ')
                else
                    while ~ strcmp(s(j),' ')
                        j=j-1;
                    end
                end
                
                if ~strcmp(s(j),' ') && strcmp(s(j+1),' ')
                    s=[s(1:j) '\n' s(j+3:end)];
                    j = j+4 + maxChars;
                elseif strcmp(s(j),' ') && strcmp(s(j+1),' ')
                    s=[s(1:j-1) '\n' s(j+2:end)];
                    j = j+3 + maxChars;
                elseif strcmp(s(j),' ') && ~strcmp(s(j+1),' ')
                    s=[s(1:j-2) '\n' s(j+1:end)];
                    j = j+2 + maxChars;
                end
                
                
                if j >= length(s)
                    break
                end
            end
            sentences_ue{t}{i}=s;
            nBreaks_ue_all(t,i)=nBreaks;
        else
            nBreaks_ue_all(t,i)=0;
            sentences_ue{t}{i}=s;
        end
    end
end


% Lesen Gesamt mit Absätzen

for t=1:4
     for i = 2: length(sentences_l_pre{t})
         k = absatz{t}(i); 
         sentences_l_x{t}{k} = [sentences_l_x{t}{k},sentences_l_pre{t}{i},' '];
     end
end


for t=1:4
    for i = 1:length(sentences_l_x{t})
        s=sentences_l_x{t}{i};
        s = strrep(s,' ','  ');
        nBreaks= floor(length(s)/maxChars);
        while true
            
            j=maxChars;
            while ~ strcmp(s(j),' ')
                j=j-1;
            end
            sentences_l_g_p{t}{i}= [sentences_l_g_p{t}{i},s(1:j-1),'\n'];
            s=s(j+1:end);
            if strcmp(s(1),' ')
                s= s(2:end);
            end
            if length(s)<= maxChars
                sentences_l_g_p{t}{i} = [sentences_l_g_p{t}{i},s(1:end-2)];
                break
            end
        end
    end
end

for t=1:4
    if t == 1 || t == 2
        sentences_l_g{t}{1} = [sentences_l_g_p{t}{1},'\n\n',sentences_l_g_p{t}{2}];
        sentences_l_g{t}{2} = [sentences_l_g_p{t}{3}];
        sentences_l_g{t}{3} = [sentences_l_g_p{t}{4},'\n\n',sentences_l_g_p{t}{5}];
        sentences_l_g{t}{4} = [sentences_l_g_p{t}{6},'\n\n',sentences_l_g_p{t}{7}];
        sentences_l_g{t}{5} = [sentences_l_g_p{t}{8},'\n\n',sentences_l_g_p{t}{9}];
    elseif t == 3 || t == 4
        sentences_l_g{t}{1} = [sentences_l_g_p{t}{1}];
        sentences_l_g{t}{2} = [sentences_l_g_p{t}{2}];
        sentences_l_g{t}{3} = [sentences_l_g_p{t}{3},'\n\n',sentences_l_g_p{t}{4}];
        sentences_l_g{t}{4} = [sentences_l_g_p{t}{5}];
        sentences_l_g{t}{5} = [sentences_l_g_p{t}{6}];
    end
end

% Preparing Lesen Zeile für Zeile

for t=1:4
    for i=2:length(sentences_l_pre{t})
        sentences_l_p{t} = [sentences_l_p{t},sentences_l_pre{t}{i},' '];
    end
end

for t=1:4
    k = 1;
    s=sentences_l_p{t};
    s = strrep(s,' ','  ');
    nBreaks_l_all(t)= floor(length(s)/maxChars);
    if length(s)>maxChars
        
        
        
        
        while true
            
            j = maxChars;
            
            if strcmp(s(j+1),' ') || length(s) == maxChars
            else
                while ~ strcmp(s(j),' ')
                    j=j-1;
                end
            end
            
            if ~strcmp(s(j),' ') && strcmp(s(j+1),' ')
                sentences_l{t}{k}=s(1:j);
                s=s(j+3:end);
            elseif strcmp(s(j),' ') && strcmp(s(j+1),' ')
                sentences_l{t}{k}=s(1:j-1);
                s=s(j+2:end);
            elseif strcmp(s(j),' ') && ~strcmp(s(j+1),' ')
                sentences_l{t}{k}=s(1:j-2);
                s=s(j+1:end);
            end
            
            zeilenlaenge(t,k) = length(sentences_l{t}{k});
            
            k = k+1;
            
            if length(s)<= maxChars
                sentences_l{t}{k} = s(1:end-1);
                zeilenlaenge(t,k) = length(sentences_l{t}{k});
                break
            end
        end
    end
end

%     
%     
%     
%     
%     
%     if length(s)>maxChars
% 
%         while true
%             j=maxChars;
%             if ~ strcmp(s(j+1),' ')
%                 while ~ strcmp(s(j),' ')
%                     j=j-1;
%                 end
%             end
% 
%             if ~strcmp(s(j-1),' ')
%                 if strcmp(s(j+2),' ')
%                     sentences_l{t}{k}=s(1:j);
%                     s=s(j+3:end);
%                 else
%                     sentences_l{t}{k}=s(1:j-1);
%                     s=s(j+2:end);
%                 end
%             elseif strcmp(s(j-1),' ')
%                 sentences_l{t}{k}=s(1:j-2);
%                 s=s(j+1:end);
%             end
%             zeilenlaenge(t,k) = length(sentences_l{t}{k});
%             
%             k = k+1;
%             if length(s)<= maxChars
%                 sentences_l{t}{k} = s(1:end-1);
%                 zeilenlaenge(t,k) = length(sentences_l{t}{k});
%                 break
%             end
%         end
%     end
% end

zeilensumme = sum(zeilenlaenge');

for t=1:4
    schnitt(t) = zeilensumme(t)/length(sentences_l{t});
end