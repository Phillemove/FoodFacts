module Images exposing (getNutriscoreImg, getTrafficLightSvg)

import Html exposing (text)
import Svg exposing (Svg, svg)
import Svg.Attributes


getNutriscoreImg : String -> String
getNutriscoreImg score =
    "https://static.openfoodfacts.org/images/attributes/nutriscore-" ++ score ++ ".svg"


getTrafficLightSvg : String -> Svg msg
getTrafficLightSvg nutrientlvl =
    case nutrientlvl of
        "low" ->
            trafficLightSvg "black" "black" "green"

        "moderate" ->
            trafficLightSvg "black" "yellow" "black"

        "high" ->
            trafficLightSvg "red" "black" "black"

        _ ->
            text ""


trafficLightSvg : String -> String -> String -> Svg msg
trafficLightSvg top middle down =
    svg
        [ Svg.Attributes.width "90"
        , Svg.Attributes.height "30"
        , Svg.Attributes.viewBox "0 0 90 30"
        ]
        [ Svg.rect
            [ Svg.Attributes.x "0"
            , Svg.Attributes.y "0"
            , Svg.Attributes.rx "5"
            , Svg.Attributes.ry "5"
            , Svg.Attributes.width "90"
            , Svg.Attributes.height "30"
            , Svg.Attributes.fill "lightgrey"
            ]
            []
        , Svg.circle
            [ Svg.Attributes.cx "15"
            , Svg.Attributes.cy "15"
            , Svg.Attributes.r "15"
            , Svg.Attributes.fill top
            ]
            []
        , Svg.circle
            [ Svg.Attributes.cx "45"
            , Svg.Attributes.cy "15"
            , Svg.Attributes.r "15"
            , Svg.Attributes.fill middle
            ]
            []
        , Svg.circle
            [ Svg.Attributes.cx "75"
            , Svg.Attributes.cy "15"
            , Svg.Attributes.r "15"
            , Svg.Attributes.fill down
            ]
            []
        ]
