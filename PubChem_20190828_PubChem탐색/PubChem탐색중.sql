-- @ Athena

select count(1) from pubchem_ana.pubchem_data where tag_no = 1; -- 12,355,151 ?? 106만개여야 하는데....
select count(1) from pubchem_ana.pubchem_data where field_no = 1;  --241,113,866 ... 2.4억개... 이건 맞는듯..
select count(1) from pubchem_ana.pubchem_data_extras ex where ex.geneid = 3757;  -- 2500 개의 assay 가 있다
select * from pubchem_ana.pubchem_data;
select count(1) -- SQL Error [100071] [HY000]: [Simba][AthenaJDBC](100071) An error has been thrown from the AWS Athena client. Query exhausted resources at this scale factor
  from pubchem_ana.pubchem_data_extras ex
       inner join pubchem_ana.pubchem_data da on ex.aid = da.aid
 where ex.geneid = 3757;

select count(1) -- 1,503,629
  from pubchem_ana.pubchem_data_extras ex
       inner join pubchem_ana.pubchem_data da on ex.aid = da.aid and da.field_no = 1
 where ex.geneid = 3757;
 
select ex.aid, count(1) cnt  -- cnt max:343,909 sum:1,503,629
  from pubchem_ana.pubchem_data_extras ex 
       inner join pubchem_ana.pubchem_data da on ex.aid = da.aid and da.field_no = 1
 where ex.geneid = 3757
 group by ex.aid
 order by cnt desc
;
/* aid cnt
720551	343909  -- activity 개수가 34만건 ???
720553	342311
1511	305679
1117357	115372
651811	64752
1117281	64752
1159506	59220*/

select count(1) 
  from pubchem_ana.pubchem_data_extras ex
       inner join pubchem_ana.pubchem_data da on ex.aid = da.aid -- and da.tag_no <= 3000
 where ex.geneid = 3757
   and da.tag_no <= 100000 -- 19,288,758건 -- 이건 조회되네... 
;

select *  from pubchem_ana.pubchem_description where aid = 720551;

...The recently identified KCNH2 3.1 potassium channel, a brain selective isoform of the KCNH2 (hERG1) potassium channel, 
has been shown to be increased in the brains of patients with schizophrenia, a genetic risk factor for the emergence of schizophrenia, 
and to affect neuronal cell activity and brain physiology.  
Many antipsychotic drugs that inhibit the neurotransmitter dopamine also bind to hERG1 channel which might help explain their antipsychotic activity but also produces cardiac side effects.  
The discovery of the novel KCNH2 3.1 isoform offers a potential new target for the development of antipsychotic drugs 
without cardiac side effects. This proposal will use a high throughput thallium flux assay developed 
or KCNH2 to screen compounds that modulate the  activity of KCNH2 3.1. 
The wild type KCNH2 channel will also be screened in parallel to help define the selective modulators of this KCNH2 3.1 potassium channel. 
The resulting compounds will be validated in electrophysiology experiments. 
The availability of animal models will allow future testing in vivo for effects on memory and other aspects of animal physiology linked with psychosis....NIH Chemical Genomics Center [NCGC].
NIH Molecular Libraries Probe Centers Network [MLPCN]...MLPCN Grant: MH096539.Assay Submitter (PI): James Barrow, Johns Hopkins University, Lieber Institute for Brain Development 

.Phenotype
.Potency
.Efficacy
.Analysis Comment
.Activity_Score
.Curve_Description
.Fit_LogAC50
.Fit_HillSlope
.Fit_R2
.Fit_InfiniteActivity
.Fit_ZeroActivity
.Fit_CurveClass
.Excluded_Points
.Max_Response
.Activity at 0.369 uM
.Activity at 1.840 uM
.Compound QC

select count(1) from pubchem_ana.pubchem_data where aid = 720551;  --8,253,816건
select * from pubchem_ana.pubchem_data where aid = 720551 order by 1,2,4;

select * from pubchem_ana.pubchem_compound limit 10;

select count(1) cnt
      ,count(iupac_inchikey) inchi_cnt, count(distinct iupac_inchi) inchi_dis, count(distinct iupac_inchikey) inchikey_dis
      ,count(distinct openeye_can_smiles) can, count(distinct openeye_iso_smiles) iso 
  from pubchem_ana.pubchem_compound;
/*cnt	inchi_cnt	inchi_dis	inchikey_dis	can	iso  
95,753,695	95,753,695	95,487,383	95,487,379	81,202,114	95,714,295   ... inchi 도 아주 신뢰할 만한 정보는 아닌듯 하네.. */

