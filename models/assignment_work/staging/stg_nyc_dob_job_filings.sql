-- Clean and standardize job filing data
-- One row per job filing

WITH source AS (
   SELECT * FROM {{ source('raw', 'source_nyc_dob_job_apps') }}
), -- Easier to refer to the dbt reference to a long name table this way

cleaned AS (
   SELECT
       -- Get all columns from source, except ones we're transforming below
       -- To do cleaning on them or explicitly cast them as types just in case
       * EXCEPT (
           job_filing_number,
           filing_status,
           filing_date,
           current_status_date,
           first_permit_date,
           approved_date,
           signoff_date,
           borough,
           council_district,
           zip,
           job_type,
           building_type,
           applicant_first_name,
           applicant_middle_initial,
           applicant_last_name,
           applicant_professional_title,
           applicant_license,
           owner_s_business_name,
           city,
           state,
           filing_representative_first_name,
           filing_representative_middle_initial,
           filing_representative_last_name,
           filing_representative_business_name,
           filing_representative_street_name,
           filing_representative_city,
           filing_representative_state,
           filing_representative_zip,
           sprinkler_work_type,
           plumbing_work_type,
           boiler_equipment_work_type_,
           standpipe,
           antenna,
           curb_cut,
           sign,
           fence,
           scaffold,
           shed,
           earth_work_work_type_,
           foundation_work_type_,
           general_construction_work_type_,
           mechanical_systems_work_type_,
           place_of_assembly_work_type_,
           structural_work_type_,
           support_of_excavation_work_type_,
           sidewalk_shed_work_type_,
           temporary_place_of_assembly_work_type_,
           initial_cost,
           total_construction_floor_area,
           existing_stories,
           proposed_no_of_stories,
           existing_dwelling_units,
           proposed_dwelling_units,
           latitude,
           longitude,
           bbl,
           bin,
           block,
           lot,
           house_no,
           street_name,
           census_tract,
           nta,
       ),

       -- Identifiers/Filing Status Detials
       CAST(job_filing_number AS STRING) AS job_filing_number,
       CAST(filing_status AS STRING) AS filing_status,

       -- Date/Time
       CAST(filing_date AS TIMESTAMP) AS filing_date,
       CAST(current_status_date AS TIMESTAMP) AS current_status_date,
       CAST(first_permit_date AS TIMESTAMP) AS first_permit_date,
       CAST(approved_date AS TIMESTAMP) AS approved_date,
       CAST(signoff_date AS TIMESTAMP) AS signoff_date,

       -- Location - Clean applicant zip code, handling several common zip code data problems
       CASE
           WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(zip AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 9 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(zip AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(zip AS STRING)
           ELSE NULL
       END AS zip,
    
       -- Location - standardized borough, just in case
       CASE
           WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
           WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
           WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
           WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
           WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
           ELSE 'UNKNOWN or CITYWIDE'
       END AS borough,

       -- Location Details
       CAST(borough AS STRING) AS borough,
       CAST(council_district AS STRING) AS council_district,
       CAST(zip AS STRING) AS zip,

       -- Job Type Details
       CAST(job_type AS STRING) AS job_type,
       CAST(building_type AS STRING) AS building_type,

       -- Applicant Details
       CAST(applicant_first_name AS STRING) AS applicant_first_name,
       CAST(applicant_middle_initial AS STRING) AS applicant_middle_initial,
       CAST(applicant_last_name AS STRING) AS applicant_last_name,
       CAST(applicant_professional_title AS STRING) AS applicant_professional_title,
       CAST(applicant_license AS STRING) AS applicant_license,

       -- Owner Details
       CAST(owner_s_business_name AS STRING) AS owner_s_business_name,
       CAST(city AS STRING) AS city,
       CAST(state AS STRING) AS state,
       CAST(zip AS STRING) AS zip,

       -- Filing Rep Details
       CAST(filing_representative_first_name AS STRING) AS filing_representative_first_name,
       CAST(filing_representative_middle_initial AS STRING) AS filing_representative_middle_initial,
       CAST(filing_representative_last_name AS STRING) AS filing_representative_last_name,
       CAST(filing_representative_business_name AS STRING) AS filing_representative_business_name,
       CAST(filing_representative_street_name AS STRING) AS filing_representative_street_name,
       CAST(filing_representative_city AS STRING) AS filing_representative_city,
       CAST(filing_representative_state AS STRING) AS filing_representative_state,
       CAST(filing_representative_zip AS STRING) AS filing_representative_zip,

       -- Work Type Details
       CAST(sprinkler_work_type AS BOOLEAN) AS sprinkler_work_type,
       CAST(plumbing_work_type AS BOOLEAN) AS plumbing_work_type,
       CAST(boiler_equipment_work_type_ AS BOOLEAN) AS boiler_equipment_work_type_,
       CAST(standpipe AS BOOLEAN) AS standpipe,
       CAST(antenna AS BOOLEAN) AS antenna,
       CAST(curb_cut AS BOOLEAN) AS curb_cut,
       CAST(sign AS BOOLEAN) AS sign,
       CAST(fence AS BOOLEAN) AS fence,
       CAST(scaffold AS BOOLEAN) AS scaffold,
       CAST(shed AS BOOLEAN) AS shed,
       CAST(earth_work_work_type_ AS BOOLEAN) AS earth_work_work_type_,
       CAST(foundation_work_type_ AS BOOLEAN) AS foundation_work_type_,
       CAST(general_construction_work_type_ AS BOOLEAN) AS general_construction_work_type_,
       CAST(mechanical_systems_work_type_ AS BOOLEAN) AS mechanical_systems_work_type_,
       CAST(place_of_assembly_work_type_ AS BOOLEAN) AS place_of_assembly_work_type_,
       CAST(structural_work_type_ AS BOOLEAN) AS structural_work_type_,
       CAST(support_of_excavation_work_type_ AS BOOLEAN) AS support_of_excavation_work_type_,
       CAST(sidewalk_shed_work_type_ AS BOOLEAN) AS sidewalk_shed_work_type_,
       CAST(temporary_place_of_assembly_work_type_ AS BOOLEAN) AS temporary_place_of_assembly_work_type_,

       -- High Cardinality Details
       CAST(initial_cost AS DECIMAL) AS initial_cost,
       CAST(total_construction_floor_area AS DECIMAL) AS total_construction_floor_area,
       CAST(existing_stories AS INT) AS existing_stories,
       CAST(proposed_no_of_stories AS INT) AS proposed_no_of_stories,
       CAST(existing_dwelling_units AS INT) AS existing_dwelling_units,
       CAST(proposed_dwelling_units AS INT) AS proposed_dwelling_units,
       CAST(latitude AS DECIMAL) AS latitude,
       CAST(longitude AS DECIMAL) AS longitude,
       CAST(bbl AS STRING) AS bbl,
       CAST(bin AS STRING) AS bin,
       CAST(block AS STRING) AS block,
       CAST(lot AS STRING) AS lot,
       CAST(house_no AS STRING) AS house_no,
       CAST(street_name AS STRING) AS street_name,
       CAST(census_tract AS STRING) AS census_tract,
       CAST(nta AS STRING) AS nta,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   -- Filters
   WHERE job_filing_number IS NOT NULL
   AND filing_date IS NOT NULL
   AND CAST(filing_date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 YEAR)
   AND borough IS NOT NULL

   -- Deduplicate
   QUALIFY ROW_NUMBER() OVER (PARTITION BY job_filing_number ORDER BY filing_date DESC) = 1
)

SELECT * FROM cleaned
-- All should be part of this table after running: stg_nyc_311_dot
