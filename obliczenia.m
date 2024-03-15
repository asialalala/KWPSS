close all, clear all

%==================== IDENTYFIKACJA =======================%
% wartości nominalne
TwewN = 20;     %oC
TgpN = 70;      %oC
TzewN = -20;    %oC
TgzN = 90;      %oC
QgN = 10000;    % moc grzałki W
QtN = 0;        % moc "wyłączonej" grzałki W
TwzN = 130;     %oC
TwpN = 110;     %oC
TozN = TgzN;    %oC
TopN = TgpN;    %oC


Vw = 2*6*6;     % pojemnośc pokoju m^3
Vg = 1*0.5*0.5; % pojemność grzałki m^3
Vvo1 = 7.5;     % pojemność 1 połowy węzła ciepłowniczego m^3
Vvo2 = 7.5;     % pojemność 2 połowy węzła ciepłowniczego m^3

Cpw = 1000;     % ciepło własiściwe powietrza J/(kg*K)
Cmg = 4175;     % ciepło własiściwe wody J/(kg*K)
Row = 1.2;      % gęstość powietrza kg/m^3
Rog = 960;      % gęstość wody kg/m^3

%-----------------------
% identyfikacja parametrów statycznych
FmgN = QgN/(Cpw*(TgzN - TgpN));
Kcg = QgN/(TgpN-TwewN);  % sprawdz czy to jest dobrze
Kcw = QgN/(TwewN-TzewN);   % sprawdz czy to jest dobrze
Kco = 2*QgN/(TwpN-TozN);
FmwN = Kco*(TwpN - TozN)/(Cpw*(TwzN - TwpN));
FmoN = Kco*(TwpN - TozN)/(Cpw*(TozN - TopN));

%-----------------------
% identyfikacja parametrów dynamicznych
Cvw = Cpw*Row*Vw;  
Cvg = Cmg*Rog*Vg; 
Cvo1 = Cmg*Rog*Vvo1; 
Cvo2 = Cmg*Rog*Vvo1; 

%-----------------------
% sprawdzenie
assert(Kcg > 0, "Ujemny współczynik przenikania")
assert(Kcw > 0, "Ujemny wspólczynnik przenikania")
assert(0 == (Kcg*(TgpN - TwewN) - Kcw*(TwewN-TzewN)), "Rownania statyczne nierowne")
assert(0 == (Cpw*FmgN*(TgzN-TgpN)-Kcg*(TgpN - TwewN)), "Rownania statyczne nierowne")

%==================== PUNKT PRACY =======================%
% warunki początkowe
Tzew0 = TzewN + 0;  % 0 - nominalne
Tgz0 = TgzN + 0;    % 0 - nominalne
Qg0 = QgN*1.0;      % 1.0 - nominalne
Fmg0 = FmgN*1.0;    % 1.0 - nominalne
Twz0 = TwzN + 0;    % 0 - nominalnie

% stan równowagi        (dla nominalnych warubkowpoczatkowcyh Twew0 = TwewN i Tgp0 = TgpN)
Twew0 = (Cpw*Fmg0*Kcg*Tgz0 + Kcw*(Kcg + Cpw*Fmg0)*Tzew0)/(Kcg*Kcw + Cpw*Fmg0*(Kcg + Kcw));
Tgp0 = ((Kcg + Kcw)*Twew0 - Kcw*Tzew0)/(Kcg);
    Top0 = Tgp0;        % PRZYBLIZENIE 3
Toz0 = TozN; % Fmg0*Kco/(Kco*Fmg0 + Cpw*Fmg0*Fmg0 + Kco*Fmg0)*(Twz0 + (Cpw*Fmg0)*Top0/(Kco)); % JESLI JEST ZLE PRZYJMIN TozN
Twp0 = TwpN; % (Cpw*Fmg0+Kco)*Toz0/Kco - (Cpw*Fmg0 + Kco)*Top0/Kco; % JEŚLI JEST ŹLE PRZYJMIJ TwpN


%==================== SYMULACJE =======================%
%symulacja
tmax = 200;  % czas symulacji

%zaklocenia
tsok = 0; % czas skoku
dFmg = 0;
dTgz = 0;
dTzew = 0;
dQt = 0;
% dTop = 0;
dTwz = 0;
dFmw = 0;
% dFmo = 0;

model='model_rownan';
[t]=sim(model,tmax);    % t - wektor czasu
%wykresy
figure, plot(t, Twew, 'r'), grid on, title("Reakcja Twew");
xlabel("t[s]"), ylabel("Twew[^{\circ}C]");

figure, plot(t, Tgp1, 'r'), grid on, title("Reakcja Tgp1");
xlabel("t[s]"), ylabel("Tgp1[^{\circ}C]");

figure, plot(t, Twp, 'r'), grid on, title("Reakcja Twp");
xlabel("t[s]"), ylabel("Tgp[^{\circ}C]");

figure, plot(t, Toz, 'r'), grid on, title("Reakcja Toz");
xlabel("t[s]"), ylabel("Tgp[^{\circ}C]");

