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


-- ----------------------------
-- domain
select * from ohdsi_cdm53_synthea.domain; -- 45 rows
select * from ohdsi_cdm53_synthea.concept c order by concept_id;
select domain_id, count(1) concept_cnt from ohdsi_cdm53_synthea.concept c group by domain_id;
select domain_id, count(1) concept_cnt from ohdsi_cdm53_synthea.concept c where standard_concept is not null group by domain_id order by 2 desc;

-- concept table 의 domain_id 별 건수 확인 (full joi 꼼수 구현->불필요..)
SELECT d.domain_id, d.domain_name, c.domain_id c_domain_id, c.concept_cnt, 'ohdsi_cdm53_synthea' sch_nm
  from ohdsi_cdm53_synthea.domain d
       left join (select domain_id, count(1) concept_cnt from ohdsi_cdm53_synthea.concept c group by domain_id) c
                 on d.domain_id = c.domain_id
union all
SELECT d.domain_id, d.domain_name, c.domain_id c_domain_id, c.concept_cnt, 'ohdsi_cdm53_ohdsi' sch_nm
  from ohdsi_cdm53_ohdsi.domain d
       left join (select domain_id, count(1) concept_cnt from ohdsi_cdm53_ohdsi.concept c group by domain_id) c
                 on d.domain_id = c.domain_id
order by domain_id
;

select * from ohdsi_cdm53_synthea.concept c where concept_id in (42496858, 42488512, 4232697);
select * from ohdsi_cdm53_synthea.concept c where lower(concept_name) like '%persistent atrial fibrillation%';
/* concept_id	concept_name							domain_id	vocabulary_id	concept_class_id	standard_concept	concept_code	valid_start_date	valid_end_date	invalid_reason
4,232,697	Persistent atrial fibrillation				Condition	SNOMED			Clinical Finding	S					440059007	2009-01-31	2099-12-31	[NULL]
35,207,785	Persistent atrial fibrillation				Condition	ICD10CM			4-char billing code	[NULL]				I48.1	2007-01-01	2099-12-31	[NULL]
45,548,021	Persistent atrial fibrillation				Condition	ICD10			ICD10 code			[NULL]				I48.1	2013-01-01	2099-12-31	[NULL]
45,768,480	Longstanding persistent atrial fibrillation	Condition	SNOMED			Clinical Finding	S					706923002	2015-01-31	2099-12-31	[NULL]
 */

select * from ohdsi_cdm53_synthea.concept_relationship cr where concept_id_1 = 4232697;
-- Mapped from 되었다는 정보는 제공되나... 그이상의 정보가 없다...
select * from ohdsi_cdm53_synthea.concept c
 where concept_id in (select concept_id_2 from ohdsi_cdm53_synthea.concept_relationship where concept_id_1 = 4232697);

-- 지속적 심방세동 (4232697) 의 relationship 테이블 정보... 
select cr.relationship_id, c.*
  from ohdsi_cdm53_synthea.concept c
       inner join ohdsi_cdm53_synthea.concept_relationship cr 
                  on cr.concept_id_1 = 4232697 and c.concept_id = cr.concept_id_2

-- ohdsi book 의 자궁내막염을 겪었던 Lauren 의
select * from ohdsi_cdm53_synthea.person where person_id = 1; -- 1982/3/12 생 아님... 
select * from ohdsi_cdm53_synthea.person where year_of_birth = 1982 and month_of_birth = 3 and day_of_birth = 12; -- 없다. 



-- ---------------------------
-- observation_period 
select * from ohdsi_cdm53_synthea.concept c where concept_id = 44814725;
select * from ohdsi_cdm53_synthea.concept c where concept_class_id = 'Obs Period Type'; -- 총 6건 존재
select period_type_concept_id, count(1) cnt from ohdsi_cdm53_synthea.observation_period op group by period_type_concept_id;
-- 1126 건 모두 44814724 : 'Period covering healthcare encounters' ... 6개 type 중 일반적인 병원 방문에 해당하는 것은 모두 이것으로 보임


-- ---------------------------
-- visit_occurrence
select * from ohdsi_cdm53_synthea.visit_occurrence vo; -- 32,153

--   visit_concept_id
select visit_concept_id, count(1) cnt  
  from ohdsi_cdm53_synthea.visit_occurrence vo group by visit_concept_id;
select * from ohdsi_cdm53_synthea.concept c where concept_id in (9201,9202,9203);
--   9201	Inpatient Visit	  9202:Outpatient Visit   9203:Emergency Room Visit
select * from ohdsi_cdm53_synthea.concept c where concept_class_id = 'Visit';  -- visit 도메인에 모두 12건 존재, 버전에 따라 값이 추가된 듯.. 
--   vigit_type_concept_id 
select * from ohdsi_cdm53_synthea.concept c where concept_id = 44818517;
select * from ohdsi_cdm53_synthea.concept c where concept_class_id = 'Visit Type';

-- admitted from, discharge to (어디로부터 입원했는지, 어디로 퇴원하는지) 에 대한 데이터는 샘플에 없음..
select admitting_source_concept_id, admitting_source_value, discharge_to_concept_id, discharge_to_source_value
      ,count(1) cnt
  from ohdsi_cdm53_synthea.visit_occurrence vo 
 group by admitting_source_concept_id, admitting_source_value, discharge_to_concept_id, discharge_to_source_value;

--
select visit_occurrence_id, person_id, visit_start_date, preceding_visit_occurrence_id prec
  from ohdsi_cdm53_synthea.visit_occurrence vo 
 where preceding_visit_occurrence_id is not NULL
 order by visit_occurrence_id;


-- -----------------------------------------------
-- condition_occurrence

select * from ohdsi_cdm53_synthea.condition_occurrence co; -- 7,900

-- condition_concept_id 내용...
select co.condition_concept_id, count(1) cnt, c.concept_name, c.vocabulary_id, c.domain_id, c.concept_class_id 
  from ohdsi_cdm53_synthea.condition_occurrence co
       left join ohdsi_cdm53_synthea.concept c on co.condition_concept_id = c.concept_id
 group by co.condition_concept_id, c.concept_name, c.vocabulary_id, c.domain_id, c.concept_class_id
 order by cnt desc;
-- 바이러스성 부비동염, 일치 개념 없음, 급성 바이러스 인두염, 급성 기관지염, 정상 임신, 포도당 내성 손상, 고혈압 장애... 
-- 이건 우리나라 질병관리코드? 와 어떻게 연결될까... 

-- domain = 'Condition' 의 concept 살펴보기... 
select vocabulary_id, domain_id, concept_class_id, standard_concept, count(1) 
  from ohdsi_cdm53_synthea.concept c 
 where domain_id = 'Condition'
 group by vocabulary_id, domain_id, concept_class_id, standard_concept
; 
-- SNOMED, ICD10CM, ICD9CM, ICD10 의 voca 에서 정리되었음 
-- SNOMED 가 Condition domain 의 Standard 임

-- concept_class_id = 'Clinical Finding' -- 임상소견 
select vocabulary_id, domain_id, concept_class_id, standard_concept, count(1) 
  from ohdsi_cdm53_synthea.concept c 
 where concept_class_id = 'Clinical Finding' -- 임상소견
 group by vocabulary_id, domain_id, concept_class_id, standard_concept
; 

select * from ohdsi_cdm53_synthea.concept c where concept_name like '%sinusitis%';

select concept_class_id, standard_concept, count(1) cnt from ohdsi_cdm53_synthea.concept c 
 where vocabulary_id = 'SNOMED' 
 group by concept_class_id, standard_concept order by cnt desc;
 
select count(1) from ohdsi_cdm53_synthea.concept c where vocabulary_id != 'SNOMED' and standard_concept = 'S'; -- 2052902

select vocabulary_id, domain_id, concept_class_id, count(1) cnt from ohdsi_cdm53_synthea.concept c 
 where vocabulary_id != 'SNOMED' and standard_concept = 'S'
 group by vocabulary_id, domain_id, concept_class_id order by vocabulary_id, cnt desc;


-- 도메인별 CDM표준(standard_concept = 'S') voca 구성 분포 파악
-- Condition(진단/증상):SNOMED, Device(장비):SNOMED, Drug(약):RxNorm(Extenstion), Measurement(측정/검사?):LONIC,SNOMED
-- ,Observarion(관찰?):SNOMED, Procedure(수술/처치):ICD10PCS,SNOMED, Specimen(검채?):SNOMED...
select domain_id, vocabulary_id, concept_class_id, count(1) cnt from ohdsi_cdm53_synthea.concept c 
 where standard_concept = 'S'
 group by domain_id, vocabulary_id, concept_class_id order by domain_id, cnt desc;
 
select condition_type_concept_id, count(1) cnt from ohdsi_cdm53_synthea.condition_occurrence co
 group by condition_type_concept_id; -- 전부 32020 (= EHR encounter diagnosis 전자건강기록에의 분석 내... )
 

 
-- ------------------------------------------------------------
-- drug_exposure
select * from ohdsi_cdm53_synthea.drug_exposure; -- 29,581건 

-- drug_concept_id ... 
select drug_concept_id, count(1) cnt, c.concept_name drug_name, c.*
  from ohdsi_cdm53_synthea.drug_exposure de
       left join ohdsi_cdm53_synthea.concept c on de.drug_concept_id = c.concept_id
 group by drug_concept_id order by cnt desc;

select count(1) from ohdsi_cdm53_synthea.concept c where domain_id = 'drug' and standard_concept = 'S'; -- 'S'만 1,727,439건, drug전체 3,486,525

select * from ohdsi_cdm53_synthea.concept c where concept_id in (40213154, 1539464, 40213227)...;

-- drug_type_concept_id ... (type name : 외래 사무실 분배, 처방전... )
select drug_type_concept_id, count(1) cnt, c.concept_name drug_type_concept_name, c.*
  from ohdsi_cdm53_synthea.drug_exposure de
       left join ohdsi_cdm53_synthea.concept c on de.drug_type_concept_id = c.concept_id
 group by drug_type_concept_id order by cnt desc;

select * from ohdsi_cdm53_synthea.concept c where concept_class_id = 'Drug Type'; -- OMOP generated 16개 type

-- stop_reason, refills, quantity, sig  synthea 샘플 데이터에는 모두 null or 0 
select stop_reason, refills, quantity, sig, count(1) cnt from ohdsi_cdm53_synthea.drug_exposure de
 group by stop_reason, refills, quantity, sig order by cnt desc;

-- route_concept_id ... 약물 투여 경로... 경구,패치.... 샘플데이터에는 모두 0
select route_concept_id, count(1) cnt, c.concept_name route_concept_name, c.*
  from ohdsi_cdm53_synthea.drug_exposure de
       left join ohdsi_cdm53_synthea.concept c on de.route_concept_id = c.concept_id
 group by route_concept_id order by cnt desc;
 
select * from ohdsi_cdm53_synthea.concept c where concept_id = 4132161;
select * from ohdsi_cdm53_synthea.concept c where domain_id = 'Route' and standard_concept = 'S'; -- 183건... concept_class_id 는 모두 Qualifier Value
-- 동정맥 이식, 관절 내, 흡입, 귀의, 질의, 경구, 위 절제 .... 
select * from ohdsi_cdm53_synthea.concept c where concept_class_id = 'Qualifier Value'; -- 많아... 도메인이 route, observation, Meas Value 등... 많음.

select * from ohdsi_cdm53_synthea.concept c where concept_id = 1127433;

select * from ohdsi_cdm53_synthea.drug_exposure de where person_id = 548; -- 62건 



-- ------------------------------------------------------------
-- precedure_occurrence

select * from ohdsi_cdm53_synthea.procedure_occurrence po; -- 17333
-- procedure_occurrence_id	person_id	procedure_concept_id	procedure_date	procedure_datetime	procedure_type_concept_id	modifier_concept_id	quantity	provider_id	visit_occurrence_id	visit_detail_id	procedure_source_value	procedure_source_concept_id	modifier_source_value

-- procedure_concept_id  -- synthea 샘플에만 91건의 조치/시술이 있음 
select procedure_concept_id, count(1) cnt, c.concept_name precedure_concept_name, c.*
  from ohdsi_cdm53_synthea.procedure_occurrence de
       left join ohdsi_cdm53_synthea.concept c on de.procedure_concept_id = c.concept_id
 group by procedure_concept_id order by cnt desc;

select count(1) from ohdsi_cdm53_synthea.concept c where domain_id = 'procedure' and standard_concept = 'S'; -- 'S'만 254,644건, proc전체 291,535

 
-- procedure_type_concept_id  -- synthea 샘플에는 17,333건 모두 "EHR order list entry"
select procedure_type_concept_id, count(1) cnt, c.concept_name precedure_type_concept_name, c.*
  from ohdsi_cdm53_synthea.procedure_occurrence po
       left join ohdsi_cdm53_synthea.concept c on po.procedure_type_concept_id = c.concept_id
 group by procedure_type_concept_id order by cnt desc;

select * from ohdsi_cdm53_synthea.concept c where concept_class_id = 'Procedure Type' and standard_concept = 'S'; -- 'S'만 OMOP generated 97건

-- modifier_concept_id  -- synthea 샘플에는 17,333건 모두 No matching concept
select modifier_concept_id, count(1) cnt, c.concept_name modifier_concept_name, c.*
  from ohdsi_cdm53_synthea.procedure_occurrence po
       left join ohdsi_cdm53_synthea.concept c on po.modifier_concept_id = c.concept_id
 group by modifier_concept_id order by cnt desc;

select * from ohdsi_cdm53_synthea.concept c where concept_id = 42739579;
select domain_id, vocabulary_id, concept_class_id, count(1) from ohdsi_cdm53_synthea.concept c 
 where concept_class_id like '%modi%' and standard_concept = 'S'
 group by domain_id, vocabulary_id, concept_class_id order by 1,2,3;
/* domain_id	vocabulary_id	concept_class_id	count(1)
Condition	HCPCS	HCPCS Modifier	1
Device	HCPCS	HCPCS Modifier	42
Measurement	HCPCS	HCPCS Modifier	8
Observation	HCPCS	HCPCS Modifier	310
Procedure	CPT4	CPT4 Modifier	382
Procedure	HCPCS	HCPCS Modifier	2
 */ -- 도메인별로 concept 이 존재하나 정작 modifier_concept_id 컬럼이 있는 테이블은 procedure_occurrence 



-- person_id = 548
select vo.visit_occurrence_id, dense_rank() over (partition by 1 order by vo.visit_start_datetime) visit_odr
      ,c1.concept_name visit_name, visit_start_datetime, visit_end_datetime -- , preceding_visit_occurrence_id bf_visit
      ,co.condition_occurrence_id condi_occur, c2.concept_name condition_name, co.condition_start_datetime, co.condition_end_datetime
      ,de.drug_exposure_id drug_expo, c3.concept_name drug_name, de.drug_exposure_start_datetime, de.drug_exposure_end_date, de.days_supply, de.drug_source_value
      ,po.procedure_occurrence_id proc_occur, c4.concept_name procedure_name, po.procedure_datetime
  from ohdsi_cdm53_synthea.visit_occurrence vo 
                 left join ohdsi_cdm53_synthea.concept c1 on vo.visit_concept_id = c1.concept_id
       left join ohdsi_cdm53_synthea.condition_occurrence co on vo.visit_occurrence_id = co.visit_occurrence_id
                 left join ohdsi_cdm53_synthea.concept c2 on co.condition_concept_id = c2.concept_id
       left join ohdsi_cdm53_synthea.drug_exposure de on vo.visit_occurrence_id = de.visit_occurrence_id
                 left join ohdsi_cdm53_synthea.concept c3 on de.drug_concept_id = c3.concept_id
       left join ohdsi_cdm53_synthea.procedure_occurrence po on vo.visit_occurrence_id = po.procedure_occurrence_id
                 left join ohdsi_cdm53_synthea.concept c4 on po.procedure_concept_id = c4.concept_id
 where vo.person_id = 548
 order by visit_start_datetime, visit_occurrence_id, co.condition_occurrence_id, de.drug_exposure_id;



-- visit_detail 은 synthea 샘플 건수 0 
select * from ohdsi_cdm53_synthea.observation_period op where person_id = 548; -- visit 의 start 및 end 와 일치함... (필요성은 무엇?) 


select * from ohdsi_cdm53_synthea.concept c where concept_id = 42056540;
select * from ohdsi_cdm53_synthea.concept c where concept_id in (42082209,42061277,42075763,42065112,42081868,42046255,42060141,42063180);
select * from ohdsi_cdm53_synthea.concept c where concept_id = 254;
select * from ohdsi_cdm53_synthea.concept c where concept_id = 437611;  -- KCD7 : O00 자궁외임신(Ectopic pregnancy) concept_id : 42495083

select * from ohdsi_cdm53_synthea.concept c where concept_id = 200763;  -- Chronic hepatitis 만성간염.... KCD7 에는  K73  달리 분류되지 않은 만성 간염 42489881

select relationship_id, count(1) cnt from ohdsi_cdm53_synthea.concept_relationship cr group by relationship_id order by cnt desc ;

select * from ohdsi_cdm53_synthea.concept c where concept_id = 35707864;

select * from ohdsi_cdm53_synthea.relationship r;
select * from ohdsi_cdm53_synthea.concept_class cc;
select * from ohdsi_cdm53_synthea.concept c where concept_id = 44819279;
select * from ohdsi_cdm53_synthea.relationship r;
select * from ohdsi_cdm53_synthea.concept_ancestor ca;