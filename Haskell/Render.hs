-- Render.hs
-- Todo lo relacionado con "mostrar algo en una terminal que es mucho
-- mas pequena que la imagen original". La idea clave: reducimos la
-- lista de alturas M agrupando columnas en bloques y promediando,
-- y esa MISMA lista reducida sirve tanto para dibujar la silueta de
-- la curva como para dibujar el grafico de M[x]. El area y f(x) que
-- se muestran en el resto del programa siempre usan M completo, sin
-- reducir: esta reduccion es puramente visual.

module Render
  ( reducirBloques
  , promedio
  , dibujarSilueta
  , dibujarBarrasAltura
  ) where

-- | Parte una lista en bloques de tamano k (el ultimo bloque puede ser
-- mas pequeno) y aplica una funcion de resumen a cada bloque.
reducirBloques :: Int -> [a] -> ([a] -> b) -> [b]
reducirBloques k xs resumen
  | k <= 0    = error "El tamano de bloque debe ser mayor que cero"
  | otherwise = map resumen (partir xs)
  where
    partir [] = []
    partir ys = let (bloque, resto) = splitAt k ys
                in bloque : partir resto

-- | Promedio entero de una lista de alturas (funcion de resumen para
-- reducirBloques).
promedio :: [Int] -> Int
promedio xs = sum xs `div` length xs

-- | Los caracteres de gradiente (de "vacio" a "lleno") usados para dar
-- sensacion de variacion en las visualizaciones. Se usa ASCII plano
-- (en vez de bloques Unicode) para que funcione en cualquier terminal
-- sin depender de su configuracion de encoding.
caracteresBloque :: String
caracteresBloque = " .:-=+*#%@"

-- | Dado el nivel (0..maximo) de una columna y el numero de niveles
-- posibles, escoge el caracter de bloque correspondiente.
caracterPara :: Int -> Int -> Char
caracterPara valor maximo
  | maximo <= 0 = last caracteresBloque
  | otherwise   =
      let n = length caracteresBloque - 1
          idx = min n (max 0 (valor * n `div` maximo))
      in caracteresBloque !! idx

-- | Dibuja la silueta de la curva como una cuadricula de "filasConsola"
-- filas de texto: para cada columna (ya reducida), pinta con bloques
-- llenos desde abajo hasta la altura normalizada de esa columna.
dibujarSilueta :: [Int] -> Int -> String
dibujarSilueta alturasReducidas filasConsola =
  let maxAltura = maximum (1 : alturasReducidas)
      normalizadas = [ altura * filasConsola `div` maxAltura | altura <- alturasReducidas ]
      fila y = [ if h >= (filasConsola - y) then '#' else ' ' | h <- normalizadas ]
  in unlines [ fila y | y <- [0 .. filasConsola - 1] ]

-- | Dibuja M[x] (ya reducida) como una sola linea de bloques Unicode
-- graduados segun la altura relativa de cada columna: un "sparkline".
dibujarBarrasAltura :: [Int] -> String
dibujarBarrasAltura alturasReducidas =
  let maxAltura = maximum (1 : alturasReducidas)
  in map (\v -> caracterPara v maxAltura) alturasReducidas
