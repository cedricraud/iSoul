//
//  ContactTableViewController.m
//  iSoul
//
//  Created by Cédric Raud on 27/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "ContactTableViewController.h"

@implementation ContactTableViewController

- (id)initWithStyle:(UITableViewStyle)style account:(ISAccount *)a
{
	// Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	if ((self = [super initWithStyle:style]) != nil)
	{
		_account = [a retain];
		[self.tableView setRowHeight: 58];
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.showsVerticalScrollIndicator = NO;
		self.tableView.backgroundColor = [UIColor clearColor];
		//CGRectMake(0, 0, 320, 200);
		
		_addCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		_addCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		_addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
		
		_addPicture = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 34, 40)];
		_addPicture.image = _account.imageLoader.placeholder;
		[_addCell addSubview:_addPicture];
		_addLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 2, 200, 30)];
		_addLabel.text = @"Ajouter";
		_addLabel.alpha = 0.5;
		[_addCell addSubview:_addLabel];
		_addTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 5, 200, 30)];
		_addTextField.borderStyle = UITextBorderStyleRoundedRect;
		_addTextField.delegate = self;
		_addTextField.keyboardType = UIKeyboardTypeASCIICapable;
		_addTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_addTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		_addTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_addTextField.returnKeyType = UIReturnKeyDone;
	}
	
	return self;
}

- (void)dealloc
{
	[_account release];
	[_addCell release];
	[_addPicture release];
	[_addLabel release];
	[_addTextField release];

	[super dealloc];
}

- (void)addButton
{
	_frame = self.tableView.frame;
	[_addLabel removeFromSuperview];
	[_addCell addSubview:_addTextField];
	_addTextField.text = @"";
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	self.tableView.frame = CGRectMake(0, 0, 320, 200);
	_addButton.alpha = 1;
	_addButton.enabled = YES;
	NSIndexPath *index = [NSIndexPath indexPathForRow:[_account.contacts count] inSection:0];
	[self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionBottom];
	[index release];
	[UIView commitAnimations];
	self.tableView.userInteractionEnabled = NO;
	[_addTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	self.tableView.userInteractionEnabled = YES;
	[_addTextField resignFirstResponder];
	[_addTextField removeFromSuperview];
	[_addCell addSubview:_addLabel];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	self.tableView.frame = _frame;
	_addButton.alpha = 0.5;
	_addButton.enabled = NO;
	[UIView commitAnimations];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	if ([_account addContact:[NSString stringWithString:_addTextField.text]])
		[self.tableView reloadData];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self textFieldShouldReturn:textField];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (_account.searching)
	{
		NSUInteger length = [_account.searching length];
		return (length >= 3 && [_account.searching characterAtIndex:(length - 2)] == '_') ? 1 : 0;
	}
	else
		return [_account.contacts count] + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_account.searching)
		return [_account.searchContact updateWithLogin:_account.searching];
	else
		return indexPath.row < [_account.contacts count] ? [[_account.contacts objectAtIndex:indexPath.row] view] : _addCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_account.searching)
	{
		[_account.contacts addObject:[[Contact alloc] initWithLogin:_account.searching imageLoader:_account.imageLoader]];
	}
	else
		if (indexPath.row == [_account.contacts count])
		{
			[self addButton];
		}
		else
		{
			Contact *c = [_account.contacts objectAtIndex:indexPath.row];
			if (c)
			{
				_account.current = c;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/viewConversation" object:self userInfo:nil];
			}
		}
	
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}



/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


@end

