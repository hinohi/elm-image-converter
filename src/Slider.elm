module Slider exposing (Model, Msg, update, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode


type alias Model =
    { value : Float
    , minValue : Float
    , maxValue : Float
    , step : Float
    }


type Msg
    = ChangeValue Float


update : Msg -> Model -> Model
update msg slider =
    case msg of
        ChangeValue value ->
            { slider | value = value }


view : Model -> Html Msg
view model =
    Html.input
        [ Attr.type_ "range"
        , Attr.min (model.minValue |> String.fromFloat)
        , Attr.max (model.maxValue |> String.fromFloat)
        , Attr.step (model.step |> String.fromFloat)
        , Events.on "change" (Decode.map ChangeValue Decode.float)
        ]
        []
