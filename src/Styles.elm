module Styles exposing
    ( buttonStyles
    , clickableStyle
    , displayNone
    , filterStyles
    , fontStyle
    , ingredientStyle
    , inputStyles
    , liSelectedStyle
    , liStyle
    , mainGridStyles
    , nutriscoreImgStyles
    , productDetailStyles
    , productImgStyles
    , productStyles
    , productWrapperStyles
    , productsStyles
    , searchGridStyles
    , shoppingListItemStyle
    , shoppingListStyles
    , subGridStyles
    )

import Html exposing (Attribute)
import Html.Attributes exposing (style)


mainGridStyles : List (Attribute msg)
mainGridStyles =
    [ style "display" "grid"
    , style "width" "90%"
    , style "grid-template-rows" "10% 90%"
    , style "grid-template-columns" "75% 25%"
    , style "margin" "auto"
    , style "margin-top" "0.1em"
    , style "font-family" "verdana"
    , style "background-color" "white"
    ]


inputStyles : List (Attribute msg)
inputStyles =
    [ style "padding" "10px"
    , style "width" "90%"
    , style "font-size" "1.5em"
    ]


buttonStyles : List (Attribute msg)
buttonStyles =
    [ style "font-size" "1.5em"
    , style "padding" "10px"
    , style "width" "8%"
    , style "float" "right"
    , style "border" "solid 1px black"
    , style "border-radius" "5px"
    ]


searchGridStyles : List (Attribute msg)
searchGridStyles =
    [ style "grid-row" "1/2"
    , style "grid-column" "1/ span 2"
    ]


subGridStyles : List (Attribute msg)
subGridStyles =
    [ style "grid-column" "2/2"
    , style "grid-row" "2/2"
    , style "grid-template-rows" "subgrid"
    , style "position" "sticky"
    , style "top" "0"
    , style "height" "100vh"
    , style "box-sizing" "border-box"
    , style "margin-top" "1em"
    , style "overflow-y" "scroll"
    ]


productsStyles : List (Attribute msg)
productsStyles =
    [ style "display" "flex"
    , style "flex-direction" "row"
    , style "flex-wrap" "wrap"
    , style "grid-column" "1/2"
    , style "grid-row" "2/2"
    , style "margin-top" "1em"
    ]


productWrapperStyles : List (Attribute msg)
productWrapperStyles =
    [ style "width" "14em"
    , style "height" "14em"
    ]


productStyles : List (Attribute msg)
productStyles =
    [ style "box-shadow" "0px 10px 16px 0px rgba(0,0,0,0.2)"
    , style "width" "90%"
    , style "height" "90%"
    , style "text-align" "center"
    , style "background-color" "#F2F2F2"
    ]


productImgStyles : List (Attribute msg)
productImgStyles =
    [ style "width" "6em"
    , style "height" "6em"
    ]


productDetailStyles : List (Attribute msg)
productDetailStyles =
    [ style "box-shadow" "0px 10px 16px 0px rgba(0,0,0,0.2)"
    , style "grid-column" "2/2"
    , style "grid-row" "2/2"
    , style "padding" "0.5em"
    , style "background-color" "#F2F2F2"
    ]


shoppingListStyles : List (Attribute msg)
shoppingListStyles =
    [ style "box-shadow" "0px 10px 16px 0px rgba(0,0,0,0.2)"
    , style "grid-column" "2/2"
    , style "grid-row" "1/2"
    , style "padding" "0.5em"
    , style "background-color" "#F2F2F2"
    , style "margin-bottom" "3em"
    ]


nutriscoreImgStyles : List (Attribute msg)
nutriscoreImgStyles =
    [ style "width" "25%" ]


liStyle : List (Attribute msg)
liStyle =
    [ style "display" "inline-block"
    , style "flex-direction" "row"
    , style "flex-wrap" "wrap"
    , style "border" "solid black 1px"
    , style "padding" "0.3em"
    ]


liSelectedStyle : List (Attribute msg)
liSelectedStyle =
    [ style "background-color" "blue" ]


clickableStyle : List (Attribute msg)
clickableStyle =
    [ style "cursor" "pointer" ]


ingredientStyle : List (Attribute msg)
ingredientStyle =
    [ style "display" "inline-block"
    , style "flex-direction" "row"
    , style "flex-wrap" "wrap"
    , style "padding" "0.1em"
    ]


shoppingListItemStyle : List (Attribute msg)
shoppingListItemStyle =
    [ style "list-style" "none" ]


displayNone : List (Attribute msg)
displayNone =
    [ style "display" "none" ]


fontStyle : List (Attribute msg)
fontStyle =
    [ style "font-weight" "bold" ]


filterStyles : List (Attribute msg)
filterStyles =
    [ style "margin-top" "1em" ]
