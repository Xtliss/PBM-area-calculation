-- Curve.hs
-- Aqui vive el corazon matematico del problema: la funcion discreta
-- f(x), la estructura de alturas M y el area como suma de Riemann.
-- Todo se expresa como transformaciones puras sobre datos, siguiendo
-- el espiritu funcional pedido en el enunciado:
--   M = map f [0 .. ancho-1]
--   area = sum M

module Curve
  ( f
  , alturas
  , area
  , muestras
  ) where

import PBM (Imagen(..), esNegro)

-- | f(x): cuenta los pixeles negros consecutivos en la columna x,
-- comenzando en la fila inferior de la imagen (y = alto-1) y subiendo
-- hasta encontrar el primer pixel blanco (o hasta el borde superior).
f :: Imagen -> Int -> Int
f img x = length (takeWhile (\y -> esNegro img x y) filasDeAbajoHaciaArriba)
  where
    filasDeAbajoHaciaArriba = [alto img - 1, alto img - 2 .. 0]

-- | M = [f(0), f(1), ..., f(ancho-1)]
-- La aplicacion de f sobre todo el dominio horizontal, via map:
-- esta linea es la version funcional (declarativa) de "para cada
-- columna, calcula su altura".
alturas :: Imagen -> [Int]
alturas img = map (f img) [0 .. ancho img - 1]

-- | Suma de Riemann con Delta x = 1: el area es simplemente la suma
-- de las alturas, ya que cada columna es un rectangulo de base 1.
area :: [Int] -> Int
area = sum

-- | Selecciona n posiciones distribuidas uniformemente a lo largo del
-- dominio de M y las empareja con su valor: [(x_i, f(x_i)), ...].
muestras :: [Int] -> Int -> [(Int, Int)]
muestras m n =
  let total    = length m
      indices  = indicesUniformes total n
  in [ (i, m !! i) | i <- indices ]

-- | Genera n indices enteros distribuidos uniformemente entre 0 y
-- (total - 1), inclusive en ambos extremos.
indicesUniformes :: Int -> Int -> [Int]
indicesUniformes total n
  | n <= 1    = [0]
  | otherwise =
      [ round (fromIntegral i * fromIntegral (total - 1) / fromIntegral (n - 1) :: Double)
      | i <- [0 .. n - 1]
      ]
