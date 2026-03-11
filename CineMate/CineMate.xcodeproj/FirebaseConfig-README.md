// Firebase konfiguration

// Den här filen förklarar hur du ska hantera Firebase-konfigurationen i projektet.

// Vad har jag gjort nu?
// - Skapat en platshållarfil med namnet `GoogleService-Info.example.plist.plist` för att släcka den röda referensen i Xcode.
// - Den här filen ska INTE användas i produktion eller byggas in i appen.

// Rätt sätt framåt
// 1. Hämta din riktiga `GoogleService-Info.plist` från Firebase Console (Project settings → Your apps → iOS app).
// 2. Lägg filen i projektet (dra in i Xcode):
//    - Kryssa i "Copy items if needed".
//    - Bocka i din app’s Target Membership.
// 3. Se till att `GoogleService-Info.example.plist` (exempelfilen) inte är inkluderad i target.
// 4. Om du inte vill ha dubbeländelse i repo, byt namn på exempelfilen till `GoogleService-Info.example.plist` och uppdatera Xcode-referensen.

// Valfri säkerhetskontroll i Build Phase
// Lägg till ett Run Script i Build Phases för att få ett tydligt fel om filen saknas:

/*
FILE="${SRCROOT}/PATH/TILL/GoogleService-Info.plist"
if [ ! -f "$FILE" ]; then
  echo "error: Missing GoogleService-Info.plist. Ladda ner från Firebase Console och lägg den på $FILE"
  exit 1
fi
*/

// Tips: Lägg aldrig upp din riktiga `GoogleService-Info.plist` i publika repos. Använd privata repos eller CI-hemligheter.
