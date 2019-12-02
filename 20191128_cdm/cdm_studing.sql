-- mariadb (columnstore)

select * from ohdsi_cdm.concept where concept_name like '%male%';

select * from ohdsi_cdm.person limit 10;

select * from ohdsi_cdm.location limit 100;

-- person 테이블의 concept_id 풀어주
select person_id, year_of_birth, month_of_birth, day_of_birth
      ,gender_concept_id, gender_source_concept_id, gender_source_value, c1.concept_name gender_name
      ,race_concept_id, race_source_concept_id, race_source_value, c2.concept_name race_name
      ,ethnicity_concept_id, ethnicity_source_concept_id, ethnicity_source_value, c3.concept_name ethnicity_name
      ,p.location_id, l.state, l.county
  from ohdsi_cdm.person p
       left join ohdsi_cdm.concept c1 on p.gender_concept_id = c1.concept_id
       left join ohdsi_cdm.concept c2 on p.race_concept_id = c2.concept_id
       left join ohdsi_cdm.concept c3 on p.ethnicity_concept_id = c3.concept_id
       left join ohdsi_cdm.location l on p.location_id = l.location_id
 limit 100;

