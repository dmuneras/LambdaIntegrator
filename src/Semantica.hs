module Semantica where

import GramaticaConcreta
import GramaticaAbstracta

{-Funcion que sustituye una variable en una funcion
-}
sust :: Func -> (Char, Func) -> Func
sust a@(FConst c) _ = a
sust a@(FVar x) (var,f)
      | x == var      = f
      | otherwise     = a 
sust (FSum a b) s@(var,f)  = FSum (sust a s) (sust b s)
sust (FRes a b) s@(var,f)  = FRes (sust a s) (sust b s)
sust (FMult a b) s@(var,f) = FMult (sust a s) (sust b s)
sust (FDiv a b) s@(var,f)  = FDiv (sust a s) (sust b s)
sust (FPot a b) s@(var,f)  = FPot (sust a s) (sust b s)
sust (FExp a) s@(var, f)   = FExp (sust a s)
sust (FLn a)  s@(var, f)   = FLn  (sust a s)
sust (FSen a) s@(var, f)   = FSen (sust a s)
sust (FCos a) s@(var, f)   = FCos (sust a s)
sust (FTan a) s@(var, f)   = FTan (sust a s)
sust (FSec a) s@(var, f)   = FSec (sust a s)
sust (FCsc a) s@(var, f)   = FCsc (sust a s)
sust (FCot a) s@(var, f)   = FCot (sust a s)

{-Funcion que saca el caracter que representa la variable de un diferencial
-}
sacarVar :: Dif -> Char
sacarVar (Dif x) = x
	
{- Funcion que integra una Func 
-}
eval :: Itg -> Func
eval (ItgSim (a,b) f d) = reduccion (integral a b 2.0 f (sacarVar d))
eval (ItgMult (a,b) i d)= reduccion ( integral a b 2.0 (eval i) (sacarVar d))

{-Funcion que integra funciones
-}                  
integral :: Func -> Func -> Double -> Func -> Char -> Func
integral a b m f d = let (xi1,xi2) = foldl g (FConst (0.0),FConst (0.0)) [1..(2*m-1)]
                 in  FDiv (FMult (h) (FSum (xi0) (FSum (FMult (FConst 2) (xi2))
                  (FMult (FConst 4) (xi1)))))
                  (FConst 3.0)
    where g (xi1,xi2) i
              | even (truncate i)   = (xi1, FSum (xi2) (sust f (d,(x i))))
              | otherwise = (FSum (xi1) (sust f (d, (x i))), xi2)
          x i             = FSum a (FMult (FConst i)  h)
          h               = FDiv (FRes b a) (FMult (FConst 2.0) (FConst m))
          xi0             = FSum (sust f (d,a)) (sust f (d, b))

{-Funcion que determina si una funcion es constante          
-}
isCons :: Func -> Bool
isCons (FConst a) = True
isCons _          = False

{-Funcion que saca el valor de una funcion constante
-}
sacarNum :: Func -> Double
sacarNum (FConst a) = a
sacarNum _          = error "No const"

{-Funcion que reduce los terminos de una funcion y de sus subterminos
-}          
reduccion' :: Func -> Func
reduccion' (FConst c) = FConst c
reduccion' (FVar x)   = FVar x
reduccion' (FSum a b)
		| (isCons a) && (isCons b) = FConst (sacarNum (a)+ sacarNum (b))
		| otherwise                =  FSum (reduccion' a) (reduccion' b)
reduccion' (FRes a b)
		| (isCons a) && (isCons b) = FConst (sacarNum (a)- sacarNum (b))
		| otherwise                =  FRes (reduccion' a) (reduccion' b)
reduccion' (FMult a b)
		| (isCons a) && (isCons b) = FConst (sacarNum (a)* sacarNum (b))
		| otherwise                =  FMult (reduccion' a) (reduccion' b)
reduccion' (FDiv a b)
		| (isCons a) && (isCons b) = FConst (sacarNum (a)/ sacarNum (b))
		| otherwise                = FDiv (reduccion' a) (reduccion' b)
reduccion' (FPot a b)
		| (isCons a) && (isCons b) = FConst ((sacarNum (a)**(sacarNum (b))))
		| otherwise                = FPot (reduccion' a) (reduccion' b)
reduccion' (FExp a)
		| isCons a  = FConst ((2.7182)**(sacarNum (a)))
		| otherwise = FExp (reduccion' a)
reduccion' (FLn a)
		| isCons a  = FConst (log (sacarNum (a)))
		| otherwise = FLn (reduccion' a)
reduccion' (FSen a)
		| isCons a  = FConst (sin (sacarNum (a)))
		| otherwise = FSen (reduccion' a)
reduccion' (FCos a)
		| isCons a  = FConst (cos (sacarNum (a)))
		| otherwise = FCos (reduccion' a)
reduccion' (FTan a)
		| isCons a  = FConst (tan (sacarNum (a)))
		| otherwise = FTan (reduccion' a)
reduccion' (FCot a)
		| isCons a  = FConst (1/tan(sacarNum (a)))
		| otherwise = FCot (reduccion' a)
reduccion' (FSec a)
		| isCons a  = FConst (1/cos (sacarNum (a)))
		| otherwise = FSec (reduccion' a)
reduccion' (FCsc a)
		| isCons a  = FConst (1/sin (sacarNum (a)))
		| otherwise = FCsc (reduccion' a)

{-Funcion que determina hasta que punto se reduce
-}
reduccion :: Func -> Func
reduccion t = let t' = reduccion' t
              in if t == t'
                 then t'
                 else reduccion t'