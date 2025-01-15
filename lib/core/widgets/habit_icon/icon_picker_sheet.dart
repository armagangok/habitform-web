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
  void initState() {
    controller = AnimationController(vsync: this);
    super.initState();
  }

// Define categories with emojis
  Map<String, List<String>> emojiCategories = {
    "Daily Life": [
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
      '☕',
      '🍽️',
      '🍕',
      '🍔',
      '🍜',
      '🍎',
      '🥤',
    ],
    "Sports": [
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
    "Health": [
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
    "Social": [
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
    "Nature": [
      "☁️", // Bulut
      "☀️", // Güneş
      "🌙", // Ay
      "🌬️", // Rüzgar
      "🌨️", // Kar
      "🌱", // Yeşil alan
      "🐦", // Kuş
      "🌳", // Ağaç
      "🌿", // Çimen
      "⾃然", // Doğa
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
    "Business": [
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
    "Task & Project": [
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
      "",
      "📝", // Not
      "📆" // Planlama
    ],
    "Art": [
      "✏️", // Kalem
      "🖌️", // Boyama
      "🖼️", // Fotoğraf
      "📷", // Kamera
      "🎨", // Renk paleti
      "🖼️", // Sanat eseri
      "✏️", // Düzenleme
      "📷", // Fotoğrafçılık
      "🧶", "🧵", "✍🏻", "👨🏻‍🎨",
    ],
    "Study": [
      "📚", // Kitap
      "📝", // Not
      "📂", // Dosya
      "⏱️", // Zamanlayıcı
      "📆", // Takvim
      "💡", // Fikir
      "📃", // Belge
      "❔", // Soru
      "📝", // Ödev
      "📚", // Kütüphane
      "📚", // Çalışma planı
      "⏱️", // Zaman yönetimi
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
    "Science": [
      "🌡️",
      "🧪",
      "🧫",
      "🦠",
      "🧬",
      "🩸",
      "💉",
      "💊",
      "🩺",
      "🩻",
      "🩹",
      "🕳️",
      "🔬",
      "🔭",
      "🔺",
      "💉",
      "🩺",
      "🩻",
      "🔬",
      "🔭",
      "💉",
      "🩺",
      "🩻",
      "🔬",
      "🔭",
      "🪐",
      "🧑🏻‍🔬",
      "🧑🏻‍🔬",
      "👩🏻‍🔬",
      "👨🏻‍🔬",
      "🥼",
      "🌑",
    ],
    "Pets": [
      "🐾", // Hayvan ayak izi
      "🐶",
      "🦴",
      "🐩",
      "🐩",
      "🐈‍⬛",
      "🐈", "🐂", "🐂",
      "🐱", // Kedi
      "🐶", // Köpek
      "🐰", // Tavşan
      "🐹", // Hamster
      "🐟", // Balık
      "🦎", // Timsah
      "🚗", // Araba
      "🦦", // Otter
      "🐦", // Kuş
      "🦮",
      "🐕‍🦺",
    ],
    "Garden & Yard": [
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
              height: 150,
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: emojiCategories[categoryNames[selectedCategoryIndex]]!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
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
                      color: index == selectedIconIndex ? context.primary : null,
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
