//
//  ViewController.m
//  Dump1090 Mac Server
//
//  Created by Maxwell Swadling on 26/1/19.
//  Copyright © 2019 Maxwell Swadling. All rights reserved.
//

#import "ViewController.h"

#define NOUSB @"No USB Device"

@implementation ViewController {
    NSString *serverPath;
    __weak IBOutlet NSTextField *portField;
    __weak IBOutlet NSTextField *statusField;
    __weak IBOutlet NSButton *startButton;
    __unsafe_unretained IBOutlet NSTextView *consoleView;
    BOOL serverRunning;
    NSNetService *service;
    NSTask *task;
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
    if (!serverRunning) {
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
    task = [[NSTask alloc] init];
    task.executableURL = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"dump1090-mac"];
    task.arguments = @[];
    task.environment = @{};
    NSPipe *taskOut = [NSPipe pipe];
    NSPipe *errOut = [NSPipe pipe];

    [taskOut.fileHandleForReading setReadabilityHandler:^(NSFileHandle * _Nonnull fh) {
        NSData *d = [fh availableData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self appendConsole:d];
        });
    }];
    [errOut.fileHandleForReading setReadabilityHandler:^(NSFileHandle * _Nonnull fh) {
        NSData *d = [fh availableData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self appendConsole:d];
        });
    }];
    consoleView.string = @"";
    task.standardOutput = taskOut;
    task.standardError = errOut;
    [task setTerminationHandler:^(NSTask * _Nonnull task) {
        taskOut.fileHandleForReading.readabilityHandler = nil;
        errOut.fileHandleForReading.readabilityHandler = nil;
        NSData *finalOut = [taskOut.fileHandleForReading readDataToEndOfFile];
        NSData *finalErr = [errOut.fileHandleForReading readDataToEndOfFile];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self appendConsole:finalOut];
            [self appendConsole:finalErr];
            [self setServerState:false];
        });
    }];
    
    NSError *e;
    if (![task launchAndReturnError:&e]) {
        consoleView.string = [NSString stringWithFormat:@"failed to launch dump1090\n%@", e.localizedDescription];
    } else {
        [self setServerState:true];
    }
}

- (void)appendConsole:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str hasPrefix:@"No supported RTLSDR devices found."]) {
        statusField.stringValue = NOUSB;
    }
    consoleView.string = [consoleView.string stringByAppendingString:str];
    [consoleView scrollToEndOfDocument:nil];
}

- (void)killServer {
    [task interrupt];
    usleep(10);
    if ([task isRunning]) {
        [task terminate];
    }
    task = nil;
    [self setServerState:false];
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
