select count(1) cnt from ana_string.txt_protein_info;  -- 24584629 일치 OK!!
select * from ana_string.txt_protein_info where protein_external_id like '9606.%'; -- 19566 row(s) fetched - 10.700s

select count(1) cnt from ana_string.txt_protein_link;  -- 6183296213   1 row(s) fetched - 19.772s
select * from ana_string.txt_protein_link;

select regexp_extract(l.protein1,'^[0-9]+') tax_id, i1.preferred_name prtein1_name, i2.preferred_name protein2_name, combined_score
  from ana_string.txt_protein_link l
       inner join ana_string.txt_protein_info i1 on l.protein1 = i1.protein_external_id
       inner join ana_string.txt_protein_info i2 on l.protein2 = i2.protein_external_id
order by 1,2,3,4
;
-- Query exhausted resources at this scale factor
-- This query ran against the "ana_string" database, unless qualified by the query. Please post the error message on our forum or contact customer support with Query Id: c9339187-ab1c-419d-a862-e662b0b22b90.

select regexp_extract(l.protein1,'^[0-9]+') tax_id, count(1) cnt
  from ana_string.txt_protein_link l 
 group by regexp_extract(l.protein1,'^[0-9]+')
 order by 1
; -- 5090 row(s) fetched - 1m 3s (+32ms)

select regexp_extract(l.protein1,'^[0-9]+') tax_id, i1.preferred_name prtein1_name, i2.preferred_name protein2_name, combined_score
  from ana_string.txt_protein_link l
       inner join ana_string.txt_protein_info i1 on l.protein1 = i1.protein_external_id
       inner join ana_string.txt_protein_info i2 on l.protein2 = i2.protein_external_id
 where regexp_extract(l.protein1,'^[0-9]+\.') = '9606.'
 order by 2,3,4
 ;

create table ana_string.protein_link_psj_9606  -- 실패... 생성파일 S3 결과 포맷이 잘 안나옴... 
with (format = 'TEXTFILE', external_location = 's3://use-skcc-dat-p-hcdp/ana/string/txt/protein_link_psj/9606.txt') 
as 
select regexp_extract(l.protein1,'^[0-9]+') tax_id, i1.preferred_name prtein1_name, i2.preferred_name protein2_name, combined_score
  from ana_string.txt_protein_link l
       inner join ana_string.txt_protein_info i1 on l.protein1 = i1.protein_external_id
       inner join ana_string.txt_protein_info i2 on l.protein2 = i2.protein_external_id
 where regexp_extract(l.protein1,'^[0-9]+\.') = '9606.'
 order by 2,3,4
 ;

select regexp_extract(l.protein1,'^[0-9]+') tax_id, i1.preferred_name prtein1_name, i2.preferred_name protein2_name, combined_score
  from ana_string.txt_protein_link l
       inner join ana_string.txt_protein_info i1 on l.protein1 = i1.protein_external_id
       inner join ana_string.txt_protein_info i2 on l.protein2 = i2.protein_external_id
 where l.protein1 like '1%'
 order by 1,2,3,4
;

select regexp_extract(l.protein1,'^[0-9]+') tax_id, i1.preferred_name prtein1_name, i2.preferred_name protein2_name, combined_score
  from ana_string.txt_protein_link l
       inner join ana_string.txt_protein_info i1 on l.protein1 = i1.protein_external_id
       inner join ana_string.txt_protein_info i2 on l.protein2 = i2.protein_external_id
 where regexp_extract(l.protein1,'^[0-9]+\.') in ('9606.','10116.','10090.')
 order by 1,2,3,4
;

select count(12) -- regexp_extract(l.protein1,'^[0-9]+') tax_id, i1.preferred_name prtein1_name, i2.preferred_name protein2_name, combined_score
  from ana_string.txt_protein_link l
       inner join ana_string.txt_protein_info i1 on l.protein1 = i1.protein_external_id
       inner join ana_string.txt_protein_info i2 on l.protein2 = i2.protein_external_id
 where regexp_extract(l.protein1,'^[0-9]+\.') in ('9606.','10116.','10090.')
; 
 
