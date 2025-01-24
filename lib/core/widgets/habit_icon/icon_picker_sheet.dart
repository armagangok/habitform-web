import '/core/core.dart';

class IconPickerSheet extends StatefulWidget {
  final Function(String) onIconSelected;

  const IconPickerSheet({super.key, required this.onIconSelected});

  @override
  IconPickerSheetState createState() => IconPickerSheetState();
}

class IconPickerSheetState extends State<IconPickerSheet> with SingleTickerProviderStateMixin {
  // Initial selected category index
  int selectedCategoryIndex = 0;

  int? selectedIconIndex;

  late final AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    super.initState();
  }

// Define categories with emojis
  Map<String, List<String>> emojiCategories = {
    LocaleKeys.iconCategories_dailylife.tr(): [
      '🛏️',
      '🛌',
      '🪥',
      '🚿',
      '🧴',
      '🪒',
      '👕',
      '👖',
      '👟',
      '💧',
      '🎛️',
      '🍳',
      '🍞',
      '🥚',
      '🥛',
      "📚", // Kitap
      "🚴‍♂️", // Bisiklet
      "🏊‍♂️", // Yüzme
      "🏃‍♂️", // Koşu
      "🚶🏼‍➡️",
      "🚶🏻‍➡️",
      "🚶🏼‍♀️",
      "🚶🏿‍➡️",
      "🚶🏿‍♀️",
      '☕',
      '🍽️',
      '🍕',
      '🍔',
      '🍜',
      '🍎',
      '🥤',
    ],
    LocaleKeys.iconCategories_sports.tr(): [
      "🚶🏻‍➡️",
      "🚶🏼‍♀️",
      "🚶🏻‍♀️",
      "⚽", // Futbol
      "🏀", // Basketbol
      "⚾", // Beyzbol
      "🥎", // Beyzbol
      "⛳", // Golf
      "🏋️‍♂️", // Ağırlık kaldırma
      "🏈", // Amerikan futbolu
      "🎾", // Tenis
      "🏐", // Voleybol
      "🏉", // Rugby
      "🥏", // Kriket
      "🥋", // MMA
      "🏎️", // Motor sporları
      "🛹", // Skateboard
      "🏂", // Snowboard
      "🏄‍♂️", // Sörf
      "🚣‍♂️", // Kürek sporu
      "🚴‍♂️", // Bisiklet
      "🏊‍♂️", // Yüzme
      "🏃‍♂️", // Koşu
      "🛶", // Kayak
      "⛰️", // Doğa yürüyüşü
      "🥾", // Hiking
      "🛂", // Paragliding
      "⛵", // Yelken sporu
    ],
    LocaleKeys.iconCategories_health.tr(): [
      "❤️", // Kalp
      "🔥", // Kalori yakma
      "🩹", // Sağlık bakımı
      "🌡️", // Sıcaklık ölçümü
      "❤️‍🩹", // Kalp sağlığı
      "💪", // Fitness
      "💧", // Hidrasyon
      "💉", // Aşı
      "⚕️",
      "🩺",
      "🩻",
      "🏥",
      "🧑🏻‍⚕️",
      "👩🏻‍⚕️",
      "👩🏼‍⚕️",
      "👨🏻‍⚕️",
      "👨🏼‍⚕️",
      "👨🏿‍⚕️",
      "👩🏿‍⚕️",
      "🚑",
      "⛑️",
    ],
    LocaleKeys.iconCategories_social.tr(): [
      "👥", // Sosyal bağlantı
      "💬", // Sohbet
      "📧", // E-posta
      "📞", // Telefon
      "🌐", // İnternet
      "🔔", // Bildirim
      "🤝", // İş birliği
      "👥", // Grup
      "🗣️", // Konuşma
      "📢", // Duyuru
      "🔗", // Bağlantı
      "⭐", // Beğeni
      "💌", // Günlük mesaj
      "🌍" // Genel paylaşım
    ],
    LocaleKeys.iconCategories_nature.tr(): [
      "☁️", // Bulut
      "☀️", // Güneş
      "🌙", // Ay
      "🌬️", // Rüzgar
      "🌨️", // Kar
      "🌱", // Yeşil alan
      "🐦", // Kuş
      "🌳", // Ağaç
      "🌿", // Çimen
      "🌸", // Çiçek,
      "🌵",
      "🌴",
      "🍀",
      "🍁",
      "🍂",
      "🦣",
      "🦤",
      "🦥",
      "🐫",
      "🐪",
      "🐎",
      "🐐",
      "🐑",
      "🐏",
      "🐒",
      "🐓",
      "🐔",
      "🐕",
      "🐖",
      "🐗",
      "🐙",
      "🐚",
      "🌨️",
      "⛈️",
      "🌦️",
      "🏔️",
      "☄️",
      "⛰️",
      "🌬️",
      "🌪️"
    ],
    LocaleKeys.iconCategories_business.tr(): [
      "💼", // Çanta
      "📈", // Grafik
      "📊", // Pasta grafiği
      "📁", // Klasör
      "📄", // Doküman
      "💰", // Para
      "💳", // Kredi kartı
      "📆", // Takvim
      "👥", // Kişiler
      "📧", // E-posta
      "📞", // Telefon
      "🏢", // işletme
      "🕴🏻",
      "🖇️",
      "🗂️",
      "🗄️",
      "🗒️",
      "📤",
      "📥",
      "📊",
      "📉",
      "📈",
      "📇",
    ],
    LocaleKeys.iconCategories_art.tr(): [
      "🎭",
      "✏️", // Kalem
      "🖌️", // Boyama
      "🖼️", // Fotoğraf
      "📷", // Kamera
      "🎨", // Renk paleti
      "🖼️", // Sanat eseri
      "✏️", // Düzenleme
      "📷", // Fotoğrafçılık
      "🧶",
      "🧵",
      "✍🏻",
      "👨🏻‍🎨",
      "👩🏼‍🎨",
      "🧑🏼‍🎨",
      "👨🏼‍🎨",
    ],
    LocaleKeys.iconCategories_studyandtask.tr(): [
      "📚", // Kitap
      "📝", // Not
      "📂", // Dosya
      "⏱️", // Zamanlayıcı
      "📆", // Takvim
      "💡", // Fikir
      "📃", // Belge
      "❔", // Soru
      "📝", // Ödev
      "⏱️", // Zaman yönetimi
      "📃", // Liste
      "📆", // Takvim
      "📑", // Belge
      "📋",
      "☑️",
      "📎", // Paperclip
      "📁", // Klasör
      "💼", // Çanta
      "✅", // Tamamlanan
      "✔️", // Onay
      "📅", // Tarih
      "🔔", // Alarm
      "⏱️", // Zaman
      "📝", // Not
      "📆", // Planlama
      "🙇🏻",
      "🙇🏻",
      "🙇🏻‍♀️",
      "🧑‍🎄",
      "📖",
      "🧑🏻‍💻",
      "👩🏻‍💻",
      "👨🏻‍💻",
      "🧑🏻‍🏫",
      "🧑🏻‍🏫",
      "👩🏻‍🏫",
      "👨🏻‍🏫",
      "✍🏻",
      "📌",
      "📍",
      "🖇️",
      "🔗",
      "🧷",
      "🔖",
      "🖍️",
      "🖌️",
      "🖊️",
      "🖋️",
      "🧮",
      "📊",
      "📅",
      "🗃️",
      "📇",
      "🗳️",
      "🗄️",
      "📋",
      "📁",
      "📂",
      "🗂️",
      "🗞️",
      "📰",
      "📓",
      "📔",
      "📒",
      "📕",
      "📗",
      "📘",
      "📙"
    ],
    LocaleKeys.iconCategories_science.tr(): [
      "🌡️",
      "🧪",
      "🧫",
      "🦠",
      "🧬",
      "🩸",
      "💉",
      "⚗️",
      "💊",
      "🩺",
      "🩻",
      "🩹",
      "🕳️",
      "🔬",
      "🔺",
      "💉",
      "🔭",
      "🪐",
      "🧑🏻‍🔬",
      "👩🏻‍🔬",
      "👨🏻‍🔬",
      "🥼",
      "🌑",
    ],
    LocaleKeys.iconCategories_gardenandyard.tr(): [
      "🌱", // Bitki
      "🌳", // Ağaç
      "🌾", // Çim
      "🌼", // Bahçe
      "🌍", // Arazi
      "🌹", // Çiçek
      "⛲️",
      "🪴",
      "👨🏻‍🌾",
      "👩🏻‍🌾",
      "🧑🏻‍🌾",
      "🌿", // Çimen
      "🌹" // Çiçek
    ],
    LocaleKeys.iconCategories_pets.tr(): [
      "🐾", // Hayvan ayak izi
      "🐶",
      "🦴",
      "🐩",
      "🐩",
      "🐈‍⬛",
      "🐈",
      "🦮",
      "🐕‍🦺",
      "🐱", // Kedi
      "🐶", // Köpek
      "🐐",
      "🐑",
      "🐰", // Tavşan
      "🐹", // Hamster
      "🐟", // Balık
      "🐂",
      "🦎", // Timsah
      "🚗", // Araba
      "🦦", // Otter
      "🐦", // Kuş
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Extract the keys as category names
    List<String> categoryNames = emojiCategories.keys.toList();

    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            CategoryWidget(
              categories: categoryNames,
              onCategorySelected: (int selectedCategory) {
                controller.forward(from: 0);

                selectedIconIndex = null;
                setState(() {
                  selectedCategoryIndex = selectedCategory;
                });
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: emojiCategories[categoryNames[selectedCategoryIndex]]!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                ),
                itemBuilder: (context, index) {
                  final iconData = emojiCategories[categoryNames[selectedCategoryIndex]]![index];

                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        selectedIconIndex = index;
                      });

                      widget.onIconSelected(iconData);
                    },
                    child: Card(
                      elevation: .25,
                      color: index == selectedIconIndex ? context.primary.withAlpha(100) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              iconData,
                              textAlign: TextAlign.center,
                              style: context.titleLarge?.copyWith(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).animate(controller: controller).fadeIn(duration: 500.ms),
            ),
          ],
        ),
      ],
    );
  }
}
