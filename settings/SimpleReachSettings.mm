#import <Preferences/Preferences.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <sys/utsname.h>

OBJC_EXTERN CFStringRef MGCopyAnswer(CFStringRef key) WEAK_IMPORT_ATTRIBUTE;
static const CFStringRef kMobileDeviceUniqueIdentifier = CFSTR("UniqueDeviceID");

@interface PSTableCell()
@property(nonatomic, readonly, retain) UIView *contentView;
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
@end

@interface SimpleReachSettingsListController: PSListController<MFMailComposeViewControllerDelegate> {
}
@end

@implementation SimpleReachSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SimpleReachSettings" target:self] retain];
	}
	return _specifiers;
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
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
		                                                message: @"Please setup an email account in Settings.app -> Mail, Contacts, Calendars."
		                                               delegate: self
	                                    	  cancelButtonTitle: @"OK"
		                                      otherButtonTitles: nil, nil];
		[alert show];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	if (result == MFMailComposeResultSent) {

	} else if (result == MFMailComposeResultCancelled) {

	}
	[controller dismissViewControllerAnimated:YES completion:^{

	}];
}

// https://gist.github.com/vhbit/958738
- (BOOL)openTwitterClientForUserName:(NSString*)userName {
    NSArray *urls = [NSArray arrayWithObjects: @"twitter:@{username}", // Twitter
							                   @"tweetbot:///user_profile/{username}", // TweetBot
										    //    @"twitterrific:///profile?screen_name={username}", // Twitterrific
                                               @"echofon:///user_timeline?{username}", // Echofon
                    						//    @"tweetings:///user?screen_name={username}", // Tweetings
						                       @"http://twitter.com/{username}", // Web fallback,
                                               nil];

    UIApplication *application = [UIApplication sharedApplication];
    for (NSString *candidate in urls) {
        candidate = [candidate stringByReplacingOccurrencesOfString:@"{username}" withString:userName];
        NSURL *url = [NSURL URLWithString:candidate];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            return YES;
        }
    }
    return NO;
}

- (void)followOnTwitter: (PSSpecifier *)specifier {
	NSString *twitterID = [specifier propertyForKey: @"twitterID"];
	[self openTwitterClientForUserName: twitterID];
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
