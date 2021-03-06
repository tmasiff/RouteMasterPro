//
//  TripDetailsViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "TripDetailsViewController.h"
#import "MapCell.h"
#import "constants.h"

enum {
    SectionDetails = 0,
    SectionMap,
    SectionCount
};

enum {
    RowDetailsDistance = 0,
    RowDetailsAvgSpeed,
    RowDetailsDuration,
    RowDetailsStart,
    RowDetailsStop,
    RowDetailsPoints,
    RowDetailsCount
};

@interface TripDetailsViewController () {
    NSDateFormatter *_dateFormatter;
    MapCell *_mapCell;
}
@end

@implementation TripDetailsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Trip Details";

        _trip = nil;

        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;

        _mapCell = nil;
    }
    return self;
}

- (void)dealloc {
    [_trip release];
    [_dateFormatter release];
    [_mapCell release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionDetails:
            return RowDetailsCount;

        case SectionMap:
            return 1;

        default:
            break;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionMap:
            return 300;

        default:
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case SectionDetails: {
            cell = [self tableView:tableView detailCellForRow:indexPath.row];
            break;
        }

        case SectionMap: {
            cell = [self tableView:tableView mapCellForRow:indexPath.row];
            break;
        }

        default:
            break;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView detailCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"DetailCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switch (row) {
        case RowDetailsDistance: {
            cell.textLabel.text = @"Distance";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f mi", [_trip distance] * METER_TO_MILES];
            break;
        }

        case RowDetailsAvgSpeed: {
            cell.textLabel.text = @"Avg Speed";

            NSTimeInterval duration = [_trip duration];
            if (duration == 0.0) {
                cell.detailTextLabel.text = @"Unknown";
            } else {
                double avgSpeed = [_trip distance] / duration;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d MPH", (int)round(avgSpeed * MPS_TO_MIPH)];
            }
            break;
        }

        case RowDetailsDuration: {
            cell.textLabel.text = @"Duration";

            NSInteger duration = (NSInteger)[_trip duration];
            NSInteger hour = duration / 3600;
            NSInteger min = (duration / 60) % 60;
            NSInteger sec = duration % 60;

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
            break;
        }

        case RowDetailsStart: {
            cell.textLabel.text = @"Start";
            cell.detailTextLabel.text = [_dateFormatter stringFromDate:[_trip firstLocation].timestamp];
            break;
        }

        case RowDetailsStop: {
            cell.textLabel.text = @"Stop";
            cell.detailTextLabel.text = [_dateFormatter stringFromDate:[_trip lastLocation].timestamp];
            break;
        }

        case RowDetailsPoints: {
            cell.textLabel.text = @"Points";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [_trip.locations count]];
            break;
        }

        default:
            break;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView mapCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"MapCell";

    if (_mapCell == nil) {
        _mapCell = [[MapCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        _mapCell.selectionStyle = UITableViewCellSelectionStyleNone;

        MKPolyline *polyline = [_trip mapAnnotation];
        [_mapCell.mapView addOverlay:polyline];

        MKCoordinateRegion coordinateRegion = MKCoordinateRegionForMapRect(polyline.boundingMapRect);
        coordinateRegion.span.latitudeDelta += 0.01;
        coordinateRegion.span.longitudeDelta += 0.01;
        [_mapCell.mapView setRegion:coordinateRegion animated:NO];
    }

    return _mapCell;
}

@end
