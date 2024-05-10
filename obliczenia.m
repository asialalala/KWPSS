close all

%==================== IDENTYFIKACJA =======================%
% wartości nominalne
TwewN = 20;     %oC
TgpN = 70;      %oC
TzewN = -20;    %oC
TgzN = 90;      %oC
QgN = 2000;    % moc grzałki W
QtN = 0;        % moc "wyłączonej" grzałki W
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

T0 = 0; % s opoznienie czasowe

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
tmax = 70000;  % czas symulacji

%zaklocenia
tsok = 2000; % czas skoku
dFmg = 0;
dTzew = 0;
dQt = 0;
dTwz = 0;
dFmw = 0;


%==================== IDENTYFIKACJ =======================%
% k1 = (20.2553 - 20)/0.0100000000000000;
% Topu1 = 5820- 2000;
% Tczas1 = 25390-Topu1;
% 
% k2 = (20.2553 - 20)/0.0100000000000000;
% Tczas2 = 21425-11955;
% Topu2 = 21425 - Tczas2;

%==================== STEROWANIE =======================%
%%%%%%%%%%%%%%%%%%%%%%%%%%         nastawy z metody stycznej
% wartosc zadana 
% dTwew = 1;

%------------------------
% nastawy regulacji styczna ZN
% Kp = 0.9*Tczas1/(k1*Topu1);
% Ki = 1;
% Ti = 3.33*Topu1/Kp;
% modelOb='obiekt_sterowanie_tune';



% % --------------------------
% nastawy regulacji dwupunktowa ZN
% Kp = 0.9*Tczas2/(k2*Topu2);
% Ki = 1;
% Ti = 3.33*Topu2/Kp;


% % -------------------------
% nastawy z tune
% Kp = 0.06016;
% Ki = 4.35489929311168e-06;
% Ti = 1/Ki;

% -------------------------
% % nastawy z CC styczna
% a=k1*Topu1/Tczas1;
% tau=Topu1/(Topu1 + Tczas1);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu1/Kp;

% % -------------------------
% nastawy z CC dwupunktowa
% a=k2*Topu2/Tczas2;
% tau=Topu2/(Topu2 + Tczas2);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu2/Kp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  REGULACJA POGODOWA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

kRp= (1.3488)/0.02;
TopuRp = 2648 - 2000;
TczasRp = 10670-2648;
% dla dFmw = 0.02

% modelOb='regulacjapogodowaobiekt';
% f1=figure(1);
% f1.Position = [0,0,1400,1000];
% clf(f1);
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Toz, 'b');
% xlabel("t[s]"), ylabel("Toz[^{\circ}C]");
% hold on, grid on;

% modelOb='regulacja_pogodowa_model';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, TozRpId1, 'g');
% legend("Toz obiekt", "Toz model")
% xlabel("t[s]"), ylabel("Toz[^{\circ}C]");
% hold off;


% ------------------------------------------------------
% wyznaczenie krzywych pogodowych - to sa proste
az = (TgzN - TzewN)/(TwewN - TzewN);
bz = (TgzN - TwewN)/(TwewN - TzewN);
ap = (TgpN - TzewN)/(TwewN - TzewN);
bp = (TgpN - TwewN)/(TwewN - TzewN);

Kp = 0.9*TczasRp/(kRp*TopuRp);
Ki = 1;
Ti = 3.33*TopuRp/Kp;
% ------------------------------------------

TemVec = [-20:20];
dTwew1 = 1;

figure(1);
modelOb='regulacja_pogodowa_model';
[t]=sim(modelOb,tmax);    % t - wektor czasu
plot(TemVec, TgzOut, 'g');
hold on;
plot(TemVec, TgpOut, 'b');
legend("Tgz", "Tgp")
xlabel("Tzew[^{\circ}C]"), ylabel("T[^{\circ}C]");
hold off;

% STEROWANIE NA MODELU
% figure(2);
% plot(t, Cv, 'g');
% legend("Toz")
% xlabel("t[s]"), ylabel("Toz[^{\circ}C]");

% STEROWANIE NA OBIEKCIE
modelOb='regulacjapogodowaobiekt';
[t]=sim(modelOb,tmax);    % t - wektor czasu
figure(2);
plot(t, Twew1, 'g');
hold on;
plot(t, Twew2, 'b')
legend("Twew1", "Twew2")
xlabel("t[s]"), ylabel("Twew[^{\circ}C]");

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