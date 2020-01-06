-- mariadb (columnstore)

-- 테이블 목록
select * from information_schema.TABLES t 
 where TABLE_SCHEMA = 'ohdsi_cdm'
order by table_name;

select concat('select ''',table_name,''' t_nm, count(1) cnt from ',table_name,' union all')
 from information_schema.TABLES t 
 where TABLE_SCHEMA = 'ohdsi_cdm'
order by table_name;
-- --

-- -------------------------------------------------
-- 테이블 목록 ohdsi_cdm53_synthea
select * from information_schema.TABLES t 
 where TABLE_SCHEMA = 'ohdsi_cdm53_synthea'
order by table_name;

select concat('select ''',table_name,''' t_nm, count(1) cnt from ',table_name,' union all')
 from information_schema.TABLES t 
 where TABLE_SCHEMA = 'ohdsi_cdm'
order by table_name;

select TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION ODR
      ,case when IS_NULLABLE = 'YES' then 'No' when IS_NULLABLE = 'NO' then 'Yes' else '검토필' end REQUIERD
      ,upper(COLUMN_TYPE) DATA_TYPE
  from information_schema.COLUMNS t 
 where TABLE_SCHEMA = 'ohdsi_cdm53_synthea'
order by table_name, ORDINAL_POSITION;
-- --

select 'aa' t_nm, count(1) cnt from care_site;

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

-- concept.concept_id 가 실제 데이터에서 사용되는 코드값
-- concept.concept_name 이 코드값명  --> 이것만 조인해도 값명은 모두 확인할 수 있는 구조

select * from ohdsi_cdm.vocabulary; 
select * from ohdsi_cdm.concept where concept_id = 44819232;
select * from ohdsi_cdm.concept where vocabulary_id = 'Vocabulary';

select     domain_id, vocabulary_id, concept_class_id, standard_concept, count(10) cnt from ohdsi_cdm.concept 
 group by  domain_id, vocabulary_id, concept_class_id, standard_concept  order by 1,2,3;

select * from concept_ancestor ca order by 1,2;

-- standaerd_concept 컬럼 : -- -> S는 데이터,  C는 Classify 용 컨
-- This flag determines where 
--   a Concept is a Standard Concept, i.e. is used in the data, 
--                a Classification Concept, or a non-standard Source Concept. 
--  The allowables values are 'S' (Standard Concept) and 'C' (Classification Concept), otherwise the content is NULL.

-- ------------------------------------------------
-- concept_ancestor
-- 코드의 상하위 계층구조 구성
-- 상하위가 없는 건은 상하 동일한 번호로 1건만 존재(하위가 있는 건도 동일 번호 하위가 존재....)
select * from concept_ancestor ca order by 1,2;

select ancestor_concept_id, c1.concept_name, descendant_concept_id, c2.concept_name
  from concept_ancestor ca
       inner join concept c1 on ca.ancestor_concept_id = c1.concept_id
       inner join concept c2 on ca.descendant_concept_id = c2.concept_id
 where ancestor_concept_id = 8515 -- Asian 
 order by descendant_concept_id;

select ancestor_concept_id, c1.concept_name, descendant_concept_id, c2.concept_name
  from concept_ancestor ca
       inner join concept c1 on ca.ancestor_concept_id = c1.concept_id
       inner join concept c2 on ca.descendant_concept_id = c2.concept_id
 where ancestor_concept_id = 38003585 -- Asian 
 order by descendant_concept_id;


select * from vocabulary v;
select * from concept c where concept_name like '%visit%';
select * from concept c where domain_id like '%visit%';
select * from concept c where vocabulary_id like '%visit%';
select * from visit_occurrence vo;

select * 


-- ------------------------------------------------
-- concept_synonym
-- vocabulary 별로 (SNOMED, RxNorm ... ) 구분하는 역할인가... 

select count(1) from concept_synonym cs ; -- 4898065
select * from concept_synonym cs;

select language_concept_id, count(1) cnt
  from concept_synonym cs
 group by language_concept_id
 order by cnt desc;
-- 4093769	2501091  
-- 4180186	2396974
select * from concept c where concept_id in (4093769,4180186); -- ?

select * from concept_synonym cs where concept_synonym_name = 'gender'; -- 12건
select cs.*, c1.*
  from concept_synonym cs 
       inner join concept c1 on cs.concept_id = c1.concept_id
 where concept_synonym_name = 'gender';

select ancestor_concept_id, c1.concept_name, descendant_concept_id, c2.concept_name
  from concept_ancestor ca
       inner join concept c1 on ca.ancestor_concept_id = c1.concept_id
       inner join concept c2 on ca.descendant_concept_id = c2.concept_id
 where ancestor_concept_id = 4135376 -- gender (s) 
 order by descendant_concept_id; -- 아... 그런데도 하위에 male, female 이 없다... 
 

select cs.*, c1.*
  from concept_synonym cs 
       inner join concept c1 on cs.concept_id = c1.concept_id
 where concept_synonym_name = 'male';

select ancestor_concept_id, c1.concept_name, descendant_concept_id, c2.concept_name
  from concept_ancestor ca
       inner join concept c1 on ca.ancestor_concept_id = c1.concept_id
       inner join concept c2 on ca.descendant_concept_id = c2.concept_id
 where descendant_concept_id = 8507 -- MALE (S)
 order by descendant_concept_id; -- 상위에도 없다... 상위 개념이 
 
select * from concept c where concept_class_id = 'ATC 1st'; -- 30건... 
-- 21601237	CARDIOVASCULAR SYSTEM
select ancestor_concept_id, c1.concept_name, descendant_concept_id, c2.concept_name
  from concept_ancestor ca
       inner join concept c1 on ca.ancestor_concept_id = c1.concept_id
       inner join concept c2 on ca.descendant_concept_id = c2.concept_id
 where ancestor_concept_id = 21601237 -- 흠... 1st 아래에는 자식 데이터가 많이 있군!!
 order by descendant_concept_id;



-- ------------------------------------
-- relationship  관계 자체를 정의해 놓은 테이
select count(1) from relationship; -- 388 건...
select * from relationship; 

-- ------------------------------------
-- concept_relationship  
-- 
select count(1) from concept_relationship; -- 18450688 건...
select * from concept_relationship; 

select * from concept_relationship where concept_id_2 = 8507; -- MALE 
select * from concept_relationship where concept_id_1 = 8507; -- MALE 
select * from concept c where concept_id = 44814666; -- 44814666	Male	Observation	PCORNet 뭐 그다지...
select c1.concept_name, c2.concept_name, cr.*
  from concept_relationship cr
       inner join concept c1 on cr.concept_id_1 = c1.concept_id
       inner join concept c2 on cr.concept_id_2 = c2.concept_id
 where concept_id_1 = 4135376; -- GENDER

-- ------------------------------------
-- source_to_concept_map
select count(1) from source_to_concept_map; -- 0 건...

-- ------------------------------------
-- drug_strength : ingredient 별로 drug 의 양, 투여방법을 다 정의해 놓음... 통계에는 좋으나 유연하진 못할 것 같은데....
select count(1) from drug_strength; -- 387222
select * from drug_strength;

select c1.concept_name, c2.concept_name, ds.*
  from drug_strength ds
       inner join concept c1 on ds.drug_concept_id = c1.concept_id
       inner join concept c2 on ds.ingredient_concept_id = c2.concept_id
;





select * from person;

-- ----------------------------
-- visit_occurrence
select * from visit_occurrence vo;

select count(1), count(distinct person_id) from visit_occurrence vo; -- 5579542	99210

select visit_concept_id, count(1) cnt from visit_occurrence vo group by visit_concept_id;
select * from concept c where concept_id in (9201,9202); -- 입원, 외래 

select visit_type_concept_id, count(1) cnt from visit_occurrence vo group by visit_type_concept_id;
select * from concept c where concept_id in (44818517);
select * from concept c where vocabulary_id = 'Visit Type'; -- 그리 안중요..

-- ----------------------------
-- observation 
select count(1) from observation o; -- 1876834
select * from observation;
select * from observation where person_id = 2 order by observation_date desc;
select c1.concept_name observation, c2.concept_name observation_type, c3.concept_name observation_source
      ,o.* 
  from observation o
       inner join concept c1 on o.observation_concept_id = c1.concept_id
       inner join concept c2 on o.observation_type_concept_id = c2.concept_id
       inner join concept c3 on o.observation_source_concept_id = c3.concept_id
where person_id = 2 order by observation_date desc;

-- ----------------------------
-- observation_period

select count(1) from observation_period o; -- 104891
select * from observation_period;
select period_type_concept_id, count(1) cnt from observation_period group by period_type_concept_id; -- 전부 44814722 
select * from concept c where concept_id in (44814722); -- period_type_concept_id = 44814722 : Period while enrolled in insurance (= 보험 가입 기간) 
select * from concept c where domain_id = 'Type Concept';
select * from concept c where concept_class_id = 'Obs Period Type';

-- ----------------------------
-- procedure_occurrence

select count(1) from procedure_occurrence; -- 13926771
select * from procedure_occurrence;
select period_type_concept_id, count(1) cnt from observation_period group by period_type_concept_id; -- 전부 44814722 
select * from concept c where concept_id in (44814722); -- period_type_concept_id = 44814722 : Period while enrolled in insurance (= 보험 가입 기간) 
select * from concept c where domain_id = 'Type Concept';
select * from concept c where concept_class_id = 'Obs Period Type';

select * from concept c where concept_id =  2001198;
select * from concept c where domain_id like '%procedure%' -- 303752건... 많다. 



select * from drug_cost vc;

select count(1) from person;
