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
      // Morning Routine
      '🌅', '🛏️', '🪥', '🚿', '🧴', '🪒', '👕', '👖', '👟',

      // Food & Meals
      '🍳', '🍞', '🥚', '🥛', '☕', '🍽️', '🍕', '🍔', '🍜', '🍎', '🥤',

      // Work & Productivity
      '💼', '🖥️', '💻', '📱', '📅', '🕒', '📝', '📂', '📌', '✏️', '🖊️',

      // Health & Fitness
      '🏋️‍♂️', '🏃‍♂️', '🧘‍♀️', '🏥', '💊', '🩺', '🩹', '🧬', '🧪',

      // Transportation
      '🚗', '🚕', '🚌', '🚲', '🚆', '✈️', '🚶‍♂️', '🛴',

      // Shopping & Errands
      '🛒', '🛍️', '💳', '🏪', '🧾',

      // Household Chores
      '🧹', '🧽', '🧺', '🧼', '🗑️', '🪣', '🪠',

      // Leisure & Entertainment
      '📺', '🎮', '🎧', '🎤', '🎬', '🎨', '🛋️',

      // Social Life
      '👥', '🎉', '🎁', '🍻', '🍰', '💌',

      // Sleep & Relaxation
      '🌙', '🛌', '🧘‍♂️', '🛀', '🕯️',

      // Weather & Nature
      '☀️', '🌧️', '🌈', '🌳', '🌱', '🐦', '🐕', '🐈',

      // Technology
      '🔌', '🔋', '📡', '🖨️', '🎛️',

      // Miscellaneous
      '🔑', '💡', '🕳️', '🧮', '📦',
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
      "💧", // Su damlası
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
      "🌿", // Yaprak
      "🌾", // Çim
      "🌼", // Bahçe
      "🌍", // Arazi
      "🌿", // Çimen
      "🌹", // Çiçek
      "", // Çim
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

    return SizedBox(
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        navigationBar: SheetHeader(
          title: "Icon",
          closeButtonPosition: CloseButtonPosition.left,
          trailing: TrailingActionButton(
            title: "Save",
            onPressed: navigator.pop,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CategoryWidget(
                      categories: categoryNames,
                      onCategorySelected: (int selectedCategory) {
                        controller.forward(from: 0);
                        setState(() {
                          selectedCategoryIndex = selectedCategory;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CupertinoScrollbar(
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: emojiCategories[categoryNames[selectedCategoryIndex]]!.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
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
                              elevation: .2,
                              color: index == selectedIconIndex ? CupertinoColors.systemBlue.withOpacity(.5) : null,
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
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
                            ),
                          );
                        },
                      ).animate(controller: controller).fadeIn(duration: 500.ms),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
