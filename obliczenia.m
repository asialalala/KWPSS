close all

%==================== IDENTYFIKACJA =======================%
% wartości nominalne
TwewN = 20;     %oC
TgpN = 70;      %oC
TzewN = -20;    %oC
TgzN = 90;      %oC
QgN = 2000;    % moc grzałki W
QtN = 0;        % dodatkowe starty ciepła
TwzN = 130;     %oC
TwpN = 110;     %oC
TozN = TgzN;    %oC
TopN = TgpN;    %oC


Vw = 10*6*2;   % pojemnośc pokoju m^3
Vg = 1*0.5*0.25; % pojemność grzałki m^3
Vvo1 = 1;     % pojemność 1 połowy węzła ciepłowniczego m^3
Vvo2 = 1;     % pojemność 2 połowy węzła ciepłowniczego m^3

Cpw = 1000;     % ciepło własiściwe powietrza J/(kg*K)
Cmg = 4175;     % ciepło własiściwe wody J/(kg*K)
Row = 1.2;      % gęstość powietrza kg/m^3
Rog = 960;      % gęstość wody kg/m^3

%-----------------------
% identyfikacja parametrów statycznych
FmgN = QgN/(Cpw*(TgzN - TgpN));
Kcg = QgN/(TgpN-TwewN);                         
Kcw = QgN/(TwewN-TzewN);
Kco = 2*QgN/(TwpN-TozN);
FmwN = Kco*(TwpN - TozN)/(Cpw*(TwzN - TwpN));
FmoN = Kco*(TwpN - TozN)/(Cpw*(TozN - TopN));

%-----------------------
% identyfikacja parametrów dynamicznych
Cvw = Cpw*Row*Vw*2;       % pojemność cieplna powietrza w pokoju
                          % 2 - chcemy zwiekszyc znaczenie ścian
Cvg = Cmg*Rog*Vg;         % pojemność cieplna grzejnika
Cvo1 = Cvg;    
Cvo2 = Cvg;    

%-----------------------
% sprawdzenie
assert(Kcg > 0, "Ujemny współczynik przenikania")
assert(Kcw > 0, "Ujemny wspólczynnik przenikania")
assert(0 == (Kcg*(TgpN - TwewN) - Kcw*(TwewN-TzewN)), "Rownania statyczne nierowne")
assert(0 == (Cpw*FmgN*(TgzN-TgpN)-Kcg*(TgpN - TwewN)), "Rownania statyczne nierowne")

%==================== PUNKT PRACY =======================%
% warunki początkowe
Tzew0 = TzewN + 0;  % 0 - nominalne
Tgz10 = TgzN + 0;    % 0 - nominalne
Tgz20 = TgzN + 0;    % 0 - nominalne
Qg0 = QgN*1.0;      % 1.0 - nominalne
Fmg0 = FmgN*1.0;    % 1.0 - nominalne
Twz0 = TwzN + 0;    % 0 - nominalnie

Fmg10 = Fmg0;
Fmg20 = Fmg0;
Fmw0 = FmwN;

T0 = 10; % s opoznienie czasowe

% stan równowagi        (dla nominalnych warubkowpoczatkowcyh Twew0 = TwewN i Tgp0 = TgpN)
Twew10 = (Cpw*Fmg10 *Kcg*Tgz10 + Kcw*(Kcg + Cpw*Fmg10)*Tzew0)/(Kcg*Kcw + Cpw*Fmg10*(Kcg + Kcw));
Twew20 = (Cpw*Fmg20 *Kcg*Tgz20 + Kcw*(Kcg + Cpw*Fmg20)*Tzew0)/(Kcg*Kcw + Cpw*Fmg20*(Kcg + Kcw));
Tgp10 = ((Kcg + Kcw)*Twew10 - Kcw*Tzew0)/(Kcg);
Tgp20 = ((Kcg + Kcw)*Twew20 - Kcw*Tzew0)/(Kcg);

Top0 = TopN;  % PRZYBLIZENIE 3
Toz0 = TozN; % Fmg0*Kco/(Kco*Fmg0 + Cpw*Fmg0*Fmg0 + Kco*Fmg0)*(Twz0 + (Cpw*Fmg0)*Top0/(Kco)); % JESLI JEST ZLE PRZYJMIN TozN
Twp0 = TwpN; % (Cpw*Fmg0+Kco)*Toz0/Kco - (Cpw*Fmg0 + Kco)*Top0/Kco; % JEŚLI JEST ŹLE PRZYJMIJ TwpN

SumT0 = (Tgp10*Fmg10 + Tgp20*Fmg20)/(Fmg10 + Fmg20);

%==================== SYMULACJE =======================%
%symulacja
tmax = 150000;  % czas symulacji

%zaklocenia
tsok = 2000; % czas skoku
dFmg1 = 0;%0.05*Fmg10;
dFmg2 = 0;
dTzew = 0;
dQt1 = 0.05*QgN;
dQt2 = 0;
dTwz = 0;
dFmw = 0;%0.1*FmwN;

dTwew1 = 0;

TopuCiep = 4*tsok;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%  IDENTYFIKACJA %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 63.2% i 28.3% -> 0.7751 i 1.7310
% identyfikacja
kRp= (1.3488)/0.02;
TopuRp = 2648 - 2000;
TczasRp = 10670-2648;

% kRp2= 1.6/0.02;
% TopuRp2 = 0.0000000000000001; % przyjęto bardzo małą nieznaczącą waartość
% TczasRp2 = 4036-2000;
% % dla dFmw = 0.02


kRp2= (71.1034-70)/0.02;
TopuRp2 = 4606 - tsok; % przyjęto bardzo małą nieznaczącą waartość
TczasRp2 = 20334-TopuRp2;
% % dla dFmw = 0.02

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  REGULACJA POGODOWA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



% --------------------------  Top  i Tgp  ----------------------------
% wyznaczenie krzywych pogodowych - to sa proste
% dla modelu
az_gz = (TgzN - TzewN)/(TwewN - TzewN);
bz_gz = (TgzN - TwewN)/(TwewN - TzewN);
ap_gz = (TgpN - TzewN)/(TwewN - TzewN);
bp_gz = (TgpN - TwewN)/(TwewN - TzewN);

% dla cieplowni
az_wz = (TwzN - TzewN)/(TwewN - TzewN);
bz_wz = (TwzN - TwewN)/(TwewN - TzewN);
ap_wz = (TwpN - TzewN)/(TwewN - TzewN);
bp_wz = (TwpN - TwewN)/(TwewN - TzewN);



% modelOb='model_rownan';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Top, 'g');
% xlabel("t[s]"), ylabel("T[^{\circ}C]");
% 

% modelOb='model_rownan';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Top, 'g');
% hold on;
% TemVec = [-20:20];
% modelOb='model_rownan';
% [t]=sim("regulacja_pogodowa_model",tmax); 
% plot(t, TopRpId, 'b')
% legend('Top obiekt', 'Top model' );
% xlabel("t[s]"), ylabel("T[^{\circ}C]");
% 
% prompt = "Nacisnij eneter aby kontynuować"
% x = input(prompt)

% krzywe pogodowe
TemVec = [-20:20];
fprintf("regulacja pogodowa model...\n")
f1 = figure(1);
f1.Position = [0,0,1000,600];
modelOb='regulacja_pogodowa_model';
[t]=sim(modelOb,tmax);    % t - wektor czasu
plot(TemVec, TgzOut, 'g');
hold on;
plot(TemVec, TgpOut, 'b');
legend("Twz", "Twp")
xlabel("Tzew[^{\circ}C]"), ylabel("T[^{\circ}C]");
hold off;


% STEROWANIE NA MODELU
% figure(2);
% plot(t, Cv, 'g');
% legend("Toz")
% xlabel("t[s]"), ylabel("Toz[^{\circ}C]");

% % STEROWANIE NA OBIEKCIE

% Dla sterowania Toz
Kp = 0.9*TczasRp/(kRp*TopuRp);
Ki = 1;
Ti = 3.33*TopuRp/Kp;

fprintf("Tgp regulacja pogodowa...\n")
modelOb='regulacjapogodowaobiekt';
[t]=sim(modelOb,tmax);    % t - wektor czasu
f2 = figure(2);
f2.Position = [0,0,1000,600];
subplot(2,1,1)
plot(t, Twew1, 'g');
hold on;
plot(t, Twew2, 'm--')
subplot(2,1,2)
plot(t, CvObiekt, 'g')
hold on;
% fprintf("Error ")
% disp(err2)

% % parametry z identyfikacji metoda styczna
k1 = (20.2553 - 20)/0.0100000000000000;
Topu1 = 5820-2000;
Tczas1 = 25390 - Topu1;

% % nastawy regulacji styczna ZN
Kp = 0.9*Tczas1/(k1*Topu1);
Ki = 1;
Ti = 3.33*Topu1/Kp;


modelOb='obiekt_sterowanie';
[t]=sim(modelOb,tmax);    % t - wektor czasu
subplot(2,1,1)
plot(t, Twew1, 'b');
plot(t, Twew2, 'c--')
subplot(2,1,2)
plot(t, CvO, 'b')
% fprintf("Error ")
% disp(err2)



% Dla regulacji pogodowej Twp
Kp = 0.9*TczasRp2/(kRp2*TopuRp2); % ustawiony bardzo maly czas opoznienia
Ki = 1;
Ti = 3.33*TopuRp2/Kp;

% Kp = 1; % ustawiony bardzo maly czas opoznienia
% Ki = 2;
% Ti = 3;

fprintf("Top regulacja pogodowa...\n")
modelOb='Top_regulacjapogodowaobiekt';
[t]=sim(modelOb,tmax);    % t - wektor czasu
subplot(2,1,1)
plot(t, Twew1, 'r');
hold on;
plot(t, Twew2, 'k--')
legend("Twew1 RP Tgz", "Twew2 RP Tgz", "Twew1", "Twew2", "Twew1 RP Tgp", "Twew2 RP Tgp")
xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
legend()
subplot(2,1,2)
plot(t, CvObiekt, 'r')
legend("Cv RP Tgz", "Cv", "Cv RP Tgp")
xlabel("t[s]"), ylabel("Fmw[m^3/s]");
fprintf("Error ")
disp(err2)



% Tzewnętrzene znamy 
% Twewnetrzen to wartość zadana, też nzamy
% Oblicznamy Tgz i Tgb
% 
% Zmienną procesową będzie Toz, uchyb - różnica pomiędzy
% mierzonym Toz, a tym co mamy z krzywych pogodowych

% tamten (stary) ukłąd regulacji nie dział
% celem badan jest porównanie regulacji 

% Do identyfikacji modelu wykorzystano metodę stycznej. Następnie obliczon
% nastawy regulatora zgodnie z metodą Zieglera-Niholsa


% Wnioski na temat realności sterowania


% na dodatkowye pynkty regulacja na podstawie Tgp, wszystko na jednym
% wykresie


% gdy zwiększy się opóźnienie z ciepłowni widać działanie regulatora, zanim dotrze woda
% z ciełowni


% Toz
% Kp $0.1652$, Ti  $1.9444 \cdot 10^{4}$
% iden: k1=67.4400, Topu=648, Tczas=8022

% Top
%$0.1110$, Ti  $7.8198 \cdot 10^{4}$
% iden: k1=55.1700, Topu=2606, Tczas=17728

% ZN styczna
% Kp $0.1991$, Ti $1.1463 \cdot 10^5 $
% iden: k1=25.5300, Topu=3820, Tczas=21570


