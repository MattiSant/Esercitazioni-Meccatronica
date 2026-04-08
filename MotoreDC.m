%% ESERCITAZIONI 1 - Motore DC

clc;
close all ;
clear all;

%% Dati
% Associare i valori della tensione [0,12]V a valori di tempo di simulink
% per plot, input a rampa

%Convertire omega da rad/sec a giri/min -> x60/2pi

V = 0:1:12;     %[V]
R = 4.4;        %[Ohm]
L = 6.2e-3;     %[H]
J = 16e-7;      %[Kg m^2]

Ke = 0.025;     %[V s/rad]
Kt = 2.5e-2;    %[N m/A]           

Cr_Stall = 6.6e-2 ;    %[N m]
Cr_Rated = 2.0e-2;     %[N m]
Cr_noLoad = 0.0;       %[N m]

Cr = [Cr_Stall; Cr_Rated ; Cr_noLoad];


% corr 0, 0.8, 2.7
% vel max 4500 giri/min

%% Matrici SS
A = [-R/L -Ke/L ; Kt/J 0];
B = [1/L 0 ; 0 -1/J];
C = eye(2);
D = zeros(2);

%% Transfer Function

% Tensione
[V_tfNum,V_tfDen] = ss2tf(A,B,C,D,1);

% -> Corrente
V_num_I = V_tfNum(1,:);
V_den_I = V_tfDen(1,:);
% -> Vel Angolare
V_num_W = V_tfNum(2,:);
V_den_W = V_tfDen(1,:);

% Coppia
[C_tfNum,C_tfDen] = ss2tf(A,B,C,D,2);

% -> Corrente
C_num_I = C_tfNum(1,:);
C_den_I = C_tfDen(1,:);
% -> Vel Angolare
C_num_W = C_tfNum(2,:);
C_den_W = C_tfDen(1,:);

%% Punto 4
V_pt4 = 0:2:12;
Cr_pt4 = (0:1:6)/100;


%% Porta a Simulink i Parametri
sim('DC_Motor');