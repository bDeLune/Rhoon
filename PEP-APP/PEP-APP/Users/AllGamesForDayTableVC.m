#import "AllGamesForDayTableVC.h"
#import "Game.h"
#import "HeaderView.h"

@interface AllGamesForDayTableVC ()
{
    NSArray  *data;
}

@property (nonatomic,strong)UIButton  *backButton;
-(void)goBack;
@end

@implementation AllGamesForDayTableVC

-(void)setUSerData:(NSArray*)games
{
    data=games;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    NSLog(@"All Games view did load");
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    //set the frame here
    //self.view.frame = CGRectMake(10, 10, 200, 400);
    UIImage *image = [UIImage imageNamed: @"User-Project.png"];
    [self.backgroundColouredImage setImage:image];
    [self.view addSubview:self.backgroundColouredImage];
    [self.view bringSubviewToFront:self.backgroundColouredImage];
    [self.backgroundColouredImage sendSubviewToBack:self.view];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:237/255.0f alpha:1.0f] ;
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:237/255.0f alpha:1.0f] ;
    
   // self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"DISSAPEARS: go back to users");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
    //[self removeFromParentViewController];
}

- (IBAction)tapGesture:(UITapGestureRecognizer*)gesture
{
    NSLog(@"tap gesture");
    // In your controller, you have the main view, which is the view
    // on which you added your UIViews.  You need that view.  Add it as an IBOutlet
    // You should know how to do that...  ctrl-drag to the class INTERFACE source.
    // Assuming you name it "galleryView"
    
    // Take the tap location from the gesture, and make sure it is in the
    // coordinate space of the view.  Loop through all the imageViews and
    // find the one that contains the point where the finger was taped.
    // Then, "remove" that one from its superview...
    CGPoint tapLocation = [gesture locationInView: self.view];
    for (UIImageView *imageView in self.view.subviews) {
        NSLog(@"imageView");
        if (CGRectContainsPoint(imageView.frame, tapLocation)) {
            NSLog(@"BACK BUTTON: go back to users");
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.view removeFromSuperview];
        }
    }

}

- (void)goBack:(UIButton *)sender  {
    NSLog(@"go back to users");
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Game  *game=[data objectAtIndex:indexPath.row];
    NSDate  *date=game.gameDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM y H:m:s"];
    NSString *attemptDateString = [dateFormat stringFromDate:date];
    int gameType=[game.gameType intValue];
    
    NSString  *typeString;
    if (gameType==0) {
        typeString=@"Balloon Game";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Balloons :%@",game.achievedBalloons];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Balloons :%@",game.requiredBalloons];
    }else if (gameType==1)
    {
        typeString=@"Image Game";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Breath Length :%f",[game.achievedBreathLength floatValue]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Breath Length :%f",[game.requiredBreathLength floatValue]];
    }else if (gameType==2)
    {
        typeString=@"Duo Game";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Breath Length :%f",[game.achievedBreathLength floatValue]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Breath Length :%f",[game.requiredBreathLength floatValue]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Balloons :%@",game.achievedBalloons];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Balloons :%@",game.requiredBalloons];
    }
    
    cell.textLabel.text=[NSString stringWithFormat:@"%@  %@",typeString,attemptDateString];

    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView  *header=[[HeaderView alloc]initWithFrame:CGRectMake(30, 180, 670, 20)];
    header.section=section;
    //header.user=[self.userList objectAtIndex:section];
    //header.delegate=self;
    [header build];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame=CGRectMake(220, 225, 180, 0);
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(tapGesture:) forControlEvents:UIControlEventAllEvents];

    //[self.view addSubview:self.backButton];
   // [self.view bringSubviewToFront:self.backButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.backButton addGestureRecognizer:tap];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

@end
