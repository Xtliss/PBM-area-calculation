-- Main.hs
-- Orquesta el pipeline completo:
--   PBM -> bytes -> pixeles -> f(x) -> M -> area
-- y produce la salida de consola pedida por el enunciado.

module Main (main) where

import PBM (Imagen(..), cargarPBM)
import Curve (alturas, area, muestras)
import Render (reducirBloques, promedio, dibujarSilueta, dibujarBarrasAltura)
import Text.Printf (printf)
import System.IO (hSetEncoding, stdout, utf8)

-- | Nombre del archivo de entrada. Se asume que el ejecutable corre
-- desde una ubicacion donde este archivo es accesible (ver README).
archivoPBM :: FilePath
archivoPBM = "curva_binaria_P4.pbm"

-- | Ancho objetivo (en caracteres) de la visualizacion en consola.
anchoConsola :: Int
anchoConsola = 100

-- | Alto (en filas de texto) de la silueta dibujada.
altoSilueta :: Int
altoSilueta = 20

main :: IO ()
main = do
  hSetEncoding stdout utf8
  img <- cargarPBM archivoPBM

  let m           = alturas img               -- M = map f [0..ancho-1]
      a           = area m                     -- area = sum M
      diezMuestras = muestras m 10

      -- k: cuantas columnas originales representa cada caracter de consola
      k             = max 1 (ceilDiv (ancho img) anchoConsola)
      mReducido     = reducirBloques k m promedio

  putStrLn "=== Practica I: From Pixels to the Integral (Haskell) ==="
  printf "Imagen: %d x %d pixeles\n" (ancho img) (alto img)
  printf "Escala de visualizacion: 1 caracter = %d columna(s) originales\n\n" k

  putStrLn "Vista de la curva (silueta reducida):"
  putStr (dibujarSilueta mReducido altoSilueta)
  putStrLn ""

  putStrLn "Funcion de altura M[x] = f(x) (reducida):"
  putStrLn (dibujarBarrasAltura mReducido)
  putStrLn ""

  putStrLn "Algunos valores x_i -> f(x_i):"
  mapM_ mostrarMuestra diezMuestras

  putStrLn ""
  printf "Cada columna tiene base = 1 pixel\n"
  printf "Area = suma de f(x_i)\n"
  printf "Area = %d pixeles cuadrados\n" a

-- | Division entera redondeando hacia arriba (techo).
ceilDiv :: Int -> Int -> Int
ceilDiv a b = (a + b - 1) `div` b

mostrarMuestra :: (Int, Int) -> IO ()
mostrarMuestra (x, fx) = printf "x = %d -> f(x) = %d pixeles\n" x fx
