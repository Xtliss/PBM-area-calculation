% curve.pl
% El corazon matematico del problema, expresado como relaciones en vez
% de como un algoritmo paso a paso: que significa que Altura sea la
% altura de la columna X, y que conjunto de valores satisface esa
% relacion para todo el dominio.

:- module(curve, [f/4, alturas/3, area/2, muestras/3]).

:- use_module(pbm, [pixel_negro/4]).

% f(+X, +Info, +Datos, -Altura)
% Altura es la cantidad de pixeles negros consecutivos en la columna X,
% contando desde la fila inferior de la imagen (Y = Alto-1) hacia
% arriba, hasta el primer pixel blanco (o hasta el borde superior).
f(X, imagen(Ancho, Alto), Datos, Altura) :-
    YInicio is Alto - 1,
    contar_negros_desde(X, YInicio, imagen(Ancho, Alto), Datos, Altura).

% contar_negros_desde(+X, +Y, +Info, +Datos, -Cuenta)
% Relacion recursiva: si (X,Y) es negro, la cuenta es 1 mas la cuenta
% de la fila de arriba; si no, o si ya no hay mas filas, la cuenta es 0.
contar_negros_desde(X, Y, Info, Datos, Cuenta) :-
    Y >= 0,
    pixel_negro(X, Y, Info, Datos),
    !,
    YAnterior is Y - 1,
    contar_negros_desde(X, YAnterior, Info, Datos, CuentaResto),
    Cuenta is CuentaResto + 1.
contar_negros_desde(_, _, _, _, 0).

% alturas(+Info, +Datos, -M)
% M = [f(0), f(1), ..., f(Ancho-1)]. En vez de "recorrer" el dominio,
% se pide a Prolog que encuentre TODOS los valores de Altura que
% satisfacen f/4 para cada X entre 0 y Ancho-1: findall recolecta las
% soluciones de una relacion, no ejecuta un bucle.
alturas(imagen(Ancho, Alto), Datos, M) :-
    MaxX is Ancho - 1,
    findall(Altura,
            ( between(0, MaxX, X),
              f(X, imagen(Ancho, Alto), Datos, Altura)
            ),
            M).

% area(+M, -Area)
% La suma de Riemann con Delta x = 1: el area es la suma de las
% alturas, ya que cada columna es un rectangulo de base 1.
area(M, Area) :- sum_list(M, Area).

% muestras(+M, +N, -Muestras)
% N pares X-Fx distribuidos uniformemente a lo largo del dominio de M.
muestras(M, N, Muestras) :-
    length(M, Total),
    indices_uniformes(Total, N, Indices),
    findall(X-Fx,
            ( member(X, Indices), nth0(X, M, Fx) ),
            Muestras).

% indices_uniformes(+Total, +N, -Indices)
% N indices enteros distribuidos uniformemente entre 0 y Total-1.
indices_uniformes(Total, N, [0]) :- N =< 1, !, Total > 0.
indices_uniformes(Total, N, Indices) :-
    N > 1,
    MaxIdx is Total - 1,
    NMenos1 is N - 1,
    findall(Idx,
            ( between(0, NMenos1, I0),
              Idx is round(I0 * MaxIdx / NMenos1)
            ),
            Indices).
