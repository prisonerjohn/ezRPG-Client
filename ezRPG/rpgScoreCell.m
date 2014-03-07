//
//  rpgScoreCell.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-07.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgScoreCell.h"

@implementation rpgScoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)textFieldValueChanged:(id)sender {
}
@end
