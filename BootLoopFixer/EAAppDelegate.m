//
//  EAAppDelegate.m
//  BootLoopFixer
//
//  Created by Ethan Arbuckle on 10/22/13.
//
//

#import "EAAppDelegate.h"

am_device *device;
@implementation EAAppDelegate

void BLFDeviceNotificationReceived(am_device_notification_callback_info *info, void *context) {
	[(EAAppDelegate *)[NSApplication sharedApplication].delegate deviceNotificationReceivedWithInfo:info];
}

void Disconnect(am_device_notification_callback_info *info, void *context) {
	[(EAAppDelegate *)[NSApplication sharedApplication].delegate deviceNotificationReceivedWithInfo : info];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	am_device_notification *deviceNotification;
	AMDeviceNotificationSubscribe(BLFDeviceNotificationReceived, 0, 0, NULL, &deviceNotification);
}

- (void)deviceNotificationReceivedWithInfo:(am_device_notification_callback_info *)info {
	if (info->msg == ADNCI_MSG_CONNECTED) {
        device = info->dev;
		if (AMDeviceConnect(device) == MDERR_OK && AMDeviceIsPaired(device) && AMDeviceValidatePairing(device) == MDERR_OK && AMDeviceStartSession(device) == MDERR_OK) {
			AMDeviceRetain(device);
            [_fixButton setEnabled:YES];
			_statusLabel.stringValue = [NSString stringWithFormat:@"Connected Device: %@", AMDeviceCopyValue(device, 0, CFSTR("DeviceName"))];
		}
	}
    else if (info->msg == ADNCI_MSG_DISCONNECTED) {
        [_fixButton setEnabled:NO];
        _statusLabel.stringValue = @"No Device Detected!";
    }
}

- (IBAction)fixDevice:(id)sender {
    afc_connection *afc;
    service_conn_t afc_conn;
    AMDeviceStartService(device, CFSTR("com.apple.afc2"), &afc_conn, NULL);
    AFCConnectionOpen(afc_conn, 0, &afc);
    afc_cycle_shit(afc, "/var/mobile/Library/Caches/");
    AMDeviceRelease(device);
    AMDeviceStopSession(device);
    AMDeviceDisconnect(device);
    _statusLabel.stringValue = @"Done! Now do a hard reset!";
}

void afc_iter_dir(struct afc_connection *conn, char *path, afc_iter_callback callback) {
	struct afc_directory *dir;
	char *dirent;
	if (AFCDirectoryOpen(conn, path, &dir)) return;
	for (;; ) {
		AFCDirectoryRead(conn, dir, &dirent);
		if (!dirent) break;
		if (strcmp(dirent, ".") == 0 || strcmp(dirent, "..") == 0) continue;
		callback(conn, path, dirent);
	}
}

void afc_cycle_shit(struct afc_connection *conn, char *path) {
	afc_iter_dir(conn, path, (afc_iter_callback)afc_cycle_shit_callback);
}



void afc_cycle_shit_callback(struct afc_connection *conn, char *path, char *dirent) {
    if ([[NSString stringWithUTF8String:dirent] rangeOfString:@"LaunchServices"].location != NSNotFound) {
        NSString *fileToDelete = [NSString stringWithFormat:@"%s%s", path, dirent];
        AFCRemovePath(conn, [fileToDelete UTF8String]);
    }
    else if ([[NSString stringWithUTF8String:dirent] rangeOfString:@"com.apple.mobile.installation.plist"].location != NSNotFound) {
        NSString *fileToDelete = [NSString stringWithFormat:@"%s%s", path, dirent];
        AFCRemovePath(conn, [fileToDelete UTF8String]);
    }
}

- (IBAction)openHelp:(id)sender {
NSURL *url = [NSURL URLWithString:@"http://www.jailbreakqa.com/faq#32535"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)askReddit:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.reddit.com/r/jailbreak/submit?selftext=true"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}
@end
