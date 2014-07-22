#import "ParseStarterProjectViewController.h"
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>

@implementation ParseStarterProjectViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pullKontakts:(id)sender {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        //[self addPetToContacts:sender];
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    //4
                    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                    [cantAddContactAlert show];
                    return;
                }
                //5
               // [self addPetToContacts:sender];
            });
        });
    }

    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    
    
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    for( id record in allContacts) {
        
        //NSString
        ABRecordRef thisContact = (__bridge CFDataRef)record;
        NSString *name = (__bridge NSString *)(ABRecordCopyCompositeName(thisContact));
        
        NSString* phone = nil;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(thisContact,
                                                        
                                                         kABPersonPhoneProperty);
        
        PFObject *testObject =  [PFObject objectWithClassName:@"ContactObject"];
        NSNull *null = [NSNull null] ;
        
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            phone = (__bridge_transfer NSString*)
            ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            
            
        } else {
            phone = @"[None]"; }
        

        
        if (name != nil) {
             testObject[@"name"] = name;
            
        } else {
             testObject[@"name"] = null;
        }
        
        if (phone != nil) {
          
                testObject[@"tel"] = phone;
          
            } else {
                testObject[@"tel"] = null;
              }
        
        
        [testObject saveInBackground];
          NSLog(@"name is: %@ Phone: %@ ", name, phone);
        
    }

    
}


@end
