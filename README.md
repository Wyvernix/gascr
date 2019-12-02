# README

This web application is available at [gascr.herokuapp.com](https://gascr.herokuapp.com/). All data is returned in JSON format.

Program will calculate weekly trend as either positive or negative, with some intensity. The day of week effect is also available.

## Configuration ##

1. Set environment variable `EIA_KEY` via access from [EIA's OpenData API](https://www.eia.gov/opendata/qb.php)

## Database ##

1. Run `rails db:migrate`
2. Access page `http://hostname/trends` will update

## Deployment instructions ##

1. You may need to change the production database in file `gascr/config/database.yml`
