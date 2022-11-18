module Filter exposing (Filter(..), filterListToString, filterProducts, filterProductsBasedOnKeywords, filterProductsBasedOnNutriscore, removeAllFilter)

import Product exposing (Product)


type alias Nutriscore =
    String


type alias Keyword =
    String


type Filter
    = Nutriscore Nutriscore (List Product)
    | Keywords (List Keyword) (List Product)


filterListToString : List Filter -> String
filterListToString filters =
    case filters of
        [] ->
            ""

        x :: xs ->
            case x of
                Nutriscore _ _ ->
                    "Filter by Nutriscore, " ++ filterListToString xs

                Keywords _ _ ->
                    "Filter by Keywords, " ++ filterListToString xs


filterProducts : List Product -> List Product
filterProducts list =
    list
        |> List.filter (\p -> p.nutriscore /= "noscore")
        |> List.filter (\p -> p.name /= "noname")
        |> List.filter (\p -> p.imageurl /= "noimage")
        |> List.filter (\p -> p.name /= "")


filterProductsBasedOnKeywords : List String -> List Product -> List Product
filterProductsBasedOnKeywords keywords products =
    case keywords of
        [] ->
            products

        x :: xs ->
            filterProductsBasedOnKeywords xs (List.filter (\p -> List.member x p.keywords) products)


filterProductsBasedOnNutriscore : String -> List Product -> List Product
filterProductsBasedOnNutriscore score list =
    list
        |> List.filter (\p -> p.nutriscore < score)


removeAllFilter : List Filter -> List Product
removeAllFilter filters =
    case filters of
        [] ->
            []

        [ filter ] ->
            case filter of
                Nutriscore _ products ->
                    products

                Keywords _ products ->
                    products

        _ :: xs ->
            removeAllFilter xs
