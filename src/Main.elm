module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Slider
import Task
import Http


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
    { img_file : Maybe File
    , img_url : Maybe String
    , widthSlider : Slider.Model
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { img_file = Nothing
      , img_url = Nothing
      , widthSlider = Slider.Model 100 10 800 1
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected File
    | ImageLoaded String
    | SliderMsg Slider.Msg
    | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ImageRequested ->
            ( model
            , Select.file [ "image/jpeg", "image/png" ] ImageSelected
            )

        ImageSelected file ->
            ( { model | img_file = Just file }
            , Task.perform ImageLoaded (File.toUrl file)
            )

        ImageLoaded content ->
            ( { model | img_url = Just content }
            , Cmd.none
            )

        SliderMsg slider_msg ->
            ( { model | widthSlider = Slider.update slider_msg model.widthSlider }
            , Cmd.none
            )

        Submit ->
            (model, )

-- VIEW


view : Model -> Html Msg
view model =
    case model.img_url of
        Nothing ->
            Html.div []
                [ viewImageLoadButton
                , viewSlider "width" model.widthSlider
                ]

        Just content ->
            Html.div []
                [ viewImageLoadButton
                , viewSlider "width" model.widthSlider
                , Html.div []
                    [ Html.img [ Attr.src content, Attr.width (round model.widthSlider.value) ] []
                    ]
                ]


viewImageLoadButton : Html Msg
viewImageLoadButton =
    Html.div []
        [ Html.button [ onClick ImageRequested ] [ Html.text "Load Image" ] ]


viewSubmitButton : Html Msg
viewSubmitButton =
    Html.div []
        [ Html.button [ onClick Submit ] [ Html.text "convert" ] ]


viewSlider : String -> Slider.Model -> Html Msg
viewSlider name model =
    Html.div []
        [ Html.text name
        , Html.map SliderMsg (Slider.view [ Attr.name name ] model)
        , Html.text (model.value |> String.fromFloat)
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
