module Slider exposing (Model, Msg, update, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


type alias Model =
    { value : Float
    , minValue : Float
    , maxValue : Float
    , step : Float
    }


type Msg
    = ChangeValue String


update : Msg -> Model -> Model
update msg slider =
    case msg of
        ChangeValue s ->
            case String.toFloat s of
                Just value ->
                    { slider | value = value }

                Nothing ->
                    slider


view : Model -> Html Msg
view model =
    Html.input
        [ Attr.type_ "range"
        , Attr.min (model.minValue |> String.fromFloat)
        , Attr.max (model.maxValue |> String.fromFloat)
        , Attr.step (model.step |> String.fromFloat)
        , Events.onInput ChangeValue
        ]
        []
