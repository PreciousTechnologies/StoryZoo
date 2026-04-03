import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

class AppI18n {
  AppI18n._();

  static final Map<String, String> _exactSwToEn = {
    'Pakia Hadithi Mpya': 'Upload New Story',
    'Andika sura, chagua bei, lugha na uchapishe':
      'Write chapters, choose price, language, and publish',
    'Picha ya Jalada (Hiari)': 'Cover Image (Optional)',
    'Bofya kuchagua picha ya jalada': 'Tap to choose a cover image',
    'Taarifa za Msingi': 'Basic Information',
    'Kichwa cha Hadithi': 'Story Title',
    'Mfano: Safari ya Simba': 'Example: Lion\'s Journey',
    'Weka kichwa cha hadithi.': 'Enter the story title.',
    'Maelezo': 'Description',
    'Eleza hadithi kwa ufupi...': 'Describe the story briefly...',
    'Weka maelezo ya hadithi.': 'Enter the story description.',
    'Bei na Upatikanaji': 'Pricing and Availability',
    'Weka ON kama hadithi ina audio.': 'Turn ON if the story has audio.',
    'Weka ON kufanya usomaji bure kwa wote.':
      'Turn ON to make reading free for everyone.',
    'Weka bei ya hadithi.': 'Enter story price.',
    'Weka namba sahihi ya bei.': 'Enter a valid price number.',
    'Sura za Hadithi': 'Story Chapters',
    'Hifadhi Rasimu': 'Save Draft',
    'Chapisha': 'Publish',
    'Sura': 'Chapter',
    'Kichwa cha Sura': 'Chapter Title',
    'Mfano: Mwanzo wa Safari': 'Example: Journey Begins',
    'Weka kichwa cha sura.': 'Enter chapter title.',
    'Maudhui ya Sura': 'Chapter Content',
    'Andika maudhui ya sura hapa...': 'Write chapter content here...',
    'Andika maudhui ya sura.': 'Write chapter content.',
    'Chagua kutoka Gallery': 'Choose from Gallery',
    'Piga picha kwa Camera': 'Take photo with Camera',
    'Ingia kwanza ili kupakia hadithi.':
      'Please login first to upload a story.',
    'Kila sura lazima iwe na kichwa na maudhui.':
      'Each chapter must have a title and content.',
    'Ongeza angalau sura moja kabla ya kuchapisha.':
      'Add at least one chapter before publishing.',
    'Bei sio sahihi.': 'Invalid price.',
    'Hadithi imechapishwa. Itaonekana Home na Explore mara moja.':
      'Story published. It will appear on Home and Explore immediately.',
    'Rasimu imehifadhiwa. Unaweza kuichapisha baadaye.':
      'Draft saved. You can publish it later.',
    'Akaunti na Mipangilio': 'Account and Settings',
    'Story Zoo Plus': 'Story Zoo Plus',
    'Soma bila matangazo, pata mapendekezo maalum na ufikie releases mapema.':
        'Read without ads, get personalized recommendations, and access early releases.',
    'Boresha': 'Upgrade',
    'Manunuzi': 'Purchases',
    'Hadithi nilizoinunua': 'Stories I purchased',
    'Hadithi nilizosoma': 'Stories I have read',
    'Njia za malipo': 'Payment methods',
    'Mipangilio ya arifa': 'Notification settings',
    'Hali ya giza/Mwanga': 'Dark/Light mode',
    'Maswali yanayoulizwa': 'Frequently asked questions',
    'Toleo 1.0.0': 'Version 1.0.0',
    'Je, una uhakika unataka kutoka?': 'Are you sure you want to log out?',
    'Sasisha wasifu': 'Update profile',
    'Hakuna picha mpya iliyochaguliwa': 'No new image selected',
    'Wasifu umesasishwa.': 'Profile updated.',
    'Dashibodi': 'Dashboard',
    'Tafadhali ingia tena ili kuona dashibodi.':
      'Please login again to view the dashboard.',
    'Dashibodi haikupatikana': 'Dashboard not found',
    'Futa Hadithi': 'Delete Story',
    'Una uhakika unataka kufuta hadithi hii? Haitaweza kurudishwa.':
      'Are you sure you want to delete this story? This cannot be undone.',
    'Hadithi imefutwa.': 'Story deleted.',
    'Hariri Hadithi': 'Edit Story',
    'Mabadiliko yamehifadhiwa.': 'Changes saved.',
    'Taarifa za Mwandishi': 'Author Information',
    'Mapato': 'Earnings',
    'Mapato yote': 'Total earnings',
    'Wasomaji': 'Readers',
    'Jumla ya usomaji': 'Total readers',
    'Hadithi Zangu': 'My Stories',
    'Tazama Zote': 'View All',
    'Takwimu za Mauzo': 'Sales Analytics',
    'Hali ya Malipo': 'Payout Status',
    'Pakia Hadithi': 'Upload Story',
    'Bado hujapakia hadithi yoyote.': 'You have not uploaded any stories yet.',
    'Hakuna takwimu za mauzo kwa sasa.': 'No sales data available right now.',
    'Wiki Hii': 'This Week',
    'Malipo Yanayokuja': 'Upcoming Payout',
    'Hakuna historia ya malipo kwa sasa.': 'No payout history available right now.',
    'Mwandishi': 'Author',
    'Maktaba Yangu': 'My Library',
    'Maktaba': 'Library',
    'Zimesomwa': 'Read',
    'Nilinunua': 'Purchased',
    'Hakuna Hadithi Ulizozinunua': 'No Purchased Stories',
    'Hakuna Hadithi Zilizohifadhiwa': 'No Saved Stories',
    'Nenda Explore uchague hadithi za kusoma.':
      'Go to Explore and choose stories to read.',
    'Bonyeza ikoni ya moyo kuhifadhi hadithi unazopenda.':
      'Tap the heart icon to save stories you like.',
    'Inapakuliwa...': 'Downloading...',
    'Imeondolewa kutoka kwenye zilizohifadhiwa':
      'Removed from saved stories',
    'Mwisho kusoma: Jana, 21:00': 'Last read: Yesterday, 21:00',
    'Imehifadhiwa kwa baadaye': 'Saved for later',
    'Karibu! 👋': 'Welcome! 👋',
    'Hadithi Maarufu': 'Popular Stories',
    'Hakuna hadithi zilizochapishwa kwa sasa.':
      'No published stories at the moment.',
    'Kategoria za Hadithi': 'Story Categories',
    'Angalia Zote': 'See All',
    'Chagua Hadithi': 'Choose Stories',
    'Hakuna hadithi kwenye kategoria hii.':
      'No stories in this category.',
    'Gundua Hadithi': 'Explore Stories',
    'Pata hadithi mpya za kusisimua': 'Find exciting new stories',
    'Tafuta hadithi...': 'Search stories...',
    'Bei (TSh)': 'Price (TSh)',
    'Futa Chujio': 'Clear Filters',
    'Hakuna hadithi zilizopatikana.': 'No stories found.',
    'Read': 'Read',
    'Listen': 'Listen',
    'All': 'All',
    'Lugha': 'Language',
    'Chagua lugha': 'Choose language',
    'Lugha inayotumika': 'Current language',
    'Badilisha lugha itabadilisha lugha ya programu na maudhui':
        'Changing language will update app language and content',
    'Lugha imebadilishwa kuwa': 'Language changed to',
    'Imeshindikana kubadilisha lugha. Jaribu tena.':
      'Failed to change language. Try again.',
    'Kiswahili': 'Swahili',
    'Mwanzo': 'Home',
    'Gundua': 'Explore',
    'Wasifu': 'Profile',
    'Historia': 'History',
    'Manunuzi Yangu': 'My Purchases',
    'Malipo': 'Payments',
    'Arifa': 'Notifications',
    'Mandhari': 'Theme',
    'Msaada': 'Help',
    'Kuhusu': 'About',
    'Kuhusu Story Zoo': 'About Story Zoo',
    'Toka': 'Logout',
    'Njia za Malipo': 'Payment Methods',
    'Ongeza Njia ya Malipo': 'Add Payment Method',
    'Historia ya Malipo': 'Payment History',
    'Matumizi mwezi huu: TSh 8,500': 'This month spending: TSh 8,500',
    'Chaguo-msingi': 'Default',
    'Weka Chaguo-msingi': 'Set as Default',
    'Namba ya Simu': 'Phone Number',
    'Chagua Mtoa Huduma': 'Select Provider',
    'Ongeza': 'Add',
    'Njia ya malipo imeongezwa': 'Payment method added',
    'Futa Njia ya Malipo': 'Delete Payment Method',
    'Imekamilika': 'Completed',
    'Leo, 14:30': 'Today, 14:30',
    'Jana, 10:15': 'Yesterday, 10:15',
    'Juzi, 16:45': '2 days ago, 16:45',
    'Mipangilio ya Jumla': 'General Settings',
    'Arifa za Kusukuma': 'Push Notifications',
    'Pokea arifa kwenye kifaa chako': 'Receive notifications on your device',
    'Arifa za Barua Pepe': 'Email Notifications',
    'Pokea arifa kupitia email': 'Receive notifications by email',
    'Arifa za Maudhui': 'Content Notifications',
    'Arifa za hadithi mpya': 'Notifications for new stories',
    'Matangazo': 'Promotions',
    'Punguzo na matoleo maalum': 'Discounts and special offers',
    'Sasisho za Waandishi': 'Author Updates',
    'Hadithi mpya kutoka waandishi unaofuata':
      'New stories from authors you follow',
    'Arifa za Kijamii': 'Social Notifications',
    'Maoni': 'Comments',
    'Mtu anapotoa maoni kwenye hadithi yako':
      'When someone comments on your story',
    'Mipendwa': 'Likes',
    'Mtu anapopenda hadithi yako': 'When someone likes your story',
    'Sauti na Mtetemo': 'Sound and Vibration',
    'Sauti': 'Sound',
    'Cheza sauti kwa arifa': 'Play sound for notifications',
    'Mtetemo': 'Vibration',
    'Tetema wakati wa arifa': 'Vibrate for notifications',
    'Chagua arifa muhimu tu ili usipate usumbufu.':
      'Choose only important notifications to avoid distractions.',
    'Chagua mandhari': 'Choose theme',
    'Mwanga': 'Light',
    'Mandhari ya mchana': 'Day theme',
    'Giza': 'Dark',
    'Mandhari ya usiku': 'Night theme',
    'Otomatiki': 'Automatic',
    'Fuata mipangilio ya mfumo': 'Follow system settings',
    'Mandhari huathiri usomaji wa muda mrefu. Chagua inayokufaa mchana na usiku.':
      'Themes affect long reading sessions. Choose what suits you for day and night.',
    'Mipangilio ya Ziada': 'Additional Settings',
    'Mandhari ya AMOLED': 'AMOLED Theme',
    'Giza kamili kwa vifaa vya OLED': 'Pure black for OLED devices',
    'Itakuwa inapatikana hivi karibuni': 'Coming soon',
    'Imeshindikana kubadilisha mandhari. Jaribu tena.':
      'Failed to change theme. Try again.',
    'Msaada': 'Help',
    'Maswali yanayoulizwa mara kwa mara': 'Frequently asked questions',
    'Tafuta msaada, mfano: malipo, lugha, login...':
      'Search help, for example: payment, language, login...',
    'Barua Pepe': 'Email',
    'Piga Simu': 'Call',
    'Inafungua programu ya barua pepe...': 'Opening email app...',
    'Inafungua programu ya simu...': 'Opening phone app...',
    'Timu yetu ya msaada inajibu ndani ya saa 2 hadi 6 kwa maswali mengi.':
      'Our support team responds within 2 to 6 hours for most questions.',
    'Maswali Yanayoulizwa': 'Frequently Asked Questions',
    'Vyanzo Vya Ziada': 'Additional Resources',
    'Miongozo ya Matumizi': 'User Guides',
    'Jifunze jinsi ya kutumia programu': 'Learn how to use the app',
    'Ripoti Tatizo': 'Report an Issue',
    'Taarifa ya matatizo ya kiufundi': 'Technical issue reports',
    'Pendekeza Kipengele': 'Suggest a Feature',
    'Tuambie unachotaka kuona': 'Tell us what you want to see',
    'Ninawezaje kununua hadithi?': 'How can I buy a story?',
    'Bonyeza kwenye hadithi unayotaka, kisha bofya kitufe cha "Nunua". Chagua njia ya malipo na kamilisha muamala.':
      'Tap the story you want, then press the "Buy" button. Select a payment method and complete the transaction.',
    'Je, ninaweza kusoma bila mtandao?': 'Can I read offline?',
    'Ndio! Baada ya kununua hadithi, bonyeza kitufe cha kupakua ili uweze kusoma bila mtandao.':
      'Yes! After buying a story, tap the download button so you can read offline.',
    'Ninawezaje kuwa mwandishi?': 'How can I become an author?',
    'Nenda kwenye ukurasa wa wasifu na bofya "Kuwa Mwandishi". Fuata hatua za usajili na uanze kupakia hadithi zako.':
      'Go to the profile page and tap "Become an Author". Follow the registration steps and start uploading your stories.',
    'Je, nina malipo ya kila mwezi?': 'Do I have a monthly subscription fee?',
    'Hapana! StoryZoo haina malipo ya kila mwezi. Ulipia tu hadithi unazotaka kununua.':
      'No! StoryZoo has no monthly fee. You only pay for the stories you want to buy.',
    'Ninawezaje kupata msaada wa ziada?': 'How can I get additional support?',
    'Wasiliana nasi kupitia barua pepe: support@storyzoo.co.tz au piga simu: +255 754 123 456':
      'Contact us by email: support@storyzoo.co.tz or call: +255 754 123 456',
    'Sera ya kurejesha pesa ni gani?': 'What is the refund policy?',
    'Unaweza kuomba kurejesha pesa ndani ya siku 7 baada ya kununua ikiwa hadithi haikufaa.':
      'You can request a refund within 7 days after purchase if the story was not suitable.',
    'Kampuni': 'Company',
    'Viungo': 'Links',
    'Sera ya Faragha': 'Privacy Policy',
    'Soma sera yetu ya faragha': 'Read our privacy policy',
    'Masharti ya Matumizi': 'Terms of Use',
    'Masharti ya kutumia huduma': 'Terms for using the service',
    'Leseni': 'Licenses',
    'Leseni na haki za uandishi': 'Licenses and copyrights',
    'Tufuate': 'Follow Us',
    '© 2026 Story Zoo. Haki zote zimehifadhiwa.':
      '© 2026 Story Zoo. All rights reserved.',
    'Story Zoo ni jukwaa la kisasa la hadithi za Kiswahili ambapo wasomaji wanaweza kugundua, kununua na kusoma hadithi za kuvutia. Waandishi pia wanaweza kuandika na kuuza hadithi zao kwa umma mkubwa.':
      'Story Zoo is a modern Swahili storytelling platform where readers can discover, buy, and read engaging stories. Authors can also write and sell their stories to a wider audience.',
    'Ghairi': 'Cancel',
    'Hifadhi': 'Save',
    'Hariri': 'Edit',
    'Futa': 'Delete',
    'Jaribu tena': 'Try again',
    'Next': 'Next',
    'Previous': 'Previous',
    'Nunua Sasa': 'Buy Now',
    'Baadaye': 'Later',
    'Lipa Sasa': 'Pay Now',
    'Sikiliza Hadithi': 'Listen to Story',
    'Ingia': 'Login',
    'Thibitisha': 'Verify',
    'Tuma OTP': 'Send OTP',
    'Karibu Story Zoo! 🦁': 'Welcome to Story Zoo! 🦁',
    'Watoto': 'Kids',
    'Elimu': 'Education',
    'Imani': 'Faith',
    'Hadithi': 'Stories',
    'Biashara': 'Business',
    'Yote': 'All',
    'Kiarabu': 'Arabic',
    'Home': 'Home',
    'Explore': 'Explore',
    'Saved': 'Saved',
    'Dashboard': 'Dashboard',
    'Profile': 'Profile',
  };

  static final Map<String, String> _phraseSwToEn = {
    'Hakuna ': 'No ',
    ' hadithi': ' stories',
    'Imechapishwa': 'Published',
    'Inasubiri': 'Pending',
    'Imekataliwa': 'Rejected',
    'Imeshindikana': 'Failed',
    'Ina audiobook': 'Has audiobook',
    'Hadithi ni bure?': 'Is this story free?',
    'Ongeza Sura': 'Add Chapter',
    'Sura': 'Chapter',
    'Kategoria': 'Category',
    'Lugha': 'Language',
    'Bei': 'Price',
    'Bure': 'Free',
    'Masaa': 'Hours',
    'Hadithi': 'Stories',
    'Zilizohifadhiwa': 'Saved',
    'Jumla': 'Total',
    'Bajeti': 'Budget',
    'Muda': 'Time',
    'Vitabu': 'Books',
    'Kumaliza': 'Completion',
    'Leo': 'Today',
    'Jana': 'Yesterday',
    'Wiki iliyopita': 'Last week',
    'Ingia kwanza': 'Please login first',
    'Tafadhali': 'Please',
    'Imeshindikana kufuta hadithi': 'Failed to delete story',
    'Imeshindikana kuhifadhi mabadiliko': 'Failed to save changes',
    'Imeshindikana kusasisha wasifu:': 'Failed to update profile:',
    'Imeshindikana kupakia hadithi:': 'Failed to upload story:',
    'Picha mpya: ': 'New image: ',
    'Jina: ': 'Name: ',
    'Bio: ': 'Bio: ',
    'Simu: ': 'Phone: ',
    'Akaunti ya Malipo: ': 'Payout Account: ',
    'kutoka kwa ': 'from ',
    ' z imepitishwa': ' approved',
    ' zimepitishwa': ' approved',
    'Lugha imebadilishwa kuwa ': 'Language changed to ',
    'Mandhari imebadilishwa kuwa ': 'Theme changed to ',
    'Inafungua ': 'Opening ',
    ' imewekwa kuwa chaguo-msingi': ' set as default',
    ' imefutwa': ' deleted',
    'Je, una uhakika unataka kufuta ': 'Are you sure you want to delete ',
    ' hadithi jumla': ' stories total',
    ' jumla': ' total',
    'Umesoma sura ya kwanza bure. Ili kuendelea na sura zinazofuata, nunua kitabu hiki sasa.':
        'You have read chapter one for free. To continue to the next chapters, buy this book now.',
  };

  static final Map<String, String> _wordSwToEn = {
    'ingia': 'login',
    'barua': 'email',
    'pepe': 'mail',
    'weka': 'enter',
    'msimbo': 'code',
    'tafuta': 'search',
    'hadithi': 'story',
    'hadithi...': 'stories...',
    'msaada': 'help',
    'malipo': 'payment',
    'lugha': 'language',
    'jina': 'name',
    'namba': 'number',
    'simu': 'phone',
    'chagua': 'select',
    'mtoa': 'provider',
    'huduma': 'service',
    'kategoria': 'category',
    'kichwa': 'title',
    'maelezo': 'description',
    'bei': 'price',
    'bure': 'free',
    'futa': 'delete',
    'hifadhi': 'save',
    'jaribu': 'try',
    'tena': 'again',
    'kwa': 'for',
    'ya': 'of',
    'na': 'and',
    'ni': 'is',
    'imeongezwa': 'added',
  };

  static final List<MapEntry<String, String>> _phraseEntries =
      _phraseSwToEn.entries.toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length));

  static String translate(String input, String languageCode) {
    if (languageCode.toLowerCase() != 'en') return input;

    final exact = _exactSwToEn[input];
    if (exact != null) return exact;

    String output = input;
    for (final pair in _phraseEntries) {
      output = output.replaceAll(pair.key, pair.value);
    }

    _wordSwToEn.forEach((sw, en) {
      final pattern = RegExp('\\b${RegExp.escape(sw)}\\b', caseSensitive: false);
      output = output.replaceAllMapped(pattern, (match) {
        final original = match.group(0) ?? '';
        if (original.isEmpty) return en;
        final isUpper = original == original.toUpperCase();
        final isTitle = original[0] == original[0].toUpperCase();
        if (isUpper) return en.toUpperCase();
        if (isTitle) return en[0].toUpperCase() + en.substring(1);
        return en;
      });
    });

    return output;
  }
}

extension AppI18nContextX on BuildContext {
  String tr(String input) {
    final lang = read<AuthProvider>().preferredLanguage;
    return AppI18n.translate(input, lang);
  }
}
