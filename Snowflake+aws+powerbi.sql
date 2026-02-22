CREATE OR REPLACE STORAGE INTEGRATION PBI_INTEGRATION
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::942114770075:role/powerbi.role'
STORAGE_ALLOWED_LOCATIONS = ('s3://hari-powerbi-project/')
COMMENT = 'Optional Comment';

desc integration PBI_INTEGRATION;

create database POWER_BI;
create schema PBI_Data;

create table PBI_Dataset(
Year int, Location string, Area int, Rainfall float
,Temperature float, Soil_type string,
Irrigation string, yeilds int, Humidity float,
Crops string, Price int, Season string
);

select * from PBI_Dataset;

create stage POWER_BI.PBI_Data.pbi_stage
url = 's3://hari-powerbi-project'
storage_integration = PBI_INTEGRATION;

copy into PBI_Dataset
from @pbi_stage
file_format = (type=csv field_delimiter=',' skip_header=1)
on_error = 'continue';

select * from PBI_Dataset;

create table agriculture as
select * from pbi_dataset;

select * from agriculture;

update agriculture set rainfall = 1.1*rainfall;

update agriculture set area = 0.9*area;

// Year 2004 & 2009 - Y1
// Year 2010 & 2015 - Y2
// Year 2016 & 2019 - Y3

alter table agriculture
add Year_group string;

select * from agriculture;

update agriculture set Year_group = 'Y1' where Year >=2004 and Year <=2009;
update agriculture set Year_group = 'Y2' where Year >=2010 and Year <=2015;
update agriculture set Year_group = 'Y3' where Year >=2016 and Year <=2019;

select count(*),year_group
from agriculture
group by year_group;

//Add column rainfll_groups based on low, medium and high
//Min 255 Max 4103

// rain fall 255 & 1200 then - Low
// rain fall 1200 & 2800 then - Medium
// rain fall 2800 & 4103 then - High

alter table agriculture 
add rainfall_groups string;

select * from agriculture;

//1st update
update agriculture set rainfall_groups = 'Low'
where rainfall >= 255 and rainfall < 1200;

update agriculture set rainfall_groups = 'Medium'
where rainfall >= 1200 and rainfall < 2800;

update agriculture set rainfall_groups = 'High'
where rainfall >= 2800;

select * from agriculture;
