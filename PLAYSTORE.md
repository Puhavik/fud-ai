# Play Store Listing

Google Play Console listing copy for Fud AI Android (current: v2.1.0 / versionCode 21). Each field is in a code block for easy copy-paste. Char counts are tracked because Play Console enforces hard caps and silently truncates anything over.

**Where to paste each field in Play Console:**
- App name / Short description / Full description → Grow → Store presence → **Main store listing** (default English) and Grow → Store presence → **Custom store listings** → Manage translations (per-language overrides)
- What's new → **Releases → Production / Closed testing → Create new release → Release notes** field (paste the entire `<lang-tag>` block; Play Console parses tags automatically)

---

## 1. App Name

**30 char hard cap per language.** Brand name stays as `Fud AI` untranslated; the descriptor after the dash is what gets localized. English-only on Play Console — non-English Play Store browsers see the English source as fallback.

### English (en-US) — 24 chars
```
Fud AI - Calorie Tracker
```

---

## 2. Short Description

**80 char hard cap per language. Cannot include price/promotion keywords ("free", "discount", "sale", "best", "#1", etc.) — Play Console will block promotion of the listing.** Live Play Store currently has "Snap, speak, or type a meal. AI logs the calories. Free & open source." which triggers the warning; replacement below drops "Free" while keeping the same rhythm. English-only on Play Console — non-English Play Store browsers see the English source as fallback.

### English (en-US) — 63 chars
```
Snap, speak, or type a meal. AI logs the calories. Open source.
```

---

## 3. Full Description

**4000 char hard cap per language.** This is the long-form "About this app" copy. English-only on Play Console — non-English Play Store browsers see the English source as fallback (deliberate decision; the in-app UI is fully translated via per-locale `values-{lang}/strings.xml` so users still get a localized experience once installed).

### English (en-US)
```
Fud AI makes calorie tracking effortless with AI-powered food recognition. Snap a photo, scan a barcode, speak it, or type it — get instant nutrition: calories, protein, carbs, fats, vitamins, minerals, and more.

NEW in v2.1.0: Health Connect can estimate calorie goals from energy burn while keeping macros editable, macro nutrition preserves decimal grams across logs/Home/widgets, Progress shows net change and average for weight/body fat, future-day logging no longer crashes with Health Connect, About > What's New shows the in-app changelog, and update checks ask Google Play directly.

Free, open source, privacy-first. Bring your own API key. All data stays on your device.

HOW TO USE
1) Set up your profile with goals + body stats
2) Snap, scan, speak, type, or manually enter a meal — review and save
3) Ask Coach anything: trends, predictions, advice
4) Track progress on charts and home screen widgets

11 WAYS TO LOG A MEAL
• Photo — AI identifies food and returns nutrition
• Photo + Note — add context before AI analysis
• Photo + Photo — combine two images in one analysis
• Nutrition Label — scan package nutrition facts
• Barcode — look up packaged foods with Open Food Facts
• From Photos — analyze an existing image
• From Photos + Note — add context to a library photo
• Voice — 5 STT engines with language selection
• Text — describe in plain language, AI parses it
• Manual Entry — name + calories + macros + meal type
• Saved Meals — re-log recents, frequent meals, and favorites
• Copy from Day — copy meals from another date

BODY COMPOSITION TRACKING
Log body fat % over time, set a goal %, and see it alongside weight on the unified Progress chart. Health Connect can auto-import samples from compatible apps and scales.

13 AI PROVIDERS
Google Gemini, OpenAI, Anthropic Claude, xAI Grok, Groq, OpenRouter, Together AI, Hugging Face, Fireworks AI, DeepInfra, Mistral, Ollama, or any OpenAI-compatible endpoint. Switch anytime. Keys are stored encrypted.

6 SPEECH-TO-TEXT ENGINES
Native Android, Gemini, OpenAI Whisper, Groq, Deepgram, AssemblyAI. Choose Provider Auto, Use Device Language, or a fixed language.

COACH
Multi-turn chat that sees your profile, weight, body fat, and food log. Ask "what was my weight in March?" or "how's my protein this week?" — Coach pulls the date range it needs via on-demand tools. You can also attach a camera photo or photo-library image to a Coach message.

PERSONALIZED GOALS
BMR via Katch-McArdle or Mifflin-St Jeor. TDEE with 6 activity levels. Auto-calculated calorie + protein + carbs + fat targets — fully customizable.

OPTIONAL NUTRIENT GOALS
Set expanded nutrient goals separately from the macro calculator: fiber, sugar, fats, cholesterol, sodium, potassium, calcium, iron, magnesium, zinc, vitamins, folate, omega-3, and more when available. Use AI Estimate from your profile, or set goals manually. Home cards can show macros or selected detailed nutrients.

PROGRESS
Unified Weight / Body Fat chart with current, goal, net change, average, trend lines, and goal overlays. Calorie trend vs goal. Macro averages over 1W, 1M, 3M, 6M, 1Y, All Time.

WIDGETS
Calorie and nutrient widgets refresh when you log a meal.

15 LANGUAGES
Auto-selected by phone language: English, Spanish, French, German, Italian, Portuguese (BR), Dutch, Russian, Japanese, Korean, Chinese, Hindi, Arabic, Romanian, Azerbaijani.

PRIVACY FIRST
No account, no sign-in, no cloud sync, no analytics, no ads, no tracking. Local-only. MIT licensed.

HEALTH CONNECT
Sync nutrition, weight, and body fat with permission reconciliation and backfill support. Edits and deletes sync back where supported.

NOTE: Not medical advice. All nutritional estimates are AI-generated. Consult a healthcare professional before significant diet changes.

Terms: https://fud-ai.app/terms.html
Privacy: https://fud-ai.app/privacy.html
Source: https://github.com/apoorvdarshan/fud-ai

```

### Other 14 languages
English-only on Play Console — non-English Play Store browsers (ar, az-AZ, de-DE, es-ES, fr-FR, hi-IN, it-IT, ja-JP, ko-KR, nl-NL, pt-BR, ro, ru-RU, zh-CN) see the English source as fallback. The in-app UI itself is fully translated into all 14 locales via per-locale `values-{lang}/strings.xml`, so the localization gap is only on the Play Store listing surface, not inside the app.

---

## 4. What's New (v2.1.0 / versionCode 21)

**500 char hard cap per language.** Paste the entire block below into Play Console's "Release notes" field — it auto-routes each `<lang-tag>` block to the matching locale.

```
<en-US>
• Health Connect can estimate calorie goals from energy burn; macros stay editable.
• Decimal macro grams are preserved in logs, Home, nutrition details, and widgets.
• Progress shows current, goal, net change, and average for weight/body fat.
• Quantity fields support comma decimals, clearer cursor/clear behavior, and tap-out keyboard dismiss.
• Future-day logging no longer crashes when Health Connect is enabled; update checks ask Google Play directly.
</en-US>

<ar>
• Health Connect يقدر هدف السعرات من الطاقة المحروقة، والماكروز تبقى قابلة للتعديل.
• حفظ غرامات الماكروز العشرية في السجل وHome والتفاصيل والويدجت.
• Progress يعرض الحالي والهدف وصافي التغيير والمتوسط للوزن ودهون الجسم.
• الكمية تدعم الفاصلة العشرية مع تحرير أوضح وإغلاق لوحة المفاتيح عند النقر خارجها.
• تسجيل الأيام المستقبلية لم يعد يتعطل مع Health Connect؛ التحديثات عبر Google Play.
</ar>

<az-AZ>
• Health Connect yandırılan enerjidən kalori hədəfini təxmin edə bilər; makrolar redaktə edilə qalır.
• Ondalıq makro qramları loglarda, Home-da, detallarda və vidjetlərdə saxlanır.
• Progress çəki və bədən yağı üçün cari, hədəf, net dəyişiklik və ortalamanı göstərir.
• Miqdar sahələri vergül ondalığını, daha aydın kursor/təmizləmə davranışını və kənara toxunanda klaviaturanın bağlanmasını dəstəkləyir.
• Gələcək günə qeyd Health Connect ilə artıq çökmür; yeniləmə Google Play-dən yoxlanır.
</az-AZ>

<de-DE>
• Health Connect kann Kalorienziele aus verbrannter Energie schätzen; Makros bleiben editierbar.
• Dezimale Makro-Grammwerte bleiben in Logs, Home, Details und Widgets erhalten.
• Progress zeigt Aktuell, Ziel, Nettoänderung und Durchschnitt für Gewicht/Körperfett.
• Mengenfelder unterstützen Komma-Dezimalwerte, besseres Cursor-/Löschverhalten und Tastatur-Ausblenden per Tippen außerhalb.
• Zukunfts-Logging stürzt mit Health Connect nicht mehr ab; Updates fragen Google Play.
</de-DE>

<es-ES>
• Health Connect puede estimar el objetivo de calorías desde la energía quemada; los macros siguen editables.
• Los gramos decimales de macros se conservan en registros, Home, detalles y widgets.
• Progress muestra actual, objetivo, cambio neto y promedio para peso/grasa corporal.
• Los campos de cantidad admiten coma decimal, mejor cursor/borrado y cerrar teclado al tocar fuera.
• Registrar días futuros ya no falla con Health Connect; las actualizaciones consultan Google Play.
</es-ES>

<fr-FR>
• Health Connect peut estimer l'objectif calorique depuis l'énergie brûlée; les macros restent modifiables.
• Les grammes décimaux des macros sont conservés dans le journal, Home, les détails et les widgets.
• Progress affiche actuel, objectif, net et moyenne poids/masse grasse.
• Les champs quantité acceptent la virgule décimale, avec meilleur curseur/effacement et fermeture du clavier en tapant ailleurs.
• Jour futur ne plante plus avec Health Connect; mises à jour via Google Play.
</fr-FR>

<hi-IN>
• Health Connect energy burn से calorie goal estimate कर सकता है; macros editable रहते हैं.
• Decimal macro grams logs, Home, nutrition details और widgets में preserve होते हैं.
• Progress में weight/body fat के लिए current, goal, net change और average दिखता है.
• Quantity fields comma decimals, clear button और बाहर tap पर keyboard dismiss support करते हैं.
• Future-day logging अब Health Connect के साथ crash नहीं करता; update check Google Play से होता है.
</hi-IN>

<it-IT>
• Health Connect può stimare l'obiettivo calorie dall'energia bruciata; i macro restano modificabili.
• I grammi decimali dei macro restano in log, Home, dettagli nutrizionali e widget.
• Progress mostra attuale, obiettivo, cambio netto e media per peso/grasso corporeo.
• I campi quantità supportano decimali con virgola, cursore/cancellazione migliori e chiusura tastiera toccando fuori.
• Il log su giorni futuri non va più in crash con Health Connect; update via Google Play.
</it-IT>

<ja-JP>
• Health Connectの消費エネルギーからカロリー目標を推定可能に。マクロは編集可能です。
• マクロの小数グラムを記録、Home、栄養詳細、ウィジェットで保持します。
• Progressで体重/体脂肪の現在、目標、差分、平均を表示します。
• 数量入力でカンマ小数、カーソル/クリア改善、外側タップでキーボードを閉じる動作に対応。
• Health Connect有効時も未来日の記録でクラッシュしません。更新確認はGoogle Playへ。
</ja-JP>

<ko-KR>
• Health Connect가 에너지 소모량으로 칼로리 목표를 추정할 수 있으며 매크로는 계속 수정 가능합니다.
• 소수점 매크로 g 값이 기록, Home, 영양 상세, 위젯에 유지됩니다.
• Progress에 체중/체지방의 현재, 목표, 순변화, 평균이 표시됩니다.
• 수량 입력에서 쉼표 소수점, 더 나은 커서/지우기, 바깥 탭 키보드 닫기를 지원합니다.
• Health Connect 사용 중 미래 날짜 기록이 더 이상 충돌하지 않으며 업데이트는 Google Play에서 확인합니다.
</ko-KR>

<nl-NL>
• Health Connect kan caloriedoelen schatten uit verbrande energie; macro's blijven bewerkbaar.
• Decimale macrogrammen blijven behouden in logs, Home, details en widgets.
• Progress toont huidig, doel, netto verandering en gemiddelde voor gewicht/vetpercentage.
• Hoeveelheidsvelden ondersteunen kommadecimalen, betere cursor/wissen en toetsenbord sluiten door buiten te tikken.
• Loggen op toekomstige dagen crasht niet meer met Health Connect; updates via Google Play.
</nl-NL>

<pt-BR>
• Health Connect pode estimar a meta de calorias pela energia queimada; macros continuam editáveis.
• Gramas decimais de macros são preservados em registros, Home, detalhes e widgets.
• Progress mostra atual, meta, mudança líquida e média de peso/gordura corporal.
• Campos de quantidade aceitam vírgula decimal, melhor cursor/limpar e fecham teclado ao tocar fora.
• Registrar dias futuros não trava mais com Health Connect; updates consultam Google Play.
</pt-BR>

<ro>
• Health Connect poate estima ținta de calorii din energia arsă; macro-urile rămân editabile.
• Gramele zecimale pentru macro-uri se păstrează în jurnal, Home, detalii și widgeturi.
• Progress arată curent, țintă, schimbare netă și medie pentru greutate/grăsime corporală.
• Câmpurile de cantitate acceptă virgulă zecimală, cursor/ștergere mai clare și închid tastatura la tap în afară.
• Jurnalizarea unei zile viitoare nu mai pică cu Health Connect; update-uri via Google Play.
</ro>

<ru-RU>
• Health Connect оценивает цель калорий по сожженной энергии; макро можно редактировать.
• Десятичные граммы макро сохраняются в журнале, Home, деталях и виджетах.
• Progress показывает текущее, цель, изменение и среднее для веса/жира.
• Количество поддерживает запятую, очистку и закрытие клавиатуры тапом вне поля.
• Запись будущих дней больше не падает с Health Connect; обновления через Google Play.
</ru-RU>

<zh-CN>
• Health Connect 可根据能量消耗估算热量目标，宏量营养仍可编辑。
• 宏量营养的小数克数会保留在日志、Home、营养详情和小组件中。
• Progress 显示体重/体脂的当前、目标、净变化和平均值。
• 数量输入支持逗号小数，光标/清除更顺手，点按输入框外可收起键盘。
• Health Connect 开启时记录未来日期不再崩溃，更新检查直接询问 Google Play。
</zh-CN>
```

---

## 5. Categorization

```
App category: Health & Fitness
Tags: Calorie tracker, Nutrition, AI, Food tracker
```

## 6. Contact details

```
Email: apoorv@fud-ai.app
Phone: (omit — optional, US-only enforcement)
Website: https://fud-ai.app
Privacy policy: https://fud-ai.app/privacy.html
```

## 7. App content declarations

These are one-time setup in Play Console → Policy → App content. Don't drift from these answers across submissions:

- **Privacy policy URL**: https://fud-ai.app/privacy.html
- **App access**: All functionality available without restrictions
- **Ads**: No
- **Content rating**: Everyone (E)
- **Target audience**: 13+
- **News app**: No
- **COVID-19 contact tracing**: No
- **Data safety**: All processing on-device. No data collected/shared. API keys stored in EncryptedSharedPreferences. Encryption in transit when calling AI provider APIs (HTTPS). User can request deletion via in-app "Delete All Data" — no server data exists.
- **Government app**: No
- **Financial features**: No
- **Health features**: Yes — fitness/nutrition tracking. Local-only.
