// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome to Mental Gym';

  @override
  String get start => 'Start';

  @override
  String get back => 'Back';

  @override
  String get restart => 'Restart';

  @override
  String get appName => 'Bulk Mind';

  @override
  String get red => 'Red';

  @override
  String get blue => 'Blue';

  @override
  String get green => 'Green';

  @override
  String get yellow => 'Yellow';

  @override
  String get orange => 'Orange';

  @override
  String get purple => 'Purple';

  @override
  String get pink => 'Pink';

  @override
  String get grey => 'Grey';

  @override
  String get brown => 'Brown';

  @override
  String get white => 'White';

  @override
  String get correct => '¡Correct!';

  @override
  String get youCanContinue => 'You can continue...';

  @override
  String get continueLabel => 'Continue';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get logic => 'Logic';

  @override
  String get intuition => 'Intuition';

  @override
  String get memory => 'Memory';

  @override
  String get patterns => 'Patterns';

  @override
  String get spatial => 'Spatial';

  @override
  String get youAreALooser => 'You are a looser';

  @override
  String get newRecord => 'New Record';

  @override
  String get maxLevel => 'Max Level';

  @override
  String get newBestTime => 'New Best Time';

  @override
  String get bestTime => 'Best Time';

  @override
  String get yourScore => 'Your Score';

  @override
  String get timeTaken => 'Time Taken';

  @override
  String get levels => 'Levels';

  @override
  String get level => 'Level';

  @override
  String get time => 'Time';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordInvalid =>
      'Password must be at least 9 characters and include uppercase, lowercase, a number, and a special character.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get fullName => 'Full Name';

  @override
  String get age => 'Age';

  @override
  String get birthday => 'Birthday';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Log out';

  @override
  String get continueWithOutSignIn => 'Continue without signing in';

  @override
  String get privacyPolicyAgreementPrefix => 'I accept the ';

  @override
  String get privacyPolicyLinkText => 'privacy policy';

  @override
  String get privacyPolicyRequired =>
      'You must accept the privacy policy before signing up.';

  @override
  String get getAllGamesTitle => 'Get All Games';

  @override
  String annualSubscriptionPrice(Object price) {
    return 'Annual subscription price: $price';
  }

  @override
  String get discountCodeLabel => 'Discount code';

  @override
  String get apply => 'Apply';

  @override
  String finalPrice(Object price) {
    return 'Final price: $price';
  }

  @override
  String finalPriceWithOriginal(Object finalPrice, Object originalPrice) {
    return 'Final price: $finalPrice (was $originalPrice)';
  }

  @override
  String appliedCode(Object code) {
    return 'Applied code: $code';
  }

  @override
  String get priceUnavailable => 'Price unavailable';

  @override
  String get failedToLoadPrice => 'Failed to load price';

  @override
  String get discountApplied => 'Discount code applied';

  @override
  String get invalidOrExpiredCode => 'Invalid or expired code';

  @override
  String get couldNotApplyCode => 'Could not apply code';

  @override
  String get purchaseAnnualSubscription => 'Purchase annual subscription';

  @override
  String get purchaseFlowStub => 'Purchase flow would start here (Stripe)';

  @override
  String get payNow => 'Pay';

  @override
  String get launchingGooglePlayPurchase =>
      'Opening Google Play billing flow...';

  @override
  String get launchingAppStorePurchase => 'Opening App Store billing flow...';

  @override
  String get purchaseNotAvailableOnPlatform =>
      'Purchases are not supported on this platform.';

  @override
  String get complimentaryAccessGranted =>
      'Complimentary access granted! Enjoy all games.';

  @override
  String get mustBeLoggedInToPurchase =>
      'You need to be signed in to continue.';

  @override
  String get purchaseFailed =>
      'We couldn\'t start the purchase. Please try again.';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String checkEmailSubtitle(Object email) {
    return 'We sent a verification link to $email. Please verify to continue.';
  }

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get verificationEmailSent => 'Verification email sent.';

  @override
  String get verificationEmailError =>
      'Couldn\'t send verification email. Try again later.';

  @override
  String get checkEmailHelp =>
      'Once your email is verified, this screen will close automatically.';
}
