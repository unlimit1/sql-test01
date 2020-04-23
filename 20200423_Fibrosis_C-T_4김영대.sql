select count(1) from patents-public-data.ebi_chembl.activities union all
select count(1) from patents-public-data.ebi_chembl.activities_25;

select * from patents-public-data.ebi_chembl.drug_indication_26 where efo_term like '%fibrosis%';

select * from patents-public-data.ebi_chembl.assays_26 limit 100;
select * from patents-public-data.ebi_chembl.activities_26 limit 100;

select mesh_heading, efo_id, efo_term, max_phase_for_ind, di.molregno 
  from patents-public-data.ebi_chembl.drug_indication_26 di
       inner join patents-public-data.ebi_chembl.activities_26 act on di.molregno = act.molregno
 where efo_term like '%fibrosis%';
 