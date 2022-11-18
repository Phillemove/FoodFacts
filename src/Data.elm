module Data exposing (Data(..), fromResult)

import Http


type Data value
    = Loading
    | Failure Http.Error
    | Success value
    | Empty


fromResult : Result Http.Error (List a) -> Data (List a)
fromResult result =
    case result of
        Err e ->
            Failure e

        Ok value ->
            Success value
