module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Element exposing (Element, layout)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import File exposing (File)
import File.Select as Select
import Html exposing (Html)
import Http
import Task
import Url.Builder



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
    , submitable : Bool
    , widthSlider : SliderModel
    , hueSlider : SliderModel
    , luminanceSlider : SliderModel
    , saturationSlider : SliderModel
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { img_file = Nothing
      , img_url = Nothing
      , submitable = True
      , widthSlider = SliderModel 100 10 800 1 "width"
      , hueSlider = SliderModel 0.5 0.0 1.0 0.01 "H"
      , luminanceSlider = SliderModel 0.5 0.0 10.0 0.01 "L"
      , saturationSlider = SliderModel 0.5 0.0 1.0 0.01 "S"
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected File
    | ImageLoaded String
    | WidthSliderChange Float
    | HSliderChange Float
    | LSliderChange Float
    | SSliderChange Float
    | Submit
    | Converted (Result Http.Error String)


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

        HSliderChange value ->
            ( { model | hueSlider = updateSlider value model.hueSlider }
            , Cmd.none
            )

        LSliderChange value ->
            ( { model | luminanceSlider = updateSlider value model.luminanceSlider }
            , Cmd.none
            )

        SSliderChange value ->
            ( { model | saturationSlider = updateSlider value model.saturationSlider }
            , Cmd.none
            )

        Submit ->
            let
                req =
                    case model.img_file of
                        Just file ->
                            Http.post
                                { url = Url.Builder.relative [ "api", "hls" ] []
                                , body =
                                    Http.multipartBody
                                        [ Http.stringPart "width" (model.widthSlider.value |> String.fromFloat)
                                        , Http.stringPart "H" (model.hueSlider.value |> String.fromFloat)
                                        , Http.stringPart "L" (model.luminanceSlider.value |> String.fromFloat)
                                        , Http.stringPart "S" (model.saturationSlider.value |> String.fromFloat)
                                        , Http.filePart "image" file
                                        ]
                                , expect = Http.expectString Converted
                                }

                        Nothing ->
                            Cmd.none
            in
            ( { model | submitable = False }
            , req
            )

        Converted _ ->
            ( model, Cmd.none )



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
                        , viewSlider HSliderChange model.hueSlider
                        , viewSlider LSliderChange model.luminanceSlider
                        , viewSlider SSliderChange model.saturationSlider
                        ]

                Just content ->
                    Element.column [ Element.padding 10 ]
                        [ viewImageLoadButton
                        , viewSlider WidthSliderChange model.widthSlider
                        , viewSlider HSliderChange model.hueSlider
                        , viewSlider LSliderChange model.luminanceSlider
                        , viewSlider SSliderChange model.saturationSlider
                        , Element.image
                            [ Element.width (model.widthSlider.value |> round |> Element.px) ]
                            { src = content, description = "画像" }
                        , viewSubmit model.submitable
                        ]
    in
    layout [] body


viewImageLoadButton : Element Msg
viewImageLoadButton =
    Input.button [ Background.color (Element.rgb255 120 120 120) ] { onPress = Just ImageRequested, label = Element.text "load image" }


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


viewSubmit : Bool -> Element Msg
viewSubmit active =
    if active then
        Input.button [] { onPress = Just Submit, label = Element.text "submit" }

    else
        Input.button [] { onPress = Nothing, label = Element.text "submit" }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
