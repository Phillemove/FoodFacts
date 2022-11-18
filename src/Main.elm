module Main exposing (main)

import Browser
import Browser.Events
import Data exposing (Data(..))
import Filter exposing (Filter(..), filterListToString, filterProducts, filterProductsBasedOnKeywords, filterProductsBasedOnNutriscore, removeAllFilter)
import Html exposing (Attribute, Html, br, button, div, h2, h3, h4, h5, img, input, li, table, td, text, tr, ul)
import Html.Attributes exposing (id, placeholder, src, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Images exposing (getNutriscoreImg, getTrafficLightSvg)
import Json.Decode as Decode exposing (Decoder)
import Product exposing (Product, ProductDetail(..))
import Styles
    exposing
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


type alias Model =
    { searchKey : String
    , products : Data (List Product)
    , productDetail : ProductDetail
    , shoppingList : List Product
    , keywordList : List String
    , collapsedContainers : List String
    , activeFilters : List Filter
    }


type Msg
    = Change String
    | ExecSearch
    | Response (Result Http.Error (List Product))
    | Key Key
    | ProductClick Product
    | AddToShoppingList Product
    | DeleteFromShoppingList String
    | LookForAlternatives String
    | Selected String
    | LookForKeywords
    | DeleteShoppingList
    | ToggleCollapse String
    | RemoveAllFilters


type Key
    = Enter
    | Unknown


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , subscriptions = subscriptions
        , view = view
        , update = update
        }


init : ( Model, Cmd Msg )
init =
    ( { searchKey = ""
      , products = Data.Empty
      , productDetail = Product.Empty
      , shoppingList = []
      , keywordList = []
      , collapsedContainers = []
      , activeFilters = []
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div mainGridStyles
        [ div searchGridStyles
            [ input
                (placeholder "Eingabe (mindestens zwei Zeichen eingeben)"
                    :: onInput Change
                    :: inputStyles
                )
                []
            , button (onClick ExecSearch :: buttonStyles) [ text "Suchen" ]
            , br [] []
            , filterView model.activeFilters
            ]
        , br [] []
        , productsView model.products
        , div subGridStyles
            [ shoppingListView model.shoppingList
            , productDetailView model.productDetail model.keywordList model.collapsedContainers
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change string ->
            ( { model
                | searchKey = string
                , products = Data.Empty
                , productDetail = Product.Empty
                , keywordList = []
              }
            , Cmd.none
            )

        ExecSearch ->
            ( { model
                | products = validateSearchkeyData model.searchKey
                , keywordList = []
              }
            , validateSearchkeyCmd model.searchKey
            )

        Response result ->
            ( { model
                | products = Data.fromResult result
              }
            , Cmd.none
            )

        Key buttonkey ->
            case buttonkey of
                Enter ->
                    ( { model
                        | products = validateSearchkeyData model.searchKey
                        , keywordList = []
                      }
                    , validateSearchkeyCmd model.searchKey
                    )

                Unknown ->
                    ( model, Cmd.none )

        ProductClick product ->
            ( { model
                | productDetail = ProductDetail product
              }
            , Cmd.none
            )

        AddToShoppingList product ->
            if List.member product model.shoppingList then
                ( model, Cmd.none )

            else
                ( { model
                    | shoppingList = product :: model.shoppingList
                  }
                , Cmd.none
                )

        DeleteFromShoppingList id ->
            ( { model
                | shoppingList = List.filter (\product -> product.id /= id) model.shoppingList
              }
            , Cmd.none
            )

        LookForAlternatives score ->
            ( { model
                | products =
                    Success
                        (filterProductsBasedOnNutriscore
                            score
                            (case model.products of
                                Success products ->
                                    products

                                _ ->
                                    []
                            )
                        )
                , activeFilters =
                    Nutriscore score
                        (case model.products of
                            Success products ->
                                products

                            _ ->
                                []
                        )
                        :: model.activeFilters
              }
            , Cmd.none
            )

        Selected key ->
            ( { model | keywordList = checkKeywords key model.keywordList }, Cmd.none )

        LookForKeywords ->
            ( { model
                | products =
                    Success
                        (filterProductsBasedOnKeywords
                            model.keywordList
                            (case model.products of
                                Success products ->
                                    products

                                _ ->
                                    []
                            )
                        )
                , activeFilters =
                    Keywords model.keywordList
                        (case model.products of
                            Success products ->
                                products

                            _ ->
                                []
                        )
                        :: model.activeFilters
              }
            , Cmd.none
            )

        DeleteShoppingList ->
            ( { model | shoppingList = [] }, Cmd.none )

        ToggleCollapse id ->
            ( { model
                | collapsedContainers =
                    if List.member id model.collapsedContainers then
                        List.filter (\i -> i /= id) model.collapsedContainers

                    else
                        id :: model.collapsedContainers
              }
            , Cmd.none
            )

        RemoveAllFilters ->
            ( { model
                | products = Success (removeAllFilter model.activeFilters)
                , keywordList = []
                , activeFilters = []
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onKeyDown keyDecoder


keyDecoder : Decoder Msg
keyDecoder =
    let
        toEnter string =
            case string of
                "Enter" ->
                    Enter

                _ ->
                    Unknown
    in
    Decode.map Key (Decode.map toEnter (Decode.field "key" Decode.string))


validateSearchkeyData : String -> Data value
validateSearchkeyData key =
    if String.length key < 2 then
        Data.Empty

    else
        Loading


validateSearchkeyCmd : String -> Cmd Msg
validateSearchkeyCmd key =
    if String.length key < 2 then
        Cmd.none

    else
        getProducts key


getProducts : String -> Cmd Msg
getProducts name =
    Http.get
        { url =
            "https://de.openfoodfacts.org/cgi/search.pl?search_terms="
                ++ name
                ++ "&search_simple=1&action=process&json=true&page_size=100"
        , expect = Http.expectJson Response Product.productsDecoder
        }


errToString : Http.Error -> String
errToString err =
    case err of
        Http.BadUrl _ ->
            "A bad Url was called"

        Http.Timeout ->
            "Connection Timed out"

        Http.NetworkError ->
            "A Network Error occured"

        Http.BadStatus status ->
            "A Bad Status occured " ++ String.fromInt status

        Http.BadBody _ ->
            "A Bad body was returned"


checkKeywords : String -> List String -> List String
checkKeywords keyword keywordList =
    case keywordList of
        [] ->
            [ keyword ]

        _ ->
            if List.member keyword keywordList then
                List.filter (\k -> k /= keyword) keywordList

            else if List.length keywordList < 3 then
                keyword :: keywordList

            else
                keywordList


productsView : Data (List Product) -> Html Msg
productsView prod =
    case prod of
        Success products ->
            case products of
                [] ->
                    text "keine Produkte gefunden..."

                _ ->
                    div productsStyles (List.map productView (filterProducts products))

        Loading ->
            text "Loading"

        Failure err ->
            text (errToString err)

        Data.Empty ->
            text ""


productView : Product -> Html Msg
productView product =
    div productWrapperStyles
        [ div
            ((onClick (ProductClick product) :: productStyles)
                ++ clickableStyle
            )
            [ div fontStyle [ text (splitBrand product.brand) ]
            , br [] []
            , img (src product.imageurl :: productImgStyles) []
            , br [] []
            , text (String.left 15 product.name)
            , br [] []
            , addButton product
            ]
        ]


splitBrand : String -> String
splitBrand brands =
    case List.head (String.split "," brands) of
        Just brand ->
            brand

        Nothing ->
            ""


productDetailView : ProductDetail -> List String -> List String -> Html Msg
productDetailView prodDetail selectedkeywords collapsedContainers =
    case prodDetail of
        ProductDetail product ->
            div productDetailStyles
                [ addButton product
                , h3 [] [ text (splitBrand product.brand) ]
                , h4 [] [ text product.name ]
                , img [ src product.imageurl ] []
                , br [] []
                , br [] []
                , table []
                    [ tr []
                        [ h5 []
                            [ text "Kategorien"
                            , div [ onClick (ToggleCollapse "categories") ]
                                [ text (getCollapsedStatus "categories" collapsedContainers) ]
                            ]
                        ]
                    , tr []
                        [ div (getCollapsedStyle "categories" collapsedContainers)
                            [ keywordsView selectedkeywords product.keywords
                            , br [] []
                            , button [ onClick LookForKeywords ] [ text "Nach Kategorien filtern" ]
                            ]
                        ]
                    ]
                , br [] []
                , br [] []
                , table []
                    [ tr []
                        [ h5 []
                            [ text "Zutaten"
                            , div [ onClick (ToggleCollapse "ingredients") ]
                                [ text (getCollapsedStatus "ingredients" collapsedContainers) ]
                            ]
                        ]
                    , tr []
                        [ div (getCollapsedStyle "ingredients" collapsedContainers)
                            [ ingredientsView product.ingredients ]
                        ]
                    ]
                , table []
                    [ tr []
                        [ h5 []
                            [ text "Nährwertangaben"
                            , div [ onClick (ToggleCollapse "nutrients") ]
                                [ text (getCollapsedStatus "nutrients" collapsedContainers) ]
                            ]
                        ]
                    , tr []
                        [ div (getCollapsedStyle "nutrients" collapsedContainers)
                            [ div []
                                [ table []
                                    [ tr []
                                        [ td [] [ text "Fett: " ]
                                        , td [] [ getTrafficLightSvg product.nutrientLevels.fat ]
                                        ]
                                    , tr []
                                        [ td [] [ text "Salz: " ]
                                        , td [] [ getTrafficLightSvg product.nutrientLevels.salt ]
                                        ]
                                    , tr []
                                        [ td [] [ text "Gesättigte Fettsäuren: " ]
                                        , td [] [ getTrafficLightSvg product.nutrientLevels.saturatedfats ]
                                        ]
                                    , tr []
                                        [ td [] [ text "Zucker: " ]
                                        , td [] [ getTrafficLightSvg product.nutrientLevels.sugars ]
                                        ]
                                    ]
                                ]
                            , img (src (getNutriscoreImg product.nutriscore) :: nutriscoreImgStyles) []
                            , br [] []
                            , if product.nutriscore == "a" || product.nutriscore == "b" then
                                text ""

                              else
                                button [ onClick (LookForAlternatives product.nutriscore) ] [ text "nach Alternativen filtern" ]
                            , br [] []
                            , br [] []
                            , text
                                ("kcal auf 100g: "
                                    ++ (if product.kcal100g < 0 then
                                            "nichts hinterlegt"

                                        else
                                            String.fromFloat product.kcal100g
                                       )
                                )
                            ]
                        ]
                    ]
                ]

        Product.Empty ->
            text ""


shoppingListView : List Product -> Html Msg
shoppingListView products =
    div shoppingListStyles
        [ h2 [] [ text "Einkaufsliste" ]
        , ul [] (List.map shoppingListItemView products)
        , br [] []
        , div []
            [ text "Durchschnittlicher Nutriscore: "
            , case products of
                [] ->
                    text ""

                _ ->
                    img (src (getNutriscoreImg (averageNutriscore products)) :: nutriscoreImgStyles) []
            ]
        , div []
            [ text "Kalorien insgesamt (100g): "
            , case products of
                [] ->
                    text ""

                _ ->
                    text
                        (String.fromFloat
                            (List.foldl (+)
                                0
                                (List.map
                                    (\p ->
                                        if p.kcal100g < 0 then
                                            0

                                        else
                                            p.kcal100g
                                    )
                                    products
                                )
                            )
                        )
            ]
        , if products == [] then
            text ""

          else
            button [ onClick DeleteShoppingList ] [ text "Liste leeren" ]
        ]


shoppingListItemView : Product -> Html Msg
shoppingListItemView product =
    li
        (onClick (ProductClick product)
            :: clickableStyle
            ++ shoppingListItemStyle
        )
        [ input [ type_ "checkbox" ] []
        , text product.name
        , text "    "
        , button [ onClick (DeleteFromShoppingList product.id) ] [ text "x" ]
        ]


keywordsView : List String -> List String -> Html Msg
keywordsView selectedkeywords keywords =
    ul [] (List.map (keywordView selectedkeywords) keywords)


keywordView : List String -> String -> Html Msg
keywordView selectedkeywords keyword =
    li
        (onClick (Selected keyword)
            :: liStyle
            ++ clickableStyle
            ++ (if List.member keyword selectedkeywords then
                    liSelectedStyle

                else
                    []
               )
        )
        [ text keyword ]


ingredientsView : List String -> Html Msg
ingredientsView ingredients =
    ul [] (List.map ingredientView ingredients)


ingredientView : String -> Html Msg
ingredientView ingredient =
    li ingredientStyle [ text (ingredient ++ ", ") ]


averageNutriscore : List Product -> String
averageNutriscore products =
    nutriscoreIntToString <|
        round <|
            List.sum (List.map nutriscoreStringToFloat products)
                / toFloat (List.length products)


nutriscoreStringToFloat : Product -> Float
nutriscoreStringToFloat product =
    case product.nutriscore of
        "a" ->
            1

        "b" ->
            2

        "c" ->
            3

        "d" ->
            4

        "e" ->
            5

        _ ->
            0


nutriscoreIntToString : Int -> String
nutriscoreIntToString score =
    case score of
        1 ->
            "a"

        2 ->
            "b"

        3 ->
            "c"

        4 ->
            "d"

        5 ->
            "e"

        _ ->
            ""


addButton : Product -> Html Msg
addButton prod =
    button [ onClick (AddToShoppingList prod) ] [ text "zur Einkaufsliste hinzufügen" ]


getCollapsedStatus : String -> List String -> String
getCollapsedStatus id collapsedContainers =
    if List.member id collapsedContainers then
        "-"

    else
        "+"


getCollapsedStyle : String -> List String -> List (Attribute msg)
getCollapsedStyle id collapsedContainers =
    if List.member id collapsedContainers then
        []

    else
        displayNone


filterView : List Filter -> Html Msg
filterView filters =
    case filters of
        [] ->
            text ""

        _ ->
            div filterStyles
                [ text ("Aktive Filter: " ++ filterListToString filters), button [ onClick RemoveAllFilters ] [ text "Alle Filter Löschen" ] ]
