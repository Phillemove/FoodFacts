module Product exposing (Product, ProductDetail(..), productsDecoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, optionalAt, required)


type alias Product =
    { id : String
    , name : String
    , imageurl : String
    , nutriscore : String
    , keywords : List String
    , kcal100g : Float
    , brand : String
    , nutrientLevels : NutrientLevels
    , ingredients : List String
    }


type alias NutrientLevels =
    { fat : String
    , salt : String
    , saturatedfats : String
    , sugars : String
    }


type ProductDetail
    = ProductDetail Product
    | Empty


productsDecoder : Decoder (List Product)
productsDecoder =
    Decode.field "products"
        (Decode.list
            (Decode.succeed Product
                |> required "_id" Decode.string
                |> optional "product_name" Decode.string "noname"
                |> optional "image_front_thumb_url" Decode.string "noimage"
                |> optional "nutriscore_grade" Decode.string "noscore"
                |> required "_keywords" (Decode.list Decode.string)
                |> optionalAt [ "nutriments", "energy-kcal_100g" ] Decode.float -1
                |> optional "brands" Decode.string "nobrand"
                |> optional "nutrient_levels" nutrientLevelsDecoder { fat = "", salt = "", saturatedfats = "", sugars = "" }
                |> optional "ingredients" (Decode.list (Decode.field "text" Decode.string)) []
            )
        )


nutrientLevelsDecoder : Decoder NutrientLevels
nutrientLevelsDecoder =
    Decode.succeed NutrientLevels
        |> optional "fat" Decode.string ""
        |> optional "salt" Decode.string ""
        |> optional "saturated-fat" Decode.string ""
        |> optional "sugars" Decode.string ""
