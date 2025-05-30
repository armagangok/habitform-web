import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';

final iconPickerProvider = NotifierProvider<IconPickerNotifier, IconPickerState>(() {
  return IconPickerNotifier();
});

class IconPickerState {
  final String? selectedIcon;
  final int selectedCategoryIndex;
  final int? selectedIconIndex;
  final Map<String, List<String>> emojiCategories;

  IconPickerState({
    this.selectedIcon,
    this.selectedCategoryIndex = 0,
    this.selectedIconIndex,
    Map<String, List<String>>? emojiCategories,
  }) : emojiCategories = emojiCategories ?? {};

  IconPickerState copyWith({
    String? selectedIcon,
    int? selectedCategoryIndex,
    int? selectedIconIndex,
    Map<String, List<String>>? emojiCategories,
  }) {
    return IconPickerState(
      selectedIcon: selectedIcon ?? this.selectedIcon,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedIconIndex: selectedIconIndex ?? this.selectedIconIndex,
      emojiCategories: emojiCategories ?? this.emojiCategories,
    );
  }
}

class IconPickerNotifier extends Notifier<IconPickerState> {
  @override
  IconPickerState build() {
    // Initialize with default categories
    final categories = _initializeCategories();
    return IconPickerState(emojiCategories: categories);
  }

  Map<String, List<String>> _initializeCategories() {
    return {
      LocaleKeys.iconCategories_dailylife.tr(): [
        // Sleep and Rest
        '🛏️', // bed
        '🛌', // sleeping person
        '😴', // sleep emoji
        '🌙', // night

        // Personal Care
        '🚿', // shower
        '🪥', // toothbrush
        '💧', // water drop
        '🧴', // lotion
        '💆🏻‍♂️', // face care
        '💆🏻‍♀️', // spa
        '💇🏻‍♂️', // haircut
        '💇🏻‍♀️', // hair care

        // Hydration and Nutrition
        '💦', // water splash
        '🥤', // cup with straw
        '🫗', // pouring liquid
        '🧊', // ice
        '🧃', // juice box
        '🍶', // sake bottle (water bottle)

        // Protein and Healthy Foods
        '🥚', // egg
        '🍗', // poultry leg
        '🥩', // cut of meat
        '🥜', // peanuts
        '🫘', // beans
        '🧆', // falafel
        '🍤', // fried shrimp
        '🥓', // bacon

        // Fruits and Vegetables
        '🥦', // broccoli
        '🥬', // leafy green
        '🥕', // carrot
        '🍅', // tomato
        '🥒', // cucumber
        '🍆', // eggplant
        '🥑', // avocado
        '🌽', // corn
        '🍎', // apple
        '🍌', // banana
        '🍓', // strawberry

        // Meals and Cooking
        '🍳', // cooking
        '🥄', // spoon
        '🍽️', // plate and cutlery
        '🥗', // salad
        '🥪', // sandwich
        '🍲', // pot of food
        '🍚', // cooked rice
        '🥘', // shallow pan of food
        '🍞', // bread
        '🥛', // milk

        // Exercise and Movement
        '🏃🏻', // running
        '🚶🏻', // walking
        '🧘🏻‍♂️', // meditation
        '🧘🏻‍♀️', // yoga
        '🏋🏻‍♂️', // weight lifting
        '🏋🏻‍♀️', // fitness
        '🚴', // cycling
        '🏊', // swimming
        '⛹️', // ball bouncing
        '🤸', // cartwheeling

        // Work and Productivity
        '💻', // computer
        '📱', // phone
        '📚', // book
        '✍🏻', // writing
        '📝', // note taking
        '⏰', // alarm clock
        '📅', // calendar

        // Household Activities
        '🧹', // sweeping
        '🧺', // laundry
        '🧼', // cleaning
        '🛒', // shopping cart
        '🧰', // toolbox
        '🪴', // potted plant (fixed)

        // Transportation
        '🚗', // car
        '🚌', // bus
        '🚲', // bicycle

        // Communication
        '📞', // phone
        '💬', // messaging
        '📧', // email

        // Entertainment
        '🎮', // gaming
        '🎵', // music
        '📺', // TV
        '🎧', // headphones
        '📱', // smartphone
        '🎬', // movie clapper
      ],
      LocaleKeys.iconCategories_sports.tr(): [
        // Walking and Running
        '🏃🏻‍♂️', // running (male)
        '🏃🏻‍♀️', // running (female)
        '🚶🏻‍♂️', // walking (male)
        '🚶🏻‍♀️', // walking (female)

        // Fitness and Strength Sports
        '🏋🏻‍♂️', // weight lifting (male)
        '🏋🏻‍♀️', // weight lifting (female)
        '🤸🏻‍♂️', // gymnastics
        '🤸🏻‍♀️', // gymnastics
        '🧘🏻‍♂️', // yoga (male)
        '🧘🏻‍♀️', // yoga (female)
        '🤾', // handball
        '🤼', // wrestling

        // Team Sports
        '⚽', // soccer
        '🏀', // basketball
        '🏈', // american football
        '⚾', // baseball
        '🏐', // volleyball
        '🏉', // rugby
        '🏑', // field hockey
        '🏒', // ice hockey

        // Racket Sports
        '🎾', // tennis
        '🏸', // badminton
        '🏓', // table tennis
        '🥍', // lacrosse

        // Water Sports
        '🏊🏻‍♂️', // swimming (male)
        '🏊🏻‍♀️', // swimming (female)
        '🚣🏻‍♂️', // rowing
        '🏄🏻‍♂️', // surfing (male)
        '🏄🏻‍♀️', // surfing (female)
        '🤽', // water polo
        '🛶', // canoe

        // Cycling
        '🚴🏻‍♂️', // cycling (male)
        '🚴🏻‍♀️', // cycling (female)
        '🚵', // mountain biking

        // Winter Sports
        '🏂🏻', // snowboarding
        '⛷️', // skiing
        '🎿', // ski equipment
        '🛷', // sled
        '⛸️', // ice skating

        // Martial Arts
        '🥋', // martial arts
        '🥊', // boxing
        '🤺', // fencing

        // Other Sports
        '🏇', // horse riding
        '⛳', // golf
        '🎯', // darts
        '🏹', // archery
        '🛹', // skateboarding
        '🛼', // roller skate

        // Sports Equipment
        '🥅', // goal net
        '🥎', // softball
        '🥏', // frisbee
        '⚾', // baseball
        '🏆', // trophy
        '🏅', // sports medal
      ],

      LocaleKeys.iconCategories_health.tr(): [
        // Heart and Health
        '❤️', // heart
        '🫀', // anatomical heart
        '💝', // healthy heart
        '🧠', // brain
        '🫁', // lungs

        // Medical Symbols
        '⚕️', // medical symbol
        '🏥', // hospital
        '💊', // medicine
        '💉', // syringe
        '🩺', // stethoscope

        // Healthcare Professionals
        '👨🏻‍⚕️', // doctor (male)
        '👩🏻‍⚕️', // doctor (female)
        '🧑🏻‍⚕️', // healthcare worker

        // Medical Equipment
        '🌡️', // thermometer
        '🩻', // x-ray
        '🔬', // microscope
        '🩹', // bandage
        '🩼', // crutch
        '🦮', // guide dog

        // Mental Health
        '🧘', // meditation
        '😌', // relieved face
        '🙏', // prayer hands
        '✨', // sparkles
        '🧿', // nazar amulet

        // Healthy Living
        '💪🏻', // strength
        '🥗', // healthy food
        '💧', // water
        '🍏', // green apple
        '🥦', // broccoli
        '🥝', // kiwi
        '🫐', // blueberries
        '🧘‍♀️', // yoga
        '🚶‍♀️', // walking
        '🧠', // mental health

        // Sleep and Rest
        '😴', // sleeping
        '🛌', // person in bed
        '🌙', // crescent moon
        '💤', // zzz
        '🧸', // teddy bear

        // Wellness
        '🧖‍♀️', // person in steam room
        '🧖‍♂️', // person in sauna
        '🌿', // herb
        '☕', // hot beverage
        '🍵', // tea (fixed)
      ],

      LocaleKeys.iconCategories_social.tr(): [
        // Communication
        '💬', // speech bubble
        '📱', // phone
        '📞', // telephone
        '📧', // email
        '📲', // mobile with arrow

        // Social Interaction
        '👥', // people
        '🤝', // handshake
        '🫂', // hugging
        '👋', // waving
        '🙌', // raised hands
        '👏', // clapping

        // Social Media
        '🌐', // world
        '📲', // messaging
        '💌', // message
        '🔔', // notification
        '📱', // smartphone
        '📷', // camera

        // Meetings and Collaboration
        '🗣️', // speaking
        '📢', // announcement
        '🤼', // meeting
        '🔗', // link
        '👨‍👩‍👧‍👦', // family
        '👯‍♀️', // people with bunny ears

        // Social Activities
        '🎉', // celebration
        '🎊', // party
        '🎭', // event
        '⭐', // star
        '🎁', // gift
        '🎂', // birthday cake
      ],

      LocaleKeys.iconCategories_nature.tr(): [
        // Weather
        '☀️', // sun
        '🌙', // moon
        '☁️', // cloud
        '🌧️', // rain
        '⛈️', // storm
        '❄️', // snow
        '🌪️', // tornado
        '🌈', // rainbow
        '⚡', // lightning

        // Plants
        '🌱', // seedling
        '🌿', // leaf
        '🌳', // tree
        '🌸', // flower
        '🌺', // hibiscus
        '🌻', // sunflower
        '🍀', // clover
        '🌵', // cactus
        '🌴', // palm tree

        // Seasons
        '🍁', // autumn
        '🌷', // spring
        '⛱️', // summer
        '☃️', // winter

        // Animals
        '🦁', // lion
        '🐘', // elephant
        '🦒', // giraffe
        '🦊', // fox
        '🦜', // parrot
        '🦋', // butterfly
        '🐝', // bee
        '🦔', // hedgehog
        '🐢', // turtle

        // Natural Formations
        '🏔️', // mountain
        '🌋', // volcano
        '🏖️', // beach
        '🌊', // wave
        '⛰️', // mountains
        '🏞️', // landscape
        '🏜️', // desert
        '🌄', // sunrise over mountains
      ],

      LocaleKeys.iconCategories_art.tr(): [
        // Art Supplies
        '🎨', // palette
        '🖌️', // brush
        '✏️', // pencil
        '🖍️', // crayon

        // Art Forms
        '🎭', // theater
        '🎨', // painting
        '🎼', // music
        '📷', // photography

        // Artists
        '👨🏻‍🎨', // artist (male)
        '👩🏻‍🎨', // artist (female)
        '🧑🏻‍🎨', // artist (neutral)

        // Crafts
        '🧶', // yarn
        '🧵', // thread
        '✂️', // scissors
        '🖼️', // frame

        // Performance
        '🎭', // mask
        '🎪', // circus
        '🎬', // film
        '🎤', // microphone
      ],

      LocaleKeys.iconCategories_business.tr(): [
        // Business Tools
        '💼', // briefcase
        '📱', // phone
        '💻', // laptop
        '📊', // chart

        // Office Supplies
        '📁', // folder
        '📝', // note
        '📎', // paperclip
        '✒️', // pen

        // Finance
        '💰', // money
        '💳', // credit card
        '📈', // growth chart
        '🏦', // bank

        // Planning
        '📅', // calendar
        '⏰', // clock
        '📋', // clipboard
        '✅', // check mark

        // Communication
        '👥', // meeting
        '📧', // email
        '📞', // phone
        '🤝', // agreement

        // Office
        '🏢', // building
        '💺', // seat
        '🗄️', // filing cabinet
        '🖨️', // printer
      ],

      LocaleKeys.iconCategories_studyandtask.tr(): [
        // Study Tools
        '📚', // books
        '📖', // open book
        '📓', // notebook
        '📔', // decorated notebook
        '📒', // ledger
        '📝', // note taking
        '✏️', // pencil
        '✒️', // fountain pen
        '🖊️', // pen
        '🖋️', // fountain pen
        '📏', // ruler
        '📐', // triangle ruler

        // Digital Tools
        '💻', // laptop
        '⌨️', // keyboard
        '🖥️', // desktop computer
        '📱', // mobile phone
        '🖱️', // computer mouse
        '🔋', // battery
        '💾', // floppy disk
        '📀', // DVD

        // Time Management
        '⏰', // alarm clock
        '⏱️', // stopwatch
        '⌚', // watch
        '⏳', // hourglass
        '⌛', // hourglass done
        '📅', // calendar
        '📆', // tear-off calendar
        '🗓️', // spiral calendar

        // Organization
        '📋', // clipboard
        '📊', // bar chart
        '📈', // increasing chart
        '📉', // decreasing chart
        '📑', // bookmark tabs
        '🗂️', // card index dividers
        '📁', // file folder
        '📂', // open file folder
        '🗄️', // file cabinet

        // Office Supplies
        '📌', // pushpin
        '📍', // round pushpin
        '📎', // paperclip
        '🔗', // link
        '✅', // check mark
        '☑️', // check box
        '✔️', // heavy check mark
        '📧', // e-mail
        '📨', // incoming envelope

        // Learning Environment
        '🎓', // graduation cap
        '🏫', // school
        '📕', // closed book
        '🔍', // magnifying glass
        '💡', // light bulb (idea)
        '🎯', // target
        '🏆', // trophy
        '🌟', // glowing star
        '⭐', // star

        // Education
        '👨🏻‍🏫', // teacher (male)
        '👩🏻‍🏫', // teacher (female)
        '🧑🏻‍🎓', // student
        '👨🏻‍💻', // technologist
        '👩🏻‍💻', // technologist
        '✍🏻', // writing hand

        // Study Subjects
        '🔢', // numbers
        '🔤', // abc
        '🔠', // input latin uppercase
        '📐', // geometry
        '🧮', // abacus
        '🗺️', // world map
        '🎨', // art
        '🧪', // science
        '🔬', // microscope
        '📜', // scroll
        '🧩', // puzzle piece
        '🔭', // telescope
      ],

      LocaleKeys.iconCategories_science.tr(): [
        // Laboratory
        '🧪', // test tube
        '🔬', // microscope
        '⚗️', // distillation
        '🧫', // petri dish
        '🧬', // DNA
        '🔭', // telescope

        // Scientists
        '👨🏻‍🔬', // scientist (male)
        '👩🏻‍🔬', // scientist (female)
        '🧑🏻‍🔬', // researcher
        '👨🏻‍💻', // technologist (male)
        '👩🏻‍💻', // technologist (female)

        // Medicine and Biology
        '🦠', // microbe
        '🫀', // heart
        '🧠', // brain
        '🦷', // tooth
        '🦴', // bone
        '🫁', // lungs
        '👁️', // eye

        // Space
        '🌌', // galaxy
        '🪐', // planet
        '🌍', // earth
        '🌠', // shooting star
        '🌟', // glowing star
        '🛰️', // satellite
        '🚀', // rocket

        // Measurement and Analysis
        '📊', // graph
        '📐', // triangle ruler
        '🌡️', // thermometer
        '⚖️', // scale
        '🧮', // abacus
        '🔍', // magnifying glass
        '📡', // satellite antenna
      ],

      LocaleKeys.iconCategories_gardenandyard.tr(): [
        // Plants
        '🌱', // seedling
        '🌳', // tree
        '🌺', // flower
        '🌸', // blooming
        '🌵', // cactus
        '🌴', // palm tree
        '🌲', // evergreen tree
        '🌿', // herb
        '☘️', // shamrock
        '🍀', // four leaf clover

        // Garden Tools
        '🪴', // potted plant
        '🌷', // tulip
        '💐', // bouquet
        '🪓', // axe
        '🧹', // broom
        '🪣', // bucket
        '🧤', // gloves
        '✂️', // scissors

        // Gardeners
        '👨🏻‍🌾', // gardener (male)
        '👩🏻‍🌾', // gardener (female)
        '🧑🏻‍🌾', // farmer

        // Garden Elements
        '⛲', // fountain
        '🏺', // vase
        '🪨', // rock
        '🌳', // landscaping
        '🪦', // tombstone
        '🏡', // house with garden
        '🌻', // sunflower
        '🍄', // mushroom
        '🐝', // bee
        '🦋', // butterfly
      ],

      LocaleKeys.iconCategories_pets.tr(): [
        // Dogs
        '🐕', // dog
        '🐶', // dog face
        '🦮', // guide dog
        '🐕‍🦺', // service dog
        '🦴', // bone

        // Cats
        '🐈', // cat
        '🐱', // cat face
        '🐈‍⬛', // black cat
        '🧶', // yarn ball

        // Small Pets
        '🐹', // hamster
        '🐰', // rabbit
        '🐢', // turtle
        '🦜', // parrot
        '🐇', // rabbit
        '🦔', // hedgehog
        '🦝', // raccoon
        '🦨', // skunk
        '🦡', // badger

        // Fish
        '🐠', // tropical fish
        '🐟', // fish
        '🐡', // blowfish
        '🦈', // shark
        '🐙', // octopus
        '🦑', // squid
        '🦐', // shrimp
        '🦞', // lobster

        // Pet Care
        '🐾', // paw prints
        '🪮', // mouse trap
        '🧹', // broom
        '🧼', // soap
        '✂️', // scissors
        '🛁', // bathtub
        '🧽', // sponge
      ],
      "Custom": [], // Custom emojis will be loaded from EmojiPicker
    };
  }

  void initializeWithSelectedIcon(String? selectedIcon) {
    if (selectedIcon == null) return;

    // Check if the icon is in any category
    Map<String, List<String>> categories = state.emojiCategories;
    int categoryIndex = 0;
    int? iconIndex;

    for (var i = 0; i < categories.length; i++) {
      final category = categories.values.elementAt(i);
      final index = category.indexOf(selectedIcon);
      if (index != -1) {
        categoryIndex = i;
        iconIndex = index;
        break;
      }
    }

    // If not found in categories, add to custom
    if (iconIndex == null && selectedIcon.isNotEmpty) {
      final customCategory = categories["Custom"]!;
      if (!customCategory.contains(selectedIcon)) {
        customCategory.add(selectedIcon);
        categories["Custom"] = customCategory;
      }

      categoryIndex = categories.length - 1; // Custom is last
      iconIndex = customCategory.indexOf(selectedIcon);
    }

    state = state.copyWith(
      selectedIcon: selectedIcon,
      selectedCategoryIndex: categoryIndex,
      selectedIconIndex: iconIndex,
      emojiCategories: categories,
    );
  }

  void selectCategory(int categoryIndex) {
    if (categoryIndex == state.selectedCategoryIndex) return;

    state = state.copyWith(
      selectedCategoryIndex: categoryIndex,
      selectedIconIndex: null,
    );
  }

  void selectIcon(String icon, int iconIndex) {
    state = state.copyWith(
      selectedIcon: icon,
      selectedIconIndex: iconIndex,
    );
  }

  void addCustomIcon(String icon) {
    if (icon.isEmpty) return;

    final categories = Map<String, List<String>>.from(state.emojiCategories);
    final customIcons = List<String>.from(categories["Custom"] ?? []);

    if (!customIcons.contains(icon)) {
      customIcons.add(icon);
      categories["Custom"] = customIcons;

      state = state.copyWith(
        emojiCategories: categories,
      );
    }
  }

  void clearSelection() {
    state = state.copyWith(
      selectedIcon: null,
      selectedIconIndex: null,
    );
  }
}
