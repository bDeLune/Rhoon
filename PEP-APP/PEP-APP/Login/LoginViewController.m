#import "LoginViewController.h"
#import "AddNewUserOperation.h"

@interface LoginViewController ()<UserListProtoCol, UITabBarControllerDelegate>
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSManagedObject *loggedInUser;
@property (nonatomic,strong) NSOperationQueue *addUserQueue;
@property (nonatomic,strong) UINavigationController *navcontroller;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.addUserQueue = [NSOperationQueue new];
        
        // observe the keypath change to get notified of the end of the parser operation to hide the activity indicator
        [self.addUserQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
           }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    if (self.sharedPSC != nil) {
       // _managedObjectContext = [NSManagedObjectContext new];
         _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    return _managedObjectContext;
}

- (void)viewDidLoad
{
    if ([self.usernameTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
         //mylocalis
        
        UIColor *color = [UIColor lightGrayColor];
        self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Enter a username", nil)] attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    NSLog(@"LOGIN BTN");
    
    [self.loginButton setImage:[UIImage imageNamed:NSLocalizedString(@"Login-Button-Login", nil)] forState:UIControlStateNormal];
    [self.signupButton setImage: [UIImage imageNamed:NSLocalizedString(@"Login-Button-Signup", nil)] forState:UIControlStateNormal];
    
    
    [super viewDidLoad];
    self.userList=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
    self.userList.sharedPSC=self.sharedPSC;
    
    self.navcontroller=[[UINavigationController alloc]initWithRootViewController:self.userList];
    
    [self.navigationController pushViewController:self.userList  animated:YES];
    
    CGRect frame=  [[UIScreen mainScreen] bounds];
    [self.navcontroller.view setFrame:frame];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark -

#pragma mark - KVO
// observe the queue's operationCount, stop activity indicator if there is no operatation ongoing.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.addUserQueue && [keyPath isEqualToString:@"operationCount"]) {
        
        if (self.addUserQueue.operationCount == 0) {
            
    ///        [[GCDQueue mainQueue]queueBlock:^{
    ///            [self.delegate LoginSucceeded:self user:[self user:self.usernameTextField.text]];

    //        }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(User*)user:(NSString*)username
{
    NSString   *name=self.usernameTextField.text;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        User *user=[items objectAtIndex:0];
        return user;
    }
    
    return nil;
}

-(void)login:(id)sender
{
    NSString   *name=self.usernameTextField.text;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    if ([items count]==0) {
        //mylocalis

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:NSLocalizedString(@"That user does not exist. Try signing up instead", nil)] preferredStyle:UIAlertControllerStyleAlert];
        //mylocalis

        UIAlertAction* ok = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)] style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    self.loggedInUser=[items objectAtIndex:0];
    [self.delegate LoginSucceeded:self user:[self user:self.usernameTextField.text]];
}

-(void)signup:(id)sender
{
    NSString   *name=self.usernameTextField.text;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([name length] == 0){
        //mylocalis
        NSString* leftBlankString = [NSString stringWithFormat:NSLocalizedString(@"Field has been left blank", nil)];
        NSString* errorString = [NSString stringWithFormat:NSLocalizedString(@"Error", nil)];
        NSString* okString = [NSString stringWithFormat:NSLocalizedString(@"OK", nil)];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorString message:leftBlankString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:okString style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    
        return;
    }
    
    if ([items count]>0) {

        //localis
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Error", nil)] message:[NSString stringWithFormat:NSLocalizedString(@"Sorry, that user already exists", nil)] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)] style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }else{
        AddNewUserOperation *addUserOperation =[[AddNewUserOperation alloc]initWithData:self.usernameTextField.text sharedPSC:self.sharedPSC];
        
        [self.addUserQueue addOperation:addUserOperation];
        //mylocalis
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success!" message:[NSString stringWithFormat:NSLocalizedString(@"Registration Complete!", nil)] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)] style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(IBAction)goToUsersScreen:(id)sender
{
    NSLog(@"Login screen move to users");
    
    self.userList.sharedPSC=self.sharedPSC ;
    [self.userList getListOfUsers];
    [UIView transitionFromView:self.view toView:self.navcontroller.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
        self.userList.sharedPSC=self.sharedPSC;
        self.userList.delegate=self;
    }];
}

-(void)userListDismissRequest:(UserListViewController *)caller
{
   // [[GCDQueue mainQueue]queueBlock:^{
       [UIView transitionFromView:self.navcontroller.view toView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
            self.userList.sharedPSC=self.sharedPSC;
            self.userList.delegate=self;
        }];
  //  }];
}

@end
