-- mariadb (columnstore)

select * from ohdsi_cdm.concept where concept_name like '%male%';

select * from ohdsi_cdm.person limit 10;

select * from ohdsi_cdm.location limit 100;

-- person 테이블의 concept_id 를 name 으로 풀어주기
with base as (
select person_id, year_of_birth, month_of_birth, day_of_birth
      ,gender_concept_id, gender_source_concept_id, gender_source_value, c1.concept_name gender_name
      ,race_concept_id, race_source_concept_id, race_source_value, c2.concept_name race_name
      ,ethnicity_concept_id, ethnicity_source_concept_id, ethnicity_source_value, c3.concept_name ethnicity_name
      ,p.location_id, l.state, l.county
      -- provider_id, care_site_id 는 모두 null 
  from ohdsi_cdm.person p
       left join ohdsi_cdm.concept c1 on p.gender_concept_id = c1.concept_id
       left join ohdsi_cdm.concept c2 on p.race_concept_id = c2.concept_id
       left join ohdsi_cdm.concept c3 on p.ethnicity_concept_id = c3.concept_id
       left join ohdsi_cdm.location l on p.location_id = l.location_id
)
-- select * from base limit 100;
select gender_name, race_name, ethnicity_name, count(1) from base group by gender_name, race_name, ethnicity_name order by 3,2,1;
/*
FEMALE	Black or African American	Not Hispanic or Latino	6935
FEMALE	No matching concept	Hispanic or Latino	1472
FEMALE	No matching concept	Not Hispanic or Latino	2649
FEMALE	White	Not Hispanic or Latino	53291
MALE	Black or African American	Not Hispanic or Latino	5408
MALE	No matching concept	Hispanic or Latino	1257
MALE	No matching concept	Not Hispanic or Latino	2282
MALE	White	Not Hispanic or Latino	43058 */



select * from ohdsi_cdm.person where provider_id is not null; -- 0
select * from ohdsi_cdm.person where care_site_id is not null; -- 0
select * from ohdsi_cdm.provider;

-- -----------------------------------------------------
-- care_site 2번 load 된 것 처
select count(1) from ohdsi_cdm.care_site ;
rename table care_site to care_site_dup;
create table care_cite as select distinct * from care_site_dup;

-- -----------------------------------------------------
-- concept

select * from ohdsi_cdm.concept ;
concept_id	concept_name	domain_id	vocabulary_id	concept_class_id	standard_concept	concept_code	valid_start_date	valid_end_date	invalid_reason

select * from ohdsi_cdm.vocabulary; 
select * from ohdsi_cdm.concept where concept_id = 44819232;
select * from ohdsi_cdm.concept where vocabulary_id = 'Vocabulary';

select     domain_id, vocabulary_id, concept_class_id, standard_concept, count(1) cnt from ohdsi_cdm.concept 
 group by  domain_id, vocabulary_id, concept_class_id, standard_concept  order by 1,2,3;



