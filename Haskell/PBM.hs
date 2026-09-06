-- PBM.hs
-- Carga de archivos PBM P4 y acceso a pixeles individuales.
-- Responsabilidad de este modulo: transformar bytes crudos del archivo
-- en una estructura (Imagen) y ofrecer una funcion pura para saber si
-- un pixel (x, y) es negro o blanco.

module PBM
  ( Imagen(..)
  , cargarPBM
  , bytesPorFila
  , esNegro
  ) where

import qualified Data.ByteString as BS
import Data.ByteString (ByteString)
import Data.Bits (testBit)
import Data.Word (Word8)
import Data.Char (chr, isSpace, isDigit)

-- | Una imagen PBM P4 ya interpretada: dimensiones + datos binarios crudos
-- (los datos siguen empacados en bits, tal como vienen en el archivo).
data Imagen = Imagen
  { ancho   :: Int
  , alto    :: Int
  , pixeles :: ByteString
  } deriving (Show)

-- | Lee el archivo del disco y construye la Imagen.
cargarPBM :: FilePath -> IO Imagen
cargarPBM ruta = do
  contenido <- BS.readFile ruta
  return (parseHeader contenido)

-- | Interpreta el header "P4\n[comentarios]\nANCHO ALTO\n<datos binarios>"
-- y separa las dimensiones de los datos de pixeles.
parseHeader :: ByteString -> Imagen
parseHeader bs0 =
  let bs1 = requerirMagic bs0
      bs2 = saltarEspaciosYComentarios bs1
      (w, bs3) = leerEntero bs2
      bs4 = saltarEspaciosYComentarios bs3
      (h, bs5) = leerEntero bs4
      -- Tras el ultimo numero del header hay exactamente UN caracter
      -- de espacio en blanco antes de que empiecen los datos binarios.
      datos = BS.drop 1 bs5
  in Imagen { ancho = w, alto = h, pixeles = datos }

-- | Verifica y descarta la marca magica "P4".
requerirMagic :: ByteString -> ByteString
requerirMagic bs =
  case BS.stripPrefix (byteStringDeString "P4") bs of
    Just resto -> resto
    Nothing    -> error "Archivo no es un PBM P4 valido (falta la marca P4)"

-- | Salta espacios en blanco y comentarios ("#" hasta fin de linea),
-- repitiendo hasta encontrar el inicio de un token real.
saltarEspaciosYComentarios :: ByteString -> ByteString
saltarEspaciosYComentarios bs
  | BS.null bs = bs
  | esEspacioByte (BS.head bs) = saltarEspaciosYComentarios (BS.drop 1 bs)
  | BS.head bs == comentarioByte =
      saltarEspaciosYComentarios (BS.dropWhile (/= saltoLineaByte) bs)
  | otherwise = bs

-- | Lee un entero en ASCII (secuencia de digitos) desde el inicio del ByteString.
leerEntero :: ByteString -> (Int, ByteString)
leerEntero bs =
  let (digitos, resto) = BS.span esDigitoByte bs
  in (read (map (chr . fromIntegral) (BS.unpack digitos)), resto)

esEspacioByte :: Word8 -> Bool
esEspacioByte w = isSpace (chr (fromIntegral w))

esDigitoByte :: Word8 -> Bool
esDigitoByte w = isDigit (chr (fromIntegral w))

comentarioByte :: Word8
comentarioByte = fromIntegral (fromEnum '#')

saltoLineaByte :: Word8
saltoLineaByte = fromIntegral (fromEnum '\n')

byteStringDeString :: String -> ByteString
byteStringDeString = BS.pack . map (fromIntegral . fromEnum)

-- | Numero de bytes necesarios para representar una fila de "w" pixeles,
-- ya que PBM P4 empaqueta 8 pixeles (bits) por byte.
bytesPorFila :: Int -> Int
bytesPorFila w = (w + 7) `div` 8

-- | True si el pixel (x, y) de la imagen es negro (bit = 1).
-- El bit mas significativo del byte corresponde al pixel mas a la
-- izquierda de ese grupo de 8.
esNegro :: Imagen -> Int -> Int -> Bool
esNegro img x y =
  let bpf         = bytesPorFila (ancho img)
      indiceByte  = y * bpf + x `div` 8
      byte        = BS.index (pixeles img) indiceByte
      posicionBit = 7 - (x `mod` 8)
  in testBit byte posicionBit
