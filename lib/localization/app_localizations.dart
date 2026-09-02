/// Central translation dictionary for the Baas app - mirrors the
/// customer app's AppLocalizations pattern (en/si/ta), just with a
/// different key set covering job requests, wallet, and the Baas
/// profile screens instead of search/hire.
class AppLocalizations {
  AppLocalizations._();

  static const Map<String, Map<String, String>> _strings = {
    // ---- Common ----
    'appName': {'en': 'GOBAAS', 'si': 'මයි බාස්', 'ta': 'மை பாஸ்'},
    'continueBtn': {'en': 'Continue', 'si': 'ඉදිරියට', 'ta': 'தொடரவும்'},
    'cancel': {'en': 'Cancel', 'si': 'අවලංගු කරන්න', 'ta': 'ரத்து செய்'},
    'save': {'en': 'Save', 'si': 'සුරකින්න', 'ta': 'சேமி'},
    'ok': {'en': 'OK', 'si': 'හරි', 'ta': 'சரி'},
    'notSet': {'en': 'Not set', 'si': 'සකසා නැත', 'ta': 'அமைக்கப்படவில்லை'},

    // ---- Login / OTP / Name ----
    'forBaasProfessionals': {'en': 'For Baas Professionals', 'si': 'Baas වෘත්තිකයන් සඳහා', 'ta': 'பாஸ் நிபுணர்களுக்காக'},
    'mobileNumber': {'en': 'Mobile Number', 'si': 'ජංගම දුරකථන අංකය', 'ta': 'மொபைல் எண்'},
    'mobileNumberHint': {
      'en': 'Enter your 10-digit Sri Lankan mobile number.',
      'si': 'ඔබේ ලංකා ජංගම දුරකථන අංකය ඇතුළත් කරන්න.',
      'ta': 'உங்கள் இலங்கை மொபைல் எண்ணை உள்ளிடவும்.',
    },
    'enterVerificationCode': {'en': 'Enter verification code', 'si': 'තහවුරු කිරීමේ කේතය ඇතුළත් කරන්න', 'ta': 'சரிபார்ப்புக் குறியீட்டை உள்ளிடவும்'},
    'weSentCodeTo': {'en': 'We sent a code to', 'si': 'අපි කේතයක් එවා ඇත', 'ta': 'நாங்கள் ஒரு குறியீட்டை அனுப்பியுள்ளோம்'},
    'verify': {'en': 'Verify', 'si': 'තහවුරු කරන්න', 'ta': 'சரிபார்க்கவும்'},
    'whatsYourName': {'en': "What's your name?", 'si': 'ඔබේ නම කුමක්ද?', 'ta': 'உங்கள் பெயர் என்ன?'},
    'nameSubtitle': {
      'en': 'This is how customers will see you.',
      'si': 'පාරිභෝගිකයින් ඔබව දකින්නේ මෙසේය.',
      'ta': 'வாடிக்கையாளர்கள் உங்களை இப்படித்தான் பார்ப்பார்கள்.',
    },
    'firstName': {'en': 'First name', 'si': 'මුල් නම', 'ta': 'முதல் பெயர்'},
    'lastName': {'en': 'Last name', 'si': 'අග නම', 'ta': 'கடைசி பெயர்'},

    // ---- Bottom nav ----
    'home': {'en': 'Home', 'si': 'මුල් පිටුව', 'ta': 'முகப்பு'},
    'jobs': {'en': 'Jobs', 'si': 'රැකියා', 'ta': 'வேலைகள்'},
    'wallet': {'en': 'Wallet', 'si': 'මුදල් පසුම්බිය', 'ta': 'பணப்பை'},
    'settings': {'en': 'Settings', 'si': 'සැකසුම්', 'ta': 'அமைப்புகள்'},

    // ---- Home dashboard ----
    'welcome': {'en': 'Welcome', 'si': 'ආයුබෝවන්', 'ta': 'வரவேற்கிறோம்'},
    'youreOnline': {'en': "You're Online", 'si': 'ඔබ Online', 'ta': 'நீங்கள் ஆன்லைனில்'},
    'youreOffline': {'en': "You're Offline", 'si': 'ඔබ Offline', 'ta': 'நீங்கள் ஆஃப்லைனில்'},
    'visibleToCustomers': {'en': 'Visible to nearby customers', 'si': 'ළඟම පාරිභෝගිකයින්ට පෙනේ', 'ta': 'அருகிலுள்ள வாடிக்கையாளர்களுக்குத் தெரியும்'},
    'goOnlineToReceive': {'en': 'Go online to receive job requests', 'si': 'රැකියා ඉල්ලීම් ලබා ගැනීමට Online වන්න', 'ta': 'வேலை கோரிக்கைகளைப் பெற ஆன்லைனில் செல்லுங்கள்'},
    'platformFee': {'en': 'Platform fee', 'si': 'වේදිකා ගාස්තුව', 'ta': 'தள கட்டணம்'},
    'mustBePaidToGoOnline': {'en': 'This must be paid before you can go online.', 'si': 'Online වීමට පෙර මෙය ගෙවිය යුතුය.', 'ta': 'ஆன்லைனில் செல்வதற்கு முன் இது செலுத்தப்பட வேண்டும்.'},
    'pay': {'en': 'Pay', 'si': 'ගෙවන්න', 'ta': 'செலுத்து'},
    'todaysEarnings': {'en': "TODAY'S EARNINGS", 'si': 'අද උපයාගැනීම්', 'ta': 'இன்றைய வருமானம்'},
    'jobsToday': {'en': 'jobs today', 'si': 'අද රැකියා', 'ta': 'இன்று வேலைகள்'},
    'viewJobRequests': {'en': 'View Job Requests', 'si': 'රැකියා ඉල්ලීම් බලන්න', 'ta': 'வேலை கோரிக்கைகளைப் பார்க்கவும்'},
    'platformFeeDue': {'en': 'Platform Fee Due', 'si': 'වේදිකා ගාස්තුව ගෙවිය යුතුයි', 'ta': 'தள கட்டணம் செலுத்த வேண்டும்'},
    'platformFeeDueDesc': {'en': 'You have an outstanding platform fee of', 'si': 'ඔබට ගෙවිය යුතු වේදිකා ගාස්තුවක් තිබේ', 'ta': 'உங்களிடம் நிலுவையில் உள்ள தள கட்டணம் உள்ளது'},
    'payToGoOnline': {'en': 'Pay it to go back online.', 'si': 'Online වීමට එය ගෙවන්න.', 'ta': 'மீண்டும் ஆன்லைனில் செல்ல செலுத்துங்கள்.'},
    'notNow': {'en': 'Not Now', 'si': 'දැන් නොවේ', 'ta': 'இப்போது வேண்டாம்'},
    'payFromWallet': {'en': 'Pay from Wallet', 'si': 'Wallet එකෙන් ගෙවන්න', 'ta': 'பணப்பையிலிருந்து செலுத்து'},
    'payByCard': {'en': 'Pay by Card', 'si': 'කාඩ්පතෙන් ගෙවන්න', 'ta': 'அட்டையால் செலுத்து'},
    'feePaidCanGoOnline': {'en': 'Platform fee paid. You can go online now.', 'si': 'වේදිකා ගාස්තුව ගෙවා ඇත. දැන් Online විය හැක.', 'ta': 'தள கட்டணம் செலுத்தப்பட்டது. இப்போது ஆன்லைனில் செல்லலாம்.'},

    // ---- Job requests ----
    'jobRequests': {'en': 'Job Requests', 'si': 'රැකියා ඉල්ලීම්', 'ta': 'வேலை கோரிக்கைகள்'},
    'incoming': {'en': 'Incoming', 'si': 'එන', 'ta': 'உள்வரும்'},
    'active': {'en': 'Active', 'si': 'ක්‍රියාකාරී', 'ta': 'செயலில்'},
    'completed': {'en': 'Completed', 'si': 'සම්පූර්ණයි', 'ta': 'முடிந்தது'},
    'nothingHereYet': {'en': 'Nothing here yet.', 'si': 'තවම මෙහි කිසිවක් නැත.', 'ta': 'இன்னும் எதுவும் இல்லை.'},
    'requestedYou': {'en': 'Requested you', 'si': 'ඔබව ඉල්ලා ඇත', 'ta': 'உங்களைக் கோரினர்'},
    'kmAway': {'en': 'km away', 'si': 'km දුරින්', 'ta': 'கிமீ தொலைவில்'},
    'day': {'en': 'day', 'si': 'දිනය', 'ta': 'நாள்'},
    'days': {'en': 'days', 'si': 'දින', 'ta': 'நாட்கள்'},
    'reject': {'en': 'Reject', 'si': 'ප්‍රතික්ෂේප කරන්න', 'ta': 'நிராகரி'},
    'accept': {'en': 'Accept', 'si': 'පිළිගන්න', 'ta': 'ஏற்றுக்கொள்'},
    'markComplete': {'en': 'Mark Complete', 'si': 'සම්පූර්ණ ලෙස සලකුණු කරන්න', 'ta': 'முடிந்ததாகக் குறி'},
    'customer': {'en': 'Customer', 'si': 'පාරිභෝගිකයා', 'ta': 'வாடிக்கையாளர்'},
    'rejectOrderTitle': {'en': 'Reject Order', 'si': 'ඇණවුම ප්‍රතික්ෂේප කරන්න', 'ta': 'ஆர்டரை நிராகரி'},
    'rejectOrderConfirm': {'en': 'Reject the request for', 'si': 'ඉල්ලීම ප්‍රතික්ෂේප කරන්න', 'ta': 'கோரிக்கையை நிராகரிக்கவா'},
    'markCompleteTitle': {'en': 'Mark Complete', 'si': 'සම්පූර්ණ ලෙස සලකුණු කරන්න', 'ta': 'முடிந்ததாகக் குறி'},
    'markCompleteConfirm': {
      'en': 'Do this once the job is actually finished.',
      'si': 'රැකියාව සැබවින්ම අවසන් වූ පසු මෙය කරන්න.',
      'ta': 'வேலை உண்மையில் முடிந்தவுடன் இதைச் செய்யுங்கள்.',
    },

    // ---- Wallet ----
    'availableBalance': {'en': 'AVAILABLE BALANCE', 'si': 'ලබා ගත හැකි ශේෂය', 'ta': 'கிடைக்கும் இருப்பு'},
    'pending': {'en': 'PENDING', 'si': 'පොරොත්තුවෙන්', 'ta': 'நிலுவையில்'},
    'topUp': {'en': 'Top Up', 'si': 'මුදල් එකතු කරන්න', 'ta': 'நிதி சேர்'},
    'withdraw': {'en': 'Withdraw', 'si': 'මුදල් ආපසු ගන්න', 'ta': 'திரும்பப் பெறு'},
    'transactionHistory': {'en': 'Transaction History', 'si': 'ගනුදෙනු ඉතිහාසය', 'ta': 'பரிவர்த்தனை வரலாறு'},
    'noTransactionsYet': {'en': 'No transactions yet.', 'si': 'තවම ගනුදෙනු නැත.', 'ta': 'இன்னும் பரிவர்த்தனைகள் இல்லை.'},
    'payPlatformFee': {'en': 'Pay Platform Fee', 'si': 'වේදිකා ගාස්තුව ගෙවන්න', 'ta': 'தள கட்டணத்தைச் செலுத்து'},
    'amountDue': {'en': 'Amount Due', 'si': 'ගෙවිය යුතු මුදල', 'ta': 'செலுத்த வேண்டிய தொகை'},
    'amountLkr': {'en': 'Amount (LKR)', 'si': 'මුදල (රු.)', 'ta': 'தொகை (LKR)'},
    'fixedFeeNote': {'en': 'Fixed - this covers your current outstanding fee.', 'si': 'ස්ථාවර - මෙය ඔබේ වර්තමාන ගාස්තුව ආවරණය කරයි.', 'ta': 'நிலையானது - இது உங்கள் தற்போதைய நிலுவைத் தொகையை உள்ளடக்கும்.'},
    'minimumTopUp': {'en': 'Minimum Rs. 100', 'si': 'අවම රු. 100', 'ta': 'குறைந்தபட்சம் Rs. 100'},
    'continueToPayment': {'en': 'Continue to Payment', 'si': 'ගෙවීමට ඉදිරියට යන්න', 'ta': 'கட்டணத்திற்குத் தொடரவும்'},
    'availableToWithdraw': {'en': 'Available to withdraw', 'si': 'ආපසු ගත හැකි මුදල', 'ta': 'திரும்பப் பெறக்கூடியது'},
    'amount': {'en': 'Amount', 'si': 'මුදල', 'ta': 'தொகை'},
    'minimumWithdrawal': {'en': 'Minimum Rs. 1,000', 'si': 'අවම රු. 1,000', 'ta': 'குறைந்தபட்சம் Rs. 1,000'},
    'bankName': {'en': 'Bank Name', 'si': 'බැංකු නම', 'ta': 'வங்கியின் பெயர்'},
    'accountName': {'en': 'Account Name', 'si': 'ගිණුමේ නම', 'ta': 'கணக்கு பெயர்'},
    'accountNumber': {'en': 'Account Number', 'si': 'ගිණුම් අංකය', 'ta': 'கணக்கு எண்'},
    'branchOptional': {'en': 'Branch (optional)', 'si': 'ශාඛාව (විකල්ප)', 'ta': 'கிளை (விருப்பம்)'},
    'requestWithdrawal': {'en': 'Request Withdrawal', 'si': 'ආපසු ගැනීම ඉල්ලන්න', 'ta': 'திரும்பப் பெற கோரிக்கை'},
    'withdrawalRequested': {'en': 'Withdrawal Requested', 'si': 'ආපසු ගැනීම ඉල්ලා ඇත', 'ta': 'திரும்பப் பெறுதல் கோரப்பட்டது'},
    'withdrawalRequestedDesc': {
      'en': 'Your withdrawal request has been submitted and is pending approval.',
      'si': 'ඔබේ ආපසු ගැනීමේ ඉල්ලීම ඉදිරිපත් කර අනුමැතිය බලාපොරොත්තුවෙන් ඇත.',
      'ta': 'உங்கள் திரும்பப் பெறும் கோரிக்கை சமர்ப்பிக்கப்பட்டு ஒப்புதலுக்காக காத்திருக்கிறது.',
    },

    // ---- Settings / Profile ----
    'myBaasProfessional': {'en': 'GOBAAS Professional', 'si': 'GOBAAS වෘත්තිකයා', 'ta': 'GOBAAS நிபுணர்'},
    'profile': {'en': 'Profile', 'si': 'පැතිකඩ', 'ta': 'சுயவிவரம்'},
    'services': {'en': 'Services', 'si': 'සේවා', 'ta': 'சேவைகள்'},
    'selectServicesDesc': {
      'en': 'Select what you offer - this is how customers find you.',
      'si': 'ඔබ ලබා දෙන දේ තෝරන්න - පාරිභෝගිකයින් ඔබව සොයා ගන්නේ මෙසේය.',
      'ta': 'நீங்கள் வழங்குவதைத் தேர்ந்தெடுக்கவும் - வாடிக்கையாளர்கள் உங்களைக் கண்டறிவது இப்படித்தான்.',
    },
    'dailyRate': {'en': 'Daily Rate', 'si': 'දෛනික ගාස්තුව', 'ta': 'தினசரி கட்டணம்'},
    'about': {'en': 'About', 'si': 'ගැන', 'ta': 'பற்றி'},
    'aboutHint': {'en': 'A short line about your experience', 'si': 'ඔබේ පළපුරුද්ද ගැන කෙටි විස්තරයක්', 'ta': 'உங்கள் அனுபவம் பற்றிய சுருக்கமான வரி'},
    'locationLabel': {'en': 'Location Label', 'si': 'ස්ථාන ලේබලය', 'ta': 'இட லேபிள்'},
    'locationLabelDesc': {
      'en': 'Shown to customers alongside your distance.',
      'si': 'ඔබේ දුර සමඟ පාරිභෝගිකයින්ට පෙන්වයි.',
      'ta': 'உங்கள் தூரத்துடன் வாடிக்கையாளர்களுக்குக் காட்டப்படும்.',
    },
    'useCurrentLocation': {'en': 'Use My Current Location', 'si': 'මගේ වර්තමාන ස්ථානය භාවිතා කරන්න', 'ta': 'எனது தற்போதைய இருப்பிடத்தைப் பயன்படுத்தவும்'},
    'saveProfile': {'en': 'Save Profile', 'si': 'පැතිකඩ සුරකින්න', 'ta': 'சுயவிவரத்தை சேமி'},
    'security': {'en': 'Security', 'si': 'ආරක්ෂාව', 'ta': 'பாதுகாப்பு'},
    'support': {'en': 'Support', 'si': 'සහාය', 'ta': 'ஆதரவு'},
    'earnWithMybaas': {'en': 'Earn with GOBAAS', 'si': 'GOBAAS සමඟ උපයන්න', 'ta': 'GOBAAS உடன் சம்பாதிக்கவும்'},
    'aboutMybaas': {'en': 'About GOBAAS', 'si': 'GOBAAS ගැන', 'ta': 'GOBAAS பற்றி'},
    'language': {'en': 'Language', 'si': 'භාෂාව', 'ta': 'மொழி'},
    'logout': {'en': 'Logout', 'si': 'ලොග් අවුට් වන්න', 'ta': 'வெளியேறு'},
    'logoutConfirm': {'en': 'Are you sure you want to logout?', 'si': 'ඔබට ලොග් අවුට් වීමට අවශ්‍ය බව විශ්වාසද?', 'ta': 'நீங்கள் வெளியேற விரும்புகிறீர்களா?'},

    // ---- Security ----
    'email': {'en': 'Email', 'si': 'විද්‍යුත් තැපෑල', 'ta': 'மின்னஞ்சல்'},
    'mobile': {'en': 'Mobile', 'si': 'ජංගම දුරකථනය', 'ta': 'மொபைல்'},
    'change': {'en': 'Change', 'si': 'වෙනස් කරන්න', 'ta': 'மாற்று'},
    'newEmailAddress': {'en': 'New Email Address', 'si': 'නව විද්‍යුත් තැපැල් ලිපිනය', 'ta': 'புதிய மின்னஞ்சல் முகவரி'},
    'newMobileNumber': {'en': 'New Mobile Number', 'si': 'නව ජංගම දුරකථන අංකය', 'ta': 'புதிய மொபைல் எண்'},
    'sendCode': {'en': 'Send Code', 'si': 'කේතය යවන්න', 'ta': 'குறியீட்டை அனுப்பு'},
    'enterCodeTitle': {'en': 'Enter Verification Code', 'si': 'තහවුරු කිරීමේ කේතය ඇතුළත් කරන්න', 'ta': 'சரிபார்ப்புக் குறியீட்டை உள்ளிடவும்'},

    // ---- Referral ----
    'inviteEarnTitle': {'en': 'Invite a friend, earn 1%', 'si': 'මිතුරෙකු ආරාධනා කර 1% උපයන්න', 'ta': 'ஒரு நண்பரை அழைத்து 1% சம்பாதிக்கவும்'},
    'inviteEarnDesc': {
      'en': "Share your code. When a friend signs up and tops up their wallet for the first time, you'll get 1% of that top-up added straight to your own wallet.",
      'si': 'ඔබේ කේතය බෙදාගන්න. මිතුරෙකු ලියාපදිංචි වී ඔවුන්ගේ මුදල් පසුම්බිය මුලින්ම එකතු කළ විට, එම එකතුවෙන් 1% ක් කෙලින්ම ඔබේ මුදල් පසුම්බියට එකතු වේ.',
      'ta': 'உங்கள் குறியீட்டைப் பகிரவும். ஒரு நண்பர் பதிவு செய்து அவர்களின் பணப்பையை முதல் முறையாக நிரப்பும்போது, ​​அந்த தொகையில் 1% நேரடியாக உங்கள் சொந்த பணப்பைக்கு சேர்க்கப்படும்.',
    },
    'yourReferralCode': {'en': 'Your referral code', 'si': 'ඔබේ රෙෆරල් කේතය', 'ta': 'உங்கள் பரிந்துரை குறியீடு'},
    'shareCode': {'en': 'Share Code', 'si': 'කේතය බෙදාගන්න', 'ta': 'குறியீட்டைப் பகிரவும்'},
    'friendsReferred': {'en': 'Friends Referred', 'si': 'ආරාධනා කළ මිතුරන්', 'ta': 'பரிந்துரைக்கப்பட்ட நண்பர்கள்'},
    'totalEarned': {'en': 'Total Earned', 'si': 'මුළු උපයාගැනීම', 'ta': 'மொத்த சம்பாத்தியம்'},
    'referralCodeOptional': {'en': 'Referral Code (Optional)', 'si': 'රෙෆරල් කේතය (විකල්ප)', 'ta': 'பரிந்துரை குறியீடு (விருப்பம்)'},
    'referralCodeHint': {'en': 'Have a code from a friend? Enter it here.', 'si': 'මිතුරෙකුගෙන් කේතයක් තිබේද? එය මෙහි ඇතුළත් කරන්න.', 'ta': 'ஒரு நண்பரிடமிருந்து குறியீடு உள்ளதா? இங்கே உள்ளிடவும்.'},

    // ---- Language picker ----
    'selectYourLanguage': {'en': 'Select your language', 'si': 'ඔබේ භාෂාව තෝරන්න', 'ta': 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்'},

    // ---- Notifications ----
    'notifications': {'en': 'Notifications', 'si': 'දැනුම්දීම්', 'ta': 'அறிவிப்புகள்'},
    'markAllRead': {'en': 'Mark all read', 'si': 'සියල්ල කියවූ ලෙස සලකුණු කරන්න', 'ta': 'அனைத்தையும் படித்ததாகக் குறி'},
    'noNotificationsYet': {'en': 'No notifications yet.', 'si': 'තවම දැනුම්දීම් නැත.', 'ta': 'இன்னும் அறிவிப்புகள் இல்லை.'},

    // ---- Verification ----
    'verificationCenter': {'en': 'Verification Center', 'si': 'තහවුරු කිරීමේ මධ්‍යස්ථානය', 'ta': 'சரிபார்ப்பு மையம்'},
    'verificationIntro': {
      'en': 'Verify your identity to get a verified badge customers can see on your profile.',
      'si': 'ඔබේ අනන්‍යතාවය තහවුරු කර, පාරිභෝගිකයින්ට ඔබේ පැතිකඩේ පෙනෙන තහවුරු කළ බැජ් එකක් ලබාගන්න.',
      'ta': 'உங்கள் அடையாளத்தை சரிபார்த்து, வாடிக்கையாளர்கள் உங்கள் சுயவிவரத்தில் காணக்கூடிய சரிபார்க்கப்பட்ட பேட்ஜைப் பெறுங்கள்.',
    },
    'fullNameField': {'en': 'Full Name', 'si': 'සම්පූර්ණ නම', 'ta': 'முழு பெயர்'},
    'nicField': {'en': 'NIC Number', 'si': 'ජා.හැ. අංකය', 'ta': 'தே.அ.அ. எண்'},
    'phoneField': {'en': 'Phone Number', 'si': 'දුරකථන අංකය', 'ta': 'தொலைபேசி எண்'},
    'addressField': {'en': 'Address', 'si': 'ලිපිනය', 'ta': 'முகவரி'},
    'provinceField': {'en': 'Province', 'si': 'පළාත', 'ta': 'மாகாணம்'},
    'districtField': {'en': 'District', 'si': 'දිස්ත්‍රික්කය', 'ta': 'மாவட்டம்'},
    'nicFrontPhoto': {'en': 'NIC Front Photo', 'si': 'ජා.හැ. ඉදිරිපස ඡායාරූපය', 'ta': 'தே.அ.அ. முன் புகைப்படம்'},
    'nicBackPhoto': {'en': 'NIC Back Photo', 'si': 'ජා.හැ. පසුපස ඡායාරූපය', 'ta': 'தே.அ.அ. பின் புகைப்படம்'},
    'liveSelfie': {'en': 'Live Selfie', 'si': 'සජීවී සෙල්ෆි එක', 'ta': 'நேரடி செல்ஃபி'},
    'submitVerification': {'en': 'Submit for Verification', 'si': 'තහවුරු කිරීම සඳහා ඉදිරිපත් කරන්න', 'ta': 'சரிபார்ப்புக்காக சமர்ப்பிக்கவும்'},
    'verificationPending': {'en': 'Verification Pending', 'si': 'තහවුරු කිරීම පොරොත්තුවෙන්', 'ta': 'சரிபார்ப்பு நிலுவையில்'},
    'verificationPendingDesc': {
      'en': 'Your verification details are under review. This usually takes a short while.',
      'si': 'ඔබේ තහවුරු කිරීමේ විස්තර සමාලෝචනය කෙරෙමින් පවතී. මෙයට සාමාන්‍යයෙන් සුළු කාලයක් ගතවේ.',
      'ta': 'உங்கள் சரிபார்ப்பு விவரங்கள் மதிப்பாய்வு செய்யப்படுகின்றன. இதற்கு பொதுவாக சிறிது நேரம் ஆகும்.',
    },
    'verificationApproved': {'en': 'Verified', 'si': 'තහවුරු කර ඇත', 'ta': 'சரிபார்க்கப்பட்டது'},
    'verificationApprovedDesc': {
      'en': 'Your account is verified. Customers can see your verified badge.',
      'si': 'ඔබේ ගිණුම තහවුරු කර ඇත. පාරිභෝගිකයින්ට ඔබේ තහවුරු කළ බැජ් එක දැකගත හැක.',
      'ta': 'உங்கள் கணக்கு சரிபார்க்கப்பட்டது. வாடிக்கையாளர்கள் உங்கள் சரிபார்க்கப்பட்ட பேட்ஜைக் காணலாம்.',
    },
    'verificationRejected': {'en': 'Verification Rejected', 'si': 'තහවුරු කිරීම ප්‍රතික්ෂේප විය', 'ta': 'சரிபார்ப்பு நிராகரிக்கப்பட்டது'},
    'verificationRejectedDesc': {
      'en': 'Your verification could not be approved. Please review and resubmit.',
      'si': 'ඔබේ තහවුරු කිරීම අනුමත කළ නොහැකි විය. කරුණාකර සමාලෝචනය කර නැවත ඉදිරිපත් කරන්න.',
      'ta': 'உங்கள் சரிபார்ப்பை அங்கீகரிக்க முடியவில்லை. மறுபரிசீலனை செய்து மீண்டும் சமர்ப்பிக்கவும்.',
    },
    'resubmit': {'en': 'Resubmit', 'si': 'නැවත ඉදිරිපත් කරන්න', 'ta': 'மீண்டும் சமர்ப்பிக்கவும்'},
    'verifiedBadge': {'en': 'Verified', 'si': 'තහවුරු කර ඇත', 'ta': 'சரிபார்க்கப்பட்டது'},
    'notVerified': {'en': 'Not Verified', 'si': 'තහවුරු කර නැත', 'ta': 'சரிபார்க்கப்படவில்லை'},
    'identityVerification': {'en': 'Identity Verification', 'si': 'අනන්‍යතා තහවුරු කිරීම', 'ta': 'அடையாள சரிபார்ப்பு'},
    'nameLockedVerified': {
      'en': "Name can't be changed after verification is approved.",
      'si': 'තහවුරු කිරීම අනුමත වූ පසු නම වෙනස් කළ නොහැක.',
      'ta': 'சரிபார்ப்பு அங்கீகரிக்கப்பட்ட பிறகு பெயரை மாற்ற முடியாது.',
    },

    // ---- Support chat ----
    'chatClosed': {'en': 'Chat closed', 'si': 'කතාබස අවසන් කර ඇත', 'ta': 'அரட்டை மூடப்பட்டது'},
    'startNewConversation': {'en': 'Start New Conversation', 'si': 'නව සංවාදයක් ආරම්භ කරන්න', 'ta': 'புதிய உரையாடலைத் தொடங்கு'},
    'typeMessage': {'en': 'Type a message...', 'si': 'පණිවිඩයක් ටයිප් කරන්න...', 'ta': 'செய்தி ஒன்றை தட்டச்சு செய்யவும்...'},
    'conversationClosed': {'en': 'Conversation closed', 'si': 'සංවාදය අවසන් කර ඇත', 'ta': 'உரையாடல் மூடப்பட்டது'},
    'sendMessageHint': {
      'en': "Send a message and we'll be right with you.",
      'si': 'පණිවිඩයක් යවන්න, අපි ඉක්මනින් ඔබ සමඟ සම්බන්ධ වෙන්නෙමු.',
      'ta': 'ஒரு செய்தியை அனுப்புங்கள், நாங்கள் விரைவில் உங்களுடன் இருப்போம்.',
    },
  };

  /// Looks up [key] for [langCode] ('en' | 'si' | 'ta'), falling
  /// back to English, then to the key itself, so a missing
  /// translation never crashes the screen.
  static String t(String key, String langCode) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[langCode] ?? entry['en'] ?? key;
  }
}
