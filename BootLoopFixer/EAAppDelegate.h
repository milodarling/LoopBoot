//
//  EAAppDelegate.h
//  BootLoopFixer
//
//  Created by Ethan Arbuckle on 10/22/13.
//
//

#import <Cocoa/Cocoa.h>
#import "MobileDevice.h"

@interface EAAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextField *statusLabel;
@property (unsafe_unretained) IBOutlet NSButton *fixButton;
- (IBAction)fixDevice:(id)sender;
@end

typedef void (*afc_iter_callback) (struct afc_connection *, char *, char *);
