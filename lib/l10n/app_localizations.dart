import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('it'),
    Locale('pl')
  ];

  /// The title text for the comments page
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// Used in buttons to denote a reply action to a user
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Used in buttons to denote a like action to a user
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Used in buttons to denote a dislike action to a user
  ///
  /// In en, this message translates to:
  /// **'Dislike'**
  String get dislike;

  /// Used as placeholder text in the comment entry box
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// May be used as a heading for a list of user's message channels
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Used to show weather a user is currently using the application
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get activityOnline;

  /// Used to show weather a user is currently using the application
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get activityOffline;

  /// Used to show when a user was last online
  ///
  /// In en, this message translates to:
  /// **'Last seen {time} ago'**
  String activityLastSeen(String time);

  /// Used as placeholder text in the message channel
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// May be used in place of the send icon in messages or send password recovery emails
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Used as a heading for an infobox containing the total distance a user has traveled
  ///
  /// In en, this message translates to:
  /// **'Distance Travelled'**
  String get distanceTraveled;

  /// Used as a heading for an infobox containing the total session duration
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get sessionDuration;

  /// Used as a heading for an infobox containing the average session duration
  ///
  /// In en, this message translates to:
  /// **'Avg. Duration'**
  String get averageSessionDuration;

  /// Used as a heading for an infobox containing the sunset time
  ///
  /// In en, this message translates to:
  /// **'Sunset Time'**
  String get sunsetTime;

  /// Used as a heading for an infobox containing the average speed
  ///
  /// In en, this message translates to:
  /// **'Avg. Speed'**
  String get averageSpeed;

  /// Used as text for a button that will take the user to a speedometer page
  ///
  /// In en, this message translates to:
  /// **'Speedometer'**
  String get speedometer;

  /// Used as a button to start the fitness tracker
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Used as a button to stop the fitness tracker
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Used as a heading for a textbox where the user can input a name for their session
  ///
  /// In en, this message translates to:
  /// **'Session Name'**
  String get sessionName;

  /// Used as a heading for a textbox where the user can input a description for their session this could range from what they did // who they met // where they went etc...
  ///
  /// In en, this message translates to:
  /// **'Session Description'**
  String get sessionDescription;

  /// Used as text for a button that will let the user add their own images from their camera roll
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// Used as a heading for a dropdown containing different types of sessions (e.g. Fitness Skating)
  ///
  /// In en, this message translates to:
  /// **'Session Type'**
  String get sessionType;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Recreational/Fitness Skating'**
  String get fitnessSkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Aggressive Inline Skating'**
  String get aggressiveInlineSkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Aggressive Quad Skating'**
  String get aggressiveQuadSkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Artistic/Figure Skating'**
  String get figureSkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Urban/Freestyle Skating'**
  String get urbanSkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Off-Road Skating'**
  String get offRoadSkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Roller Hockey'**
  String get rollerHockeySkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Ice Hockey'**
  String get iceHockeySkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Roller Disco'**
  String get rollerDiscoSkating;

  /// Used as an entry for a dropdown containing different types of skating --
  ///
  /// In en, this message translates to:
  /// **'Roller Derby'**
  String get rollerDerbySkating;

  /// Used as a heading for a dropdown outlining who can see the user's session
  ///
  /// In en, this message translates to:
  /// **'Sharing Options'**
  String get shareOptions;

  /// Used as text for a button that will save & share the session
  ///
  /// In en, this message translates to:
  /// **'Save Session'**
  String get saveSession;

  /// Used as a heading for the New Post Page
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPost;

  /// Used as a heading for the final post creation page
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// Used as a heading for a textbox that will contain the post's description
  ///
  /// In en, this message translates to:
  /// **'Post Description'**
  String get postDescription;

  /// Used as text for a post button that will finalise the post and share it
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// Used as placeholder text within a search bar
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Used as a heading for a friends count
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Used as a heading for a followers count
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// Used as a heading for a following count
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// Used as text for a follow user button
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Used as text for a unfollow user button
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// Used as text for a Share Profile user button
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// Used as text for a edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Used as text for a settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Used as text for a saved posts button
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Used as a heading for a text input where the user can change their display name
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Used as a heading for a text input where the user can change their username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Used as a heading for a text input where the user can change their country
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Used as a heading for a text input where the user can input some information that will be displayed on their profile
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// Used as text for a button where the user can change their avatar
  ///
  /// In en, this message translates to:
  /// **'Edit Picture'**
  String get editPicture;

  /// May be used as text for a button where a user can save info
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Used as a heading for a option where the user can change their email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Used as a header for the login / password change page
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Used as text for a toggle button that will enable the user to unlock the app with their fingerprint
  ///
  /// In en, this message translates to:
  /// **'Biometric Verification'**
  String get biometrics;

  /// Used as text for a button that willl log the user out of the application
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Used as text for a toggle button that will enable app notifications
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Used as text for a language selector button
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Used as text for a button that will toggle a larger font size to make text more readable
  ///
  /// In en, this message translates to:
  /// **'Large Text'**
  String get largeText;

  /// Used as text for a button that toggles a more dyslexia friendly font
  ///
  /// In en, this message translates to:
  /// **'Dyslexia Font'**
  String get dyslexiaFont;

  /// Used as text for a button that allows the user to select between light and dark theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Used as text for a button that will show Frequently Asked Questions
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Used as text for a button that will allow the user to contact developer
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Used as text for a button that will show basic info about app such as version number
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// Used as a heading for security based options such as password config & email changing
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Used as a heading for notification based options such as push & email notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Used as heading for accessibility based settings such as language selection and large font
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// Used as heading for help & support based options such as FAQ and contact support
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Used as text for a sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Used as text for a password recovery function
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Used as description telling user what to do to recover their password
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your account and we will send an introductions to reset your password.'**
  String get forgotPasswordDesc;

  /// Used as desc for user auth confirmation
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digit code sent to you at ******.'**
  String get loginConfirmCode;

  /// Used as heading for entering a confirmation code
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Used to confirm confirmation code entry
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Used to resend confirmation code
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// Used as text to be displayed when user resends a code
  ///
  /// In en, this message translates to:
  /// **'Not recieved, even in spam folder?'**
  String get resendMessage;

  /// Used as text for a create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Used as text for switching to sign in page
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Used as text for linking TOS and Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to our'**
  String get agreeTo;

  /// Terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get tos;

  /// Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Will be displayed when there are either no posts on a user profile / feed
  ///
  /// In en, this message translates to:
  /// **'No Posts Yet'**
  String get noPostsFound;

  /// Will be displayed when there are no channels in message channels
  ///
  /// In en, this message translates to:
  /// **'No Messages Yet'**
  String get noMessagesFound;

  /// Will be displayed when there are no comments on a post
  ///
  /// In en, this message translates to:
  /// **'No Comments Yet'**
  String get noCommentsFound;

  /// Will be displayed below the no posts found on a user's feed or the no channels in message channels
  ///
  /// In en, this message translates to:
  /// **'Try making some friends.'**
  String get makeFriends;

  /// Will be displayed as title of message channels
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// Will be displayed on the follow button if the user has requested to follow
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// Will be displayed on change password page for old password
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// Will be displayed on change password page for new password
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Will be displayed on change password page for confirming password
  ///
  /// In en, this message translates to:
  /// **'Retype Password'**
  String get retypePassword;

  /// Will be displayed on change password page for saving change
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Will be displayed as language in language selector
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Will be displayed as language in language selector
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get polish;

  /// Will be displayed as language in language selector
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Will be displayed as language in language selector
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// Will be displayed as language in language selector
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Will be displayed as a theme in theme selector
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Will be displayed as a theme in theme selector
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Will be displayed as a theme in theme selector
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Shown when a feature is unavailable on the user's current platform.
  ///
  /// In en, this message translates to:
  /// **'Platform Not Supported'**
  String get platformNotSupported;

  /// Displayed on the edit post screen when no image has been chosen.
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get noImageSelected;

  /// Used as the hint text in a dropdown menu on the Create Report screen.
  ///
  /// In en, this message translates to:
  /// **'Select A Report Type'**
  String get selectReportType;

  /// Label used in reports to indicate the subject field.
  ///
  /// In en, this message translates to:
  /// **'Subject:'**
  String get subject;

  /// Label used in reports to indicate the status field.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get status;

  /// Label used in reports to indicate the author's name.
  ///
  /// In en, this message translates to:
  /// **'By:'**
  String get by;

  /// Displayed in the report message section when a report is closed.
  ///
  /// In en, this message translates to:
  /// **'This Report Has Been Marked As Closed.'**
  String get reportMarkedAsClosed;

  /// Displayed when the user attempts to modify a closed report.
  ///
  /// In en, this message translates to:
  /// **'Reports marked as closed cannot be modified.'**
  String get closedReportsCannotBeModified;

  /// Button label used to submit forms, reports, or feedback.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Button label on the Settings screen that opens a list of upcoming features.
  ///
  /// In en, this message translates to:
  /// **'Planned Features'**
  String get plannedFeatures;

  /// Button label on the Settings screen that allows users to submit feature suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggest a Feature'**
  String get suggestFeature;

  /// Button label on the Settings screen to view a list of users the current user has blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// Title for the toggle switch that enables or disables email notifications in the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Button label in the Settings screen for moderators to access submitted reports for review.
  ///
  /// In en, this message translates to:
  /// **'Review Reports'**
  String get reviewReports;

  /// Button label in the Settings screen that navigates users to their submitted reports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// Button label in the Settings screen for reporting application bugs.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBug;

  /// Status label used in the support ticket list to indicate that a ticket is not assigned to any moderator.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// Label used in support tickets to show the name of the assigned moderator.
  ///
  /// In en, this message translates to:
  /// **'Assigned To:'**
  String get assignedTo;

  /// Label used in support tickets to show the name of the user who created the ticket.
  ///
  /// In en, this message translates to:
  /// **'Created By:'**
  String get createdBy;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'it', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
