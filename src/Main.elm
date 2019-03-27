module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Element exposing (Element, layout)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import File exposing (File)
import File.Select as Select
import Html exposing (Html)
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


type alias SliderModel =
    { value : Float
    , min : Float
    , max : Float
    , step : Float
    , name : String
    }


type alias Model =
    { img_file : Maybe File
    , img_url : Maybe String
    , widthSlider : SliderModel
    , aSlider : SliderModel
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { img_file = Nothing
      , img_url = Nothing
      , widthSlider = SliderModel 100 10 800 1 "width"
      , aSlider = SliderModel 0.5 0.0 1.0 0.01 "a"
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected File
    | ImageLoaded String
    | WidthSliderChange Float
    | ASliderChange Float


updateSlider : Float -> SliderModel -> SliderModel
updateSlider value model =
    { model | value = value }


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

        WidthSliderChange value ->
            ( { model | widthSlider = updateSlider value model.widthSlider }
            , Cmd.none
            )

        ASliderChange value ->
            ( { model | aSlider = updateSlider value model.aSlider }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    let
        body =
            case model.img_url of
                Nothing ->
                    Element.column [ Element.padding 10 ]
                        [ viewImageLoadButton
                        , viewSlider WidthSliderChange model.widthSlider
                        , viewSlider ASliderChange model.aSlider
                        ]

                Just content ->
                    Element.column [ Element.padding 10 ]
                        [ viewImageLoadButton
                        , viewSlider WidthSliderChange model.widthSlider
                        , viewSlider ASliderChange model.aSlider
                        , Element.image
                            [ Element.width (model.widthSlider.value |> round |> Element.px) ]
                            { src = content, description = "画像" }
                        ]
    in
    layout [] body


viewImageLoadButton : Element Msg
viewImageLoadButton =
    Input.button [] { onPress = Just ImageRequested, label = Element.text "load image" }


viewSlider : (Float -> Msg) -> SliderModel -> Element Msg
viewSlider onChange model =
    Element.row []
        [ Input.slider
            [ Element.width (Element.px 150)
            , Element.behindContent
                (Element.el
                    [ Element.width Element.fill
                    , Element.height (Element.px 5)
                    , Element.centerY
                    , Background.color (Element.rgb255 120 120 120)
                    , Border.rounded 3
                    ]
                    Element.none
                )
            ]
            { onChange = onChange
            , label = Input.labelLeft [] (Element.text model.name)
            , min = model.min
            , max = model.max
            , value = model.value
            , thumb = Input.defaultThumb
            , step = Just model.step
            }
        , Element.text (String.fromFloat model.value)
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
