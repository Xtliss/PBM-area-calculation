% main.pl
% Orquesta el pipeline completo:
%   PBM -> bytes -> pixeles -> f(x) -> M -> area
% y produce la salida de consola pedida por el enunciado.

:- use_module(pbm, [leer_pbm/3, bytes_por_fila/2]).
:- use_module(curve, [alturas/3, area/2, muestras/3]).
:- use_module(render, [reducir_bloques/3, dibujar_silueta/2, dibujar_barras_altura/2]).

:- set_prolog_flag(double_quotes, string).

archivo_pbm('curva_binaria_P4.pbm').
ancho_consola(100).

main :-
    set_stream(user_output, encoding(utf8)),
    archivo_pbm(Ruta),
    leer_pbm(Ruta, imagen(Ancho, Alto), Datos),

    alturas(imagen(Ancho, Alto), Datos, M),
    area(M, Area),
    muestras(M, 10, Muestras),

    ancho_consola(AnchoConsola),
    K is max(1, ceiling(Ancho / AnchoConsola)),
    reducir_bloques(K, M, MReducido),

    format("=== Practica I: From Pixels to the Integral (Prolog) ===~n"),
    format("Imagen: ~w x ~w pixeles~n", [Ancho, Alto]),
    format("Escala de visualizacion: 1 caracter = ~w columna(s) originales~n~n", [K]),

    format("Vista de la curva (silueta reducida):~n"),
    dibujar_silueta(MReducido, Lineas),
    forall(member(Linea, Lineas), format("~w~n", [Linea])),
    nl,

    format("Funcion de altura M[x] = f(x) (reducida):~n"),
    dibujar_barras_altura(MReducido, LineaAlturas),
    format("~w~n~n", [LineaAlturas]),

    format("Algunos valores x_i -> f(x_i):~n"),
    forall(member(X-Fx, Muestras),
           format("x = ~w -> f(x) = ~w pixeles~n", [X, Fx])),

    nl,
    format("Cada columna tiene base = 1 pixel~n"),
    format("Area = suma de f(x_i)~n"),
    format("Area = ~w pixeles cuadrados~n", [Area]).

:- initialization(main, main).
