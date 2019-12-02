-- postgre in ohdsi-virtualBox

select count(1) from public.concept;
select count(1) from public.person;
select count(1) from public.observation;
select count(1) from public.observation_period;
select count(1) from public.drug_cost;

select count(1) from public.care_site;

select * from information_schema.columns where table_catalog = 'ohdsi' and table_schema = 'public' order by table_name, ordinal_position;
select 'select '''||table_name||''' t_name, count(1) cnt from public.'||table_name||' union all' sqls
  from information_schema.tables 
 where table_catalog = 'ohdsi' and table_schema = 'public' order by table_name;
-- select 'attribute_definition' t_name, count(1) cnt from attribute_definition union all
select 'attribute_definition' t_name, count(1) cnt from public.attribute_definition union all
select 'care_site' t_name, count(1) cnt from public.care_site union all
select 'cdm_source' t_name, count(1) cnt from public.cdm_source union all
select 'cohort' t_name, count(1) cnt from public.cohort union all
select 'cohort_attribute' t_name, count(1) cnt from public.cohort_attribute union all
select 'cohort_definition' t_name, count(1) cnt from public.cohort_definition union all
select 'concept' t_name, count(1) cnt from public.concept union all
select 'concept_ancestor' t_name, count(1) cnt from public.concept_ancestor union all
select 'concept_class' t_name, count(1) cnt from public.concept_class union all
select 'concept_relationship' t_name, count(1) cnt from public.concept_relationship union all
select 'concept_synonym' t_name, count(1) cnt from public.concept_synonym union all
select 'condition_era' t_name, count(1) cnt from public.condition_era union all
select 'condition_occurrence' t_name, count(1) cnt from public.condition_occurrence union all
select 'death' t_name, count(1) cnt from public.death union all
select 'device_cost' t_name, count(1) cnt from public.device_cost union all
select 'device_exposure' t_name, count(1) cnt from public.device_exposure union all
select 'domain' t_name, count(1) cnt from public.domain union all
select 'dose_era' t_name, count(1) cnt from public.dose_era union all
select 'drug_cost' t_name, count(1) cnt from public.drug_cost union all
select 'drug_era' t_name, count(1) cnt from public.drug_era union all
select 'drug_exposure' t_name, count(1) cnt from public.drug_exposure union all
select 'drug_strength' t_name, count(1) cnt from public.drug_strength union all
select 'fact_relationship' t_name, count(1) cnt from public.fact_relationship union all
select 'location' t_name, count(1) cnt from public.location union all
select 'measurement' t_name, count(1) cnt from public.measurement union all
select 'note' t_name, count(1) cnt from public.note union all
select 'observation' t_name, count(1) cnt from public.observation union all
select 'observation_period' t_name, count(1) cnt from public.observation_period union all
select 'payer_plan_period' t_name, count(1) cnt from public.payer_plan_period union all
select 'person' t_name, count(1) cnt from public.person union all
select 'procedure_cost' t_name, count(1) cnt from public.procedure_cost union all
select 'procedure_occurrence' t_name, count(1) cnt from public.procedure_occurrence union all
select 'provider' t_name, count(1) cnt from public.provider union all
select 'relationship' t_name, count(1) cnt from public.relationship union all
select 'source_to_concept_map' t_name, count(1) cnt from public.source_to_concept_map union all
select 'specimen' t_name, count(1) cnt from public.specimen union all
select 'visit_cost' t_name, count(1) cnt from public.visit_cost union all
select 'visit_occurrence' t_name, count(1) cnt from public.visit_occurrence union all
select 'vocabulary' t_name, count(1) cnt from public.vocabulary;

/* attribute_definition	0
care_site	239158
cdm_source	0
cohort	0
cohort_attribute	0
cohort_definition	0
concept	3316702
concept_ancestor	46285120
concept_class	277
concept_relationship	18450688
concept_synonym	4898065
condition_era	11168043
condition_occurrence	14455993
death	5461
device_cost	0
device_exposure	224505
domain	39
dose_era	0
drug_cost	5552421
drug_era	5832827
drug_exposure	6303388
drug_strength	546735
fact_relationship	0
location	3088
measurement	3704839
note	0
observation	1876834
observation_period	104891
payer_plan_period	389231
person	116352
procedure_cost	31821927
procedure_occurrence	13926771
provider	635456
relationship	388
source_to_concept_map	0
specimen	0
visit_cost	0
visit_occurrence	5579542
vocabulary	64 */


select * from public.observation_period;
select * from public.concept;
select * from public.concept where concept_id = 44814722;
select * from public.vocabulary;
select * from public.domain;
select * from public.person limit 100;
-- person_id,gender_concept_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,race_concept_id,ethnicity_concept_id,location_id,provider_id,care_site_id,person_source_value,gender_source_value,gender_source_concept_id,race_source_value,race_source_concept_id,ethnicity_source_value,ethnicity_source_concept_id
-- gender_concept 8507 8532
-- race_com

select * from public.concept where concept_id in (8507,8532) ;
select * from public.source_to_concept_map;
select coun

select * from public.concept 
44814722
ㅈ3ㄷ4
select domain_id, vocabulary_id, count(1) cnt from public.concept group by domain_id, vocabulary_id order by 1,2;
select * from public.concept where domain_id = 'Gender';

select * from public.cohort;
