#import <Preferences/Preferences.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <sys/utsname.h>

OBJC_EXTERN CFStringRef MGCopyAnswer(CFStringRef key) WEAK_IMPORT_ATTRIBUTE;
static const CFStringRef kMobileDeviceUniqueIdentifier = CFSTR("UniqueDeviceID");

@interface PSListController()
@property(nonatomic, readonly, retain) UINavigationController *navigationController;
@property(nonatomic, readonly, retain) UINavigationItem *navigationItem;
-(void)loadView;
@end

@interface PSTableCell()
@property(nonatomic, readonly, retain) UIView *contentView;
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
@end

@interface PSFooterHyperlinkView : UIView
- (instancetype)initWithSpecifier:(id)specifier;
- (void)setLinkRange:(NSRange)range;
- (void)setURL:(id)url;
- (NSString *)text;
@end

@interface NSObject (SRHelpers)
@end

@implementation NSObject (SRHelpers)

// https://gist.github.com/vhbit/958738
- (NSURL *)getSNSURLForUserName:(NSString *)userName {
    NSArray *urls = [NSArray arrayWithObjects:
        @"tweetbot:///user_profile/{username}"            // TweetBot
   // , @"twitterrific:///profile?screen_name={username}" // Twitterrific
      , @"echofon:///user_timeline?{username}"            // Echofon
   // , @"tweetings:///user?screen_name={username}",      // Tweetings
      , @"twitter:@{username}"                            // Twitter
   // , @"moke:///user?domain={username}"                 // Moke
      , @"http://gviridis.com/sns/{username}"
      , nil];

    UIApplication *application = [UIApplication sharedApplication];
    for (NSString *candidate in urls) {
        candidate = [candidate stringByReplacingOccurrencesOfString:@"{username}" withString:userName];
        NSURL *url = [NSURL URLWithString:candidate];
        if ([application canOpenURL:url]) {
            return url;
        }
    }
    return nil;
}

@end

@interface SimpleReachSettingsListController: PSListController<MFMailComposeViewControllerDelegate> {
}
-(void)loadView;
@end

@implementation SimpleReachSettingsListController

-(void)loadView {
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SimpleReachSettings" target:self] retain];
	}
	return _specifiers;
}

-(void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"Check out SimpleReach by @gviridis on Cydia! http://cydia.saurik.com/package/com.gviridis.simplereach/";

	UIActivityViewController *viewController = [[[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:text, nil] applicationActivities:nil] autorelease];
	[self.navigationController presentViewController:viewController animated:YES completion:NULL];
}


// https://www.reddit.com/r/jailbreakdevelopers/comments/3cyhkg/how_to_add_an_email_popup_in_a_preference_bundle/?
-(void)mailTapped {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];

		[mailComposeViewController setToRecipients:@[@"gviridis+simplereach@gmail.com"]];

		[mailComposeViewController setSubject:@"SimpleReach Support"];

		struct utsname systemInfo;
		uname(&systemInfo);
		NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
		encoding:NSUTF8StringEncoding];
		CFStringRef udid = MGCopyAnswer(kMobileDeviceUniqueIdentifier);
		NSString *messageBody = [NSString stringWithFormat: @"\n\n\n\n"
		                                                     "Please do not delete the text and attachments below.\n\n"
															 "%@ %@ %@\n"
														  , deviceModel
														  , [[UIDevice currentDevice] systemVersion]
														  , udid];
		[mailComposeViewController setMessageBody: messageBody
		                                   isHTML: NO];

		[mailComposeViewController addAttachmentData:[NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gviridis.simplereach.plist"] mimeType:@"application/xml" fileName:@"com.gviridis.simplereach.plist"];
		[mailComposeViewController addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/cydia.log"] mimeType:@"text/plain" fileName:@"cydia.log"];
		#pragma GCC diagnostic push
		#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		system("/usr/bin/dpkg -l >/tmp/dpkgl.log");
		#pragma GCC diagnostic pop
    	[mailComposeViewController addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.log"];

		mailComposeViewController.mailComposeDelegate = self;

		[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:mailComposeViewController animated:YES completion:NULL];

		CFRelease(udid);
	} else {
		#pragma GCC diagnostic push
		#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
		                                                message: @"Please setup an email account in Settings.app -> Mail, Contacts, Calendars."
		                                               delegate: self
	                                    	  cancelButtonTitle: @"OK"
		                                      otherButtonTitles: nil, nil];
		[alert show];
		#pragma GCC diagnostic pop
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	if (result == MFMailComposeResultSent) {

	} else if (result == MFMailComposeResultCancelled) {

	}
	[controller dismissViewControllerAnimated:YES completion:^{

	}];
}

- (BOOL)openSNSClientForUserName:(NSString *)userName {
	NSURL *url = [self getSNSURLForUserName:userName];
	if (!url) return NO;
	UIApplication *application = [UIApplication sharedApplication];
	[application openURL:url];
	return YES;
}

- (void)followOnSNS: (PSSpecifier *)specifier {
	NSString *SNSID = [specifier propertyForKey: @"SNSID"];
	[self openSNSClientForUserName: SNSID];
}

@end

@interface SRHeaderCell : PSTableCell{
	UILabel *heading;
}
@end

@implementation SRHeaderCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimpleReachHeaderCell" specifier:specifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGRect frame = CGRectMake(0, 18, [[UIScreen mainScreen] bounds].size.width, 60);
        heading = [[UILabel alloc] initWithFrame:frame];
        [heading setNumberOfLines:1];
        heading.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
        [heading setText:@"SimpleReach"];
        [heading setBackgroundColor:[UIColor clearColor]];
        heading.textColor = [UIColor blackColor];
        heading.textAlignment = NSTextAlignmentCenter;

        [self.contentView addSubview:heading];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(double)arg1 inTableView:(id)arg2 {
    return 90.0;
}

@end

@interface SRFooterHyperlinkView : PSFooterHyperlinkView
- (id)initWithSpecifier:(id)arg1;
@end

@implementation SRFooterHyperlinkView

- (id)initWithSpecifier:(id)specifier {
	self = [super initWithSpecifier:specifier];
	NSString *SNSID = [specifier propertyForKey: @"SNSID"];
	[self setURL: [self getSNSURLForUserName:SNSID]];
	NSUInteger length = [[self text] length];
    [self setLinkRange: NSMakeRange(length-1,1)];
	return self;
}

@end
