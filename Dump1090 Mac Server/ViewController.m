//
//  ViewController.m
//  Dump1090 Mac Server
//
//  Created by Maxwell Swadling on 26/1/19.
//  Copyright © 2019 Maxwell Swadling. All rights reserved.
//

#import "ViewController.h"
#import "Dump1090API.h"

#define NOUSB @"No USB Device"

@interface ViewController ()
- (void)appendConsole:(NSData *)data;
@end

static void consoleOutput(const char *buf, size_t len, void *ctx) {
    NSData *d = [NSData dataWithBytes:buf length:len];
    __weak ViewController *weakSelf = (__bridge ViewController *)ctx;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf appendConsole:d];
    });
}

@implementation ViewController {
    NSString *serverPath;
    __weak IBOutlet NSTextField *portField;
    __weak IBOutlet NSTextField *statusField;
    __weak IBOutlet NSButton *startButton;
    __unsafe_unretained IBOutlet NSTextView *consoleView;
    BOOL serverRunning;
    NSNetService *service;
    NSThread *serverThread;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    serverRunning = false;
    portField.stringValue = @"30005";
    service = [[NSNetService alloc] initWithDomain:@"" type:@"_maxplanes._tcp" name:@"" port:30005];
    [service publish];
    // FIXME: make this a NSUserDefault that is persisted?? I can do that with bindings i believe.
}

- (IBAction)startServer:(id)sender {
    if (!serverThread) {
        [self launchServer];
    } else {
        [self killServer];
    }
}

- (IBAction)toggleNetworkDiscovery:(id)sender {
    NSButton *box = sender;
    if (box.state == NSControlStateValueOn) {
        [service publish];
        
    } else {
        [service stop];
    }
    
}

- (void)launchServer {
    consoleView.string = @"";
    dump1090_set_output_handler(consoleOutput, (__bridge void *)self);

    __weak ViewController *weakSelf = self;
    serverThread = [[NSThread alloc] initWithBlock:^{
        char *argv[] = {"dump1090", "--net", NULL};
        dump1090_main(2, argv);
        // Queued after any console output from the run, so it lands last
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf serverDidFinish];
        });
    }];
    serverThread.name = @"dump1090";
    // dump1090 was written to run on a process main thread
    serverThread.stackSize = 8 * 1024 * 1024;
    [serverThread start];
    [self setServerState:true];
}

- (void)serverDidFinish {
    serverThread = nil;
    startButton.enabled = YES;
    [self setServerState:false];
}

- (void)appendConsole:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (str == nil) {
        return;
    }
    if ([str hasPrefix:@"No supported RTLSDR devices found."]) {
        statusField.stringValue = NOUSB;
    }
    consoleView.string = [consoleView.string stringByAppendingString:str];
    [consoleView scrollToEndOfDocument:nil];
}

- (void)killServer {
    // serverDidFinish re-enables the button once dump1090 has shut down
    startButton.enabled = NO;
    statusField.stringValue = @"Stopping...";
    dump1090_stop();
}

- (void)setServerState:(BOOL)running {
    serverRunning = running;
    startButton.title = serverRunning ? @"Stop" : @"Start";
    if (running || ![statusField.stringValue isEqualToString:NOUSB]) {
        statusField.stringValue = running ? @"Running..." : @"Offline";
        
    }
}

- (void)showAcknowledgements:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[[NSBundle mainBundle] URLForResource:@"Acknowledgements" withExtension:@"rtf"]];
}

@end
