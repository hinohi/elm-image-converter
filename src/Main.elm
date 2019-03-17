module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, img, text)
import Html.Attributes as Attributes
import Html.Events exposing (onClick)
import Slider
import Task



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { img : Maybe String
    , imgWidth : Slider.Model
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { img = Nothing
      , imgWidth = Slider.Model 100 10 800 1
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected File
    | ImageLoaded String
    | SliderMsg Slider.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ImageRequested ->
            ( model
            , Select.file [ "image/jpeg", "image/png" ] ImageSelected
            )

        ImageSelected file ->
            ( model
            , Task.perform ImageLoaded (File.toUrl file)
            )

        ImageLoaded content ->
            ( { model | img = Just content }
            , Cmd.none
            )

        SliderMsg slider_msg ->
            ( { model | imgWidth = Slider.update slider_msg model.imgWidth }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    case model.img of
        Nothing ->
            div []
                [ div []
                    [ button [ onClick ImageRequested ] [ text "Load Image" ]
                    , Html.map SliderMsg (Slider.view model.imgWidth)
                    ]
                ]

        Just content ->
            div []
                [ div []
                    [ button [ onClick ImageRequested ] [ text "Change Image" ]
                    , Html.map SliderMsg (Slider.view model.imgWidth)
                    ]
                , div []
                    [ img [ Attributes.src content, Attributes.width (round model.imgWidth.value) ] []
                    ]
                ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
