module GramaticaAbstracta where

{-Defincion de la gramatica abstracta para escribir funciones e integrales.
-}

{-Itg representa un pequeño lenguaje para para la gramatica de las integrales.
-}
data Itg  = ItgSim (Func, Func) Func Dif --Integral Simple
	  | ItgMult (Func, Func) Itg Dif --Integral Multiple
	deriving (Show, Eq, Ord)

{-Dif representa el diferencial de una funcion a integrar.
  Es importante porque nos indica el orden de integracion en integrales multiples.
-}
data Dif = Dif Char
	deriving (Show, Eq, Ord)

{-Func representa un pequeño lenguaje para la gramatica de las funciones.
-}
data Func = FConst Double  	--Una constante
	  | FVar Char		--Una variable
	  | FSum Func Func	--Suma de funciones 
	  | FRes Func Func	--Resta de funciones
	  | FMult Func Func	--Multiplicacion de funciones
	  | FDiv Func Func	--Division de funciones
	  | FPot Func Func	--Potencia de funciones
	  | FExp Func		--Funcion exponencial
	  | FLn Func		--Funcion logaritmica
	  | FSen Func		--Funcion Seno
	  | FCos Func		--Funcion Coseno
	  | FTan Func		--Funcion Tangente
	  | FSec Func		--Funcion Secante
	  | FCsc Func		--Funcion Cosecante
	  | FCot Func		--Funcion Cotangente
	deriving (Show, Eq, Ord)
