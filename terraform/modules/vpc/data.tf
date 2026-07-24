# DATA SOURCES read existing information from AWS instead of creating
# anything. This one asks the current region which AZs are usable, so the
# module works in any region without hardcoding AZ names.
data "aws_availability_zones" "available" {
  state = "available"
}
