
# MEAL AI (standalone Food Search)

Itsenäinen SwiftUI-sovellus nimellä **MEAL AI**. Ominaisuudet:
- Teksti-/äänihaku (USDA + AI-tarkennus)
- Viivakoodi (OpenFoodFacts)
- Kamera (OpenAI Vision)
- Suosikit
- Shortcut-integraatio (iAPS)

## Käyttöönotto
1) Lisää Info.plist:
   - `NSCameraUsageDescription` (esim. "Kameraa käytetään ruoka-annoksen kuvaamiseen")
   - `NSMicrophoneUsageDescription` (esim. "Mikrofonia käytetään äänihakuun")
   - `NSSpeechRecognitionUsageDescription` (esim. "Puheentunnistusta käytetään äänihakuun")
2) Avaa MEAL AI → Asetukset → syötä API-avaimet (OpenAI vähintään). Avaimet tallennetaan **Keychainiin**.
3) Aseta Shortcuttin nimi, jos haluat välittää makrot iAPS:lle.

## Huom.
- Claude/Gemini on jätetty placeholderiksi – voit lisätä provider-luokat samalla rajapinnalla.
- Kuvien lähetys tehdään base64-data-urlina OpenAI chat completions -päätepisteelle.
- App Group (`group.lajtinen.MEAL-AI`) on valmiina tulevia integraatioita varten.
