# Mathematicus

iOS aplikace (SwiftUI, iOS 17+) pro procvičování matematiky 2. stupně ZŠ (6.–9. třída) formou tréninku a her.
Bundle ID: `cz.mathematicus.app`

## Jak to funguje
- **Profily** – každé dítě má svého hráče (avatar, XP, úroveň, denní série 🔥).
- **Rozcestník tříd** 6.–9. → v každé třídě 9–10 okruhů.
- **Trénink** – 10 náhodně generovaných příkladů (lehká/střední/těžká) s nápovědou a vysvětlením řešení.
  Výsledek alespoň 6/10 odemkne challenge okruhu.
- **Challenge** na konci okruhu (střídají se):
  - ⏱ *Závod s časem* – 60 s, co nejvíc správných odpovědí,
  - ❤️ *Přežití* – 3 životy, příklady těžknou,
  - 🔥 *Souboj s bossem* – správné odpovědi ubírají bossovi HP, série 3 = dvojnásobný zásah.
  Za výkon 1–3 ⭐.
- **Velká výzva třídy** – boss s příklady ze všech okruhů, odemkne se po získání hvězdy v 5 okruzích.

## Okruhy
| Třída | Okruhy |
|---|---|
| 6. | Přirozená čísla, Desetinná čísla, Dělitelnost, Zlomky, Rovnice a nerovnice, Převody jednotek, Úhly, Obvod a obsah, Krychle a kvádr, Zaokrouhlování |
| 7. | Zlomky, Celá čísla, Racionální čísla, Poměr, Úměrnost, Procenta, Promile, Obsahy útvarů, Hranoly |
| 8. | Druhá mocnina a odmocnina, Pythagorova věta, Mocniny, Výrazy, Mnohočleny, Lineární rovnice, Kruh a kružnice, Válec, Statistika |
| 9. | Vzorce, Lomené výrazy, Soustavy rovnic, Lineární funkce, Podobnost, Jehlan a kužel, Koule, Goniometrie, Finanční matematika |

## Struktura
- `Mathematicus/Generators/Grade6…9.swift` – generátory příkladů (každý okruh = funkce `(obtížnost) -> Question`)
- `Mathematicus/Models/Curriculum.swift` – třídy, okruhy, typy challenge
- `Mathematicus/Models/AppStore.swift` – profily a postup (ukládá se do UserDefaults)
- `Mathematicus/Views/` – SwiftUI obrazovky
- `MathematicusTests/` – testy generátorů (tisíce náhodných příkladů ověří, že správná odpověď projde kontrolou)

Nový okruh přidáš napsáním generátoru a jeho zapsáním do `Curriculum.grades`.

## Build a testy
```bash
xcodebuild -project Mathematicus.xcodeproj -scheme Mathematicus -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Ladicí spouštěcí argumenty (jen DEBUG): `-demoProfile`, `-unlockAll`, `-openTopic g8-1`, `-openPractice`, `-openChallenge`.
